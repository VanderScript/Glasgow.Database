CREATE TABLE [auth].[role_claim_mapping] (
    [mapping_id]  INT          IDENTITY(1,1) NOT NULL,
    [role_id]     INT          NOT NULL,
    [claim_id]    INT          NOT NULL,
    [level]       INT          NOT NULL,
    PRIMARY KEY CLUSTERED ([mapping_id] ASC),
    FOREIGN KEY ([level]) REFERENCES [auth].[access_level_map] ([level]),
    FOREIGN KEY ([role_id]) REFERENCES [auth].[roles] ([role_id]),
    FOREIGN KEY ([claim_id]) REFERENCES [auth].[claim_list] ([claim_id])
); 