
/***************************************************************************************
  Procedure: sp_upsert_batch
  PK: batch_id
***************************************************************************************/
CREATE PROCEDURE forge.sp_upsert_batch
(
    @p_record_id UNIQUEIDENTIFIER = NULL,
    @p_created_by_user_id UNIQUEIDENTIFIER,
    @p_is_delete BIT = 0,

    -- Table-specific columns
    @p_batch_code VARCHAR(100),
    @p_batch_type_id INT,
    @p_state_id INT,
    @p_date_started_utc DATETIME,
    @p_date_completed_utc DATETIME,

    -- Outputs
    @p_return_result_ok BIT OUTPUT,
    @p_return_result_message NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @l_log_id UNIQUEIDENTIFIER = NEWID();
    DECLARE @l_exists BIT = 0;
    DECLARE @l_action_type_id INT;

    IF @p_record_id IS NOT NULL
       AND EXISTS(SELECT 1 FROM forge.batch WHERE batch_id = @p_record_id)
    BEGIN
        SET @l_exists = 1;
    END

    BEGIN TRY

        IF @p_is_delete = 1 AND @p_record_id IS NOT NULL AND @l_exists = 1
        BEGIN
            DELETE FROM forge.batch
            WHERE batch_id = @p_record_id;

            SET @l_action_type_id = 3;

            EXEC core.sp_log_transaction
                @p_transaction_log_id = @l_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'batch',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = NULL,
                @p_data_after = NULL,
                @p_diff_data = NULL,
                @p_message = 'Deleted from batch',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_loggingid = @l_log_id OUTPUT;
        END
        ELSE IF @l_exists = 1
        BEGIN
            UPDATE forge.batch
            SET
                batch_code = @p_batch_code,
                batch_type_id = @p_batch_type_id,
                state_id = @p_state_id,
                date_started_utc = @p_date_started_utc,
                date_completed_utc = @p_date_completed_utc
            WHERE batch_id = @p_record_id;

            SET @l_action_type_id = 2;

            EXEC core.sp_log_transaction
                @p_transaction_log_id = @l_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'batch',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = NULL,
                @p_data_after = NULL,
                @p_diff_data = NULL,
                @p_message = 'Updated batch',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_loggingid = @l_log_id OUTPUT;
        END
        ELSE
        BEGIN
            IF @p_record_id IS NULL
                SET @p_record_id = NEWID();

            INSERT INTO forge.batch
            (
                batch_id,
                batch_code,
                batch_type_id,
                state_id,
                date_started_utc,
                date_completed_utc
            )
            VALUES
            (
                @p_record_id,
                @p_batch_code,
                @p_batch_type_id,
                @p_state_id,
                @p_date_started_utc,
                @p_date_completed_utc
            );

            SET @l_action_type_id = 1;

            EXEC core.sp_log_transaction
                @p_transaction_log_id = @l_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'batch',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = NULL,
                @p_data_after = NULL,
                @p_diff_data = NULL,
                @p_message = 'Inserted into batch',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_loggingid = @l_log_id OUTPUT;
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
                @p_transaction_log_id = @l_transaction_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'batch',
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
                @p_loggingid = NULL;
        END TRY
        BEGIN CATCH
        END CATCH
    END CATCH
END;

