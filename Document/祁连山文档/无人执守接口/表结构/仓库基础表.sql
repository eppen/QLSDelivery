USE [AX20160530]
GO

/****** Object:  Table [dbo].[INVENTLOCATION]    Script Date: 2016/6/20 11:05:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[INVENTLOCATION](
	[INVENTLOCATIONID] [nvarchar](20) NOT NULL DEFAULT (''),
	[NAME] [nvarchar](60) NOT NULL DEFAULT (''),
	[MANUAL] [int] NOT NULL DEFAULT ((0)),
	[MAXPICKINGROUTEVOLUME] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[PICKINGLINETIME] [int] NOT NULL DEFAULT ((0)),
	[MAXPICKINGROUTETIME] [int] NOT NULL DEFAULT ((0)),
	[WMSLOCATIONIDDEFAULTRECEIPT] [nvarchar](10) NOT NULL DEFAULT (''),
	[WMSLOCATIONIDDEFAULTISSUE] [nvarchar](10) NOT NULL DEFAULT (''),
	[INVENTLOCATIONIDREQMAIN] [nvarchar](20) NOT NULL DEFAULT (''),
	[REQREFILL] [int] NOT NULL DEFAULT ((0)),
	[INVENTLOCATIONTYPE] [int] NOT NULL DEFAULT ((0)),
	[INVENTLOCATIONIDQUARANTINE] [nvarchar](20) NOT NULL DEFAULT (''),
	[INVENTLOCATIONLEVEL] [int] NOT NULL DEFAULT ((0)),
	[REQCALENDARID] [nvarchar](10) NOT NULL DEFAULT (''),
	[DEL_LEADTIMETRANSFER] [int] NOT NULL DEFAULT ((0)),
	[DEL_CALENDARDAYSTRANSFER] [int] NOT NULL DEFAULT ((0)),
	[WMSAISLENAMEACTIVE] [int] NOT NULL DEFAULT ((0)),
	[WMSRACKNAMEACTIVE] [int] NOT NULL DEFAULT ((0)),
	[WMSRACKFORMAT] [nvarchar](10) NOT NULL DEFAULT (''),
	[WMSLEVELNAMEACTIVE] [int] NOT NULL DEFAULT ((0)),
	[WMSLEVELFORMAT] [nvarchar](10) NOT NULL DEFAULT (''),
	[WMSPOSITIONNAMEACTIVE] [int] NOT NULL DEFAULT ((0)),
	[WMSPOSITIONFORMAT] [nvarchar](10) NOT NULL DEFAULT (''),
	[USEWMSORDERS] [int] NOT NULL DEFAULT ((0)),
	[INVENTLOCATIONIDTRANSIT] [nvarchar](20) NOT NULL DEFAULT (''),
	[VENDACCOUNT] [nvarchar](20) NOT NULL DEFAULT (''),
	[UNITWEIGHTRATIO] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[VOLUMNHEIGHT] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[REMAINHEIGHTMETER] [int] NOT NULL DEFAULT ((0)),
	[CMT_PACKTYPE] [int] NOT NULL DEFAULT ((0)),
	[MODIFIEDDATE] [datetime] NOT NULL DEFAULT ('1900-01-01 00:00:00.000'),
	[MODIFIEDBY] [nvarchar](5) NOT NULL DEFAULT ('?'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT ('1900-01-01 00:00:00.000'),
	[CREATEDBY] [nvarchar](5) NOT NULL DEFAULT ('?'),
	[DATAAREAID] [nvarchar](3) NOT NULL DEFAULT ('dat'),
	[RECVERSION] [int] NOT NULL DEFAULT ((1)),
	[RECID] [bigint] NOT NULL,
 CONSTRAINT [I_158INVENTLOCATIONIDX] PRIMARY KEY CLUSTERED 
(
	[DATAAREAID] ASC,
	[INVENTLOCATIONID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[INVENTLOCATION]  WITH CHECK ADD CHECK  (([RECID]<>(0)))
GO

