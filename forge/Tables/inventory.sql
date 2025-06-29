CREATE TABLE [forge].[stock] (
    [stock_id]            UNIQUEIDENTIFIER NOT NULL,
    [item_uom_id]         UNIQUEIDENTIFIER NULL,
    [storage_location_id] UNIQUEIDENTIFIER NULL,
    [quantity_on_hand]    DECIMAL (10, 2)  NULL,
    [quantity_allocated]  DECIMAL (10, 2)  NULL,
    [status_id]           INT              NULL,
    [date_created_utc]    DATETIME         NULL,
    [date_modified_utc]   DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([stock_id] ASC),
    FOREIGN KEY ([item_uom_id]) REFERENCES [forge].[item_uom] ([item_uom_id]),
    FOREIGN KEY ([status_id]) REFERENCES [forge].[inventory_status] ([status_id]),
    FOREIGN KEY ([storage_location_id]) REFERENCES [forge].[storage_location] ([storage_location_id])
);

