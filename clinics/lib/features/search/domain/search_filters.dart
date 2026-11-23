/// Filtros opcionais da busca (além do texto, da categoria e da ordenação).
class SearchFilters {
  final String? neighborhood;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;

  const SearchFilters({
    this.neighborhood,
    this.minPrice,
    this.maxPrice,
    this.minRating,
  });

  static const none = SearchFilters();

  /// Quantos filtros além do bairro estão ativos (para o selo do botão).
  int get activeCount =>
      (neighborhood != null ? 1 : 0) +
      (minPrice != null || maxPrice != null ? 1 : 0) +
      (minRating != null ? 1 : 0);

  SearchFilters copyWith({
    Object? neighborhood = _keep,
    Object? minPrice = _keep,
    Object? maxPrice = _keep,
    Object? minRating = _keep,
  }) => SearchFilters(
    neighborhood: identical(neighborhood, _keep)
        ? this.neighborhood
        : neighborhood as String?,
    minPrice: identical(minPrice, _keep) ? this.minPrice : minPrice as double?,
    maxPrice: identical(maxPrice, _keep) ? this.maxPrice : maxPrice as double?,
    minRating: identical(minRating, _keep)
        ? this.minRating
        : minRating as double?,
  );

  Map<String, dynamic> toParams() => {
    if (neighborhood != null) 'neighborhood': neighborhood,
    if (minPrice != null) 'min_price': minPrice,
    if (maxPrice != null) 'max_price': maxPrice,
    if (minRating != null) 'min_rating': minRating,
  };

  @override
  bool operator ==(Object other) =>
      other is SearchFilters &&
      other.neighborhood == neighborhood &&
      other.minPrice == minPrice &&
      other.maxPrice == maxPrice &&
      other.minRating == minRating;

  @override
  int get hashCode =>
      Object.hash(neighborhood, minPrice, maxPrice, minRating);
}

const Object _keep = Object();
