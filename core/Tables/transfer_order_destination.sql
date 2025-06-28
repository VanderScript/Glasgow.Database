CREATE TABLE [core].[transfer_order_destination] (
    [transfer_order_id] UNIQUEIDENTIFIER NOT NULL,
    [destination_id]    UNIQUEIDENTIFIER NOT NULL,
    [priority]          INT              NULL,
    [date_created_utc]  DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([transfer_order_id] ASC, [destination_id] ASC)
);

