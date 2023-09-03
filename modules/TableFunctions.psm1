$HOLES_TABLE_NAME = 'holes'
$PATTERN_TABLE_NAME = 'pattern'

function CheckAndDropTable {
    param (
        [string]$tableName
    )

    $tableExists = Invoke-SqlQuery -query "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = '$tableName'"
    if ($tableExists -gt 0) {
        Write-Output "Table '$tableName' already exists. Dropping it..."
        Invoke-SqlQuery -query "DROP TABLE [$tableName]"
    }
}

function CreatePatternTable {
    param (
    )

    $createPatternTableQuery = @"
CREATE TABLE $PATTERN_TABLE_NAME (
    PatternName VARCHAR(50) PRIMARY KEY,
    Description VARCHAR(255)
);
"@
    Invoke-SqlQuery -query $createPatternTableQuery
    Write-Output "Table '$PATTERN_TABLE_NAME' created successfully!"
}

function CreateHolesTable {
    param (
    )

    $createTableQuery = @"
CREATE TABLE [$HOLES_TABLE_NAME] (
    HoleName CHAR(4),
    DepthDrilled REAL,
    HoleStartTime DATETIME,
    HoleEndTime DATETIME,
    PatternID VARCHAR(50) FOREIGN KEY REFERENCES $PATTERN_TABLE_NAME(PatternName),
    PRIMARY KEY (HoleName, PatternID),
    INDEX idx_HoleName (HoleName)
);
"@
    Invoke-SqlQuery -query $createTableQuery
    Write-Output "Table '$HOLES_TABLE_NAME' created successfully!"
}

function Get-HolesCount {
    param (
        [string]$holesTableName = $HOLES_TABLE_NAME
    )

    $query = "SELECT COUNT(*) FROM [$holesTableName]"
    return Invoke-SqlQuery -query $query
}

function Get-TotalDepthDrilled {
    param (
        [string]$holesTableName = $HOLES_TABLE_NAME
    )

    $query = "SELECT SUM(DepthDrilled) FROM [$holesTableName]"
    return Invoke-SqlQuery -query $query
}

Export-ModuleMember -Function CheckAndDropTable, CreatePatternTable, CreateHolesTable, Get-HolesCount, Get-TotalDepthDrilled
