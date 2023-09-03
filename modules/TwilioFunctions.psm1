$config = Import-PowerShellDataFile -Path "./modules/config.psd1"
$accountSid = $config.TwilioConfig.AccountSid
$authToken = $config.TwilioConfig.AuthToken
$uri = $config.TwilioConfig.Uri + $config.TwilioConfig.AccountSid + "/Messages.json"
$FromNumber = $config.TwilioConfig.PhoneNumber

function Send-SMSMessage {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ToNumber,

        [Parameter(Mandatory=$true)]
        [string]$message
    )

    # Prepare the request body
    $body = @{
        From = $FromNumber
        To = $ToNumber
        Body = $message
    }

    # Convert the credentials to Base64 for Basic Authentication
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("${accountSid}:${authToken}")))

    # Send the message using Twilio's API
    $response = Invoke-RestMethod -Uri $uri -Method Post -Body $body -Headers @{Authorization=("Basic $base64AuthInfo")} -ErrorAction Stop

    # Output the result - TODO: output the message SID to a log file
    $response.sid
}

Export-ModuleMember -Function Send-SMSMessage
