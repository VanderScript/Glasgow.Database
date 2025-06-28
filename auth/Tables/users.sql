CREATE TABLE [auth].[users] (
    [user_id]         UNIQUEIDENTIFIER DEFAULT (NEWID()) NOT NULL,
    [username]        VARCHAR (32)  NOT NULL,
    [password_hash]   VARCHAR (244) NOT NULL,
    [password_salt]   VARCHAR (244) NOT NULL,
    PRIMARY KEY CLUSTERED ([user_id] ASC),
    UNIQUE NONCLUSTERED ([username] ASC)
); 