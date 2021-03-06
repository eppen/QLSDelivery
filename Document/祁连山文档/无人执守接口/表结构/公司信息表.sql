USE [AX20160530]
GO

/****** Object:  Table [dbo].[COMPANYDOMAINLIST]    Script Date: 2016/6/20 10:52:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[COMPANYDOMAINLIST](
	[COMPANYID] [nvarchar](3) NOT NULL DEFAULT (''),
	[DOMAINID] [nvarchar](10) NOT NULL DEFAULT (''),
	[MODIFIEDDATE] [datetime] NOT NULL DEFAULT ('1900-01-01 00:00:00.000'),
	[MODIFIEDTIME] [int] NOT NULL DEFAULT ((0)),
	[MODIFIEDBY] [nvarchar](5) NOT NULL DEFAULT ('?'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT ('1900-01-01 00:00:00.000'),
	[CREATEDTIME] [int] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](5) NOT NULL DEFAULT ('?'),
	[RECVERSION] [int] NOT NULL DEFAULT ((1)),
	[RECID] [bigint] NOT NULL,
 CONSTRAINT [I_65509COMPANY] PRIMARY KEY CLUSTERED 
(
	[COMPANYID] ASC,
	[DOMAINID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[COMPANYDOMAINLIST]  WITH CHECK ADD CHECK  (([RECID]<>(0)))
GO

