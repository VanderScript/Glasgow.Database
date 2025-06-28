CREATE TABLE [forge].[validation_type] (
    [validation_type_id] INT           NOT NULL,
    [validation_code]    VARCHAR (50)  NOT NULL,
    [description]        VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([validation_type_id] ASC),
    UNIQUE NONCLUSTERED ([validation_code] ASC)
);

