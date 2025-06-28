CREATE TABLE [forge].[location_type_compatibility] (
    [compatibility_id]            UNIQUEIDENTIFIER NOT NULL,
    [location_type_id]            INT              NULL,
    [compatible_location_type_id] INT              NULL,
    [is_preferred]                BIT              NOT NULL,
    PRIMARY KEY CLUSTERED ([compatibility_id] ASC),
    FOREIGN KEY ([compatible_location_type_id]) REFERENCES [forge].[storage_location_type] ([location_type_id]),
    FOREIGN KEY ([location_type_id]) REFERENCES [forge].[storage_location_type] ([location_type_id])
);

