/***************************************************************************************
  Procedure: sp_upsert_order_line
  PK: order_line_id
***************************************************************************************/
CREATE PROCEDURE forge.sp_upsert_order_line
(
    @p_record_id UNIQUEIDENTIFIER = NULL,
    @p_created_by_user_id UNIQUEIDENTIFIER = NULL,
    @p_is_delete BIT = 0,

    -- Table-specific columns
    @p_transfer_order_id UNIQUEIDENTIFIER,
    @p_item_uom_id UNIQUEIDENTIFIER,
    @p_requested_quantity DECIMAL(10,2),
    @p_fulfilled_quantity DECIMAL(10,2),
    @p_fill_method_id INT,
    @p_movement_type_id INT,
    @p_source_location_id UNIQUEIDENTIFIER,
    @p_destination_location_id UNIQUEIDENTIFIER,
    @p_status_id INT,
    @p_line_sequence INT,
    @p_date_expected_utc DATETIME,
    @p_date_completed_utc DATETIME = NULL,

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
       AND EXISTS(SELECT 1 FROM forge.order_line WHERE order_line_id = @p_record_id)
    BEGIN
        SET @l_exists = 1;
    END

    BEGIN TRY

        IF @p_is_delete = 1 AND @p_record_id IS NOT NULL AND @l_exists = 1
        BEGIN
            -- Capture data before deletion
            SELECT @l_data_before = (
                SELECT 
                    order_line_id,
                    transfer_order_id,
                    item_uom_id,
                    requested_quantity,
                    fulfilled_quantity,
                    fill_method_id,
                    movement_type_id,
                    source_location_id,
                    destination_location_id,
                    status_id,
                    line_sequence,
                    date_created_utc,
                    date_expected_utc,
                    date_completed_utc
                FROM forge.order_line 
                WHERE order_line_id = @p_record_id
                FOR JSON PATH
            );
            
            DELETE FROM forge.order_line
            WHERE order_line_id = @p_record_id;

            SET @l_action_type_id = 3;

            IF @l_data_before IS NOT NULL AND @l_data_before != '[]'
            BEGIN
                EXEC core.sp_log_transaction
                    @p_logging_id = @l_log_id,
                    @p_source_system = 'FORGE',
                    @p_user_id = @p_created_by_user_id,
                    @p_object_name = 'order_line',
                    @p_object_id = @p_record_id,
                    @p_action_type_id = @l_action_type_id,
                    @p_status_code_id = 1,
                    @p_data_before = @l_data_before,
                    @p_data_after = NULL,
                    @p_diff_data = NULL,
                    @p_message = 'Deleted from order_line',
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
                    order_line_id,
                    transfer_order_id,
                    item_uom_id,
                    requested_quantity,
                    fulfilled_quantity,
                    fill_method_id,
                    movement_type_id,
                    source_location_id,
                    destination_location_id,
                    status_id,
                    line_sequence,
                    date_created_utc,
                    date_expected_utc,
                    date_completed_utc
                FROM forge.order_line 
                WHERE order_line_id = @p_record_id
                FOR JSON PATH
            );

            UPDATE forge.order_line
            SET
                transfer_order_id = @p_transfer_order_id,
                item_uom_id = @p_item_uom_id,
                requested_quantity = @p_requested_quantity,
                fulfilled_quantity = @p_fulfilled_quantity,
                fill_method_id = @p_fill_method_id,
                movement_type_id = @p_movement_type_id,
                source_location_id = @p_source_location_id,
                destination_location_id = @p_destination_location_id,
                status_id = @p_status_id,
                line_sequence = @p_line_sequence,
                date_expected_utc = @p_date_expected_utc,
                date_completed_utc = @p_date_completed_utc
            WHERE order_line_id = @p_record_id;

            -- Capture data after update
            SELECT @l_data_after = (
                SELECT 
                    order_line_id,
                    transfer_order_id,
                    item_uom_id,
                    requested_quantity,
                    fulfilled_quantity,
                    fill_method_id,
                    movement_type_id,
                    source_location_id,
                    destination_location_id,
                    status_id,
                    line_sequence,
                    date_created_utc,
                    date_expected_utc,
                    date_completed_utc
                FROM forge.order_line 
                WHERE order_line_id = @p_record_id
                FOR JSON PATH
            );

            -- Generate diff data
                WITH DiffData AS (
                    SELECT 
                        'transfer_order_id' as [field],
                        JSON_VALUE(@l_data_before, '$[0].transfer_order_id') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].transfer_order_id') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].transfer_order_id') <> JSON_VALUE(@l_data_after, '$[0].transfer_order_id')
                    UNION ALL
                    SELECT 
                        'item_uom_id' as [field],
                        JSON_VALUE(@l_data_before, '$[0].item_uom_id') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].item_uom_id') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].item_uom_id') <> JSON_VALUE(@l_data_after, '$[0].item_uom_id')
                    UNION ALL
                    SELECT 
                        'requested_quantity' as [field],
                        JSON_VALUE(@l_data_before, '$[0].requested_quantity') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].requested_quantity') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].requested_quantity') <> JSON_VALUE(@l_data_after, '$[0].requested_quantity')
                    UNION ALL
                    SELECT 
                        'fulfilled_quantity' as [field],
                        JSON_VALUE(@l_data_before, '$[0].fulfilled_quantity') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].fulfilled_quantity') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].fulfilled_quantity') <> JSON_VALUE(@l_data_after, '$[0].fulfilled_quantity')
                    UNION ALL
                    SELECT 
                        'fill_method_id' as [field],
                        JSON_VALUE(@l_data_before, '$[0].fill_method_id') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].fill_method_id') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].fill_method_id') <> JSON_VALUE(@l_data_after, '$[0].fill_method_id')
                    UNION ALL
                    SELECT 
                        'movement_type_id' as [field],
                        JSON_VALUE(@l_data_before, '$[0].movement_type_id') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].movement_type_id') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].movement_type_id') <> JSON_VALUE(@l_data_after, '$[0].movement_type_id')
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
                        'status_id' as [field],
                        JSON_VALUE(@l_data_before, '$[0].status_id') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].status_id') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].status_id') <> JSON_VALUE(@l_data_after, '$[0].status_id')
                    UNION ALL
                    SELECT 
                        'line_sequence' as [field],
                        JSON_VALUE(@l_data_before, '$[0].line_sequence') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].line_sequence') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].line_sequence') <> JSON_VALUE(@l_data_after, '$[0].line_sequence')
                    UNION ALL
                    SELECT 
                        'date_expected_utc' as [field],
                        JSON_VALUE(@l_data_before, '$[0].date_expected_utc') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].date_expected_utc') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].date_expected_utc') <> JSON_VALUE(@l_data_after, '$[0].date_expected_utc')
                    UNION ALL
                    SELECT 
                        'date_completed_utc' as [field],
                        JSON_VALUE(@l_data_before, '$[0].date_completed_utc') as [old_value],
                        JSON_VALUE(@l_data_after, '$[0].date_completed_utc') as [new_value]
                    WHERE JSON_VALUE(@l_data_before, '$[0].date_completed_utc') <> JSON_VALUE(@l_data_after, '$[0].date_completed_utc')
                )
                          
               SELECT @l_diff_data = (SELECT * FROM DiffData FOR JSON PATH);

            SET @l_action_type_id = 2;

            EXEC core.sp_log_transaction
                @p_logging_id = @l_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'order_line',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = @l_data_before,
                @p_data_after = @l_data_after,
                @p_diff_data = @l_diff_data,
                @p_message = 'Updated order_line',
                @p_context_id = NULL,
                @p_return_result_ok = @p_return_result_ok OUTPUT,
                @p_return_result_message = @p_return_result_message OUTPUT,
                @p_logging_id_out = @l_log_id OUTPUT;
        END
        ELSE
        BEGIN
            IF @p_record_id IS NULL
                SET @p_record_id = NEWID();

            INSERT INTO forge.order_line
            (
                order_line_id,
                transfer_order_id,
                item_uom_id,
                requested_quantity,
                fulfilled_quantity,
                fill_method_id,
                movement_type_id,
                source_location_id,
                destination_location_id,
                status_id,
                line_sequence,
                date_expected_utc,
                date_completed_utc
            )
            VALUES
            (
                @p_record_id,
                @p_transfer_order_id,
                @p_item_uom_id,
                @p_requested_quantity,
                @p_fulfilled_quantity,
                @p_fill_method_id,
                @p_movement_type_id,
                @p_source_location_id,
                @p_destination_location_id,
                @p_status_id,
                @p_line_sequence,
                @p_date_expected_utc,
                @p_date_completed_utc
            );

            -- Capture data after insert
            SELECT @l_data_after = (
                SELECT 
                    order_line_id,
                    transfer_order_id,
                    item_uom_id,
                    requested_quantity,
                    fulfilled_quantity,
                    fill_method_id,
                    movement_type_id,
                    source_location_id,
                    destination_location_id,
                    status_id,
                    line_sequence,
                    date_created_utc,
                    date_expected_utc,
                    date_completed_utc
                FROM forge.order_line 
                WHERE order_line_id = @p_record_id
                FOR JSON PATH
            );

            SET @l_action_type_id = 1;

            EXEC core.sp_log_transaction
                @p_logging_id = @l_log_id,
                @p_source_system = 'FORGE',
                @p_user_id = @p_created_by_user_id,
                @p_object_name = 'order_line',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 1,
                @p_data_before = NULL,
                @p_data_after = @l_data_after,
                @p_diff_data = NULL,
                @p_message = 'Inserted into order_line',
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
                @p_object_name = 'order_line',
                @p_object_id = @p_record_id,
                @p_action_type_id = @l_action_type_id,
                @p_status_code_id = 2,
                @p_data_before = NULL,
                @p_data_after = NULL,
                @p_diff_data = NULL,
                @p_message = @p_return_result_message,
                @p_context_id = NULL,
                @p_return_result_ok = NULL,
                @p_return_result_message = NULL,
                @p_logging_id_out = NULL;
        END TRY
        BEGIN CATCH
        END CATCH
    END CATCH
END;

