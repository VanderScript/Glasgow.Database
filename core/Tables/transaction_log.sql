CREATE TABLE [core].[transaction_log] (
    [transaction_log_id] UNIQUEIDENTIFIER NOT NULL,
    [source_system]      VARCHAR (50)     NOT NULL,
    [user_id]            UNIQUEIDENTIFIER NULL,
    [event_timestamp]    DATETIME         DEFAULT (getutcdate()) NOT NULL,
    [object_name]        VARCHAR (100)    NOT NULL,
    [object_id]          UNIQUEIDENTIFIER NULL,
    [action_type_id]     INT              NULL,
    [status_code_id]     INT              NULL,
    [data_before]        NVARCHAR (MAX)   NULL,
    [data_after]         NVARCHAR (MAX)   NULL,
    [diff_data]          NVARCHAR (MAX)   NULL,
    [message]            NVARCHAR (1000)  NULL,
    [context_id]         UNIQUEIDENTIFIER NULL,
    [created_utc]        DATETIME         DEFAULT (getutcdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([transaction_log_id] ASC),
    FOREIGN KEY ([action_type_id]) REFERENCES [core].[transaction_action_type] ([action_type_id]),
    FOREIGN KEY ([status_code_id]) REFERENCES [core].[status_code] ([status_code_id])
);

