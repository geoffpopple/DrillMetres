# Load required assemblies
Add-Type -AssemblyName "System.Data"

# Function to execute a SQL command and return the result
function Open-SqlQuery {
    param (
        [string]$connectionString,
        [string]$query
    )

    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString

    $command = $connection.CreateCommand()
    $command.CommandText = $query

    try {
        $connection.Open()
        $result = $command.ExecuteScalar()
    } finally {
        $connection.Close()
    }

    return $result
}

# Prompt for server name
$ServerName = Read-Host -Prompt "Enter SQL Server Name"

# Create a connection string for the master database to check server connectivity and database existence
$ConnectionString = "Server=$ServerName;Database=master;Integrated Security=True;"

# Check server connectivity
try {
    $serverVersion = Open-SqlQuery -connectionString $ConnectionString -query "SELECT @@VERSION"
    Write-Output "Connected to SQL Server. Version: $serverVersion"
} catch {
    Write-Output "The server does not exist or no connection can be established."
    exit
}

# Ask the user for a database name
$DatabaseName = Read-Host -Prompt "Enter the name of the database you want to create"
$dbExists = Open-SqlQuery -connectionString $ConnectionString -query "SELECT COUNT(name) FROM sys.databases WHERE name = '$DatabaseName'"

if ($dbExists -gt 0) {
    Write-Output "Database '$DatabaseName' already exists."
    Write-Output "Bye"
    exit
}

# Confirm creation
$confirmation = Read-Host -Prompt "Do you want to create the database '$DatabaseName'? (Y/N)"

if ($confirmation -eq "Y" -or $confirmation -eq "y") {
    # Create the database
    $createDbQuery = "CREATE DATABASE [$DatabaseName]"
    Open-SqlQuery -connectionString $ConnectionString -query $createDbQuery
    Write-Output "Database '$DatabaseName' created successfully!"
} else {
    Write-Output "Bye"
    exit
}
