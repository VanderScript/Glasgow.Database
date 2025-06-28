CREATE TABLE [forge].[wave_transfer_order] (
    [wave_id]           UNIQUEIDENTIFIER NOT NULL,
    [transfer_order_id] UNIQUEIDENTIFIER NOT NULL,
    PRIMARY KEY CLUSTERED ([wave_id] ASC, [transfer_order_id] ASC),
    FOREIGN KEY ([transfer_order_id]) REFERENCES [forge].[transfer_order] ([transfer_order_id]),
    FOREIGN KEY ([wave_id]) REFERENCES [forge].[wave] ([wave_id])
);

