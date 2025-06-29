CREATE TABLE [forge].[storage_location] (
    [storage_location_id]    UNIQUEIDENTIFIER NOT NULL,
    [location_code]          VARCHAR (100)    NOT NULL,
    [location_type_id]       INT              NULL,
    [parent_location_id]     UNIQUEIDENTIFIER NULL,
    [area]                   VARCHAR (50)     NULL,
    [zone]                   VARCHAR (50)     NULL,
    [aisle]                  VARCHAR (50)     NULL,
    [rack]                   VARCHAR (50)     NULL,
    [level]                  VARCHAR (50)     NULL,
    [position]               VARCHAR (50)     NULL,
    [storage_location_status_id]              INT              NULL,
    [capacity_volume]        DECIMAL (10, 2)  NULL,
    [capacity_weight]        DECIMAL (10, 2)  NULL,
    [location_definition_id] UNIQUEIDENTIFIER NULL,
    PRIMARY KEY CLUSTERED ([storage_location_id] ASC),
    FOREIGN KEY ([location_type_id]) REFERENCES [forge].[storage_location_type] ([location_type_id]),
    CONSTRAINT [FK_storage_location_definition] FOREIGN KEY ([location_definition_id]) REFERENCES [forge].[location_definition] ([location_definition_id]),
    CONSTRAINT [FK_storage_location_status] FOREIGN KEY ([storage_location_status_id]) REFERENCES [forge].[storage_location_status] ([storage_location_status_id])
);

