CREATE TABLE [forge].[inventory_document] (
    [inventory_document_id] UNIQUEIDENTIFIER NOT NULL,
    [document_number]         VARCHAR (100)    NOT NULL,
    [inventory_status_id]              INT              NOT NULL,
    [date_created_utc]      DATETIME         NOT NULL,
    [date_updated_utc]      DATETIME         NULL,
    [date_completed_utc]    DATETIME         NULL,
    [created_by_user_id]    UNIQUEIDENTIFIER NULL,
    [completed_by_user_id]  UNIQUEIDENTIFIER NULL,
    PRIMARY KEY CLUSTERED ([inventory_document_id] ASC),
    FOREIGN KEY ([inventory_status_id]) REFERENCES [forge].[inventory_status] ([inventory_status_id])
);

