import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/search_repository.dart';
import '../../domain/money.dart';
import '../../domain/search_filters.dart';

/// Folha de filtros da busca. Devolve os filtros escolhidos ao tocar em "Aplicar".
Future<SearchFilters?> showFiltersSheet(
  BuildContext context,
  SearchFilters current,
) {
  return showModalBottomSheet<SearchFilters>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _FiltersSheet(initial: current),
  );
}

class _FiltersSheet extends ConsumerStatefulWidget {
  final SearchFilters initial;

  const _FiltersSheet({required this.initial});

  @override
  ConsumerState<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<_FiltersSheet> {
  static const _maxPrice = 500.0;
  static const _ratings = <double>[4.0, 4.5, 4.8];

  late SearchFilters _filters = widget.initial;
  late RangeValues _range = RangeValues(
    widget.initial.minPrice ?? 0,
    widget.initial.maxPrice ?? _maxPrice,
  );

  void _applyRange(RangeValues values) {
    setState(() {
      _range = values;
      _filters = _filters.copyWith(
        minPrice: values.start <= 0 ? null : values.start.roundToDouble(),
        maxPrice: values.end >= _maxPrice ? null : values.end.roundToDouble(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final neighborhoods = ref.watch(neighborhoodsProvider).value ?? const [];
    final rangeLabel =
        '${formatPrice(_range.start)} – ${_range.end >= _maxPrice ? 'sem limite' : formatPrice(_range.end)}';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Filtros', style: theme.textTheme.titleLarge),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, SearchFilters.none),
                  child: const Text('Limpar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Bairro', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: _filters.neighborhood == null,
                  onSelected: (_) => setState(
                    () => _filters = _filters.copyWith(neighborhood: null),
                  ),
                ),
                for (final n in neighborhoods)
                  ChoiceChip(
                    label: Text(n.name),
                    selected: _filters.neighborhood == n.name,
                    onSelected: (_) => setState(
                      () => _filters = _filters.copyWith(neighborhood: n.name),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Faixa de preço', style: theme.textTheme.labelLarge),
                Text(
                  rangeLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: _range,
              min: 0,
              max: _maxPrice,
              divisions: 50,
              onChanged: _applyRange,
            ),
            const SizedBox(height: 8),
            Text('Nota mínima da clínica', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Qualquer'),
                  selected: _filters.minRating == null,
                  onSelected: (_) => setState(
                    () => _filters = _filters.copyWith(minRating: null),
                  ),
                ),
                for (final r in _ratings)
                  ChoiceChip(
                    label: Text('${r.toString().replaceAll('.', ',')}+ ★'),
                    selected: _filters.minRating == r,
                    onSelected: (_) => setState(
                      () => _filters = _filters.copyWith(minRating: r),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Somente o melhor preço'),
              subtitle: const Text(
                'Mostra só a oferta mais barata de cada exame',
              ),
              value: _filters.bestPriceOnly,
              onChanged: (v) => setState(
                () => _filters = _filters.copyWith(bestPriceOnly: v),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, _filters),
              child: const Text('Aplicar filtros'),
            ),
          ],
        ),
      ),
    );
  }
}
