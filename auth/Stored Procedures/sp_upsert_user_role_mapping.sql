/***************************************************************************************
  Procedure: sp_upsert_user_role_mapping
  PK: mapping_id (INT)
***************************************************************************************/
CREATE PROCEDURE auth.sp_upsert_user_role_mapping
(
    @p_record_id INT = NULL,
    @p_created_by_user_id UNIQUEIDENTIFIER = NULL,
    @p_is_delete BIT = 0,

    -- Table-specific columns
    @p_user_id UNIQUEIDENTIFIER,
    @p_role_id INT,

    -- Logging
    @p_logging_id UNIQUEIDENTIFIER = NULL,

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

    DECLARE @l_log_id UNIQUEIDENTIFIER = ISNULL(@p_logging_id, NEWID());
    DECLARE @l_exists BIT = 0;
    DECLARE @l_action_type_id INT;
    DECLARE @l_data_before NVARCHAR(MAX) = NULL;
    DECLARE @l_data_after NVARCHAR(MAX) = NULL;
    DECLARE @l_diff_data NVARCHAR(MAX) = NULL;

    IF @p_record_id IS NOT NULL
       AND EXISTS(SELECT 1 FROM auth.user_role_mapping WHERE mapping_id = @p_record_id)
    BEGIN
        SET @l_exists = 1;
    END

    BEGIN TRY

        IF @p_is_delete = 1 AND @p_record_id IS NOT NULL AND @l_exists = 1
        BEGIN
            -- Get the user_id for logging before deletion
            DECLARE @l_user_id UNIQUEIDENTIFIER;
            SELECT @l_user_id = user_id 
            FROM auth.user_role_mapping 
            WHERE mapping_id = @p_record_id;

            -- Capture data before deletion
            SELECT @l_data_before = (
                SELECT 
                    mapping_id,
                    user_id,
                    role_id
                FROM auth.user_role_mapping 
                WHERE mapping_id = @p_record_id
                FOR JSON PATH
            );

            DELETE FROM auth.user_role_mapping
            WHERE mapping_id = @p_record_id;

            SET @l_action_type_id = 3;

            IF @l_data_before IS NOT NULL AND @l_data_before != '[]'
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_log_id,
                    @p_source_system = 'AUTH',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'user_role_mapping',
                    @p_object_id = @l_user_id,
                    @p_action_type_id = @l_action_type_id,
                    @p_status_code_id = 1,
                    @p_data_before = @l_data_before,
                    @p_data_after = NULL,
                    @p_diff_data = NULL,
                    @p_message = 'Deleted from user_role_mapping',
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
                    mapping_id,
                    user_id,
                    role_id
                FROM auth.user_role_mapping 
                WHERE mapping_id = @p_record_id
                FOR JSON PATH
            );

            UPDATE auth.user_role_mapping
            SET
                user_id = @p_user_id,
                role_id = @p_role_id
            WHERE mapping_id = @p_record_id;

            -- Capture data after update
            SELECT @l_data_after = (
                SELECT 
                    mapping_id,
                    user_id,
                    role_id
                FROM auth.user_role_mapping 
                WHERE mapping_id = @p_record_id
                FOR JSON PATH
            );

            -- Generate diff data
            WITH DiffData AS (
                SELECT 
                    'user_id' as [field],
                    JSON_VALUE(@l_data_before, '$[0].user_id') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].user_id') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].user_id') <> JSON_VALUE(@l_data_after, '$[0].user_id')
                UNION ALL
                SELECT 
                    'role_id' as [field],
                    JSON_VALUE(@l_data_before, '$[0].role_id') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].role_id') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].role_id') <> JSON_VALUE(@l_data_after, '$[0].role_id')
            )
            SELECT @l_diff_data = ( SELECT * FROM DiffData FOR JSON PATH );

            SET @l_action_type_id = 2;

            EXEC core.sp_log_transaction
                @p_logging_id = @l_log_id,
                @p_source_system = 'AUTH',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'user_role_mapping',
                @p_object_id = @p_user_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = @l_data_before,
                @p_data_after = @l_data_after,
                @p_diff_data = @l_diff_data,
                @p_message = 'Updated user_role_mapping',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_logging_id_out = @l_log_id OUTPUT;
        END
        ELSE
        BEGIN
            INSERT INTO auth.user_role_mapping
            (
                user_id,
                role_id
            )
            VALUES
            (
                @p_user_id,
                @p_role_id
            );

            SET @p_record_id = SCOPE_IDENTITY();

            -- Capture data after insert
            SELECT @l_data_after = (
                SELECT 
                    mapping_id,
                    user_id,
                    role_id
                FROM auth.user_role_mapping 
                WHERE mapping_id = @p_record_id
                FOR JSON PATH
            );

            SET @l_action_type_id = 1;

            EXEC core.sp_log_transaction
                @p_logging_id = @l_log_id,
                @p_source_system = 'AUTH',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'user_role_mapping',
                @p_object_id = @p_user_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = NULL,
                @p_data_after = @l_data_after,
                @p_diff_data = NULL,
                @p_message = 'Inserted into user_role_mapping',
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
            @p_object_name = 'user_role_mapping',
            @p_object_id = @p_user_id,
            @p_action_type_id = 4, -- Error
            @p_status_code_id = 2, -- Error
            @p_data_before = NULL,
            @p_data_after = NULL,
            @p_diff_data = NULL,
            @p_message = @p_return_result_message,
            @p_context_id = NULL,
            @p_return_result_ok = @p_return_result_ok OUTPUT,
            @p_return_result_message = @p_return_result_message OUTPUT,
            @p_logging_id_out = @l_transaction_log_id OUTPUT;
    END CATCH
END 