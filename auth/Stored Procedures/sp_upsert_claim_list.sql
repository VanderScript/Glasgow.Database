/***************************************************************************************
  Procedure: sp_upsert_claim_list
  PK: claim_id (INT - IDENTITY)
***************************************************************************************/
CREATE PROCEDURE auth.sp_upsert_claim_list
(
    @p_record_id INT = NULL,
    @p_created_by_user_id UNIQUEIDENTIFIER = NULL,
    @p_is_delete BIT = 0,
    @p_donot_log BIT = 0,

    -- Table-specific columns
    @p_claim_name VARCHAR(32),

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
       AND EXISTS(SELECT 1 FROM auth.claim_list WHERE claim_id = @p_record_id)
    BEGIN
        SET @l_exists = 1;
    END

    BEGIN TRY
        IF @p_is_delete = 1 AND @p_record_id IS NOT NULL AND @l_exists = 1
        BEGIN
            -- Check for role_claim_mapping dependencies before delete
            IF EXISTS (SELECT 1 FROM auth.role_claim_mapping WHERE claim_id = @p_record_id)
            BEGIN
                SET @p_return_result_ok = 0;
                SET @p_return_result_message = 'Cannot delete claim because it is referenced by role_claim_mapping records.';

                IF @p_donot_log = 0
                BEGIN
                    EXEC core.sp_log_transaction
                        @p_logging_id = @l_log_id,
                        @p_source_system = '[auth].[sp_upsert_claim_list]',
                        @p_user_id = @p_created_by_user_id,
                        @p_object_name = 'claim_list',
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
                        @p_logging_id_out = @l_log_id OUTPUT;
                END
                RETURN;
            END

            -- Capture data before delete
            SELECT @l_data_before = (
                SELECT 
                    claim_id,
                    claim_name
                FROM auth.claim_list 
                WHERE claim_id = @p_record_id
                FOR JSON PATH
            );
            
            DELETE FROM auth.claim_list
            WHERE claim_id = @p_record_id;

            SET @l_action_type_id = 3;

            IF @p_donot_log = 0
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_log_id,
                    @p_source_system = '[auth].[sp_upsert_claim_list]',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'claim_list',
                    @p_object_id = @p_record_id,
                    @p_action_type_id = @l_action_type_id,
                    @p_status_code_id = 1,
                    @p_data_before = @l_data_before,
                    @p_data_after = NULL,
                    @p_diff_data = NULL,
                    @p_message = 'Deleted from claim_list',
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
                    claim_id,
                    claim_name
                FROM auth.claim_list 
                WHERE claim_id = @p_record_id
                FOR JSON PATH
            );

            UPDATE auth.claim_list
            SET
                claim_name = @p_claim_name
            WHERE claim_id = @p_record_id;

            -- Capture data after update
            SELECT @l_data_after = (
                SELECT 
                    claim_id,
                    claim_name
                FROM auth.claim_list 
                WHERE claim_id = @p_record_id
                FOR JSON PATH
            );

            -- Generate diff data
            WITH DiffData AS (
                SELECT 
                    'claim_name' as [field],
                    JSON_VALUE(@l_data_before, '$[0].claim_name') as [old_value],
                    JSON_VALUE(@l_data_after, '$[0].claim_name') as [new_value]
                WHERE JSON_VALUE(@l_data_before, '$[0].claim_name') <> JSON_VALUE(@l_data_after, '$[0].claim_name')
                    OR (JSON_VALUE(@l_data_before, '$[0].claim_name') IS NULL AND JSON_VALUE(@l_data_after, '$[0].claim_name') IS NOT NULL)
                    OR (JSON_VALUE(@l_data_before, '$[0].claim_name') IS NOT NULL AND JSON_VALUE(@l_data_after, '$[0].claim_name') IS NULL)
            )
            SELECT @l_diff_data = ( SELECT * FROM DiffData FOR JSON PATH );

            SET @l_action_type_id = 2;

            IF @p_donot_log = 0
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_log_id,
                    @p_source_system = '[auth].[sp_upsert_claim_list]',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'claim_list',
                    @p_object_id = @p_record_id,
                    @p_action_type_id = @l_action_type_id,
                    @p_status_code_id = 1,
                    @p_data_before = @l_data_before,
                    @p_data_after = @l_data_after,
                    @p_diff_data = @l_diff_data,
                    @p_message = 'Updated claim_list',
                    @p_context_id = NULL,
                    @p_return_result_ok = @p_return_result_ok OUTPUT,
                    @p_return_result_message = @p_return_result_message OUTPUT,
                    @p_logging_id_out = @l_log_id OUTPUT;
            END
        END
        ELSE
        BEGIN
            -- For insert, we don't specify claim_id as it's IDENTITY
            INSERT INTO auth.claim_list
            (
                claim_name
            )
            VALUES
            (
                @p_claim_name
            );

            -- Get the generated claim_id for logging
            SET @p_record_id = SCOPE_IDENTITY();

            -- Capture data after insert
            SELECT @l_data_after = (
                SELECT 
                    claim_id,
                    claim_name
                FROM auth.claim_list 
                WHERE claim_id = @p_record_id
                FOR JSON PATH
            );

            SET @l_action_type_id = 1;

            IF @p_donot_log = 0
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_log_id,
                    @p_source_system = '[auth].[sp_upsert_claim_list]',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'claim_list',
                    @p_object_id = @p_record_id,
                    @p_action_type_id = @l_action_type_id,
                    @p_status_code_id = 1,
                    @p_data_before = NULL,
                    @p_data_after = @l_data_after,
                    @p_diff_data = NULL,
                    @p_message = 'Inserted into claim_list',
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
        SET @p_return_result_message = CONCAT(
            'Error: ', @l_err_message,
            ' (Line ', @l_err_line,
            ', Procedure: ', ISNULL(@l_err_procedure,'N/A'),
            ', Error: ', @l_err_number, ')'
        );

        IF @p_donot_log = 0
        BEGIN
            EXEC core.sp_log_transaction
                @p_logging_id = @l_transaction_log_id,
                @p_source_system = '[auth].[sp_upsert_claim_list]',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'claim_list',
                @p_object_id = @p_record_id,
                @p_action_type_id = 4, -- Error
                @p_status_code_id = 2, -- Error
                @p_data_before = NULL,
                @p_data_after = NULL,
                @p_diff_data = NULL,
                @p_message = @p_return_result_message,
                @p_context_id = NULL,
                @p_return_result_ok = NULL,
                @p_return_result_message = NULL,
                @p_logging_id_out = @l_transaction_log_id OUTPUT;
        END
    END CATCH
END; 