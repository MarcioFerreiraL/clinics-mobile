import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/whatsapp_helper.dart';
import '../../data/mock_data.dart';
import '../../domain/entities/exam.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;
  final String initialCategory;

  const SearchResultsScreen({
    super.key,
    this.initialQuery = '',
    this.initialCategory = 'Todos',
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late TextEditingController _searchController;
  late String _selectedCategory;
  String _sortBy = 'price'; // price, rating

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Exam> get _filteredExams {
    final query = _searchController.text.trim().toLowerCase();
    var list = MockData.exams.where((exam) {
      final matchesQuery = query.isEmpty ||
          exam.title.toLowerCase().contains(query) ||
          exam.description.toLowerCase().contains(query) ||
          (exam.clinic?.name.toLowerCase().contains(query) ?? false);

      final matchesCat = _selectedCategory == 'Todos' || exam.category == _selectedCategory;

      return matchesQuery && matchesCat;
    }).toList();

    if (_sortBy == 'price') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else {
      list.sort((a, b) => (b.clinic?.rating ?? 0).compareTo(a.clinic?.rating ?? 0));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exams = _filteredExams;

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
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Buscar exames ou clínicas...',
              prefixIcon: Icon(Icons.search, size: 20, color: AppColors.slateSecondary),
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
                itemCount: MockData.categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = MockData.categories[index];
                  final isSelected = _selectedCategory == cat['key'];

                  return ChoiceChip(
                    label: Text(cat['name']),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = cat['key'];
                      });
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceCanvas,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.slateDeep,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.borderOutline,
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
                Text(
                  '${exams.length} opções encontradas',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.slateDeep,
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    icon: const Icon(Icons.sort, size: 18, color: AppColors.primary),
                    items: const [
                      DropdownMenuItem(
                        value: 'price',
                        child: Text('Menor Preço', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      DropdownMenuItem(
                        value: 'rating',
                        child: Text('Melhor Avaliação', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _sortBy = val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Exam Comparison Cards List
          Expanded(
            child: exams.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 48, color: AppColors.slateMuted),
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

                      return Container(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      if (clinic != null) {
                                        context.push('/clinic/${clinic.id}');
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          clinic?.name ?? 'Clínica',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.verified, size: 16, color: AppColors.primaryLight),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.warningBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, size: 14, color: Colors.amber),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${clinic?.rating ?? 5.0}',
                                        style: theme.textTheme.labelSmall?.copyWith(
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
                              clinic?.address ?? 'Surubim - PE',
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),

                            const Divider(height: 20, color: AppColors.borderOutline),

                            // Exam Details & Price Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exam.title,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: AppColors.slateDeep,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.atmosphericBlue,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          exam.category,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        exam.preparation,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall?.copyWith(
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
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.atmosphericBlueLight,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.atmosphericBlue),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        exam.formattedPrice,
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Text(
                                        exam.paymentMethods,
                                        style: theme.textTheme.bodySmall?.copyWith(
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
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    onPressed: () => context.push('/exam/${exam.id}'),
                                    child: const Text('Ver Preparo e Detalhes', style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.whatsApp,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(120, 42),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  ),
                                  icon: const Icon(Icons.chat, size: 16),
                                  label: const Text('WhatsApp', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  onPressed: () {
                                    if (clinic != null) {
                                      WhatsAppHelper.openChat(
                                        context: context,
                                        phone: clinic.whatsappNumber,
                                        message: 'Olá! Vi o exame ${exam.title} por ${exam.formattedPrice} no app Clinics e gostaria de agendar.',
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
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
