CREATE TABLE [forge].[item_status] (
    [item_status_id]   INT           NOT NULL,
    [item_status_name] VARCHAR (50)  NOT NULL,
    [description] VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([item_status_id] ASC),
    UNIQUE NONCLUSTERED ([item_status_name] ASC)
);

