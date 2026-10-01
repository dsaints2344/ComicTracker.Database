DROP INDEX IF EXISTS [UX_Cover_Primary_Per_Comic] ON [Cover];
CREATE UNIQUE INDEX [UX_Cover_Primary_Per_Comic]
  ON [Cover]([ComicId]) WHERE [IsPrimary] = 1;