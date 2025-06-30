/***************************************************************************************
  Procedure: sp_upsert_users
  PK: user_id (UNIQUEIDENTIFIER)
***************************************************************************************/
CREATE PROCEDURE auth.sp_upsert_users
(
    @p_record_id UNIQUEIDENTIFIER = NULL,
    @p_created_by_user_id UNIQUEIDENTIFIER = NULL,
    @p_is_delete BIT = 0,

    -- Table-specific columns
    @p_username VARCHAR(32),
    @p_email VARCHAR(255) = NULL,
    @p_email_verified BIT = 0,
    @p_full_name VARCHAR(255) = NULL,
    @p_password_hash VARCHAR(244) = NULL,
    @p_password_salt VARCHAR(244) = NULL,
    @p_external_id VARCHAR(255) = NULL,
    @p_identity_provider VARCHAR(50) = NULL,
    @p_is_active BIT = 1,

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
    DECLARE @l_data_before NVARCHAR(MAX) = NULL;
    DECLARE @l_data_after NVARCHAR(MAX) = NULL;
    DECLARE @l_diff_data NVARCHAR(MAX) = NULL;
    DECLARE @l_current_time DATETIME2 = GETUTCDATE();

    IF @p_record_id IS NOT NULL
       AND EXISTS(SELECT 1 FROM auth.users WHERE user_id = @p_record_id)
    BEGIN
        SET @l_exists = 1;
    END

    BEGIN TRY
        IF @p_is_delete = 1 AND @p_record_id IS NOT NULL AND @l_exists = 1
        BEGIN
            -- Delete user_sessions records and log them
            SELECT @l_data_before = (
                SELECT *
                FROM auth.user_sessions 
                WHERE user_id = @p_record_id
                FOR JSON PATH
            );
            
            DELETE FROM auth.user_sessions WHERE user_id = @p_record_id;
            
            -- Log user_sessions deletes if any existed
            IF @l_data_before IS NOT NULL AND @l_data_before != '[]'
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_log_id,
                    @p_source_system = 'AUTH',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'user_sessions',
                    @p_object_id = @p_record_id,
                    @p_action_type_id = 3,
                    @p_status_code_id = 1,
                    @p_data_before = @l_data_before,
                    @p_data_after = NULL,
                    @p_diff_data = NULL,
                    @p_message = 'Deleted user_sessions records for user',
                    @p_context_id = NULL,
                    @p_return_result_ok = @p_return_result_ok OUTPUT,
                    @p_return_result_message = @p_return_result_message OUTPUT,
                    @p_logging_id_out = @l_log_id OUTPUT;
            END

            -- Reset the @l_data_before variable
            SET @l_data_before = NULL;

            -- Delete user_role_mapping records and log them
            SELECT @l_data_before = (
                SELECT *
                FROM auth.user_role_mapping 
                WHERE user_id = @p_record_id
                FOR JSON PATH
            );
            
            DELETE FROM auth.user_role_mapping WHERE user_id = @p_record_id;
            
            -- Log user_role_mapping deletes if any existed
            IF @l_data_before IS NOT NULL AND @l_data_before != '[]'
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_log_id,
                    @p_source_system = 'AUTH',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'user_role_mapping',
                    @p_object_id = @p_record_id,
                    @p_action_type_id = 3,
                    @p_status_code_id = 1,
                    @p_data_before = @l_data_before,
                    @p_data_after = NULL,
                    @p_diff_data = NULL,
                    @p_message = 'Deleted user_role_mapping records for user',
                    @p_context_id = NULL,
                    @p_return_result_ok = @p_return_result_ok OUTPUT,
                    @p_return_result_message = @p_return_result_message OUTPUT,
                    @p_logging_id_out = @l_log_id OUTPUT;
            END

            -- Reset the @l_data_before variable
            SET @l_data_before = NULL;
            
            -- Delete the user and log it
            SELECT @l_data_before = (
                SELECT *
                FROM auth.users 
                WHERE user_id = @p_record_id
                FOR JSON PATH
            );
            
            DELETE FROM auth.users
            WHERE user_id = @p_record_id;

            SET @l_action_type_id = 3;

            IF @l_data_before IS NOT NULL AND @l_data_before != '[]'
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_log_id,
                    @p_source_system = 'AUTH',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'users',
                    @p_object_id = @p_record_id,
                    @p_action_type_id = @l_action_type_id,
                    @p_status_code_id = 1,
                    @p_data_before = @l_data_before,
                    @p_data_after = NULL,
                    @p_diff_data = NULL,
                    @p_message = 'Deleted from users',
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
                FROM auth.users 
                WHERE user_id = @p_record_id
                FOR JSON PATH
            );

            UPDATE auth.users
            SET
                username = @p_username,
                email = @p_email,
                email_verified = @p_email_verified,
                full_name = @p_full_name,
                password_hash = @p_password_hash,
                password_salt = @p_password_salt,
                external_id = @p_external_id,
                identity_provider = @p_identity_provider,
                is_active = @p_is_active,
                date_updated_utc = @l_current_time
            WHERE user_id = @p_record_id;

            -- Capture data after update
            SELECT @l_data_after = (
                SELECT *
                FROM auth.users 
                WHERE user_id = @p_record_id
                FOR JSON PATH
            );

            -- Generate diff data
            WITH DiffData AS (
                SELECT 
                    'username' as [field],
                    JSON_VALUE(@l_data_before, '$[0].username') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].username') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].username') <> JSON_VALUE(@l_data_after, '$[0].username')
                   OR (JSON_VALUE(@l_data_before, '$[0].username') IS NULL AND JSON_VALUE(@l_data_after, '$[0].username') IS NOT NULL)
                   OR (JSON_VALUE(@l_data_before, '$[0].username') IS NOT NULL AND JSON_VALUE(@l_data_after, '$[0].username') IS NULL)
                UNION ALL
                SELECT 
                    'email' as [field],
                    JSON_VALUE(@l_data_before, '$[0].email') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].email') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].email') <> JSON_VALUE(@l_data_after, '$[0].email')
                   OR (JSON_VALUE(@l_data_before, '$[0].email') IS NULL AND JSON_VALUE(@l_data_after, '$[0].email') IS NOT NULL)
                   OR (JSON_VALUE(@l_data_before, '$[0].email') IS NOT NULL AND JSON_VALUE(@l_data_after, '$[0].email') IS NULL)
                UNION ALL
                SELECT 
                    'email_verified' as [field],
                    CAST(JSON_VALUE(@l_data_before, '$[0].email_verified') AS VARCHAR(5)) as [old_value],
                    CAST(JSON_VALUE(@l_data_after, '$[0].email_verified') AS VARCHAR(5)) as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].email_verified') <> JSON_VALUE(@l_data_after, '$[0].email_verified')
                   OR (JSON_VALUE(@l_data_before, '$[0].email_verified') IS NULL AND JSON_VALUE(@l_data_after, '$[0].email_verified') IS NOT NULL)
                   OR (JSON_VALUE(@l_data_before, '$[0].email_verified') IS NOT NULL AND JSON_VALUE(@l_data_after, '$[0].email_verified') IS NULL)
                UNION ALL
                SELECT 
                    'full_name' as [field],
                    JSON_VALUE(@l_data_before, '$[0].full_name') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].full_name') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].full_name') <> JSON_VALUE(@l_data_after, '$[0].full_name')
                   OR (JSON_VALUE(@l_data_before, '$[0].full_name') IS NULL AND JSON_VALUE(@l_data_after, '$[0].full_name') IS NOT NULL)
                   OR (JSON_VALUE(@l_data_before, '$[0].full_name') IS NOT NULL AND JSON_VALUE(@l_data_after, '$[0].full_name') IS NULL)
                UNION ALL
                SELECT 
                    'password_hash' as [field],
                    JSON_VALUE(@l_data_before, '$[0].password_hash') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].password_hash') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].password_hash') <> JSON_VALUE(@l_data_after, '$[0].password_hash')
                   OR (JSON_VALUE(@l_data_before, '$[0].password_hash') IS NULL AND JSON_VALUE(@l_data_after, '$[0].password_hash') IS NOT NULL)
                   OR (JSON_VALUE(@l_data_before, '$[0].password_hash') IS NOT NULL AND JSON_VALUE(@l_data_after, '$[0].password_hash') IS NULL)
                UNION ALL
                SELECT 
                    'password_salt' as [field],
                    JSON_VALUE(@l_data_before, '$[0].password_salt') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].password_salt') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].password_salt') <> JSON_VALUE(@l_data_after, '$[0].password_salt')
                   OR (JSON_VALUE(@l_data_before, '$[0].password_salt') IS NULL AND JSON_VALUE(@l_data_after, '$[0].password_salt') IS NOT NULL)
                   OR (JSON_VALUE(@l_data_before, '$[0].password_salt') IS NOT NULL AND JSON_VALUE(@l_data_after, '$[0].password_salt') IS NULL)
                UNION ALL
                SELECT 
                    'external_id' as [field],
                    JSON_VALUE(@l_data_before, '$[0].external_id') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].external_id') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].external_id') <> JSON_VALUE(@l_data_after, '$[0].external_id')
                   OR (JSON_VALUE(@l_data_before, '$[0].external_id') IS NULL AND JSON_VALUE(@l_data_after, '$[0].external_id') IS NOT NULL)
                   OR (JSON_VALUE(@l_data_before, '$[0].external_id') IS NOT NULL AND JSON_VALUE(@l_data_after, '$[0].external_id') IS NULL)
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
                    'is_active' as [field],
                    CAST(JSON_VALUE(@l_data_before, '$[0].is_active') AS VARCHAR(5)) as [old_value],
                    CAST(JSON_VALUE(@l_data_after, '$[0].is_active') AS VARCHAR(5)) as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].is_active') <> JSON_VALUE(@l_data_after, '$[0].is_active')
                   OR (JSON_VALUE(@l_data_before, '$[0].is_active') IS NULL AND JSON_VALUE(@l_data_after, '$[0].is_active') IS NOT NULL)
                   OR (JSON_VALUE(@l_data_before, '$[0].is_active') IS NOT NULL AND JSON_VALUE(@l_data_after, '$[0].is_active') IS NULL)
            )
            SELECT @l_diff_data = ( SELECT * FROM DiffData FOR JSON PATH );

            SET @l_action_type_id = 2;

            EXEC core.sp_log_transaction
                @p_logging_id = @l_log_id,
                @p_source_system = 'AUTH',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'users',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = @l_data_before,
                @p_data_after = @l_data_after,
                @p_diff_data = @l_diff_data,
                @p_message = 'Updated users',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_logging_id_out = @l_log_id OUTPUT;
        END
        ELSE
        BEGIN
            -- Generate new GUID for insert
            IF @p_record_id IS NULL
                SET @p_record_id = NEWID();

            INSERT INTO auth.users
            (
                user_id,
                username,
                email,
                email_verified,
                full_name,
                password_hash,
                password_salt,
                external_id,
                identity_provider,
                is_active,
                date_created_utc,
                date_updated_utc
            )
            VALUES
            (
                @p_record_id,
                @p_username,
                @p_email,
                @p_email_verified,
                @p_full_name,
                @p_password_hash,
                @p_password_salt,
                @p_external_id,
                @p_identity_provider,
                @p_is_active,
                @l_current_time,
                @l_current_time
            );

            -- Create default role mapping for new user using the dedicated procedure
            -- Note: This is safe because both operations are in the same transaction scope
            -- The user INSERT above ensures the user_id exists for the FK constraint
            DECLARE @l_role_result_ok BIT;
            DECLARE @l_role_result_message NVARCHAR(MAX);
            
            EXEC auth.sp_upsert_user_role_mapping
                @p_created_by_user_id = '00000000-0000-0000-0000-000000000002', -- SYSTEM user
                @p_user_id = @p_record_id,
                @p_role_id = 1, -- Role ID for 'NONE'
                @p_logging_id = @l_log_id, -- Use same logging ID for traceability
                @p_return_result_ok = @l_role_result_ok OUTPUT,
                @p_return_result_message = @l_role_result_message OUTPUT;

            -- Capture data after insert
            SELECT @l_data_after = (
                SELECT *
                FROM auth.users 
                WHERE user_id = @p_record_id
                FOR JSON PATH
            );

            SET @l_action_type_id = 1;

            EXEC core.sp_log_transaction
                @p_logging_id = @l_log_id,
                @p_source_system = 'AUTH',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'users',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = NULL,
                @p_data_after = @l_data_after,
                @p_diff_data = NULL,
                @p_message = 'Inserted into users',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_logging_id_out = @l_log_id OUTPUT;
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

        EXEC core.sp_log_transaction
            @p_logging_id = @l_transaction_log_id,
            @p_source_system = 'AUTH',
            @p_user_id = @p_created_by_user_id,
            @p_object_name = 'users',
            @p_object_id = @p_record_id,
            @p_action_type_id = @l_action_type_id,
            @p_status_code_id = 2,
            @p_data_before = @l_data_before,
            @p_data_after = @l_data_after,
            @p_diff_data = @l_diff_data,
            @p_message = @l_err_message,
            @p_context_id = NULL,
            @p_return_result_ok = NULL ,
            @p_return_result_message = NULL ,
            @p_logging_id_out = @l_transaction_log_id OUTPUT;
    END CATCH;
END; 