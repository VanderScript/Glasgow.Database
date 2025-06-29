-- Database Metadata Export Script (JSON Output)
-- This script generates a comprehensive overview of database objects as JSON

SET NOCOUNT ON;

DECLARE @JSON nvarchar(max);

-- Create JSON object
WITH DatabaseInfo AS (
    SELECT 
        @@SERVERNAME AS ServerName,
        DB_NAME() AS DatabaseName,
        @@VERSION AS SQLServerVersion
),
SchemaInfo AS (
    SELECT 
        s.name AS SchemaName,
        s.schema_id,
        s.principal_id,
        USER_NAME(s.principal_id) AS SchemaOwner
    FROM sys.schemas s
),
TableInfo AS (
    SELECT 
        s.name AS SchemaName,
        t.name AS TableName,
        p.rows AS ApproximateRowCount,
        CASE WHEN t.temporal_type = 2 THEN 'History Table'
             WHEN t.temporal_type = 1 THEN 'System-Versioned'
             ELSE 'Regular Table' END AS TableType,
        OBJECT_DEFINITION(t.object_id) AS TableDefinition,
        t.object_id
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    INNER JOIN sys.partitions p ON t.object_id = p.object_id
    WHERE p.index_id IN (0,1)
),
ColumnInfo AS (
    SELECT 
        s.name AS SchemaName,
        t.name AS TableName,
        c.name AS ColumnName,
        tp.name AS DataType,
        c.max_length,
        c.precision,
        c.scale,
        c.is_nullable,
        c.is_identity,
        CASE WHEN dc.definition IS NOT NULL THEN dc.definition
             ELSE NULL END AS DefaultValue,
        cc.definition AS CheckConstraint,
        t.object_id
    FROM sys.columns c
    INNER JOIN sys.tables t ON c.object_id = t.object_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    INNER JOIN sys.types tp ON c.user_type_id = tp.user_type_id
    LEFT JOIN sys.default_constraints dc ON c.default_object_id = dc.object_id
    LEFT JOIN sys.check_constraints cc ON c.object_id = cc.parent_object_id 
        AND cc.parent_column_id = c.column_id
),
PrimaryKeyInfo AS (
    SELECT 
        s.name AS SchemaName,
        t.name AS TableName,
        i.name AS PrimaryKeyName,
        c.name AS ColumnName,
        ic.key_ordinal AS KeySequence,
        t.object_id
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id 
        AND i.index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id 
        AND ic.column_id = c.column_id
    INNER JOIN sys.tables t ON i.object_id = t.object_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE i.is_primary_key = 1
),
ForeignKeyInfo AS (
    SELECT 
        OBJECT_SCHEMA_NAME(fk.parent_object_id) AS SchemaName,
        OBJECT_NAME(fk.parent_object_id) AS TableName,
        fk.name AS ForeignKeyName,
        pc.name AS ColumnName,
        OBJECT_SCHEMA_NAME(fk.referenced_object_id) AS ReferencedSchemaName,
        OBJECT_NAME(fk.referenced_object_id) AS ReferencedTableName,
        rc.name AS ReferencedColumnName,
        fk.delete_referential_action_desc AS OnDelete,
        fk.update_referential_action_desc AS OnUpdate,
        fk.parent_object_id AS object_id
    FROM sys.foreign_keys fk
    INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
    INNER JOIN sys.columns pc ON fkc.parent_object_id = pc.object_id 
        AND fkc.parent_column_id = pc.column_id
    INNER JOIN sys.columns rc ON fkc.referenced_object_id = rc.object_id 
        AND fkc.referenced_column_id = rc.column_id
),
IndexInfo AS (
    SELECT 
        s.name AS SchemaName,
        t.name AS TableName,
        i.name AS IndexName,
        i.type_desc AS IndexType,
        i.is_unique AS IsUnique,
        STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS IndexColumns,
        t.object_id
    FROM sys.indexes i
    INNER JOIN sys.tables t ON i.object_id = t.object_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id 
        AND i.index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id 
        AND ic.column_id = c.column_id
    WHERE i.is_primary_key = 0 
        AND i.is_unique_constraint = 0
    GROUP BY s.name, t.name, i.name, i.type_desc, i.is_unique, t.object_id
),
StoredProcInfo AS (
    SELECT 
        s.name AS SchemaName,
        p.name AS ProcedureName,
        p.create_date,
        p.modify_date,
        OBJECT_DEFINITION(p.object_id) AS ProcedureDefinition,
        p.object_id
    FROM sys.procedures p
    INNER JOIN sys.schemas s ON p.schema_id = s.schema_id
),
ProcParamInfo AS (
    SELECT 
        s.name AS SchemaName,
        p.name AS ProcedureName,
        pm.parameter_id,
        pm.name AS ParameterName,
        t.name AS DataType,
        pm.max_length,
        pm.precision,
        pm.scale,
        pm.is_output,
        p.object_id
    FROM sys.parameters pm
    INNER JOIN sys.procedures p ON pm.object_id = p.object_id
    INNER JOIN sys.schemas s ON p.schema_id = s.schema_id
    INNER JOIN sys.types t ON pm.user_type_id = t.user_type_id
),
TriggerInfo AS (
    SELECT 
        s.name AS SchemaName,
        t.name AS TableName,
        tr.name AS TriggerName,
        tr.create_date,
        tr.modify_date,
        tr.is_instead_of_trigger,
        OBJECT_DEFINITION(tr.object_id) AS TriggerDefinition,
        t.object_id
    FROM sys.triggers tr
    INNER JOIN sys.tables t ON tr.parent_id = t.object_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
)

SELECT @JSON = (
    SELECT 
        (SELECT * FROM DatabaseInfo FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as DatabaseInfo,
        (SELECT * FROM SchemaInfo FOR JSON PATH) as Schemas,
        (
            SELECT 
                t.*,
                (
                    SELECT * FROM ColumnInfo c 
                    WHERE c.object_id = t.object_id 
                    FOR JSON PATH
                ) as Columns,
                (
                    SELECT * FROM PrimaryKeyInfo pk 
                    WHERE pk.object_id = t.object_id 
                    FOR JSON PATH
                ) as PrimaryKeys,
                (
                    SELECT * FROM ForeignKeyInfo fk 
                    WHERE fk.object_id = t.object_id 
                    FOR JSON PATH
                ) as ForeignKeys,
                (
                    SELECT * FROM IndexInfo i 
                    WHERE i.object_id = t.object_id 
                    FOR JSON PATH
                ) as Indexes,
                (
                    SELECT * FROM TriggerInfo tr 
                    WHERE tr.object_id = t.object_id 
                    FOR JSON PATH
                ) as Triggers
            FROM TableInfo t
            FOR JSON PATH
        ) as Tables,
        (
            SELECT 
                p.*,
                (
                    SELECT * FROM ProcParamInfo pp 
                    WHERE pp.object_id = p.object_id 
                    FOR JSON PATH
                ) as Parameters
            FROM StoredProcInfo p
            FOR JSON PATH
        ) as StoredProcedures
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
);

-- Output the JSON
SELECT @JSON as DatabaseMetadata; 