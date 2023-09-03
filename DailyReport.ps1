# Daily Drills Report
$REPORT_NAME = "Daily Drilling Report"

# Determine the modules path
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Import the necessary modules
Import-Module (Join-Path $scriptPath './modules/ConnectionFunctions.psm1')
Import-Module (Join-Path $scriptPath './modules/TableFunctions.psm1')
Import-Module (Join-Path $scriptPath './modules/EmailFunctions.psm1')
Import-Module (Join-Path $scriptPath './modules/TwilioFunctions.psm1')

#Set The file location for the batch paths
$SMSListPath = (Join-Path $scriptPath './DailyReport_SMSList.txt')
$EmailListPath = (Join-Path $scriptPath './DailyReport_EmailList.txt')

function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )

    $logDirectory = "./logs"
    if (-not (Test-Path $logDirectory)) {
        New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logFileName = (Get-Date -Format "yyyy-MM-dd") + ".log"
    $logFilePath = Join-Path $logDirectory $logFileName

    Add-Content -Path $logFilePath -Value "$timestamp - $Message" | Out-Null
}

# Function to display the usage message
function DisplayUsage {
    Write-Output @"
USAGE:
.\DailyReport.ps1 [-S <PhoneNumber>] [-E <EmailAddress>] [-BS] [-BE]

PARAMETERS:
-S: Use this switch followed by an Australian mobile phone number to send the report via SMS.
-E: Use this switch followed by an email address to send the report via Email.
-BS: Use this switch to send the report to all Australian mobile phone numbers listed in SMSList.txt.
-BE: Use this switch to send the report to all email addresses listed in EmailList.txt.

EXAMPLES:
.\DailyReport.ps1 -S '+61412345678'                                 # Sends the report via SMS.
.\DailyReport.ps1 -E 'example@email.com'                            # Sends the report via Email.
.\DailyReport.ps1 -S '+61412345678' -E 'example@email.com'          # Sends the report via both SMS and Email.
.\DailyReport.ps1 -BS                                               # Sends the report to all numbers in SMSList.txt.
.\DailyReport.ps1 -BE                                               # Sends the report to all emails in EmailList.txt.
.\DailyReport.ps1 -BS -BE                                           # Sends the report to all numbers and emails listed.

NOTES:
To execute the report, at least one parameter (-S, -E, -BS, or -BE) must be provided.
"@
    exit
}

$Email = $null
$SMS = $null
$BatchEmail = $false
$BatchSMS = $false

$i = 0
while ($i -lt $args.Count) {
    switch ($args[$i]) {
        "-E" {
            $Email = $args[$i+1]
            $i += 2
        }
        "-S" {
            $SMS = $args[$i+1]
            $i += 2
        }
        "-BS" {
            $BatchSMS = $true
            $i++
        }
        "-BE" {
            $BatchEmail = $true
            $i++
        }
        default {
            DisplayUsage
        }
    }
}

# If no valid parameters are provided
if (-not $Email -and -not $SMS -and -not $BatchEmail -and -not $BatchSMS) {
    DisplayUsage
}

# Generate the report

# Connect to default SQL Server
$connectionSuccess = Test-SqlServerConnection -serverName $DEFAULT_SERVER -databaseName $DEFAULT_DATABASE
if (-not $connectionSuccess) { exit }

# Call and output the results
$holesCount = Get-HolesCount
$totalDepth = Get-TotalDepthDrilled

# Compose the message
$reportMessage = @"
Drilling Report:
Total Holes: $holesCount
Total Meters Drilled: $totalDepth
"@

# Check if Email report is required
if ($Email) {
    Send-EmailReport -recipient $Email -MessageBody $reportMessage -EmailSubject $REPORT_NAME
    Write-Log "Send-EmailReport was called with recipient: $Email, Subject: $REPORT_NAME."
}

# Check if SMS report is required
if ($SMS) {
    Send-SMSMessage -ToNumber $SMS -message $reportMessage
    Write-Log "Send-SMSMessage was called with Phone Number: $SMS."
}

# Send batch emails if required
if ($BatchEmail -and (Test-Path $EmailListPath)) {
    $emails = Get-Content $EmailListPath
    foreach ($email in $emails) {
        Send-EmailReport -recipient $email -MessageBody $reportMessage -EmailSubject $REPORT_NAME
        Write-Log "Batch Send-EmailReport was called with recipient: $email, Subject: $REPORT_NAME."
    }
}

# Send batch SMS if required
if ($BatchSMS -and (Test-Path $SMSListPath)) {
    $phoneNumbers = Get-Content $SMSListPath
    foreach ($number in $phoneNumbers) {
        Send-SMSMessage -ToNumber $number -message $reportMessage
        Write-Log "Batch Send-SMSMessage was called with Phone Number: $number."
    }
}