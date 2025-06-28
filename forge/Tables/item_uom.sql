CREATE TABLE [forge].[item_uom] (
    [item_uom_id]               UNIQUEIDENTIFIER NOT NULL,
    [item_id]                   UNIQUEIDENTIFIER NULL,
    [uom_code]                  VARCHAR (20)     NOT NULL,
    [item_code]                 VARCHAR (100)    NOT NULL,
    [conversion_factor]         DECIMAL (10, 2)  NULL,
    [required_location_type_id] INT              NULL,
    [description]               VARCHAR (255)    NULL,
    [default_weight]            DECIMAL (10, 2)  NULL,
    [default_height]            DECIMAL (10, 2)  NULL,
    [default_width]             DECIMAL (10, 2)  NULL,
    [default_length]            DECIMAL (10, 2)  NULL,
    PRIMARY KEY CLUSTERED ([item_uom_id] ASC),
    FOREIGN KEY ([item_id]) REFERENCES [forge].[item] ([item_id]),
    UNIQUE NONCLUSTERED ([item_code] ASC)
);

