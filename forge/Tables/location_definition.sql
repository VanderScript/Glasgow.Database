CREATE TABLE [forge].[location_definition] (
    [location_definition_id] UNIQUEIDENTIFIER NOT NULL,
    [interior_length]        DECIMAL (10, 2)  NULL,
    [interior_width]         DECIMAL (10, 2)  NULL,
    [interior_height]        DECIMAL (10, 2)  NULL,
    [interior_volume]        DECIMAL (10, 2)  NULL,
    [exterior_length]        DECIMAL (10, 2)  NULL,
    [exterior_width]         DECIMAL (10, 2)  NULL,
    [exterior_height]        DECIMAL (10, 2)  NULL,
    [exterior_volume]        DECIMAL (10, 2)  NULL,
    [max_weight]             DECIMAL (10, 2)  NULL,
    [max_units]              INT              NULL,
    [temperature_control]    BIT              NULL,
    [humidity_control]       BIT              NULL,
    [date_created_utc]       DATETIME         NULL,
    [date_updated_utc]       DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([location_definition_id] ASC)
);

