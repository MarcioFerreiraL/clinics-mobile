import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/widgets/app_drawer.dart';
import '../../data/mock_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Todos';
  final searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onSearchSubmit(String query) {
    context.push('/search?query=$query&category=$selectedCategory');
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
    context.push('/search?category=$category');
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.surfaceCanvas,
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.atmosphericBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.health_and_safety, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              'Clinics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.atmosphericBlue,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'Surubim, PE',
                  style: theme.textTheme.labelSmall?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.atmosphericBlue,
              child: Icon(Icons.person, size: 18, color: AppColors.primary),
            ),
            onPressed: () => context.push('/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Spotlight Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  // Location Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.atmosphericBlue,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.near_me, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Surubim, PE • Centro',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.slateDeep,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.actionEmerald,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Encontre o melhor preço perto de você',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Compare valores de exames e consultas sem sair de casa',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),

                  // Search Box
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.borderOutline),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(Icons.search, color: AppColors.slateSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            onSubmitted: _onSearchSubmit,
                            decoration: const InputDecoration(
                              hintText: 'Buscar exame ou consulta...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              fillColor: Colors.transparent,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.mic, color: AppColors.slateSecondary, size: 20),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pesquisa por voz ativa...')),
                            );
                          },
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.atmosphericBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.tune, color: AppColors.primary, size: 16),
                          ),
                          onPressed: () => context.push('/search'),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Stats Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified, size: 16, color: AppColors.actionEmerald),
                      const SizedBox(width: 6),
                      Text(
                        '140+ exames em clínicas de Surubim',
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Categories & Trending Section
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header: Categories
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CATEGORIAS',
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slateSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/search'),
                          child: Text(
                            'Ver todas',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Category Chips Rail
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: MockData.categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = MockData.categories[index];
                        final isSelected = selectedCategory == cat['key'];

                        return FilterChip(
                          label: Text(cat['name']),
                          selected: isSelected,
                          onSelected: (_) => _onCategorySelected(cat['key']),
                          backgroundColor: AppColors.surfaceCanvas,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.slateDeep,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
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

                  const SizedBox(height: 24),

                  // Section: Em Alta em Surubim
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.trending_up, size: 20, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Mais buscados em Surubim',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Esta semana',
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Trending items
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildTrendingCard(
                          context: context,
                          title: 'Hemograma Completo',
                          subtitle: 'Laboratorial • Sangue',
                          minPrice: 18.00,
                          icon: Icons.bloodtype,
                          onTap: () => context.push('/search?query=Hemograma'),
                        ),
                        const SizedBox(height: 10),
                        _buildTrendingCard(
                          context: context,
                          title: 'Ultrassom Abdominal Total',
                          subtitle: 'Diagnóstico por Imagem',
                          minPrice: 90.00,
                          icon: Icons.personal_injury,
                          onTap: () => context.push('/search?query=Ultrassom'),
                        ),
                        const SizedBox(height: 10),
                        _buildTrendingCard(
                          context: context,
                          title: 'Eletrocardiograma (ECG)',
                          subtitle: 'Cardiologia Clínica',
                          minPrice: 45.00,
                          icon: Icons.monitor_heart,
                          onTap: () => context.push('/search?query=Eletrocardiograma'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Trust Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.atmosphericBlueLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.atmosphericBlue),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chat_bubble_outline, size: 20, color: AppColors.actionEmerald),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Agende direto no WhatsApp',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.slateDeep,
                                  ),
                                ),
                                Text(
                                  'Converse diretamente com a recepção da clínica',
                                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.slateSecondary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        backgroundColor: Colors.white,
        elevation: 4,
        indicatorColor: AppColors.atmosphericBlue,
        onDestinationSelected: (index) {
          if (index == 1) {
            context.push('/search');
          } else if (index == 2) {
            context.push('/profile');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search, color: AppColors.primary),
            label: 'Busca',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required double minPrice,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceCanvas,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderOutline),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.atmosphericBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'a partir de',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
                Text(
                  'R\$ ${minPrice.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.atmosphericBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    'Ver',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
