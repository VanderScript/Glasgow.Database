CREATE TABLE [forge].[wave] (
    [wave_id]            UNIQUEIDENTIFIER NOT NULL,
    [batch_id]           UNIQUEIDENTIFIER NULL,
    [wave_name]          VARCHAR (100)    NULL,
    [route_name]         VARCHAR (100)    NULL,
    [state_id]           INT              NULL,
    [date_created_utc]   DATETIME         NULL,
    [date_started_utc]   DATETIME         NULL,
    [date_completed_utc] DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([wave_id] ASC),
    FOREIGN KEY ([batch_id]) REFERENCES [forge].[batch] ([batch_id]),
    FOREIGN KEY ([state_id]) REFERENCES [forge].[wave_state] ([wave_state_id])
);

