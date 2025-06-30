/***************************************************************************************
  Procedure: sp_upsert_inventory_count
  PK: inventory_count_id
***************************************************************************************/
CREATE PROCEDURE forge.sp_upsert_inventory_count
(
    @p_record_id UNIQUEIDENTIFIER = NULL,
    @p_created_by_user_id UNIQUEIDENTIFIER = NULL,
    @p_is_delete BIT = 0,

    -- Table-specific columns
    @p_inventory_document_id UNIQUEIDENTIFIER,
    @p_storage_location_id UNIQUEIDENTIFIER,
    @p_item_uom_id UNIQUEIDENTIFIER,
    @p_expected_quantity INT,
    @p_counted_quantity INT,
    @p_count_status VARCHAR(50),
    @p_counted_by_user_id UNIQUEIDENTIFIER = NULL,
    @p_validated_by_user_id UNIQUEIDENTIFIER = NULL,
    @p_date_counted_utc DATETIME = NULL,
    @p_date_validated_utc DATETIME = NULL,

    -- Outputs
    @p_return_result_ok BIT OUTPUT,
    @p_return_result_message NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Default to NONE user if no user ID is provided
    IF @p_created_by_user_id IS NULL
        SET @p_created_by_user_id = '00000000-0000-0000-0000-000000000001'; -- NONE user

    DECLARE @l_log_id UNIQUEIDENTIFIER = NEWID();
    DECLARE @l_exists BIT = 0;
    DECLARE @l_action_type_id INT;
    DECLARE @l_data_before NVARCHAR(MAX);
    DECLARE @l_data_after NVARCHAR(MAX);
    DECLARE @l_diff_data NVARCHAR(MAX);

    IF @p_record_id IS NOT NULL
       AND EXISTS(SELECT 1 FROM forge.inventory_count WHERE inventory_count_id = @p_record_id)
    BEGIN
        SET @l_exists = 1;
    END

    BEGIN TRY

        IF @p_is_delete = 1 AND @p_record_id IS NOT NULL AND @l_exists = 1
        BEGIN
            -- Capture data before deletion
            SELECT @l_data_before = (
                SELECT 
                    inventory_count_id,
                    inventory_document_id,
                    storage_location_id,
                    item_uom_id,
                    expected_quantity,
                    counted_quantity,
                    count_status,
                    counted_by_user_id,
                    validated_by_user_id,
                    date_counted_utc,
                    date_validated_utc,
                    date_created_utc,
                    date_updated_utc
                FROM forge.inventory_count 
                WHERE inventory_count_id = @p_record_id
                FOR JSON PATH
            );
            
            DELETE FROM forge.inventory_count
            WHERE inventory_count_id = @p_record_id;

            SET @l_action_type_id = 3;

            IF @l_data_before IS NOT NULL AND @l_data_before != '[]'
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_log_id,
                    @p_source_system = 'FORGE',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'inventory_count',
                    @p_object_id = @p_record_id,
                    @p_action_type_id = @l_action_type_id,
                    @p_status_code_id = 1,
                    @p_data_before = @l_data_before,
                    @p_data_after = NULL,
                    @p_diff_data = NULL,
                    @p_message = 'Deleted from inventory_count',
                    @p_context_id = NULL,
                    @p_return_result_ok = @p_return_result_ok OUTPUT,
                    @p_return_result_message = @p_return_result_message OUTPUT,
                    @p_logging_id_out = @l_log_id OUTPUT;
            END
        END
        ELSE IF @l_exists = 1
        BEGIN
            -- Capture data before update
            SELECT @l_data_before = (
                SELECT 
                    inventory_count_id,
                    inventory_document_id,
                    storage_location_id,
                    item_uom_id,
                    expected_quantity,
                    counted_quantity,
                    count_status,
                    counted_by_user_id,
                    validated_by_user_id,
                    date_counted_utc,
                    date_validated_utc,
                    date_created_utc,
                    date_updated_utc
                FROM forge.inventory_count 
                WHERE inventory_count_id = @p_record_id
                FOR JSON PATH
            );

            UPDATE forge.inventory_count
            SET
                inventory_document_id = @p_inventory_document_id,
                storage_location_id = @p_storage_location_id,
                item_uom_id = @p_item_uom_id,
                expected_quantity = @p_expected_quantity,
                counted_quantity = @p_counted_quantity,
                count_status = @p_count_status,
                counted_by_user_id = @p_counted_by_user_id,
                validated_by_user_id = @p_validated_by_user_id,
                date_counted_utc = @p_date_counted_utc,
                date_validated_utc = @p_date_validated_utc,
                date_updated_utc = GETUTCDATE()
            WHERE inventory_count_id = @p_record_id;

            -- Capture data after update
            SELECT @l_data_after = (
                SELECT 
                    inventory_count_id,
                    inventory_document_id,
                    storage_location_id,
                    item_uom_id,
                    expected_quantity,
                    counted_quantity,
                    count_status,
                    counted_by_user_id,
                    validated_by_user_id,
                    date_counted_utc,
                    date_validated_utc,
                    date_created_utc,
                    date_updated_utc
                FROM forge.inventory_count 
                WHERE inventory_count_id = @p_record_id
                FOR JSON PATH
            );

            -- Generate diff data
            WITH DiffData AS (
                SELECT 
                    'inventory_document_id' as [field],
                    JSON_VALUE(@l_data_before, '$[0].inventory_document_id') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].inventory_document_id') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].inventory_document_id') <> JSON_VALUE(@l_data_after, '$[0].inventory_document_id')
                UNION ALL
                SELECT 
                    'storage_location_id' as [field],
                    JSON_VALUE(@l_data_before, '$[0].storage_location_id') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].storage_location_id') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].storage_location_id') <> JSON_VALUE(@l_data_after, '$[0].storage_location_id')
                UNION ALL
                SELECT 
                    'item_uom_id' as [field],
                    JSON_VALUE(@l_data_before, '$[0].item_uom_id') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].item_uom_id') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].item_uom_id') <> JSON_VALUE(@l_data_after, '$[0].item_uom_id')
                UNION ALL
                SELECT 
                    'expected_quantity' as [field],
                    JSON_VALUE(@l_data_before, '$[0].expected_quantity') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].expected_quantity') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].expected_quantity') <> JSON_VALUE(@l_data_after, '$[0].expected_quantity')
                UNION ALL
                SELECT 
                    'counted_quantity' as [field],
                    JSON_VALUE(@l_data_before, '$[0].counted_quantity') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].counted_quantity') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].counted_quantity') <> JSON_VALUE(@l_data_after, '$[0].counted_quantity')
                UNION ALL
                SELECT 
                    'count_status' as [field],
                    JSON_VALUE(@l_data_before, '$[0].count_status') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].count_status') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].count_status') <> JSON_VALUE(@l_data_after, '$[0].count_status')
                UNION ALL
                SELECT 
                    'counted_by_user_id' as [field],
                    JSON_VALUE(@l_data_before, '$[0].counted_by_user_id') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].counted_by_user_id') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].counted_by_user_id') <> JSON_VALUE(@l_data_after, '$[0].counted_by_user_id')
                UNION ALL
                SELECT 
                    'validated_by_user_id' as [field],
                    JSON_VALUE(@l_data_before, '$[0].validated_by_user_id') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].validated_by_user_id') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].validated_by_user_id') <> JSON_VALUE(@l_data_after, '$[0].validated_by_user_id')
                UNION ALL
                SELECT 
                    'date_counted_utc' as [field],
                    JSON_VALUE(@l_data_before, '$[0].date_counted_utc') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].date_counted_utc') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].date_counted_utc') <> JSON_VALUE(@l_data_after, '$[0].date_counted_utc')
                UNION ALL
                SELECT 
                    'date_validated_utc' as [field],
                    JSON_VALUE(@l_data_before, '$[0].date_validated_utc') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].date_validated_utc') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].date_validated_utc') <> JSON_VALUE(@l_data_after, '$[0].date_validated_utc')
            )
            SELECT @l_diff_data = ( SELECT * FROM DiffData FOR JSON PATH );

            SET @l_action_type_id = 2;

            EXEC core.sp_log_transaction
                @p_logging_id = @l_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'inventory_count',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = @l_data_before,
                @p_data_after = @l_data_after,
                @p_diff_data = @l_diff_data,
                @p_message = 'Updated inventory_count',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_logging_id_out = @l_log_id OUTPUT;
        END
        ELSE
        BEGIN
            IF @p_record_id IS NULL
                SET @p_record_id = NEWID();

            INSERT INTO forge.inventory_count
            (
                inventory_count_id,
                inventory_document_id,
                storage_location_id,
                item_uom_id,
                expected_quantity,
                counted_quantity,
                count_status,
                counted_by_user_id,
                validated_by_user_id,
                date_counted_utc,
                date_validated_utc
            )
            VALUES
            (
                @p_record_id,
                @p_inventory_document_id,
                @p_storage_location_id,
                @p_item_uom_id,
                @p_expected_quantity,
                @p_counted_quantity,
                @p_count_status,
                @p_counted_by_user_id,
                @p_validated_by_user_id,
                @p_date_counted_utc,
                @p_date_validated_utc
            );

            -- Capture data after insert
            SELECT @l_data_after = (
                SELECT 
                    inventory_count_id,
                    inventory_document_id,
                    storage_location_id,
                    item_uom_id,
                    expected_quantity,
                    counted_quantity,
                    count_status,
                    counted_by_user_id,
                    validated_by_user_id,
                    date_counted_utc,
                    date_validated_utc,
                    date_created_utc,
                    date_updated_utc
                FROM forge.inventory_count 
                WHERE inventory_count_id = @p_record_id
                FOR JSON PATH
            );

            SET @l_action_type_id = 1;

            EXEC core.sp_log_transaction
                @p_logging_id = @l_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'inventory_count',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = NULL,
                @p_data_after = @l_data_after,
                @p_diff_data = NULL,
                @p_message = 'Inserted into inventory_count',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_logging_id_out = @l_log_id OUTPUT;
        END

    END TRY
    BEGIN CATCH
        DECLARE @l_err_message NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @l_err_number INT = ERROR_NUMBER();
        DECLARE @l_err_line INT = ERROR_LINE();
        DECLARE @l_err_procedure NVARCHAR(128) = ERROR_PROCEDURE();
        DECLARE @l_transaction_log_id UNIQUEIDENTIFIER = NEWID();

        SET @p_return_result_ok = 0;
        SET @p_return_result_message = CONCAT(
            'Error: ', @l_err_message,
            ' (Line ', @l_err_line,
            ', Procedure: ', ISNULL(@l_err_procedure,'N/A'),
            ', Error: ', @l_err_number, ')'
        );

        SET @l_action_type_id = CASE
            WHEN @p_is_delete = 1 THEN 3
            WHEN @l_exists = 1 THEN 2
            ELSE 1
        END;

        BEGIN TRY
            EXEC core.sp_log_transaction
                @p_logging_id = @l_transaction_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'inventory_count',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 2,
                @p_data_before = NULL,
                @p_data_after = NULL,
                @p_diff_data = NULL,
                @p_message = @p_return_result_message,
                @p_context_id = NULL,
                @p_return_result_ok = NULL,
                @p_return_result_message = NULL,
                @p_logging_id_out = NULL;
        END TRY
        BEGIN CATCH
        END CATCH
    END CATCH
END;

