/***************************************************************************************
  Procedure: sp_upsert_roles
  PK: role_id (INT - IDENTITY)
***************************************************************************************/
CREATE PROCEDURE auth.sp_upsert_roles
(
    @p_record_id INT = NULL,
    @p_created_by_user_id UNIQUEIDENTIFIER = NULL,
    @p_is_delete BIT = 0,

    -- Table-specific columns
    @p_role VARCHAR(32),

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
       AND EXISTS(SELECT 1 FROM auth.roles WHERE role_id = @p_record_id)
    BEGIN
        SET @l_exists = 1;
    END

    BEGIN TRY

        IF @p_is_delete = 1 AND @p_record_id IS NOT NULL AND @l_exists = 1
        BEGIN
            -- Capture data before deletion
            SELECT @l_data_before = (
                SELECT 
                    role_id,
                    role
                FROM auth.roles 
                WHERE role_id = @p_record_id
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            );

            -- Cascading deletes - clean up related records first
            DELETE FROM auth.user_role_mapping WHERE role_id = @p_record_id;
            DELETE FROM auth.role_claim_mapping WHERE role_id = @p_record_id;
            
            -- Delete the role
            DELETE FROM auth.roles
            WHERE role_id = @p_record_id;

            SET @l_action_type_id = 3;

            EXEC core.sp_log_transaction
                @p_transaction_log_id = @l_log_id,
                @p_source_system = 'AUTH',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'roles',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = @l_data_before,
                @p_data_after = NULL,
                @p_diff_data = NULL,
                @p_message = 'Deleted from roles (with cascading deletes)',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_loggingid = @l_log_id OUTPUT;
        END
        ELSE IF @l_exists = 1
        BEGIN
            -- Capture data before update
            SELECT @l_data_before = (
                SELECT 
                    role_id,
                    role
                FROM auth.roles 
                WHERE role_id = @p_record_id
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            );

            UPDATE auth.roles
            SET
                role = @p_role
            WHERE role_id = @p_record_id;

            -- Capture data after update
            SELECT @l_data_after = (
                SELECT 
                    role_id,
                    role
                FROM auth.roles 
                WHERE role_id = @p_record_id
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            );

            -- Generate diff data
            SET @l_diff_data = (
                SELECT 
                    'role' as [field],
                    JSON_VALUE(@l_data_before, '$.role') as [old_value],
                    JSON_VALUE(@l_data_after, '$.role') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$.role') <> JSON_VALUE(@l_data_after, '$.role')
                FOR JSON PATH
            );

            SET @l_action_type_id = 2;

            EXEC core.sp_log_transaction
                @p_transaction_log_id = @l_log_id,
                @p_source_system = 'AUTH',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'roles',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = @l_data_before,
                @p_data_after = @l_data_after,
                @p_diff_data = @l_diff_data,
                @p_message = 'Updated roles',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_loggingid = @l_log_id OUTPUT;
        END
        ELSE
        BEGIN
            -- For insert, we don't specify role_id as it's IDENTITY
            INSERT INTO auth.roles
            (
                role
            )
            VALUES
            (
                @p_role
            );

            -- Get the generated role_id for logging
            SET @p_record_id = SCOPE_IDENTITY();

            -- Capture data after insert
            SELECT @l_data_after = (
                SELECT 
                    role_id,
                    role
                FROM auth.roles 
                WHERE role_id = @p_record_id
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            );

            SET @l_action_type_id = 1;

            EXEC core.sp_log_transaction
                @p_transaction_log_id = @l_log_id,
                @p_source_system = 'AUTH',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'roles',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = NULL,
                @p_data_after = @l_data_after,
                @p_diff_data = NULL,
                @p_message = 'Inserted into roles',
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
                @p_source_system = 'AUTH',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'roles',
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