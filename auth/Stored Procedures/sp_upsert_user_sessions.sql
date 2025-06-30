/***************************************************************************************
  Procedure: sp_upsert_user_sessions
  PK: session_id (INT - IDENTITY)
***************************************************************************************/
CREATE PROCEDURE auth.sp_upsert_user_sessions
(
    @p_record_id INT = NULL,
    @p_created_by_user_id UNIQUEIDENTIFIER = NULL,
    @p_is_delete BIT = 0,
    @p_donot_log BIT = 0,

    -- Table-specific columns
    @p_user_id UNIQUEIDENTIFIER,
    @p_session_token VARCHAR(4000),
    @p_refresh_token VARCHAR(4000) = NULL,
    @p_token_type VARCHAR(50) = 'Bearer',
    @p_scope VARCHAR(1000) = NULL,
    @p_id_token VARCHAR(4000) = NULL,
    @p_identity_provider VARCHAR(50) = NULL,
    @p_date_expires_utc DATETIME2,
    @p_date_created_utc DATETIME2 = NULL, -- Optional, will default to GETUTCDATE() for new records

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

    -- Set date_created_utc to current UTC time if not provided
    IF @p_date_created_utc IS NULL
        SET @p_date_created_utc = GETUTCDATE();

    DECLARE @l_log_id UNIQUEIDENTIFIER = NEWID();
    DECLARE @l_exists BIT = 0;
    DECLARE @l_action_type_id INT;
    DECLARE @l_data_before NVARCHAR(MAX) = NULL;
    DECLARE @l_data_after NVARCHAR(MAX) = NULL;
    DECLARE @l_diff_data NVARCHAR(MAX) = NULL;
    DECLARE @l_current_time DATETIME2 = GETUTCDATE();

    IF @p_record_id IS NOT NULL
       AND EXISTS(SELECT 1 FROM auth.user_sessions WHERE [session_id] = @p_record_id)
    BEGIN
        SET @l_exists = 1;
    END

    BEGIN TRY
        IF @p_is_delete = 1 AND @p_record_id IS NOT NULL AND @l_exists = 1
        BEGIN
            -- Capture data before delete
            SELECT @l_data_before = (
                SELECT *
                FROM auth.user_sessions 
                WHERE session_id = @p_record_id
                FOR JSON PATH
            );
            
            DELETE FROM auth.user_sessions
            WHERE session_id = @p_record_id;

            SET @l_action_type_id = 3;

            IF @p_donot_log = 0
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_log_id,
                    @p_source_system = '[auth].[sp_upsert_user_sessions]',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'user_sessions',
                    @p_object_id = @p_record_id,
                    @p_action_type_id = @l_action_type_id,
                    @p_status_code_id = 1,
                    @p_data_before = @l_data_before,
                    @p_data_after = NULL,
                    @p_diff_data = NULL,
                    @p_message = 'Deleted from user_sessions',
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
                SELECT *
                FROM auth.user_sessions 
                WHERE session_id = @p_record_id
                FOR JSON PATH
            );

            UPDATE auth.user_sessions
            SET
                user_id = @p_user_id,
                session_token = @p_session_token,
                refresh_token = @p_refresh_token,
                token_type = @p_token_type,
                scope = @p_scope,
                id_token = @p_id_token,
                identity_provider = @p_identity_provider,
                date_expires_utc = @p_date_expires_utc,
                date_created_utc = @p_date_created_utc,
                date_updated_utc = @l_current_time
            WHERE session_id = @p_record_id;

            -- Capture data after update
            SELECT @l_data_after = (
                SELECT *
                FROM auth.user_sessions 
                WHERE session_id = @p_record_id
                FOR JSON PATH
            );

            -- Generate diff data
            WITH DiffData AS (
                SELECT 
                    'user_id' as [field],
                    CAST(JSON_VALUE(@l_data_before, '$[0].user_id') AS VARCHAR(36)) as [old_value],
                    CAST(JSON_VALUE(@l_data_after, '$[0].user_id') AS VARCHAR(36)) as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].user_id') <> JSON_VALUE(@l_data_after, '$[0].user_id')
                   OR (JSON_VALUE(@l_data_before, '$[0].user_id') IS NULL AND JSON_VALUE(@l_data_after, '$[0].user_id') IS NOT NULL)
                   OR (JSON_VALUE(@l_data_before, '$[0].user_id') IS NOT NULL AND JSON_VALUE(@l_data_after, '$[0].user_id') IS NULL)
                UNION ALL
                SELECT 
                    'session_token' as [field],
                    JSON_VALUE(@l_data_before, '$[0].session_token') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].session_token') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].session_token') <> JSON_VALUE(@l_data_after, '$[0].session_token')
                   OR (JSON_VALUE(@l_data_before, '$[0].session_token') IS NULL AND JSON_VALUE(@l_data_after, '$[0].session_token') IS NOT NULL)
                   OR (JSON_VALUE(@l_data_before, '$[0].session_token') IS NOT NULL AND JSON_VALUE(@l_data_after, '$[0].session_token') IS NULL)
                UNION ALL
                SELECT 
                    'refresh_token' as [field],
                    JSON_VALUE(@l_data_before, '$[0].refresh_token') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].refresh_token') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].refresh_token') <> JSON_VALUE(@l_data_after, '$[0].refresh_token')
                   OR (JSON_VALUE(@l_data_before, '$[0].refresh_token') IS NULL AND JSON_VALUE(@l_data_after, '$[0].refresh_token') IS NOT NULL)
                   OR (JSON_VALUE(@l_data_before, '$[0].refresh_token') IS NOT NULL AND JSON_VALUE(@l_data_after, '$[0].refresh_token') IS NULL)
                UNION ALL
                SELECT 
                    'token_type' as [field],
                    JSON_VALUE(@l_data_before, '$[0].token_type') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].token_type') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].token_type') <> JSON_VALUE(@l_data_after, '$[0].token_type')
                   OR (JSON_VALUE(@l_data_before, '$[0].token_type') IS NULL AND JSON_VALUE(@l_data_after, '$[0].token_type') IS NOT NULL)
                   OR (JSON_VALUE(@l_data_before, '$[0].token_type') IS NOT NULL AND JSON_VALUE(@l_data_after, '$[0].token_type') IS NULL)
                UNION ALL
                SELECT 
                    'scope' as [field],
                    JSON_VALUE(@l_data_before, '$[0].scope') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].scope') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].scope') <> JSON_VALUE(@l_data_after, '$[0].scope')
                   OR (JSON_VALUE(@l_data_before, '$[0].scope') IS NULL AND JSON_VALUE(@l_data_after, '$[0].scope') IS NOT NULL)
                   OR (JSON_VALUE(@l_data_before, '$[0].scope') IS NOT NULL AND JSON_VALUE(@l_data_after, '$[0].scope') IS NULL)
                UNION ALL
                SELECT 
                    'id_token' as [field],
                    JSON_VALUE(@l_data_before, '$[0].id_token') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].id_token') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].id_token') <> JSON_VALUE(@l_data_after, '$[0].id_token')
                   OR (JSON_VALUE(@l_data_before, '$[0].id_token') IS NULL AND JSON_VALUE(@l_data_after, '$[0].id_token') IS NOT NULL)
                   OR (JSON_VALUE(@l_data_before, '$[0].id_token') IS NOT NULL AND JSON_VALUE(@l_data_after, '$[0].id_token') IS NULL)
                UNION ALL
                SELECT 
                    'identity_provider' as [field],
                    JSON_VALUE(@l_data_before, '$[0].identity_provider') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].identity_provider') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].identity_provider') <> JSON_VALUE(@l_data_after, '$[0].identity_provider')
                   OR (JSON_VALUE(@l_data_before, '$[0].identity_provider') IS NULL AND JSON_VALUE(@l_data_after, '$[0].identity_provider') IS NOT NULL)
                   OR (JSON_VALUE(@l_data_before, '$[0].identity_provider') IS NOT NULL AND JSON_VALUE(@l_data_after, '$[0].identity_provider') IS NULL)
                UNION ALL
                SELECT 
                    'date_expires_utc' as [field],
                    CAST(JSON_VALUE(@l_data_before, '$[0].date_expires_utc') AS VARCHAR(50)) as [old_value],
                    CAST(JSON_VALUE(@l_data_after, '$[0].date_expires_utc') AS VARCHAR(50)) as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].date_expires_utc') <> JSON_VALUE(@l_data_after, '$[0].date_expires_utc')
                   OR (JSON_VALUE(@l_data_before, '$[0].date_expires_utc') IS NULL AND JSON_VALUE(@l_data_after, '$[0].date_expires_utc') IS NOT NULL)
                   OR (JSON_VALUE(@l_data_before, '$[0].date_expires_utc') IS NOT NULL AND JSON_VALUE(@l_data_after, '$[0].date_expires_utc') IS NULL)
                UNION ALL
                SELECT 
                    'date_created_utc' as [field],
                    CAST(JSON_VALUE(@l_data_before, '$[0].date_created_utc') AS VARCHAR(50)) as [old_value],
                    CAST(JSON_VALUE(@l_data_after, '$[0].date_created_utc') AS VARCHAR(50)) as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].date_created_utc') <> JSON_VALUE(@l_data_after, '$[0].date_created_utc')
                   OR (JSON_VALUE(@l_data_before, '$[0].date_created_utc') IS NULL AND JSON_VALUE(@l_data_after, '$[0].date_created_utc') IS NOT NULL)
                   OR (JSON_VALUE(@l_data_before, '$[0].date_created_utc') IS NOT NULL AND JSON_VALUE(@l_data_after, '$[0].date_created_utc') IS NULL)
            )
            SELECT @l_diff_data = ( SELECT * FROM DiffData FOR JSON PATH );

            SET @l_action_type_id = 2;

            IF @p_donot_log = 0
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_log_id,
                    @p_source_system = '[auth].[sp_upsert_user_sessions]',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'user_sessions',
                    @p_object_id = @p_record_id,
                    @p_action_type_id = @l_action_type_id,
                    @p_status_code_id = 1,
                    @p_data_before = @l_data_before,
                    @p_data_after = @l_data_after,
                    @p_diff_data = @l_diff_data,
                    @p_message = 'Updated user_sessions',
                    @p_context_id = NULL,
                    @p_return_result_ok = @p_return_result_ok OUTPUT,
                    @p_return_result_message = @p_return_result_message OUTPUT,
                    @p_logging_id_out = @l_log_id OUTPUT;
                END
        END
        ELSE
        BEGIN
            -- For insert, we don't specify session_id as it's IDENTITY
            INSERT INTO auth.user_sessions
            (
                user_id,
                session_token,
                refresh_token,
                token_type,
                scope,
                id_token,
                identity_provider,
                date_expires_utc,
                date_created_utc,
                date_updated_utc
            )
            VALUES
            (
                @p_user_id,
                @p_session_token,
                @p_refresh_token,
                @p_token_type,
                @p_scope,
                @p_id_token,
                @p_identity_provider,
                @p_date_expires_utc,
                @p_date_created_utc,
                @l_current_time
            );

            -- Get the generated session_id for logging
            SET @p_record_id = SCOPE_IDENTITY();

            -- Capture data after insert
            SELECT @l_data_after = (
                SELECT *
                FROM auth.user_sessions 
                WHERE session_id = @p_record_id
                FOR JSON PATH
            );

            SET @l_action_type_id = 1;

            IF @p_donot_log = 0
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_log_id,
                    @p_source_system = '[auth].[sp_upsert_user_sessions]',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'user_sessions',
                    @p_object_id = @p_record_id,
                    @p_action_type_id = @l_action_type_id,
                    @p_status_code_id = 1,
                    @p_data_before = NULL,
                    @p_data_after = @l_data_after,
                    @p_diff_data = NULL,
                    @p_message = 'Inserted into user_sessions',
                    @p_context_id = NULL,
                    @p_return_result_ok = @p_return_result_ok OUTPUT,
                    @p_return_result_message = @p_return_result_message OUTPUT,
                    @p_logging_id_out = @l_log_id OUTPUT;
                END
        END

        SET @p_return_result_ok = 1;
        SET @p_return_result_message = 'Success';
    END TRY
    BEGIN CATCH
        DECLARE @l_err_message NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @l_err_number INT = ERROR_NUMBER();
        DECLARE @l_err_line INT = ERROR_LINE();
        DECLARE @l_err_procedure NVARCHAR(128) = ERROR_PROCEDURE();
        DECLARE @l_transaction_log_id UNIQUEIDENTIFIER = NEWID();

        SET @p_return_result_ok = 0;
        SET @p_return_result_message = @l_err_message;

        IF @p_donot_log = 0
        BEGIN
            EXEC core.sp_log_transaction
                @p_logging_id = @l_transaction_log_id,
                @p_source_system = '[auth].[sp_upsert_user_sessions]',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'user_sessions',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 2,
                @p_data_before = @l_data_before,
                @p_data_after = @l_data_after,
                @p_diff_data = @l_diff_data,
                @p_message = @l_err_message,
                @p_context_id = NULL,
                @p_return_result_ok = NULL,
                @p_return_result_message = NULL,
                @p_logging_id_out = @l_transaction_log_id OUTPUT;
        END
    END CATCH;
END; 