# Import the modules
Import-Module ./modules/ConnectionFunctions.psm1
Import-Module ./modules/TableFunctions.psm1

# Main Execution Flow
$ServerName = Read-Host -Prompt "Enter SQL Server Name [$DEFAULT_SERVER]"
if (-not $ServerName) { $ServerName = $DEFAULT_SERVER }
$DatabaseName = Read-Host -Prompt "Enter the database name [$DEFAULT_DATABASE]"
if (-not $DatabaseName) { $DatabaseName = $DEFAULT_DATABASE }

# Connect to SQL Server
$connectionString = "Server=$ServerName;Database=$DatabaseName;Integrated Security=True;"
$connectionSuccess = Test-SqlServerConnection -serverName $ServerName -databaseName $DatabaseName
if (-not $connectionSuccess) { exit }

# Process Pattern table
CheckAndDropTable -connectionString $connectionString -tableName $PATTERN_TABLE_NAME
CreatePatternTable -connectionString $connectionString

# Process Holes table
CheckAndDropTable -connectionString $connectionString -tableName $HOLES_TABLE_NAME
CreateHolesTable -connectionString $connectionString

# Insert dummy Pattern data
$patternNames = @('011_TL_01', '012_TL_02', '013_TL_03')
foreach ($pattern in $patternNames) {
    $query = "INSERT INTO $PATTERN_TABLE_NAME (PatternName, Description) VALUES ('$pattern', 'Description for $pattern')"
    Invoke-SqlQuery -connectionString $connectionString -query $query | Out-Null
}

# Insert dummy Holes data
$holePrefixes = @('AA', 'AB', 'AC', 'AD', 'AE')
for ($i = 0; $i -lt 50; $i++) {
    $holeName = $holePrefixes[$i % $holePrefixes.Length] + ($i % 100).ToString().PadLeft(2, '0')
    $pattern = $patternNames[$i % $patternNames.Length]
    $query = "INSERT INTO $HOLES_TABLE_NAME (HoleName, DepthDrilled, HoleStartTime, HoleEndTime, PatternID) VALUES ('$holeName', $(Get-Random -Minimum 10 -Maximum 100), GETDATE(), DATEADD(HOUR, $(Get-Random -Minimum 1 -Maximum 5), GETDATE()), '$pattern')"
    Invoke-SqlQuery -connectionString $connectionString -query $query | Out-Null
}

# Get the count of holes
$holesCount = Get-HolesCount -connectionString $connectionString -holesTableName $HOLES_TABLE_NAME
Write-Output ("Total Holes are: " + $holesCount)

# Get the total depth drilled
$totalDepth = Get-TotalDepthDrilled -connectionString $connectionString -holesTableName $HOLES_TABLE_NAME
Write-Output ("Total Metres drilled is: " + $totalDepth + " Metres")
