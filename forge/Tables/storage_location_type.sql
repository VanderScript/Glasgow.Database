CREATE TABLE [forge].[storage_location_type] (
    [location_type_id]   INT           NOT NULL,
    [location_type_code] VARCHAR (50)  NOT NULL,
    [description]        VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([location_type_id] ASC),
    UNIQUE NONCLUSTERED ([location_type_code] ASC)
);

