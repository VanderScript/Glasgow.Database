/***************************************************************************************
  Procedure: sp_upsert_item
  PK: item_id
***************************************************************************************/
CREATE PROCEDURE forge.sp_upsert_item
(
    @p_record_id UNIQUEIDENTIFIER = NULL,
    @p_created_by_user_id UNIQUEIDENTIFIER = NULL,
    @p_is_delete BIT = 0,
    @p_donot_log BIT = 0,

    -- Table-specific columns
    @p_item_number VARCHAR(100),
    @p_description VARCHAR(255),
    @p_item_status_id INT,

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
       AND EXISTS(SELECT 1 FROM forge.item WHERE item_id = @p_record_id)
    BEGIN
        SET @l_exists = 1;
    END

    BEGIN TRY

        IF @p_is_delete = 1 AND @p_record_id IS NOT NULL AND @l_exists = 1
        BEGIN
            -- Capture data before deletion
            SELECT @l_data_before = (
                SELECT 
                    item_id,
                    item_number,
                    description,
                    item_status_id
                FROM forge.item 
                WHERE item_id = @p_record_id
                FOR JSON PATH
            );
            
            DELETE FROM forge.item
            WHERE item_id = @p_record_id;

            SET @l_action_type_id = 3;

            IF @l_data_before IS NOT NULL AND @l_data_before != '[]'
            BEGIN
                IF @p_donot_log = 0
                BEGIN
                    EXEC core.sp_log_transaction
                        @p_logging_id = @l_log_id,
                        @p_source_system = '[forge].[sp_upsert_item]',
                        @p_user_id = @p_created_by_user_id,
                        @p_object_name = 'item',
                        @p_object_id = @p_record_id,
                        @p_action_type_id = @l_action_type_id,
                        @p_status_code_id = 1,
                        @p_data_before = @l_data_before,
                        @p_data_after = NULL,
                        @p_diff_data = NULL,
                        @p_message = 'Deleted from item',
                        @p_context_id = NULL,
                        @p_return_result_ok = @p_return_result_ok OUTPUT,
                        @p_return_result_message = @p_return_result_message OUTPUT,
                        @p_logging_id_out = @l_log_id OUTPUT;
                END
            END
        END
        ELSE IF @l_exists = 1
        BEGIN
            -- Capture data before update
            SELECT @l_data_before = (
                SELECT 
                    item_id,
                    item_number,
                    description,
                    item_status_id
                FROM forge.item 
                WHERE item_id = @p_record_id
                FOR JSON PATH
            );

            UPDATE forge.item
            SET
                item_number = @p_item_number,
                description = @p_description,
                item_status_id = @p_item_status_id
            WHERE item_id = @p_record_id;

            -- Capture data after update
            SELECT @l_data_after = (
                SELECT 
                    item_id,
                    item_number,
                    description,
                    item_status_id
                FROM forge.item 
                WHERE item_id = @p_record_id
                FOR JSON PATH
            );

            -- Generate diff data
            WITH DiffData AS (
                SELECT 
                    'item_number' as [field],
                    JSON_VALUE(@l_data_before, '$[0].item_number') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].item_number') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].item_number') <> JSON_VALUE(@l_data_after, '$[0].item_number')
                UNION ALL
                SELECT 
                    'description' as [field],
                    JSON_VALUE(@l_data_before, '$[0].description') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].description') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].description') <> JSON_VALUE(@l_data_after, '$[0].description')
                UNION ALL
                SELECT 
                    'status_id' as [field],
                    JSON_VALUE(@l_data_before, '$[0].status_id') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].status_id') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].status_id') <> JSON_VALUE(@l_data_after, '$[0].status_id')
            )
            SELECT @l_diff_data = ( SELECT * FROM DiffData FOR JSON PATH );

            SET @l_action_type_id = 2;

            IF @p_donot_log = 0
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_log_id,
                    @p_source_system = '[forge].[sp_upsert_item]',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'item',
                    @p_object_id = @p_record_id,
                    @p_action_type_id = @l_action_type_id,
                    @p_status_code_id = 1,
                    @p_data_before = @l_data_before,
                    @p_data_after = @l_data_after,
                    @p_diff_data = @l_diff_data,
                    @p_message = 'Updated item',
                    @p_context_id = NULL,
                    @p_return_result_ok = @p_return_result_ok OUTPUT,
                    @p_return_result_message = @p_return_result_message OUTPUT,
                    @p_logging_id_out = @l_log_id OUTPUT;
            END
        END
        ELSE
        BEGIN
            IF @p_record_id IS NULL
                SET @p_record_id = NEWID();

            INSERT INTO forge.item
            (
                item_id,
                item_number,
                description,
                item_status_id
            )
            VALUES
            (
                @p_record_id,
                @p_item_number,
                @p_description,
                @p_item_status_id
            );

            -- Capture data after insert
            SELECT @l_data_after = (
                SELECT 
                    item_id,
                    item_number,
                    description,
                    item_status_id
                FROM forge.item 
                WHERE item_id = @p_record_id
                FOR JSON PATH
            );

            SET @l_action_type_id = 1;

            IF @p_donot_log = 0
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_log_id,
                    @p_source_system = '[forge].[sp_upsert_item]',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'item',
                    @p_object_id = @p_record_id,
                    @p_action_type_id = @l_action_type_id,
                    @p_status_code_id = 1,
                    @p_data_before = NULL,
                    @p_data_after = @l_data_after,
                    @p_diff_data = NULL,
                    @p_message = 'Inserted into item',
                    @p_context_id = NULL,
                    @p_return_result_ok = @p_return_result_ok OUTPUT,
                    @p_return_result_message = @p_return_result_message OUTPUT,
                    @p_logging_id_out = @l_log_id OUTPUT;
            END
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
            IF @p_donot_log = 0
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_transaction_log_id,
                    @p_source_system = '[forge].[sp_upsert_item]',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'item',
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
            END
        END TRY
        BEGIN CATCH
        END CATCH
    END CATCH
END;
