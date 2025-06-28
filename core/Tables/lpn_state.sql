CREATE TABLE [core].[lpn_state] (
    [lpn_state_id] INT           NOT NULL,
    [state_code]   VARCHAR (50)  NOT NULL,
    [description]  VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([lpn_state_id] ASC),
    UNIQUE NONCLUSTERED ([state_code] ASC)
);

