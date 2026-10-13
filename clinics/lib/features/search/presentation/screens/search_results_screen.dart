import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/widgets/clinics_loader.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/device/location_service.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../exam/presentation/open_exam_whatsapp.dart';
import '../../../settings/data/preferences.dart';
import '../../data/search_repository.dart';
import '../../domain/search_filters.dart';
import '../widgets/filters_sheet.dart';
import '../../domain/exam_offer.dart';
import '../../domain/money.dart';

const searchCategories = [
  'Todos',
  'Sangue',
  'Raio-X',
  'Consultas',
  'Cardio',
  'Ultrassom',
];

class SearchResultsScreen extends ConsumerStatefulWidget {
  final String initialQuery;
  final String initialCategory;

  const SearchResultsScreen({
    super.key,
    this.initialQuery = '',
    this.initialCategory = 'Todos',
  });

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  late TextEditingController _searchController;
  late String _selectedCategory;
  late String _query;
  late SearchFilters _filters;
  String _sortBy = 'price'; // price, rating, name
  Timer? _debounce;
  ({double lat, double lng})? _position;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _selectedCategory = widget.initialCategory;
    _query = widget.initialQuery;
    _filters = SearchFilters(
      neighborhood: ref.read(selectedNeighborhoodProvider),
    );
  }

  Future<void> _onSortChanged(String value) async {
    if (value != 'distance') {
      setState(() => _sortBy = value);
      return;
    }
    try {
      final position = await LocationService().currentPosition();
      if (mounted) {
        setState(() {
          _position = position;
          _sortBy = value;
        });
      }
    } on LocationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _query = value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = ref.watch(
      searchResultsProvider(
        SearchQuery(
          query: _query,
          category: _selectedCategory,
          sortBy: _sortBy,
          lat: _sortBy == 'distance' ? _position?.lat : null,
          lng: _sortBy == 'distance' ? _position?.lng : null,
          filters: _filters,
        ),
      ),
    );
    final exams = results.value?.items ?? const <ExamOffer>[];

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceCanvas,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderOutline),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onQueryChanged,
            decoration: const InputDecoration(
              hintText: 'Buscar exames ou clínicas...',
              prefixIcon: Icon(
                Icons.search,
                size: 20,
                color: AppColors.slateSecondary,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              fillColor: Colors.transparent,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Rail
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: searchCategories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = searchCategories[index];
                  final isSelected = _selectedCategory == cat;

                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    selectedColor: AppColors.primarySoft,
                    backgroundColor: AppColors.surfaceCanvas,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primaryDeep
                          : AppColors.slateDeep,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primarySoft
                            : AppColors.borderOutline,
                      ),
                    ),
                    showCheckmark: false,
                  );
                },
              ),
            ),
          ),

          // Search Stats and Sort Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${results.value?.total ?? 0} opções encontradas',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.slateDeep,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  icon: Badge(
                    isLabelVisible: _filters.activeCount > 0,
                    label: Text('${_filters.activeCount}'),
                    child: const Icon(Icons.tune, size: 18),
                  ),
                  label: const Text('Filtros', style: TextStyle(fontSize: 12)),
                  onPressed: () async {
                    final result = await showFiltersSheet(context, _filters);
                    if (result != null) setState(() => _filters = result);
                  },
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    icon: const Icon(
                      Icons.sort,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'price',
                        child: Text(
                          'Menor Preço',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'distance',
                        child: Text(
                          'Mais Próximo',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'rating',
                        child: Text(
                          'Melhor Avaliação',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'name',
                        child: Text(
                          'Nome (A-Z)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) _onSortChanged(val);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Exam Comparison Cards List
          Expanded(
            child: results.isLoading && !results.hasValue
                ? const SkeletonCards()
                : results.hasError && !results.hasValue
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wifi_off,
                          size: 48,
                          color: AppColors.slateMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          results.error is ApiException
                              ? (results.error as ApiException).message
                              : 'Não foi possível carregar os exames.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium,
                        ),
                        TextButton(
                          onPressed: () =>
                              ref.invalidate(searchResultsProvider),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  )
                : exams.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 48,
                          color: AppColors.slateMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhum exame encontrado.',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tente buscar por "Hemograma", "Ultrassom" ou "Cardio"',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: exams.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final exam = exams[index];
                      final clinic = exam.clinic;

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context.push('/exam/${exam.id}'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderOutline),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Clinic Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        context.push('/clinic/${clinic.id}');
                                      },
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              clinic.name,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          if (clinic.isVerified)
                                            const Icon(
                                              Icons.verified,
                                              size: 16,
                                              color: AppColors.primaryLight,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.warningBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 14,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          clinic.rating.toStringAsFixed(1),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: AppColors.warningText,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                [
                                  if (clinic.neighborhood != null)
                                    clinic.neighborhood!,
                                  'Surubim - PE',
                                  if (exam.distanceKm != null)
                                    '${exam.distanceKm!.toStringAsFixed(1).replaceAll('.', ',')} km',
                                ].join(' • '),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                ),
                              ),

                              const Divider(
                                height: 20,
                                color: AppColors.borderOutline,
                              ),

                              // Exam Details & Price Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exam.examType.name,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                color: AppColors.slateDeep,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.atmosphericBlue,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            exam.examType.category,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          exam.preparation ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontSize: 11,
                                                color: AppColors.slateSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Price Container
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.atmosphericBlueLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.atmosphericBlue,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          formatPrice(exam.price),
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.primary,
                                              ),
                                        ),
                                        if (exam.bestPrice)
                                          Text(
                                            'Melhor preço',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: AppColors.mintDeep,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          )
                                        else if (exam.savings > 0)
                                          Text(
                                            'Economize ${formatPrice(exam.savings)}',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: AppColors.mintDeep,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        Text(
                                          exam.paymentMethods ?? '',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // Actions
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                      ),
                                      onPressed: () =>
                                          context.push('/exam/${exam.id}'),
                                      child: const Text(
                                        'Ver Preparo e Detalhes',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.whatsApp,
                                      foregroundColor: AppColors.mintDeep,
                                      minimumSize: const Size(120, 42),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                    ),
                                    icon: const Icon(Icons.chat, size: 16),
                                    label: const Text(
                                      'WhatsApp',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () =>
                                        openExamWhatsApp(context, ref, exam.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
