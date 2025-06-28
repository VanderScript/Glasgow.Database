CREATE TABLE [core].[destination] (
    [destination_id]      UNIQUEIDENTIFIER NOT NULL,
    [destination_code]    VARCHAR (100)    NOT NULL,
    [description]         VARCHAR (255)    NULL,
    [destination_type_id] INT              NULL,
    [priority]            INT              NULL,
    [state_id]            INT              NULL,
    [date_created_utc]    DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([destination_id] ASC),
    FOREIGN KEY ([destination_type_id]) REFERENCES [core].[destination_type] ([destination_type_id]),
    FOREIGN KEY ([state_id]) REFERENCES [core].[destination_state] ([destination_state_id]),
    UNIQUE NONCLUSTERED ([destination_code] ASC)
);

