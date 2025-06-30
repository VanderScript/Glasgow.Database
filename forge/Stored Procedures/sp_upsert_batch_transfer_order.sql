/***************************************************************************************
  Procedure: sp_upsert_batch_transfer_order
  Composite PK: (batch_id, transfer_order_id)
***************************************************************************************/
CREATE PROCEDURE forge.sp_upsert_batch_transfer_order
(
    @p_batch_id UNIQUEIDENTIFIER,
    @p_transfer_order_id UNIQUEIDENTIFIER,
    @p_created_by_user_id UNIQUEIDENTIFIER = NULL,
    @p_is_delete BIT = 0,
    @p_donot_log BIT = 0,
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

    IF EXISTS (
        SELECT 1 FROM forge.batch_transfer_order
        WHERE batch_id = @p_batch_id AND transfer_order_id = @p_transfer_order_id
    )
    BEGIN
        SET @l_exists = 1;
    END

    BEGIN TRY
        IF @p_is_delete = 1 AND @l_exists = 1
        BEGIN
            -- Capture data before deletion
            SELECT @l_data_before = (
                SELECT 
                    batch_id,
                    transfer_order_id
                FROM forge.batch_transfer_order 
                WHERE batch_id = @p_batch_id AND transfer_order_id = @p_transfer_order_id
                FOR JSON PATH
            );
            
            DELETE FROM forge.batch_transfer_order
            WHERE batch_id = @p_batch_id AND transfer_order_id = @p_transfer_order_id;

            SET @l_action_type_id = 3;

            IF @l_data_before IS NOT NULL AND @l_data_before != '[]'
            BEGIN
                IF @p_donot_log = 0
                BEGIN
                    EXEC core.sp_log_transaction
                        @p_logging_id = @l_log_id,
                        @p_source_system = '[forge].[sp_upsert_batch_transfer_order]',
                        @p_user_id = @p_created_by_user_id,
                        @p_object_name = 'batch_transfer_order',
                        @p_object_id = NULL,
                        @p_action_type_id = @l_action_type_id,
                        @p_status_code_id = 1,
                        @p_data_before = @l_data_before,
                        @p_data_after = NULL,
                        @p_diff_data = NULL,
                        @p_message = 'Deleted from batch_transfer_order',
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
                    batch_id,
                    transfer_order_id
                FROM forge.batch_transfer_order 
                WHERE batch_id = @p_batch_id AND transfer_order_id = @p_transfer_order_id
                FOR JSON PATH
            );

            UPDATE forge.batch_transfer_order
            SET
                batch_id = @p_batch_id,
                transfer_order_id = @p_transfer_order_id
            WHERE batch_id = @p_batch_id AND transfer_order_id = @p_transfer_order_id;

            SELECT @l_data_after = (
                SELECT 
                    batch_id,
                    transfer_order_id
                FROM forge.batch_transfer_order 
                WHERE batch_id = @p_batch_id AND transfer_order_id = @p_transfer_order_id
                FOR JSON PATH
            );

            WITH DiffData AS (
                SELECT 
                    'batch_id' as [field],
                    JSON_VALUE(@l_data_before, '$[0].batch_id') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].batch_id') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].batch_id') <> JSON_VALUE(@l_data_after, '$[0].batch_id')
                UNION ALL
                SELECT 
                    'transfer_order_id' as [field],
                    JSON_VALUE(@l_data_before, '$[0].transfer_order_id') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].transfer_order_id') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].transfer_order_id') <> JSON_VALUE(@l_data_after, '$[0].transfer_order_id')
            )
            SELECT @l_diff_data = ( SELECT * FROM DiffData FOR JSON PATH );

            SET @l_action_type_id = 2;

            IF @p_donot_log = 0
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_log_id,
                    @p_source_system = '[forge].[sp_upsert_batch_transfer_order]',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'batch_transfer_order',
                    @p_object_id = NULL,
                    @p_action_type_id = @l_action_type_id,
                    @p_status_code_id = 1,
                    @p_data_before = @l_data_before,
                    @p_data_after = @l_data_after,
                    @p_diff_data = @l_diff_data,
                    @p_message = 'Updated batch_transfer_order',
                    @p_context_id = NULL,
                    @p_return_result_ok = @p_return_result_ok OUTPUT,
                    @p_return_result_message = @p_return_result_message OUTPUT,
                    @p_logging_id_out = @l_log_id OUTPUT;
            END
        END

        ELSE IF @l_exists = 0
        BEGIN
            INSERT INTO forge.batch_transfer_order (
                batch_id,
                transfer_order_id
            )
            VALUES (
                @p_batch_id,
                @p_transfer_order_id
            );

            SET @l_action_type_id = 1;

            IF @p_donot_log = 0
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_log_id,
                    @p_source_system = '[forge].[sp_upsert_batch_transfer_order]',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'batch_transfer_order',
                    @p_object_id = NULL,
                    @p_action_type_id = @l_action_type_id,
                    @p_status_code_id = 1,
                    @p_data_before = NULL,
                    @p_data_after = NULL,
                    @p_diff_data = NULL,
                    @p_message = 'Inserted into batch_transfer_order',
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

        SET @l_action_type_id = CASE WHEN @p_is_delete = 1 THEN 3 ELSE 1 END;

        BEGIN TRY
            IF @p_donot_log = 0
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_transaction_log_id,
                    @p_source_system = '[forge].[sp_upsert_batch_transfer_order]',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'batch_transfer_order',
                    @p_object_id = NULL,
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

