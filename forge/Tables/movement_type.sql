CREATE TABLE [forge].[movement_type] (
    [movement_type_id] INT           NOT NULL,
    [movement_type_name]    VARCHAR (50)  NOT NULL,
    [description]      VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([movement_type_id] ASC),
    UNIQUE NONCLUSTERED ([movement_type_name] ASC)
);

