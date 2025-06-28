CREATE TABLE [auth].[user_sessions] (
    [session_id]    INT           IDENTITY(1,1) NOT NULL,
    [user_id]       UNIQUEIDENTIFIER NOT NULL,
    [jwttoken]      VARCHAR (2000) NOT NULL,
    [refreshtoken]  VARCHAR (244) NOT NULL,
    [expires]       DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([session_id] ASC),
    FOREIGN KEY ([user_id]) REFERENCES [auth].[users] ([user_id])
); 