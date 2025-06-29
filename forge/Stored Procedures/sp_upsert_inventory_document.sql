CREATE PROCEDURE forge.sp_upsert_inventory_document
(
    -- Procedure-level control
    @p_record_id UNIQUEIDENTIFIER = NULL,      -- PK for inventory_document
    @p_caller_user_id UNIQUEIDENTIFIER = NULL, -- The user executing this procedure
    @p_is_delete BIT = 0,                     -- Add/Update if 0, Delete if 1

    -- Table columns
    @p_document_code VARCHAR(100),
    @p_status VARCHAR(50),                    -- e.g., 'OPEN', 'IN_PROGRESS', 'COMPLETED'
    @p_date_created_utc DATETIME = NULL,
    @p_date_updated_utc DATETIME = NULL,
    @p_date_completed_utc DATETIME = NULL,

    @p_created_by_user_id UNIQUEIDENTIFIER = NULL,   -- Column: who originally created doc
    @p_completed_by_user_id UNIQUEIDENTIFIER = NULL, -- Column: who completed doc

    -- Outputs
    @p_return_result_ok BIT OUTPUT,
    @p_return_result_message NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Default to NONE user if no caller user ID is provided
    IF @p_caller_user_id IS NULL
        SET @p_caller_user_id = '00000000-0000-0000-0000-000000000001'; -- NONE user

    /***************************************************************************
     * Local variable declarations
     **************************************************************************/
    DECLARE @l_log_id UNIQUEIDENTIFIER = NEWID();  -- For logging
    DECLARE @l_exists BIT = 0;                     -- If record found
    DECLARE @l_action_type_id INT;                 -- 1=Create, 2=Update, 3=Delete

    /***************************************************************************
     * Existence check
     **************************************************************************/
    IF @p_record_id IS NOT NULL
       AND EXISTS (SELECT 1 FROM forge.inventory_document WHERE inventory_document_id = @p_record_id)
    BEGIN
        SET @l_exists = 1;
    END

    BEGIN TRY
        /***************************************************************************
         * Delete logic
         **************************************************************************/
        IF @p_is_delete = 1 AND @p_record_id IS NOT NULL AND @l_exists = 1
        BEGIN
            DELETE FROM forge.inventory_document
            WHERE inventory_document_id = @p_record_id;

            SET @l_action_type_id = 3; -- DELETE

            -- Log success
            EXEC core.sp_log_transaction
                @p_transaction_log_id = @l_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_caller_user_id,
                @p_object_name = 'inventory_document',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,       -- SUCCESS
                @p_data_before = NULL,
                @p_data_after = NULL,
                @p_diff_data = NULL,
                @p_message = 'Deleted inventory_document record',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_loggingid = @l_log_id OUTPUT;
        END
        /***************************************************************************
         * Update logic
         **************************************************************************/
        ELSE IF @l_exists = 1
        BEGIN
            UPDATE forge.inventory_document
            SET
                document_code = @p_document_code,
                status = @p_status,
                date_created_utc = @p_date_created_utc,
                date_updated_utc = @p_date_updated_utc,
                date_completed_utc = @p_date_completed_utc,
                created_by_user_id = @p_created_by_user_id,
                completed_by_user_id = @p_completed_by_user_id
            WHERE inventory_document_id = @p_record_id;

            SET @l_action_type_id = 2; -- UPDATE

            -- Log success
            EXEC core.sp_log_transaction
                @p_transaction_log_id = @l_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_caller_user_id,
                @p_object_name = 'inventory_document',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,       -- SUCCESS
                @p_data_before = NULL,
                @p_data_after = NULL,
                @p_diff_data = NULL,
                @p_message = 'Updated inventory_document record',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_loggingid = @l_log_id OUTPUT;
        END
        /***************************************************************************
         * Insert logic
         **************************************************************************/
        ELSE
        BEGIN
            IF @p_record_id IS NULL
                SET @p_record_id = NEWID();

            INSERT INTO forge.inventory_document
            (
                inventory_document_id,
                document_code,
                status,
                date_created_utc,
                date_updated_utc,
                date_completed_utc,
                created_by_user_id,
                completed_by_user_id
            )
            VALUES
            (
                @p_record_id,
                @p_document_code,
                @p_status,
                @p_date_created_utc,
                @p_date_updated_utc,
                @p_date_completed_utc,
                @p_created_by_user_id,
                @p_completed_by_user_id
            );

            SET @l_action_type_id = 1; -- CREATE

            -- Log success
            EXEC core.sp_log_transaction
                @p_transaction_log_id = @l_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_caller_user_id,
                @p_object_name = 'inventory_document',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,   -- SUCCESS
                @p_data_before = NULL,
                @p_data_after = NULL,
                @p_diff_data = NULL,
                @p_message = 'Inserted inventory_document record',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_loggingid = @l_log_id OUTPUT;
        END

    END TRY
    /***************************************************************************
     * CATCH block: handle failures
     **************************************************************************/
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

        -- Decide action type based on what we were attempting
        SET @l_action_type_id = CASE
            WHEN @p_is_delete = 1 THEN 3   -- was trying to delete
            WHEN @l_exists = 1 THEN 2      -- was trying to update
            ELSE 1                         -- was trying to insert
        END;

        -- Attempt to log the fail
        BEGIN TRY
            EXEC core.sp_log_transaction
                @p_transaction_log_id = @l_transaction_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_caller_user_id,
                @p_object_name = 'inventory_document',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 2,  -- FAILED
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
            -- Suppress nested logging failure to avoid recursion
        END CATCH
    END CATCH
END;

