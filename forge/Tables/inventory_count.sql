CREATE TABLE [forge].[inventory_count] (
    [inventory_count_id]    UNIQUEIDENTIFIER NOT NULL,
    [inventory_document_id] UNIQUEIDENTIFIER NULL,
    [storage_location_id]   UNIQUEIDENTIFIER NULL,
    [item_uom_id]           UNIQUEIDENTIFIER NULL,
    [expected_quantity]     DECIMAL (10, 2)  NULL,
    [counted_quantity]      DECIMAL (10, 2)  NULL,
    [count_status]          VARCHAR (50)     NOT NULL,
    [counted_by_user_id]    UNIQUEIDENTIFIER NULL,
    [validated_by_user_id]  UNIQUEIDENTIFIER NULL,
    [date_counted_utc]      DATETIME         NULL,
    [date_validated_utc]    DATETIME         NULL,
    [date_created_utc]      DATETIME         NOT NULL,
    [date_updated_utc]      DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([inventory_count_id] ASC),
    FOREIGN KEY ([inventory_document_id]) REFERENCES [forge].[inventory_document] ([inventory_document_id]),
    FOREIGN KEY ([item_uom_id]) REFERENCES [forge].[item_uom] ([item_uom_id]),
    FOREIGN KEY ([storage_location_id]) REFERENCES [forge].[storage_location] ([storage_location_id])
);

