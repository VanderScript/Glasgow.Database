CREATE TABLE [forge].[transfer_order] (
    [transfer_order_id]           UNIQUEIDENTIFIER NOT NULL,
    [order_number]                VARCHAR (100)    NOT NULL,
    [transfer_order_type_id]      INT              NULL,
    [status_id]                   INT              NULL,
    [source_location_id]          UNIQUEIDENTIFIER NULL,
    [destination_location_id]     UNIQUEIDENTIFIER NULL,
    [fill_method_id]              INT              NULL,
    [priority]                    INT              NULL,
    [date_created_utc]            DATETIME         NULL,
    [date_expected_utc]           DATETIME         NULL,
    [date_completed_utc]          DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([transfer_order_id] ASC),
    FOREIGN KEY ([fill_method_id]) REFERENCES [forge].[fill_method] ([fill_method_id]),
    FOREIGN KEY ([transfer_order_type_id]) REFERENCES [forge].[transfer_order_type] ([transfer_order_type_id]),
    FOREIGN KEY ([status_id]) REFERENCES [forge].[transfer_order_status] ([status_id])
);

