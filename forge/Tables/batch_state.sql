CREATE TABLE [forge].[batch_state] (
    [batch_state_id]   INT           NOT NULL,
    [batch_state_name] VARCHAR (50)  NOT NULL,
    [description]      VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([batch_state_id] ASC),
    UNIQUE NONCLUSTERED ([batch_state_name] ASC)
);

