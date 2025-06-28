CREATE TABLE [forge].[batch_transfer_order] (
    [batch_id]          UNIQUEIDENTIFIER NOT NULL,
    [transfer_order_id] UNIQUEIDENTIFIER NOT NULL,
    PRIMARY KEY CLUSTERED ([batch_id] ASC, [transfer_order_id] ASC),
    FOREIGN KEY ([batch_id]) REFERENCES [forge].[batch] ([batch_id]),
    FOREIGN KEY ([transfer_order_id]) REFERENCES [forge].[transfer_order] ([transfer_order_id])
);

