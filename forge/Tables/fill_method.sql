CREATE TABLE [forge].[fill_method] (
    [fill_method_id]   INT           NOT NULL,
    [fill_method_name] VARCHAR (50)  NOT NULL,
    [description]      VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([fill_method_id] ASC),
    UNIQUE NONCLUSTERED ([fill_method_name] ASC)
);

