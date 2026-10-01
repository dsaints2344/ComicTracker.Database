CREATE TABLE [Publisher] (
  [PublisherId] UNIQUEIDENTIFIER NOT NULL,
  [Name]        NVARCHAR(120)    NOT NULL,
  CONSTRAINT [PK_Publisher] PRIMARY KEY ([PublisherId])
);

CREATE TABLE [Series] (
  [SeriesId]    UNIQUEIDENTIFIER NOT NULL,
  [PublisherId] UNIQUEIDENTIFIER NOT NULL,
  [Name]        NVARCHAR(200)    NOT NULL,
  [Volume]      INT              NULL,
  [StartYear]   INT              NULL,
  CONSTRAINT [PK_Series] PRIMARY KEY ([SeriesId]),
  CONSTRAINT [FK_Series_Publisher] FOREIGN KEY ([PublisherId])
    REFERENCES [Publisher]([PublisherId])
);

CREATE TABLE [Event] (
  [EventId]     UNIQUEIDENTIFIER NOT NULL,
  [PublisherId] UNIQUEIDENTIFIER NOT NULL,
  [Name]        NVARCHAR(200)    NOT NULL,
  [Slug]        VARCHAR(200)     NOT NULL,
  [StartDate]   DATE             NULL,
  [EndDate]     DATE             NULL,
  CONSTRAINT [PK_Event] PRIMARY KEY ([EventId]),
  CONSTRAINT [UQ_Event_Slug] UNIQUE ([Slug]),
  CONSTRAINT [FK_Event_Publisher] FOREIGN KEY ([PublisherId])
    REFERENCES [Publisher]([PublisherId])
);

CREATE TABLE [Comic] (
  [ComicId]        UNIQUEIDENTIFIER NOT NULL,
  [SeriesId]       UNIQUEIDENTIFIER NOT NULL,
  [EventId]        UNIQUEIDENTIFIER NOT NULL,
  [Number]         VARCHAR(20)      NOT NULL,
  [SortOrder]      DECIMAL(8,2)     NOT NULL,
  [SequenceNumber] INT              NOT NULL,
  [Role]           VARCHAR(20)      NOT NULL,
  [StoreDate]      DATE             NULL,
  CONSTRAINT [PK_Comic] PRIMARY KEY ([ComicId]),
  CONSTRAINT [UQ_Comic_Series_Number] UNIQUE ([SeriesId], [Number]),
  CONSTRAINT [UQ_Comic_Event_Sequence] UNIQUE ([EventId], [SequenceNumber]),
  CONSTRAINT [CK_Comic_Role] CHECK ([Role] IN ('Core', 'TieIn', 'Optional')),
  CONSTRAINT [FK_Comic_Series] FOREIGN KEY ([SeriesId])
    REFERENCES [Series]([SeriesId]),
  CONSTRAINT [FK_Comic_Event] FOREIGN KEY ([EventId])
    REFERENCES [Event]([EventId]) ON DELETE CASCADE
);

CREATE TABLE [Cover] (
  [CoverId]     UNIQUEIDENTIFIER NOT NULL,
  [ComicId]     UNIQUEIDENTIFIER NOT NULL,
  [ImageUrl]    NVARCHAR(500)    NOT NULL,
  [VariantName] NVARCHAR(120)    NULL,
  [IsPrimary]   BIT              NOT NULL CONSTRAINT [DF_Cover_IsPrimary] DEFAULT 0,
  CONSTRAINT [PK_Cover] PRIMARY KEY ([CoverId]),
  CONSTRAINT [FK_Cover_Comic] FOREIGN KEY ([ComicId])
    REFERENCES [Comic]([ComicId]) ON DELETE CASCADE
);