
$config = Import-PowerShellDataFile -Path "./modules/config.psd1"

$FromEmail = $config.SMTPConfig.FromEmail
$Token = $config.SMTPConfig.Token 
$SMTPServer = $config.SMTPConfig.Server
$PORT = $config.SMTPConfig.Port


function Send-EmailReport {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Recipient,

        [Parameter(Mandatory = $true)]
        [string]$EmailSubject,

        [Parameter(Mandatory = $true)]
        [string]$MessageBody
    )
    $passwd = $Token  | ConvertTo-SecureString -AsPlainText -Force
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential($FromEmail, $passwd)
    Send-MailMessage -From $FromEmail -To $Recipient -Subject $EmailSubject -Body $MessageBody -SmtpServer $SMTPServer -port $PORT -UseSsl -Credential $Credential -ErrorAction Stop
}

Export-ModuleMember -Function Send-EmailReport
