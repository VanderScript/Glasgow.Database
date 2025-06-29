/***************************************************************************************
  Procedure: sp_upsert_item_uom
  PK: item_uom_id
***************************************************************************************/
CREATE PROCEDURE forge.sp_upsert_item_uom
(
    @p_record_id UNIQUEIDENTIFIER = NULL,
    @p_created_by_user_id UNIQUEIDENTIFIER = NULL,
    @p_is_delete BIT = 0,

    -- Table-specific columns
    @p_item_id UNIQUEIDENTIFIER,
    @p_uom_code VARCHAR(20),
    @p_item_code VARCHAR(100),
    @p_conversion_factor DECIMAL(10,2),
    @p_required_location_type_id INT,
    @p_description VARCHAR(255),
    @p_default_weight DECIMAL(10,2),
    @p_default_height DECIMAL(10,2),
    @p_default_width DECIMAL(10,2),
    @p_default_length DECIMAL(10,2),
    @p_is_primary BIT,

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
       AND EXISTS(SELECT 1 FROM forge.item_uom WHERE item_uom_id = @p_record_id)
    BEGIN
        SET @l_exists = 1;
    END

    BEGIN TRY

        IF @p_is_delete = 1 AND @p_record_id IS NOT NULL AND @l_exists = 1
        BEGIN
            -- Capture data before deletion
            SELECT @l_data_before = (
                SELECT 
                    item_uom_id,
                    item_id,
                    uom_code,
                    conversion_factor,
                    is_primary
                FROM forge.item_uom 
                WHERE item_uom_id = @p_record_id
                FOR JSON PATH
            );
            
            DELETE FROM forge.item_uom
            WHERE item_uom_id = @p_record_id;

            SET @l_action_type_id = 3;

            IF @l_data_before IS NOT NULL AND @l_data_before != '[]'
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_log_id,
                    @p_source_system = 'FORGE',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'item_uom',
                    @p_object_id = @p_record_id,
                    @p_action_type_id = @l_action_type_id,
                    @p_status_code_id = 1,
                    @p_data_before = @l_data_before,
                    @p_data_after = NULL,
                    @p_diff_data = NULL,
                    @p_message = 'Deleted from item_uom',
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
                    item_uom_id,
                    item_id,
                    uom_code,
                    conversion_factor,
                    is_primary
                FROM forge.item_uom 
                WHERE item_uom_id = @p_record_id
                FOR JSON PATH
            );

            UPDATE forge.item_uom
            SET
                item_id = @p_item_id,
                uom_code = @p_uom_code,
                item_code = @p_item_code,
                conversion_factor = @p_conversion_factor,
                required_location_type_id = @p_required_location_type_id,
                description = @p_description,
                default_weight = @p_default_weight,
                default_height = @p_default_height,
                default_width = @p_default_width,
                default_length = @p_default_length,
                is_primary = @p_is_primary
            WHERE item_uom_id = @p_record_id;

            -- Capture data after update
            SELECT @l_data_after = (
                SELECT 
                    item_uom_id,
                    item_id,
                    uom_code,
                    conversion_factor,
                    is_primary
                FROM forge.item_uom 
                WHERE item_uom_id = @p_record_id
                FOR JSON PATH
            );

            -- Generate diff data
            WITH DiffData AS (
                SELECT 
                    'item_id' as [field],
                    JSON_VALUE(@l_data_before, '$[0].item_id') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].item_id') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].item_id') <> JSON_VALUE(@l_data_after, '$[0].item_id')
                UNION ALL
                SELECT 
                    'uom_code' as [field],
                    JSON_VALUE(@l_data_before, '$[0].uom_code') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].uom_code') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].uom_code') <> JSON_VALUE(@l_data_after, '$[0].uom_code')
                UNION ALL
                SELECT 
                    'conversion_factor' as [field],
                    JSON_VALUE(@l_data_before, '$[0].conversion_factor') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].conversion_factor') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].conversion_factor') <> JSON_VALUE(@l_data_after, '$[0].conversion_factor')
                UNION ALL
                SELECT 
                    'is_primary' as [field],
                    JSON_VALUE(@l_data_before, '$[0].is_primary') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].is_primary') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].is_primary') <> JSON_VALUE(@l_data_after, '$[0].is_primary')
            )
            SELECT @l_diff_data = ( SELECT * FROM DiffData FOR JSON PATH );

            SET @l_action_type_id = 2;

            EXEC core.sp_log_transaction
                @p_logging_id = @l_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'item_uom',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = @l_data_before,
                @p_data_after = @l_data_after,
                @p_diff_data = @l_diff_data,
                @p_message = 'Updated item_uom',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_logging_id_out = @l_log_id OUTPUT;
        END
        ELSE
        BEGIN
            IF @p_record_id IS NULL
                SET @p_record_id = NEWID();

            INSERT INTO forge.item_uom
            (
                item_uom_id,
                item_id,
                uom_code,
                item_code,
                conversion_factor,
                required_location_type_id,
                description,
                default_weight,
                default_height,
                default_width,
                default_length,
                is_primary
            )
            VALUES
            (
                @p_record_id,
                @p_item_id,
                @p_uom_code,
                @p_item_code,
                @p_conversion_factor,
                @p_required_location_type_id,
                @p_description,
                @p_default_weight,
                @p_default_height,
                @p_default_width,
                @p_default_length,
                @p_is_primary
            );

            -- Capture data after insert
            SELECT @l_data_after = (
                SELECT 
                    item_uom_id,
                    item_id,
                    uom_code,
                    conversion_factor,
                    is_primary
                FROM forge.item_uom 
                WHERE item_uom_id = @p_record_id
                FOR JSON PATH
            );

            SET @l_action_type_id = 1;

            EXEC core.sp_log_transaction
                @p_logging_id = @l_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'item_uom',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = NULL,
                @p_data_after = @l_data_after,
                @p_diff_data = NULL,
                @p_message = 'Inserted into item_uom',
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
                @p_object_name = 'item_uom',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 2,
                @p_data_before = NULL,
                @p_data_after = NULL,
                @p_diff_data = NULL,
                @p_message = @p_return_result_message,
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_logging_id_out = NULL;
        END TRY
        BEGIN CATCH
        END CATCH
    END CATCH
END;

