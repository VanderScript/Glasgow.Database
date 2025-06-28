CREATE TABLE [auth].[claim_list] (
    [claim_id]   INT          IDENTITY(1,1) NOT NULL,
    [claim_name] VARCHAR (32) NULL,
    PRIMARY KEY CLUSTERED ([claim_id] ASC)
); 