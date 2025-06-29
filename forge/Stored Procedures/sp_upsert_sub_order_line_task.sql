/***************************************************************************************
  Procedure: sp_upsert_sub_order_line_task
  PK: task_id
***************************************************************************************/
CREATE PROCEDURE forge.sp_upsert_sub_order_line_task
(
    @p_record_id UNIQUEIDENTIFIER = NULL,
    @p_created_by_user_id UNIQUEIDENTIFIER = NULL,
    @p_is_delete BIT = 0,

    -- Table-specific columns
    @p_order_line_id UNIQUEIDENTIFIER,
    @p_movement_type_id INT,
    @p_item_uom_id UNIQUEIDENTIFIER,
    @p_quantity DECIMAL(10,2),
    @p_actual_quantity DECIMAL(10,2),
    @p_source_location_id UNIQUEIDENTIFIER,
    @p_destination_location_id UNIQUEIDENTIFIER,
    @p_task_state_id INT,
    @p_assigned_to_user_id UNIQUEIDENTIFIER = NULL,
    @p_priority INT = NULL,
    @p_validation_type_id INT = NULL,
    @p_date_assigned_utc DATETIME = NULL,
    @p_date_started_utc DATETIME = NULL,
    @p_date_completed_utc DATETIME = NULL,
    @p_notes VARCHAR(500) = NULL,

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
    DECLARE @l_data_before NVARCHAR(MAX);
    DECLARE @l_data_after NVARCHAR(MAX);
    DECLARE @l_diff_data NVARCHAR(MAX);

    IF @p_record_id IS NOT NULL
       AND EXISTS(SELECT 1 FROM forge.sub_order_line_task WHERE task_id = @p_record_id)
    BEGIN
        SET @l_exists = 1;
    END

    BEGIN TRY

        IF @p_is_delete = 1 AND @p_record_id IS NOT NULL AND @l_exists = 1
        BEGIN
            -- Capture data before deletion
            SELECT @l_data_before = (
                SELECT 
                    task_id,
                    order_line_id,
                    movement_type_id,
                    item_uom_id,
                    quantity,
                    actual_quantity,
                    source_location_id,
                    destination_location_id,
                    task_state_id,
                    assigned_to_user_id,
                    priority,
                    validation_type_id,
                    date_created_utc,
                    date_assigned_utc,
                    date_started_utc,
                    date_completed_utc,
                    notes
                FROM forge.sub_order_line_task 
                WHERE task_id = @p_record_id
                FOR JSON PATH
            );
            
            DELETE FROM forge.sub_order_line_task
            WHERE task_id = @p_record_id;

            SET @l_action_type_id = 3;

            IF @l_data_before IS NOT NULL AND @l_data_before != '[]'
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_log_id,
                    @p_source_system = 'FORGE',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'sub_order_line_task',
                    @p_object_id = @p_record_id,
                    @p_action_type_id = @l_action_type_id,
                    @p_status_code_id = 1,
                    @p_data_before = @l_data_before,
                    @p_data_after = NULL,
                    @p_diff_data = NULL,
                    @p_message = 'Deleted from sub_order_line_task',
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
                    task_id,
                    order_line_id,
                    movement_type_id,
                    item_uom_id,
                    quantity,
                    actual_quantity,
                    source_location_id,
                    destination_location_id,
                    task_state_id,
                    assigned_to_user_id,
                    priority,
                    validation_type_id,
                    date_created_utc,
                    date_assigned_utc,
                    date_started_utc,
                    date_completed_utc,
                    notes
                FROM forge.sub_order_line_task 
                WHERE task_id = @p_record_id
                FOR JSON PATH
            );

            UPDATE forge.sub_order_line_task
            SET
                order_line_id = @p_order_line_id,
                movement_type_id = @p_movement_type_id,
                item_uom_id = @p_item_uom_id,
                quantity = @p_quantity,
                actual_quantity = @p_actual_quantity,
                source_location_id = @p_source_location_id,
                destination_location_id = @p_destination_location_id,
                task_state_id = @p_task_state_id,
                assigned_to_user_id = @p_assigned_to_user_id,
                priority = @p_priority,
                validation_type_id = @p_validation_type_id,
                date_assigned_utc = @p_date_assigned_utc,
                date_started_utc = @p_date_started_utc,
                date_completed_utc = @p_date_completed_utc,
                notes = @p_notes
            WHERE task_id = @p_record_id;

            -- Capture data after update
            SELECT @l_data_after = (
                SELECT 
                    task_id,
                    order_line_id,
                    movement_type_id,
                    item_uom_id,
                    quantity,
                    actual_quantity,
                    source_location_id,
                    destination_location_id,
                    task_state_id,
                    assigned_to_user_id,
                    priority,
                    validation_type_id,
                    date_created_utc,
                    date_assigned_utc,
                    date_started_utc,
                    date_completed_utc,
                    notes
                FROM forge.sub_order_line_task 
                WHERE task_id = @p_record_id
                FOR JSON PATH
            );

            -- Generate diff data
                WITH DiffData AS (
                    SELECT 
                        'order_line_id' as [field],
                        JSON_VALUE(@l_data_before, '$[0].order_line_id') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].order_line_id') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].order_line_id') <> JSON_VALUE(@l_data_after, '$[0].order_line_id')
                    UNION ALL
                    SELECT 
                        'movement_type_id' as [field],
                        JSON_VALUE(@l_data_before, '$[0].movement_type_id') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].movement_type_id') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].movement_type_id') <> JSON_VALUE(@l_data_after, '$[0].movement_type_id')
                    UNION ALL
                    SELECT 
                        'item_uom_id' as [field],
                        JSON_VALUE(@l_data_before, '$[0].item_uom_id') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].item_uom_id') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].item_uom_id') <> JSON_VALUE(@l_data_after, '$[0].item_uom_id')
                    UNION ALL
                    SELECT 
                        'quantity' as [field],
                        JSON_VALUE(@l_data_before, '$[0].quantity') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].quantity') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].quantity') <> JSON_VALUE(@l_data_after, '$[0].quantity')
                    UNION ALL
                    SELECT 
                        'actual_quantity' as [field],
                        JSON_VALUE(@l_data_before, '$[0].actual_quantity') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].actual_quantity') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].actual_quantity') <> JSON_VALUE(@l_data_after, '$[0].actual_quantity')
                    UNION ALL
                    SELECT 
                        'source_location_id' as [field],
                        JSON_VALUE(@l_data_before, '$[0].source_location_id') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].source_location_id') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].source_location_id') <> JSON_VALUE(@l_data_after, '$[0].source_location_id')
                    UNION ALL
                    SELECT 
                        'destination_location_id' as [field],
                        JSON_VALUE(@l_data_before, '$[0].destination_location_id') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].destination_location_id') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].destination_location_id') <> JSON_VALUE(@l_data_after, '$[0].destination_location_id')
                    UNION ALL
                    SELECT 
                        'task_state_id' as [field],
                        JSON_VALUE(@l_data_before, '$[0].task_state_id') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].task_state_id') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].task_state_id') <> JSON_VALUE(@l_data_after, '$[0].task_state_id')
                    UNION ALL
                    SELECT 
                        'assigned_to_user_id' as [field],
                        JSON_VALUE(@l_data_before, '$[0].assigned_to_user_id') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].assigned_to_user_id') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].assigned_to_user_id') <> JSON_VALUE(@l_data_after, '$[0].assigned_to_user_id')
                    UNION ALL
                    SELECT 
                        'priority' as [field],
                        JSON_VALUE(@l_data_before, '$[0].priority') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].priority') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].priority') <> JSON_VALUE(@l_data_after, '$[0].priority')
                    UNION ALL
                    SELECT 
                        'validation_type_id' as [field],
                        JSON_VALUE(@l_data_before, '$[0].validation_type_id') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].validation_type_id') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].validation_type_id') <> JSON_VALUE(@l_data_after, '$[0].validation_type_id')
                    UNION ALL
                    SELECT 
                        'date_assigned_utc' as [field],
                        JSON_VALUE(@l_data_before, '$[0].date_assigned_utc') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].date_assigned_utc') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].date_assigned_utc') <> JSON_VALUE(@l_data_after, '$[0].date_assigned_utc')
                    UNION ALL
                    SELECT 
                        'date_started_utc' as [field],
                        JSON_VALUE(@l_data_before, '$[0].date_started_utc') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].date_started_utc') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].date_started_utc') <> JSON_VALUE(@l_data_after, '$[0].date_started_utc')
                    UNION ALL
                    SELECT 
                        'date_completed_utc' as [field],
                        JSON_VALUE(@l_data_before, '$[0].date_completed_utc') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].date_completed_utc') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].date_completed_utc') <> JSON_VALUE(@l_data_after, '$[0].date_completed_utc')
                    UNION ALL
                    SELECT 
                        'notes' as [field],
                        JSON_VALUE(@l_data_before, '$[0].notes') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].notes') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].notes') <> JSON_VALUE(@l_data_after, '$[0].notes')
                )
               SELECT @l_diff_data = (  SELECT * FROM DiffData FOR JSON PATH);

            SET @l_action_type_id = 2;

            EXEC core.sp_log_transaction
                @p_logging_id = @l_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'sub_order_line_task',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = @l_data_before,
                @p_data_after = @l_data_after,
                @p_diff_data = @l_diff_data,
                @p_message = 'Updated sub_order_line_task',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_logging_id_out = @l_log_id OUTPUT;
        END
        ELSE
        BEGIN
            IF @p_record_id IS NULL
                SET @p_record_id = NEWID();

            INSERT INTO forge.sub_order_line_task
            (
                task_id,
                order_line_id,
                movement_type_id,
                item_uom_id,
                quantity,
                actual_quantity,
                source_location_id,
                destination_location_id,
                task_state_id,
                assigned_to_user_id,
                priority,
                validation_type_id,
                date_assigned_utc,
                date_started_utc,
                date_completed_utc,
                notes
            )
            VALUES
            (
                @p_record_id,
                @p_order_line_id,
                @p_movement_type_id,
                @p_item_uom_id,
                @p_quantity,
                @p_actual_quantity,
                @p_source_location_id,
                @p_destination_location_id,
                @p_task_state_id,
                @p_assigned_to_user_id,
                @p_priority,
                @p_validation_type_id,
                @p_date_assigned_utc,
                @p_date_started_utc,
                @p_date_completed_utc,
                @p_notes
            );

            -- Capture data after insert
            SELECT @l_data_after = (
                SELECT 
                    task_id,
                    order_line_id,
                    movement_type_id,
                    item_uom_id,
                    quantity,
                    actual_quantity,
                    source_location_id,
                    destination_location_id,
                    task_state_id,
                    assigned_to_user_id,
                    priority,
                    validation_type_id,
                    date_created_utc,
                    date_assigned_utc,
                    date_started_utc,
                    date_completed_utc,
                    notes
                FROM forge.sub_order_line_task 
                WHERE task_id = @p_record_id
                FOR JSON PATH
            );

            SET @l_action_type_id = 1;

            EXEC core.sp_log_transaction
                @p_logging_id = @l_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'sub_order_line_task',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = NULL,
                @p_data_after = @l_data_after,
                @p_diff_data = NULL,
                @p_message = 'Inserted into sub_order_line_task',
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

        SET @l_action_type_id = CASE
            WHEN @p_is_delete = 1 THEN 3
            WHEN @l_exists = 1 THEN 2
            ELSE 1
        END;

        BEGIN TRY
            EXEC core.sp_log_transaction
                @p_logging_id = @l_transaction_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'sub_order_line_task',
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
                @p_logging_id_out = NULL;
        END TRY
        BEGIN CATCH
        END CATCH
    END CATCH
END;
