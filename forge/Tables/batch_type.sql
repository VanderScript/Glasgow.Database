CREATE TABLE [forge].[batch_type] (
    [batch_type_id] INT           NOT NULL,
    [type_code]     VARCHAR (50)  NOT NULL,
    [description]   VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([batch_type_id] ASC),
    UNIQUE NONCLUSTERED ([type_code] ASC)
);

