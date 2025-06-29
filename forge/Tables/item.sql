CREATE TABLE [forge].[item] (
    [item_id]     UNIQUEIDENTIFIER NOT NULL,
    [item_number] VARCHAR (100)    NOT NULL,
    [description] VARCHAR (255)    NULL,
    [item_status_id]   INT              NULL,
    PRIMARY KEY CLUSTERED ([item_id] ASC),
    FOREIGN KEY ([item_status_id]) REFERENCES [forge].[item_status] ([item_status_id])
);

