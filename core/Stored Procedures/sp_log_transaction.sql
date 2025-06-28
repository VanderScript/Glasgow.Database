CREATE PROCEDURE core.sp_log_transaction
    @p_transaction_log_id UNIQUEIDENTIFIER,
    @p_source_system VARCHAR(50),
    @p_user_id UNIQUEIDENTIFIER = NULL,
    @p_object_name VARCHAR(100),
    @p_object_id UNIQUEIDENTIFIER = NULL,
    @p_action_type_id INT,
    @p_status_code_id INT,
    @p_data_before NVARCHAR(MAX) = NULL,
    @p_data_after NVARCHAR(MAX) = NULL,
    @p_diff_data NVARCHAR(MAX) = NULL,
    @p_message NVARCHAR(1000) = NULL,
    @p_context_id UNIQUEIDENTIFIER = NULL,

    @p_return_result_ok BIT OUTPUT,
    @p_return_result_message NVARCHAR(MAX) OUTPUT,
    @p_loggingid UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Assign logging ID if not supplied
        IF @p_transaction_log_id IS NULL
            SET @p_transaction_log_id = NEWID();

        -- Default return values
        SET @p_return_result_ok = 1;
        SET @p_return_result_message = N'Transaction log inserted successfully.';
        SET @p_loggingid = @p_transaction_log_id;

        -- Insert the log entry
        INSERT INTO core.transaction_log (
            transaction_log_id,
            source_system,
            user_id,
            event_timestamp,
            object_name,
            object_id,
            action_type_id,
            status_code_id,
            data_before,
            data_after,
            diff_data,
            message,
            context_id,
            created_utc
        )
        VALUES (
            @p_transaction_log_id,
            @p_source_system,
            @p_user_id,
            GETUTCDATE(),
            @p_object_name,
            @p_object_id,
            @p_action_type_id,
            @p_status_code_id,
            @p_data_before,
            @p_data_after,
            @p_diff_data,
            @p_message,
            @p_context_id,
            GETUTCDATE()
        );
    END TRY
    BEGIN CATCH
        DECLARE @err_message NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @err_number INT = ERROR_NUMBER();
        DECLARE @err_severity INT = ERROR_SEVERITY();
        DECLARE @err_state INT = ERROR_STATE();
        DECLARE @err_line INT = ERROR_LINE();
        DECLARE @err_procedure NVARCHAR(128) = ERROR_PROCEDURE();

        SET @p_return_result_ok = 0;
        SET @p_return_result_message = CONCAT(
            'Error: ', @err_message, ' (Line ', @err_line, 
            ', Procedure: ', ISNULL(@err_procedure, 'N/A'), 
            ', State: ', @err_state, ', Severity: ', @err_severity, ')'
        );
        SET @p_loggingid = NULL;

        -- Attempt to log the failure of this procedure itself
        BEGIN TRY
            INSERT INTO core.transaction_log (
                transaction_log_id,
                source_system,
                user_id,
                event_timestamp,
                object_name,
                object_id,
                action_type_id,
                status_code_id,
                data_before,
                data_after,
                diff_data,
                message,
                context_id,
                created_utc
            )
            VALUES (
                NEWID(),
                'CORE',
                @p_user_id,
                GETUTCDATE(),
                'sp_log_transaction',
                NULL,
                5, -- Assuming 'VALIDATE' or 'SYSTEM_ERROR' action_type_id
                2, -- FAILED
                NULL,
                NULL,
                NULL,
                @p_return_result_message,
                @p_context_id,
                GETUTCDATE()
            );
        END TRY
        BEGIN CATCH
            -- If even the internal log fails, suppress it to avoid infinite loop
        END CATCH

        RETURN;
    END CATCH
END;
