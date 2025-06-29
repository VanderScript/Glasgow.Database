CREATE TABLE [forge].[batch_type] (
    [batch_type_id] INT           NOT NULL,
    [batch_type_name]     VARCHAR (50)  NOT NULL,
    [description]   VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([batch_type_id] ASC),
    UNIQUE NONCLUSTERED ([batch_type_name] ASC)
);

