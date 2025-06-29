CREATE TABLE [auth].[user_sessions] (
    [session_id]    INT           IDENTITY(1,1) NOT NULL,
    [user_id]       UNIQUEIDENTIFIER NOT NULL,
    [session_token]      VARCHAR (2000) NOT NULL,
    [refresh_token]  VARCHAR (244) NOT NULL,
    [date_expires_utc]       DATETIME      NOT NULL,
    [date_created_utc] DATETIME NOT NULL, 
    PRIMARY KEY CLUSTERED ([session_id] ASC),
    FOREIGN KEY ([user_id]) REFERENCES [auth].[users] ([user_id])
); 