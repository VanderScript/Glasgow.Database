CREATE TABLE [forge].[inventory_status] (
    [inventory_status_id]   INT           NOT NULL,
    [inventory_status_name] VARCHAR (50)  NOT NULL,
    [description] VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([inventory_status_id] ASC),
    UNIQUE NONCLUSTERED ([inventory_status_name] ASC)
);

