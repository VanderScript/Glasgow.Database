CREATE TABLE [forge].[stock] (
    [stock_id]            UNIQUEIDENTIFIER NOT NULL,
    [item_uom_id]         UNIQUEIDENTIFIER NULL,
    [storage_location_id] UNIQUEIDENTIFIER NULL,
    [quantity_on_hand]    INT  NULL,
    [quantity_allocated]  INT  NULL,
    [stock_status_id]     INT              NULL,
    [date_created_utc]    DATETIME         NULL,
    [date_modified_utc]   DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([stock_id] ASC),
    FOREIGN KEY ([item_uom_id]) REFERENCES [forge].[item_uom] ([item_uom_id]),
    FOREIGN KEY ([storage_location_id]) REFERENCES [forge].[storage_location] ([storage_location_id]),
    FOREIGN KEY ([stock_status_id]) REFERENCES [forge].[stock_status] ([stock_status_id])
);

