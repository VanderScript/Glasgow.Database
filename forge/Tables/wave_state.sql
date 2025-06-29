CREATE TABLE [forge].[wave_state] (
    [wave_state_id] INT           NOT NULL,
    [wave_state_name]    VARCHAR (50)  NOT NULL,
    [description]   VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([wave_state_id] ASC),
    UNIQUE NONCLUSTERED ([wave_state_name] ASC)
);

