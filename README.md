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
- [Testing](#testing)
- [Design](#design)
  - [Diagrams](#diagrams)
  - [Staging Table Design](#staging-table-design)
  - [Ingestion Query Design](#ingestion-query-design)
  - [Handling PID](#handling-pid)
- [Contacts](#contacts)
- [Licence](#licence)

## Setup

Clone the repository

```shell
git clone https://github.com/NHSDigital/nhs-notify-reporting.git
cd nhs-notify-reporting
```

## Prerequisites

In order to facilitate cross-account export of data, the reporting domain requires IAM permissions for the Glue Catalogue and underlying S3 storage to be setup in the NHS Notify core account.

## Usage

After successful deployment, the following will be available:

- Staging tables for each data view/projection.
- Athena saved queries to incrementally populate the staging tables from the core account.
- A step function to periodically execute the saved ingestion queries.

The step function and saved queries can be executed manually as required. They are idempotent, so can be executed outside of the scheduled execution without harm.

Access to the core NHS Notify account is read-only. Any side-effects of changes are restricted solely to the staging tables within the reporting environment.

## Testing

As there is no application code, testing of ingestion queries is currently performed manually.

## Design

### Diagrams

*TODO.*

### Staging Table Design

Staging tables are AWS Glue tables created in the [Apache Iceberg](https://iceberg.apache.org/) format, since these support mutation of existing staging rows via the [MERGE INTO](https://docs.aws.amazon.com/athena/latest/ug/merge-into-statement.html) operation. This means that information in the staging tables can be incrementally updated over time.

**Note: Partitions in Iceberg tables are not visible via the AWS Glue Console, but can be seen instead using a "SHOW CREATE TABLE" query in Athena (and verified by inspecting the underlying S3 storage**)

### Ingestion Query Design

The underlying transaction_history table is a Glue representation of the change capture log from DynamoDB. It has a number of characteristics that make it more difficult to query than a "traditional" RDBMS table:

- It contains a mixture of different object types due to the single table design used in DynamoDB.
- It has dynamically evolving schema, with new fields appearing over time as the NHS Notify application changes.
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

### Handling PID

Staging tables exposed to Power BI should not contain any PID.

Pseudonymisation of PID is approved via the use of a SHA256 hash together with a secret environment key held in AWS Parameter Store.

The step function will inject the environment key as the execution parameter to any SQL query that is defined in the `hash_query_ids` collection in the [Step Function Terraform](./infrastructure/terraform/components/reporting/sfn_state_machine_athena.tf).

## Contacts

Email the NHS Notify team at <england.nhsnotify@nhs.net>

## Licence

See [LICENCE.md](./LICENCE.md)

Any HTML or Markdown documentation is [© Crown Copyright](https://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/uk-government-licensing-framework/crown-copyright/) and available under the terms of the [Open Government Licence v3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).
