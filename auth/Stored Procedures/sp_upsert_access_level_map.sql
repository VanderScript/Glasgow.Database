/***************************************************************************************
  Procedure: sp_upsert_access_level_map
  PK: access_level_id (INT - IDENTITY)
***************************************************************************************/
CREATE PROCEDURE auth.sp_upsert_access_level_map
(
    @p_record_id INT = NULL,
    @p_created_by_user_id UNIQUEIDENTIFIER = NULL,
    @p_is_delete BIT = 0,

    -- Table-specific columns
    @p_level INT,
    @p_lvl_description VARCHAR(32),

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
       AND EXISTS(SELECT 1 FROM auth.access_level_map WHERE access_level_id = @p_record_id)
    BEGIN
        SET @l_exists = 1;
    END

    BEGIN TRY
        IF @p_is_delete = 1 AND @p_record_id IS NOT NULL AND @l_exists = 1
        BEGIN
            -- Capture data before delete
            SELECT @l_data_before = (
                SELECT 
                    access_level_id,
                    [level],
                    lvl_description
                FROM auth.access_level_map 
                WHERE access_level_id = @p_record_id
                FOR JSON PATH
            );
            
            DELETE FROM auth.access_level_map
            WHERE access_level_id = @p_record_id;

            SET @l_action_type_id = 3;

            EXEC core.sp_log_transaction
                @p_logging_id = @l_log_id,
                @p_source_system = 'AUTH',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'access_level_map',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = @l_data_before,
                @p_data_after = NULL,
                @p_diff_data = NULL,
                @p_message = 'Deleted from access_level_map',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_logging_id_out = @l_log_id OUTPUT;
        END
        ELSE IF @l_exists = 1
        BEGIN
            -- Capture data before update
            SELECT @l_data_before = (
                SELECT 
                    access_level_id,
                    [level],
                    lvl_description
                FROM auth.access_level_map 
                WHERE access_level_id = @p_record_id
                FOR JSON PATH
            );

            UPDATE auth.access_level_map
            SET
                [level] = @p_level,
                lvl_description = @p_lvl_description
            WHERE access_level_id = @p_record_id;

            -- Capture data after update
            SELECT @l_data_after = (
                SELECT 
                    access_level_id,
                    [level],
                    lvl_description
                FROM auth.access_level_map 
                WHERE access_level_id = @p_record_id
                FOR JSON PATH
            );

            -- Generate diff data
            WITH DiffData AS (
                SELECT 
                    'level' as [field],
                    CAST(JSON_VALUE(@l_data_before, '$[0].level') AS VARCHAR(32)) as [old_value],
                    CAST(JSON_VALUE(@l_data_after, '$[0].level') AS VARCHAR(32)) as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].level') <> JSON_VALUE(@l_data_after, '$[0].level')
                UNION ALL
                SELECT 
                    'lvl_description' as [field],
                    JSON_VALUE(@l_data_before, '$[0].lvl_description') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].lvl_description') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].lvl_description') <> JSON_VALUE(@l_data_after, '$[0].lvl_description')
            )
            SELECT @l_diff_data = ( SELECT * FROM DiffData FOR JSON PATH );

            SET @l_action_type_id = 2;

            EXEC core.sp_log_transaction
                @p_logging_id = @l_log_id,
                @p_source_system = 'AUTH',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'access_level_map',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = @l_data_before,
                @p_data_after = @l_data_after,
                @p_diff_data = @l_diff_data,
                @p_message = 'Updated access_level_map',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_logging_id_out = @l_log_id OUTPUT;
        END
        ELSE
        BEGIN
            -- For insert, we don't specify access_level_id as it's IDENTITY
            INSERT INTO auth.access_level_map
            (
                [level],
                lvl_description
            )
            VALUES
            (
                @p_level,
                @p_lvl_description
            );

            -- Get the generated access_level_id for logging
            SET @p_record_id = SCOPE_IDENTITY();

            -- Capture data after insert
            SELECT @l_data_after = (
                SELECT 
                    access_level_id,
                    [level],
                    lvl_description
                FROM auth.access_level_map 
                WHERE access_level_id = @p_record_id
                FOR JSON PATH
            );

            SET @l_action_type_id = 1;

            EXEC core.sp_log_transaction
                @p_logging_id = @l_log_id,
                @p_source_system = 'AUTH',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'access_level_map',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = NULL,
                @p_data_after = @l_data_after,
                @p_diff_data = NULL,
                @p_message = 'Inserted into access_level_map',
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
            @p_object_name = 'access_level_map',
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
            @p_logging_id_out = @l_transaction_log_id OUTPUT;

        THROW;
    END CATCH
END; 