const figureType = ['Figure', 'Yarn', 'Band'];

enum SearchCategory { Game, Name, AmiiboSeries }

enum AmiiboCategory {
  All,
  Custom,
  Figures,
  Cards,
  Owned,
  Wishlist,
  FigureSeries,
  CardSeries,
  Name,
  AmiiboSeries,
  Game
}

extension AmiiboCategoryParsingX on AmiiboCategory {
  String get name {
    switch (this) {
      case AmiiboCategory.AmiiboSeries:
        return 'amiiboSeries';
      case AmiiboCategory.Game:
        return 'gameSeries';
      case AmiiboCategory.Name:
      case AmiiboCategory.Cards:
      case AmiiboCategory.Figures:
      case AmiiboCategory.Owned:
      case AmiiboCategory.Wishlist:
      case AmiiboCategory.CardSeries:
      case AmiiboCategory.FigureSeries:
      case AmiiboCategory.Custom:
      case AmiiboCategory.All:
      default:
        return 'name';
    }
  }
}
