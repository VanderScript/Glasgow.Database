CREATE TABLE [core].[transaction_action_type] (
    [action_type_id] INT           NOT NULL,
    [action_code]    VARCHAR (50)  NOT NULL,
    [description]    VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([action_type_id] ASC),
    UNIQUE NONCLUSTERED ([action_code] ASC)
);

