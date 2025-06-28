CREATE TABLE [forge].[item_uom_override] (
    [item_uom_override_id] UNIQUEIDENTIFIER NOT NULL,
    [item_uom_id]          UNIQUEIDENTIFIER NULL,
    [override_code]        VARCHAR (100)    NOT NULL,
    [length]               DECIMAL (10, 2)  NULL,
    [width]                DECIMAL (10, 2)  NULL,
    [height]               DECIMAL (10, 2)  NULL,
    [volume]               DECIMAL (10, 2)  NULL,
    [weight]               DECIMAL (10, 2)  NULL,
    [max_per_location]     INT              NULL,
    [stackable]            BIT              NULL,
    [date_created_utc]     DATETIME         NULL,
    [date_updated_utc]     DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([item_uom_override_id] ASC),
    FOREIGN KEY ([item_uom_id]) REFERENCES [forge].[item_uom] ([item_uom_id])
);

