CREATE TABLE [auth].[access_level_map] (
    [access_level_id] INT          IDENTITY(1,1) NOT NULL,
    [level]           INT          NOT NULL,
    [lvl_description] VARCHAR (32) NOT NULL,
    PRIMARY KEY CLUSTERED ([access_level_id] ASC),
    UNIQUE NONCLUSTERED ([level] ASC)
); 