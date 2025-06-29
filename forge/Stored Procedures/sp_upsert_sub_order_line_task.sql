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
    @p_assigned_to_user_id UNIQUEIDENTIFIER,
    @p_priority INT,
    @p_validation_type_id INT,
    @p_date_assigned_utc DATETIME,
    @p_date_started_utc DATETIME,
    @p_date_completed_utc DATETIME,
    @p_notes VARCHAR(500),

    -- Outputs
    @p_return_result_ok BIT OUTPUT,
    @p_return_result_message NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @l_log_id UNIQUEIDENTIFIER = NEWID();
    DECLARE @l_exists BIT = 0;
    DECLARE @l_action_type_id INT;

    -- Default to NONE user if no user ID is provided
    IF @p_created_by_user_id IS NULL
        SET @p_created_by_user_id = '00000000-0000-0000-0000-000000000001'; -- NONE user

    IF @p_record_id IS NOT NULL
       AND EXISTS(SELECT 1 FROM forge.sub_order_line_task WHERE task_id = @p_record_id)
    BEGIN
        SET @l_exists = 1;
    END

    BEGIN TRY

        IF @p_is_delete = 1 AND @p_record_id IS NOT NULL AND @l_exists = 1
        BEGIN
            DELETE FROM forge.sub_order_line_task
            WHERE task_id = @p_record_id;

            SET @l_action_type_id = 3;

            EXEC core.sp_log_transaction
                @p_transaction_log_id = @l_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'sub_order_line_task',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = NULL,
                @p_data_after = NULL,
                @p_diff_data = NULL,
                @p_message = 'Deleted from sub_order_line_task',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_loggingid = @l_log_id OUTPUT;
        END
        ELSE IF @l_exists = 1
        BEGIN
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

            SET @l_action_type_id = 2;

            EXEC core.sp_log_transaction
                @p_transaction_log_id = @l_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'sub_order_line_task',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = NULL,
                @p_data_after = NULL,
                @p_diff_data = NULL,
                @p_message = 'Updated sub_order_line_task',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_loggingid = @l_log_id OUTPUT;
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

            SET @l_action_type_id = 1;

            EXEC core.sp_log_transaction
                @p_transaction_log_id = @l_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'sub_order_line_task',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = NULL,
                @p_data_after = NULL,
                @p_diff_data = NULL,
                @p_message = 'Inserted into sub_order_line_task',
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
                @p_loggingid = NULL;
        END TRY
        BEGIN CATCH
        END CATCH
    END CATCH
END;
