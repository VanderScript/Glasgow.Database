CREATE TABLE [core].[destination_type] (
    [destination_type_id] INT           NOT NULL,
    [type_code]           VARCHAR (50)  NOT NULL,
    [description]         VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([destination_type_id] ASC),
    UNIQUE NONCLUSTERED ([type_code] ASC)
);

