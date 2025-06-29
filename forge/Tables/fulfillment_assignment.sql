CREATE TABLE [forge].[fulfillment_assignment] (
    [fulfillment_assignment_id]         UNIQUEIDENTIFIER NOT NULL,
    [transfer_order_id]     UNIQUEIDENTIFIER NULL,
    [order_line_id]         UNIQUEIDENTIFIER NULL,
    [fulfillment_method_id] INT              NULL,
    [precedence_order]      INT              NULL,
    PRIMARY KEY CLUSTERED ([fulfillment_assignment_id] ASC),
    FOREIGN KEY ([fulfillment_method_id]) REFERENCES [forge].[fulfillment_method] ([fulfillment_method_id])
);

