CREATE TABLE [forge].[stock_status] (
    [stock_status_id]   INT           NOT NULL,
    [stock_status_name] VARCHAR (50)  NOT NULL,
    [description]       VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([stock_status_id] ASC),
    UNIQUE NONCLUSTERED ([stock_status_name] ASC)
); 