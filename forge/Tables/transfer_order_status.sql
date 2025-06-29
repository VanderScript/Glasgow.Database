CREATE TABLE [forge].[transfer_order_status] (
    [transfer_order_status_id]   INT           NOT NULL,
    [transfer_order_status_name] VARCHAR (50)  NOT NULL,
    [description] VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([transfer_order_status_id] ASC),
    UNIQUE NONCLUSTERED ([transfer_order_status_name] ASC)
);

