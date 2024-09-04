# NHS Notify Reporting

[![CI/CD Pull Request](https://github.com/NHSDigital/nhs-notify-reporting/actions/workflows/cicd-1-pull-request.yaml/badge.svg)](https://github.com/NHSDigital/nhs-notify-reporting/actions/workflows/cicd-1-pull-request.yaml)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=NHSDigital_nhs-notify-reporting&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=NHSDigital_nhs-notify-reporting)

## Introduction

This repository contains code for the reporting domain of the NHS Notify system.

The reporting domain provides an isolated environment for staging data used for reporting purposes, such as exposure of data to Power BI.

This allows appropriate views of data to be safely exposed without sharing the full contents of the underlying transactional database.

This domain does not contain any application code. The reporting domain is executed exclusively through AWS services. It incorporates the following technologies:

- [HashiCorp Terraform](https://developer.hashicorp.com/terraform)
- [AWS Step Functions](https://docs.aws.amazon.com/step-functions/latest/dg/welcome.html)
- [AWS Glue](https://docs.aws.amazon.com/glue/latest/dg/what-is-glue.html)
- [AWS Athena](https://docs.aws.amazon.com/athena/latest/ug/what-is.html)
- [AWS S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html)
- [AWS Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html)
- [Apache Iceberg](https://iceberg.apache.org/)
- [Microsoft Power BI](https://learn.microsoft.com/en-us/power-bi/)

## Table of Contents

- [Introduction](#introduction)
- [Table of Contents](#table-of-contents)
- [Setup](#setup)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
  - [Athena Workgroups](#athena-workgroups)
  - [How Do I?](#how-do-i)
  - [Workarounds / Limitations](#workarounds--limitations)
- [Testing](#testing)
- [Design](#design)
  - [Architecture Overview](#architecture-overview)
  - [Staging Table Design](#staging-table-design)
  - [Ingestion Query Design](#ingestion-query-design)
  - [Handling PID](#handling-pid)
  - [Permissions](#permissions)
- [Contacts](#contacts)
- [Licence](#licence)

## Setup

Clone the repository

```shell
git clone https://github.com/NHSDigital/nhs-notify-reporting.git
cd nhs-notify-reporting
```

## Prerequisites

In order to facilitate cross-account export of data, the reporting domain requires IAM permissions for read-only access to the Glue Catalogue and underlying S3 storage in the NHS Notify core account.

## Usage

After successful deployment, the following will be available:

- Staging tables for each data aggregation/projection.
- Athena saved queries to incrementally populate the staging tables from the core account.
- A step function to periodically execute the saved ingestion queries.

The step function and saved queries can be executed manually as required. They are idempotent, so can be executed outside of the scheduled execution without harm.

Access to the core NHS Notify account is read-only. Any side-effects of changes are restricted solely to the staging tables within the reporting environment.

More information on the individual staging tables and associated ingestion queries is available [here](/infrastructure/terraform/components/reporting/scripts/sql/README.md)

### Athena Workgroups

The following Athena workgroups are available:

- `setup` for DDL execution and initial data migration.
- `ingestion` for execution of the ingestion queries used to populate staging tables.
- `user` for execution of queries that read from staging tables, including external consumers like Power BI.

Ad-hoc queries should be executed using the `user` workgroup.

### Workarounds / Limitations

Because of a [limitation in the Terraform provider](https://github.com/hashicorp/terraform-provider-aws/issues/36531) we can't currently manage iceberg tables as a native Terraform aws_glue_catalog_table resource.

As a workaround, we manage reporting tables via DDL queries executed in Athena and wrapped in Terraform null_resources for state management. See also the [shell scripts](/infrastructure/terraform/components/reporting/scripts/) invoked by the null_resources.

### How do I?

#### How do I define a new projection/aggregation?

- Add a new file containing a terraform null_resource that wraps the [create_table](/infrastructure/terraform/components/reporting/scripts/create_table.sh) shell script
- Add a new file containing a terraform athena_named_query used for data ingestion
- Specify the DDL for the new table definition [here](/infrastructure/terraform/components/reporting/scripts/sql/tables/)
- Specify the SQL to define the ingestion query [here](/infrastructure/terraform/components/reporting/scripts/sql/queries/)
- (Optionally) specify the data migration query [here](/infrastructure/terraform/components/reporting/scripts/sql/migration/)
- Add the named query to the step function [here](/infrastructure/terraform/components/reporting/sfn_state_machine_athena.tf)

The filename should be the same in all 3 sql folders.

If your target table contains hashed NHS numbers add the step function's `hash_query_ids` array, otherwise add it to the `query_ids` array.

#### How do I add a new column to a projection/aggregation retrospectively?

Columns can be added retrospectiely by adding a terraform null_resource that wraps the [add_column](/infrastructure/terraform/components/reporting/scripts/add_column.sh) shell script.

By convention, the column null_resources are defined in the same file as the associate table null_resource.

The column null_resource should have a dependency on the underlying table null_resource so that they are created in the correct sequence.

New columns should also be added to the underlying [table definition](/infrastructure/terraform/components/reporting/scripts/sql/tables/) so they are created as part of the initial table creation in new environments.

## Testing

As there is no application code suited to unit testing, testing of ingestion queries is currently performed manually.

## Design

### Architecture Overview

![Reporting Architecture Overview](/docs/diagrams/reporting.png)

### Staging Table Design

Staging tables are AWS Glue tables created in the [Apache Iceberg](https://iceberg.apache.org/) format, since these support mutation of existing staging rows via the [MERGE INTO](https://docs.aws.amazon.com/athena/latest/ug/merge-into-statement.html) operation. This means that information in the staging tables can be incrementally updated over time.

The initial staging tables are partitioned by creation month and completion month in order to efficiently support date-range queries.

See also this [readme](/infrastructure/terraform/components/reporting/scripts/sql/README.md) for the individual tables and ingestion queries.

**Note: Partitions in Iceberg tables are not visible via the AWS Glue Console, but can be seen instead using a "SHOW CREATE TABLE" query in Athena (and verified by inspecting the underlying S3 storage**)

### Ingestion Query Design

The underlying transaction_history table is a Glue representation of the change capture log from DynamoDB. It has a number of characteristics that make it more difficult to query than a "traditional" RDBMS table:

- It contains a mixture of different object types due to the single table design used in DynamoDB.
- It has a dynamically evolving schema, with new fields appearing over time as the NHS Notify application changes.
- It contains multiple records for the same object, with one record for each change.
- It has no guarantee of ordering, so record changes may be captured out-of-sequence.
- It is subject to data retention policies. Older records will be deleted from the table automatically/without notice.

Ingestion queries must be specifically designed to take account of these characteristics in order to produce a consistent output for reporting. In addition:

- Ingestion queries must be idempotent
- Ingestion queries must operate on a moving time window (typically pulling transactional data from the last month into the staging tables)
- Ingestion queries must be one-way only (data should not be removed or unwound), specifically:
  - Ingestion queries should not change the contents of the staging table when data is expired from the underlying transaction_history table
  - Ingestion queries should not change the contents of the staging table when records leave the incremental ingestion window
- Ingestion queries should perform an upsert operation via the [MERGE INTO](https://docs.aws.amazon.com/athena/latest/ug/merge-into-statement.html) SQL statement
- Ingestion queries should safely handle the introduction of new fields over time (e.g. via the [COALESCE](https://trino.io/docs/current/functions/conditional.html#coalesce) function)
- Ingestion queries should yield the same result irrespective of the order of records in the source data
- Ingestion queries should safely handle a partial view of updates to a record (i.e. where some updates are within the ingestion window and others are outside)
- Ingestion queries should safely handle mutable data, returning the content that corresponds to the latest record
  - Data that is present in some source record versions but NULL in others
  - Data that changes between record versions

See also this [readme](/infrastructure/terraform/components/reporting/scripts/sql/README.md) for the individual tables and ingestion queries.

### Handling PID

Staging tables exposed to Power BI should not contain any PID.

Pseudonymisation of PID is approved via the use of a SHA256 hash together with a secret environment key held in AWS Parameter Store.

The step function will inject the environment key as the execution parameter to any SQL query that is defined in the `hash_query_ids` collection in the [Step Function Terraform](./infrastructure/terraform/components/reporting/sfn_state_machine_athena.tf).

### Permissions

External access (including PowerBI) should be restricted to read-only access of the staging tables only. No external access should be provided to the underlying transaction_history table.

## Contacts

Email the NHS Notify team at <england.nhsnotify@nhs.net>

## Licence

See [LICENCE.md](./LICENCE.md)

Any HTML or Markdown documentation is [© Crown Copyright](https://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/uk-government-licensing-framework/crown-copyright/) and available under the terms of the [Open Government Licence v3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).
