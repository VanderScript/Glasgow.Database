CREATE TABLE [auth].[roles] (
    [role_id] INT          IDENTITY(1,1) NOT NULL,
    [role]    VARCHAR (32) NOT NULL,
    PRIMARY KEY CLUSTERED ([role_id] ASC),
    UNIQUE NONCLUSTERED ([role] ASC)
); 