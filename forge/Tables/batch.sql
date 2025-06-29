CREATE TABLE [forge].[batch] (
    [batch_id]           UNIQUEIDENTIFIER NOT NULL,
    [batch_name]         VARCHAR (100)    NULL,
    [batch_type_id]      INT              NULL,
    [batch_state_id]           INT              NULL,
    [date_created_utc]   DATETIME         NULL,
    [date_started_utc]   DATETIME         NULL,
    [date_completed_utc] DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([batch_id] ASC),
    FOREIGN KEY ([batch_type_id]) REFERENCES [forge].[batch_type] ([batch_type_id]),
    FOREIGN KEY ([batch_state_id]) REFERENCES [forge].[batch_state] ([batch_state_id])
);

