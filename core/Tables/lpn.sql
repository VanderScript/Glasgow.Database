CREATE TABLE [core].[lpn] (
    [lpn_id]              UNIQUEIDENTIFIER NOT NULL,
    [lpn_number]          VARCHAR (100)    NOT NULL,
    [transfer_order_id]   UNIQUEIDENTIFIER NULL,
    [current_location_id] UNIQUEIDENTIFIER NULL,
    [state_id]            INT              NULL,
    [date_created_utc]    DATETIME         NULL,
    [date_assigned_utc]   DATETIME         NULL,
    [date_completed_utc]  DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([lpn_id] ASC),
    FOREIGN KEY ([state_id]) REFERENCES [core].[lpn_state] ([lpn_state_id]),
    UNIQUE NONCLUSTERED ([lpn_number] ASC)
);

