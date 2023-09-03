# Load required assemblies
Add-Type -AssemblyName "System.Data"

#Import the SQL Database constants
$config = Import-PowerShellDataFile -Path "./modules/config.psd1"
$DEFAULT_SERVER = $config.SQLConfig.ServerName
$DEFAULT_DATABASE = $config.SQLConfig.DatabaseName


#Run a Query against the connection that returns a scalar value
function Invoke-SqlQuery {
    param (
        [string]$query
    )

    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString= "Server=$DEFAULT_SERVER;Database=$DEFAULT_DATABASE;Integrated Security=True;"

    $command = $connection.CreateCommand()
    $command.CommandText = $query

    $result = $null

    try {
        $connection.Open()
        $result = $command.ExecuteScalar()
    } catch [Exception] {
        Write-Error "Error executing query: $query. Error details: $_.Exception.Message"
    } finally {
        $connection.Close()
    }

    return $result
}

function Test-SqlServerConnection {
    param (
        [string]$serverName = $DEFAULT_SERVER,
        [string]$databaseName = $DEFAULT_DATABASE
    )

    try {
        $version = Invoke-SqlQuery -query "SELECT @@VERSION"
        Write-Output "Connected to SQL Server. Version: " + $version
        return $true
    } catch {
        Write-Error "The server does not exist or no connection can be established."
        return $false
    }
}

Export-ModuleMember -Function Test-SqlServerConnection, Invoke-SqlQuery
