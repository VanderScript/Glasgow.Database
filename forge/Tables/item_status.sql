CREATE TABLE [forge].[item_status] (
    [status_id]   INT           NOT NULL,
    [status_code] VARCHAR (50)  NOT NULL,
    [description] VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([status_id] ASC),
    UNIQUE NONCLUSTERED ([status_code] ASC)
);

