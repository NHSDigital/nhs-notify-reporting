<powershell>

# Create scripts directory if it doesn't exist
if (!(Test-Path -Path "C:\scripts")) {
    New-Item -ItemType Directory -Path "C:\scripts"
}

# Create the install_powerbi_gateway.ps1 script
$installPowerBiGatewayScript = @"
# Set execution policy to bypass
Set-ExecutionPolicy Bypass -Scope Process -Force

# Enable TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# Download and install Chocolatey (if not already installed)
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Install PowerBI On-Premises Gatewat via Choco
choco install -y powerbigateway --version=3000.230.14 --checksum=7F46E578E1D07B5DC66D1FB3D245E069E00D66CA8A571454A50871925C011CC0

# Optional: Configuration of the gateway (requires gateway recovery key and registration details)
# Uncomment and fill in the necessary details if you want to configure the gateway after installation

# `$email = "your-email@example.com"
# `$password = "your-secure-password"
# `$gatewayName = "your-gateway-name"
# `$recoveryKey = "your-recovery-key"
# `$securePassword = ConvertTo-SecureString `$password -AsPlainText -Force
# `$credentials = New-Object System.Management.Automation.PSCredential (`$email, `$securePassword)

# Register the gateway
# & "C:\Program Files\On-premises data gateway\EnterpriseGatewayConfigurator.exe" /configuregateway `$gatewayName `$credentials `$recoveryKey

Write-Output "Power BI on-premises data gateway installation completed."
"@
Set-Content -Path "C:\scripts\install_powerbi_gateway.ps1" -Value $installPowerBiGatewayScript

# Execute the script
powershell.exe -ExecutionPolicy Bypass -File "C:\scripts\install_powerbi_gateway.ps1"
</powershell>
