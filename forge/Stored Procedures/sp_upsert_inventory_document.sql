CREATE PROCEDURE forge.sp_upsert_inventory_document
(
    -- Procedure-level control
    @p_record_id UNIQUEIDENTIFIER = NULL,      -- PK for inventory_document
    @p_caller_user_id UNIQUEIDENTIFIER = NULL, -- The user executing this procedure
    @p_is_delete BIT = 0,                     -- Add/Update if 0, Delete if 1

    -- Table columns
    @p_document_number VARCHAR(100),
    @p_inventory_status_id INT,
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
    DECLARE @l_data_before NVARCHAR(MAX);             -- For capturing data before deletion
    DECLARE @l_data_after NVARCHAR(MAX);              -- For capturing data after update or insert
    DECLARE @l_diff_data NVARCHAR(MAX);               -- For capturing diff data

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
            -- Capture data before deletion
            SELECT @l_data_before = (
                SELECT 
                    inventory_document_id,
                    document_number,
                    inventory_status_id,
                    date_created_utc,
                    date_updated_utc,
                    date_completed_utc,
                    created_by_user_id,
                    completed_by_user_id
                FROM forge.inventory_document 
                WHERE inventory_document_id = @p_record_id
                FOR JSON PATH
            );
            
            DELETE FROM forge.inventory_document
            WHERE inventory_document_id = @p_record_id;

            SET @l_action_type_id = 3;

            IF @l_data_before IS NOT NULL AND @l_data_before != '[]'
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_log_id,
                    @p_source_system = 'FORGE',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'inventory_document',
                    @p_object_id = @p_record_id,
                    @p_action_type_id = @l_action_type_id,
                    @p_status_code_id = 1,
                    @p_data_before = @l_data_before,
                    @p_data_after = NULL,
                    @p_diff_data = NULL,
                    @p_message = 'Deleted from inventory_document',
                    @p_context_id = NULL,
                    @p_return_result_ok = @p_return_result_ok OUTPUT,
                    @p_return_result_message = @p_return_result_message OUTPUT,
                    @p_logging_id_out = @l_log_id OUTPUT;
            END
        END
        /***************************************************************************
         * Update logic
         **************************************************************************/
        ELSE IF @l_exists = 1
        BEGIN
            -- Capture data before update
            SELECT @l_data_before = (
                SELECT 
                    inventory_document_id,
                    document_number,
                    inventory_status_id,
                    date_created_utc,
                    date_updated_utc,
                    date_completed_utc,
                    created_by_user_id,
                    completed_by_user_id
                FROM forge.inventory_document 
                WHERE inventory_document_id = @p_record_id
                FOR JSON PATH
            );

            UPDATE forge.inventory_document
            SET
                document_number = @p_document_number,
                inventory_status_id = @p_inventory_status_id,
                date_created_utc = @p_date_created_utc,
                date_updated_utc = @p_date_updated_utc,
                date_completed_utc = @p_date_completed_utc,
                created_by_user_id = @p_created_by_user_id,
                completed_by_user_id = @p_completed_by_user_id
            WHERE inventory_document_id = @p_record_id;

            -- Capture data after update
            SELECT @l_data_after = (
                SELECT 
                    inventory_document_id,
                    document_number,
                    inventory_status_id,
                    date_created_utc,
                    date_updated_utc,
                    date_completed_utc,
                    created_by_user_id,
                    completed_by_user_id
                FROM forge.inventory_document 
                WHERE inventory_document_id = @p_record_id
                FOR JSON PATH
            );

            -- Generate diff data
                WITH DiffData AS (
                    SELECT 
                        'document_number' as [field],
                        JSON_VALUE(@l_data_before, '$[0].document_number') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].document_number') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].document_number') <> JSON_VALUE(@l_data_after, '$[0].document_number')
                        AND JSON_VALUE(@l_data_before, '$[0].document_number') IS NOT NULL 
                        AND JSON_VALUE(@l_data_after, '$[0].document_number') IS NOT NULL
                    UNION ALL
                    SELECT 
                        'status_id' as [field],
                        JSON_VALUE(@l_data_before, '$[0].status_id') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].status_id') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].status_id') <> JSON_VALUE(@l_data_after, '$[0].status_id')
                        AND JSON_VALUE(@l_data_before, '$[0].status_id') IS NOT NULL 
                        AND JSON_VALUE(@l_data_after, '$[0].status_id') IS NOT NULL
                    UNION ALL
                    SELECT 
                        'date_completed_utc' as [field],
                        JSON_VALUE(@l_data_before, '$[0].date_completed_utc') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].date_completed_utc') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].date_completed_utc') <> JSON_VALUE(@l_data_after, '$[0].date_completed_utc')
                        AND JSON_VALUE(@l_data_before, '$[0].date_completed_utc') IS NOT NULL 
                        AND JSON_VALUE(@l_data_after, '$[0].date_completed_utc') IS NOT NULL
                    UNION ALL
                    SELECT 
                        'completed_by_user_id' as [field],
                        JSON_VALUE(@l_data_before, '$[0].completed_by_user_id') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].completed_by_user_id') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].completed_by_user_id') <> JSON_VALUE(@l_data_after, '$[0].completed_by_user_id')
                        AND JSON_VALUE(@l_data_before, '$[0].completed_by_user_id') IS NOT NULL 
                        AND JSON_VALUE(@l_data_after, '$[0].completed_by_user_id') IS NOT NULL
                )

                SELECT @l_diff_data = ( SELECT * FROM DiffData FOR JSON PATH );

            SET @l_action_type_id = 2;

            EXEC core.sp_log_transaction
                @p_logging_id = @l_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'inventory_document',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = @l_data_before,
                @p_data_after = @l_data_after,
                @p_diff_data = @l_diff_data,
                @p_message = 'Updated inventory_document',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_logging_id_out = @l_log_id OUTPUT;
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
                document_number,
                inventory_status_id,
                date_created_utc,
                date_updated_utc,
                date_completed_utc,
                created_by_user_id,
                completed_by_user_id
            )
            VALUES
            (
                @p_record_id,
                @p_document_number,
                @p_inventory_status_id,
                @p_date_created_utc,
                @p_date_updated_utc,
                @p_date_completed_utc,
                @p_created_by_user_id,
                @p_completed_by_user_id
            );

            -- Capture data after insert
            SELECT @l_data_after = (
                SELECT 
                    inventory_document_id,
                    document_number,
                    inventory_status_id,
                    date_created_utc,
                    date_updated_utc,
                    date_completed_utc,
                    created_by_user_id,
                    completed_by_user_id
                FROM forge.inventory_document 
                WHERE inventory_document_id = @p_record_id
                FOR JSON PATH
            );

            SET @l_action_type_id = 1;

            EXEC core.sp_log_transaction
                @p_logging_id = @l_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'inventory_document',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = NULL,
                @p_data_after = @l_data_after,
                @p_diff_data = NULL,
                @p_message = 'Inserted into inventory_document',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_logging_id_out = @l_log_id OUTPUT;
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
                @p_logging_id = @l_transaction_log_id,
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
                @p_logging_id_out = NULL;
        END TRY
        BEGIN CATCH
            -- Suppress nested logging failure to avoid recursion
        END CATCH
    END CATCH
END;

