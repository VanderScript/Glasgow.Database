CREATE TABLE [auth].[user_sessions] (
    [session_id]        INT               IDENTITY(1,1) NOT NULL,
    [user_id]           UNIQUEIDENTIFIER  NOT NULL,
    [session_token]     VARCHAR (4000)    NOT NULL,  -- Increased size to handle larger OAuth tokens
    [refresh_token]     VARCHAR (4000)    NULL,      -- Made nullable and increased size
    [token_type]        VARCHAR (50)      DEFAULT 'Bearer' NOT NULL,  -- OAuth token type
    [scope]             VARCHAR (1000)    NULL,      -- OAuth scopes
    [id_token]          VARCHAR (4000)    NULL,      -- For OpenID Connect
    [identity_provider] VARCHAR (50)      NULL,      -- Which provider issued the token
    [date_expires_utc]  DATETIME2         NOT NULL,
    [date_created_utc]  DATETIME2         NOT NULL DEFAULT GETUTCDATE(),
    [date_updated_utc]  DATETIME2         NOT NULL DEFAULT GETUTCDATE(),
    PRIMARY KEY CLUSTERED ([session_id] ASC),
    FOREIGN KEY ([user_id]) REFERENCES [auth].[users] ([user_id])
);
