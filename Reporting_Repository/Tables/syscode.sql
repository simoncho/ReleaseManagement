CREATE TABLE [dbo].[syscode] (
    [code_no]         INT           NOT NULL,
    [code_name]       VARCHAR (255) NULL,
    [code_group]      VARCHAR (255) NOT NULL,
    [related_code_no] INT           NULL,
    CONSTRAINT [PK_syscode] PRIMARY KEY CLUSTERED ([code_no] ASC, [code_group] ASC)
);

