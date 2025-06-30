CREATE TABLE [auth].[users] (
    [user_id]           UNIQUEIDENTIFIER DEFAULT (NEWID()) NOT NULL,
    [username]          VARCHAR (32)     NOT NULL,
    [email]             VARCHAR (255)    NULL,
    [email_verified]    BIT             DEFAULT(0) NOT NULL,
    [full_name]         VARCHAR (255)    NULL,
    [password_hash]     VARCHAR (244)    NULL,
    [password_salt]     VARCHAR (244)    NULL,
    [external_id]       VARCHAR (255)    NULL,
    [identity_provider] VARCHAR (50)     NULL,
    [is_active]         BIT             DEFAULT(1) NOT NULL,
    [date_created_utc]  DATETIME2       DEFAULT GETUTCDATE() NOT NULL,
    [date_updated_utc]  DATETIME2       DEFAULT GETUTCDATE() NOT NULL,
    PRIMARY KEY CLUSTERED ([user_id] ASC),
    UNIQUE NONCLUSTERED ([username] ASC)
);
GO
