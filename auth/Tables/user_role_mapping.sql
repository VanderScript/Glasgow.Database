CREATE TABLE [auth].[user_role_mapping] (
    [mapping_id] INT IDENTITY(1,1) NOT NULL,
    [user_id]    UNIQUEIDENTIFIER NOT NULL,
    [role_id]    INT NOT NULL,
    PRIMARY KEY CLUSTERED ([mapping_id] ASC),
    FOREIGN KEY ([role_id]) REFERENCES [auth].[roles] ([role_id]),
    FOREIGN KEY ([user_id]) REFERENCES [auth].[users] ([user_id])
); 