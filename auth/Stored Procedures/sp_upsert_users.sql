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
    @p_password_hash VARCHAR(244),
    @p_password_salt VARCHAR(244),

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
                SELECT 
                    session_id,
                    user_id,
                    session_token,
                    date_created_utc,
                    date_expires_utc
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
                SELECT 
                    mapping_id,
                    user_id,
                    role_id
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
                SELECT 
                    user_id,
                    username,
                    password_hash,
                    password_salt
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
                SELECT 
                    user_id,
                    username,
                    password_hash,
                    password_salt
                FROM auth.users 
                WHERE user_id = @p_record_id
                FOR JSON PATH
            );

            UPDATE auth.users
            SET
                username = @p_username,
                password_hash = @p_password_hash,
                password_salt = @p_password_salt
            WHERE user_id = @p_record_id;

            -- Capture data after update
            SELECT @l_data_after = (
                SELECT 
                    user_id,
                    username,
                    password_hash,
                    password_salt
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
                UNION ALL
                SELECT 
                    'password_hash' as [field],
                    JSON_VALUE(@l_data_before, '$[0].password_hash') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].password_hash') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].password_hash') <> JSON_VALUE(@l_data_after, '$[0].password_hash')
                UNION ALL
                SELECT 
                    'password_salt' as [field],
                    JSON_VALUE(@l_data_before, '$[0].password_salt') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].password_salt') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].password_salt') <> JSON_VALUE(@l_data_after, '$[0].password_salt')
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
                password_hash,
                password_salt
            )
            VALUES
            (
                @p_record_id,
                @p_username,
                @p_password_hash,
                @p_password_salt
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
                @p_loggingid = @l_log_id, -- Use same logging ID for traceability
                @p_return_result_ok = @l_role_result_ok OUTPUT,
                @p_return_result_message = @l_role_result_message OUTPUT;

            -- Capture data after insert
            SELECT @l_data_after = (
                SELECT 
                    user_id,
                    username,
                    password_hash,
                    password_salt
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

        EXEC core.sp_log_transaction
            @p_logging_id = @l_transaction_log_id,
            @p_source_system = 'AUTH',
            @p_user_id = @p_created_by_user_id,
            @p_object_name = 'users',
            @p_object_id = @p_record_id,
            @p_action_type_id = 4, -- Error
            @p_status_code_id = 2, -- Error
            @p_data_before = NULL,
            @p_data_after = NULL,
            @p_diff_data = NULL,
            @p_message = @p_return_result_message,
            @p_context_id = NULL,
            @p_return_result_ok = @p_return_result_ok OUTPUT,
            @p_return_result_message = @p_return_result_message OUTPUT,
            @p_loggingid_out = @l_transaction_log_id OUTPUT;
    END CATCH
END 