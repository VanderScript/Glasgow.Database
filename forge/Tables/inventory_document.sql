CREATE TABLE [forge].[inventory_document] (
    [inventory_document_id] UNIQUEIDENTIFIER NOT NULL,
    [document_code]         VARCHAR (100)    NOT NULL,
    [status]                VARCHAR (50)     NOT NULL,
    [date_created_utc]      DATETIME         NOT NULL,
    [date_updated_utc]      DATETIME         NULL,
    [date_completed_utc]    DATETIME         NULL,
    [created_by_user_id]    UNIQUEIDENTIFIER NULL,
    [completed_by_user_id]  UNIQUEIDENTIFIER NULL,
    PRIMARY KEY CLUSTERED ([inventory_document_id] ASC)
);

