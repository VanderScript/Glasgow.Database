CREATE TABLE [forge].[order_line] (
    [order_line_id]           UNIQUEIDENTIFIER NOT NULL,
    [transfer_order_id]       UNIQUEIDENTIFIER NULL,
    [item_uom_id]             UNIQUEIDENTIFIER NULL,
    [requested_quantity]      DECIMAL (10, 2)  NULL,
    [fulfilled_quantity]      DECIMAL (10, 2)  NULL,
    [fill_method_id]          INT              NULL,
    [movement_type_id]        INT              NULL,
    [source_location_id]      UNIQUEIDENTIFIER NULL,
    [destination_location_id] UNIQUEIDENTIFIER NULL,
    [status_id]               INT              NULL,
    [line_sequence]           INT              NULL,
    [date_created_utc]        DATETIME         NULL,
    [date_expected_utc]       DATETIME         NULL,
    [date_completed_utc]      DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([order_line_id] ASC),
    FOREIGN KEY ([item_uom_id]) REFERENCES [forge].[item_uom] ([item_uom_id]),
    FOREIGN KEY ([movement_type_id]) REFERENCES [forge].[movement_type] ([movement_type_id]),
    FOREIGN KEY ([status_id]) REFERENCES [forge].[transfer_order_status] ([transfer_order_status_id]),
    FOREIGN KEY ([transfer_order_id]) REFERENCES [forge].[transfer_order] ([transfer_order_id])
);

