CREATE TABLE [forge].[fulfillment_method] (
    [fulfillment_method_id] INT           NOT NULL,
    [method_name]           VARCHAR (50)  NOT NULL,
    [description]           VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([fulfillment_method_id] ASC),
    UNIQUE NONCLUSTERED ([method_name] ASC)
);

