CREATE TABLE [forge].[storage_location_status] (
    [storage_location_status_id]   INT           NOT NULL,
    [storage_location_status_name] VARCHAR (50)  NOT NULL,
    [description] VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([storage_location_status_id] ASC),
    UNIQUE NONCLUSTERED ([storage_location_status_name] ASC)
);

