CREATE TABLE [forge].[transfer_order_type] (
    [transfer_order_type_id]   INT           NOT NULL,
    [transfer_order_type_code] VARCHAR (50)  NOT NULL,
    [description]              VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([transfer_order_type_id] ASC),
    UNIQUE NONCLUSTERED ([transfer_order_type_code] ASC)
);

