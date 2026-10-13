import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/whatsapp_helper.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../search/domain/money.dart';
import '../../data/clinic_repository.dart';
import '../../domain/clinic_detail.dart';
import '../../domain/operating_hours.dart';
import '../widgets/reviews_tab.dart';

class ClinicProfileScreen extends ConsumerWidget {
  final String clinicId;

  const ClinicProfileScreen({super.key, required this.clinicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinic = ref.watch(clinicDetailProvider(clinicId));
    return clinic.when(
      data: (data) => _ClinicBody(clinic: data),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Ficha da Clínica')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Ficha da Clínica')),
        body: ErrorView(
          error: e,
          onRetry: () => ref.invalidate(clinicDetailProvider(clinicId)),
        ),
      ),
    );
  }
}

class _ClinicBody extends ConsumerStatefulWidget {
  final ClinicDetail clinic;

  const _ClinicBody({required this.clinic});

  @override
  ConsumerState<_ClinicBody> createState() => _ClinicBodyState();
}

class _ClinicBodyState extends ConsumerState<_ClinicBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Future<void> _openRoute(ClinicDetail clinic) async {
    final query = clinic.latitude != null && clinic.longitude != null
        ? '${clinic.latitude},${clinic.longitude}'
        : Uri.encodeComponent(
            '${clinic.address ?? clinic.name}, ${clinic.city}',
          );
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o mapa.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clinic = widget.clinic;
    final exams = clinic.exams;

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(title: const Text('Ficha da Clínica')),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile Header Card (Instagram-Style Aesthetic)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderOutline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 34,
                                    backgroundColor: AppColors.atmosphericBlue,
                                    child: const Icon(
                                      Icons.local_hospital,
                                      size: 36,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 11,
                                      backgroundColor: AppColors.primary,
                                      child: Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatColumn(
                                      'Exames',
                                      '${exams.length}',
                                    ),
                                    Container(
                                      width: 1,
                                      height: 28,
                                      color: AppColors.borderOutline,
                                    ),
                                    _buildStatColumn(
                                      'Avaliação',
                                      '${clinic.rating.toStringAsFixed(1)} ★',
                                    ),
                                    Container(
                                      width: 1,
                                      height: 28,
                                      color: AppColors.borderOutline,
                                    ),
                                    _buildStatColumn(
                                      'Pacientes',
                                      '${clinic.patientCount}+',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  clinic.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (clinic.isVerified)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.atmosphericBlue,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'Verificada',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            clinic.description ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.slateDeep,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  [
                                    if (clinic.address != null) clinic.address!,
                                    if (clinic.neighborhood != null)
                                      clinic.neighborhood!,
                                  ].join(' • '),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${clinic.openNow ? 'Aberto agora' : 'Fechado agora'} • ${OperatingHours.summarize(clinic.operatingHours)}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.whatsApp,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size.fromHeight(42),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(Icons.chat, size: 16),
                                  label: const Text(
                                    'WhatsApp',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: clinic.whatsappNumber == null
                                      ? null
                                      : () => WhatsAppHelper.openChat(
                                          context: context,
                                          phone: clinic.whatsappNumber!,
                                          message:
                                              'Olá ${clinic.name}! Gostaria de informações sobre exames.',
                                        ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(42),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.map_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('Rotas'),
                                  onPressed: () => _openRoute(clinic),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.slateSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.receipt_long, size: 20),
                      text: 'Exames',
                    ),
                    Tab(
                      icon: Icon(Icons.star_outline, size: 20),
                      text: 'Avaliações',
                    ),
                    Tab(icon: Icon(Icons.schedule, size: 20), text: 'Horários'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Exames da Clínica
            exams.isEmpty
                ? const Center(
                    child: Text('Nenhum exame cadastrado no momento.'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: exams.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final exam = exams[index];
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context.push('/exam/${exam.id}'),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderOutline),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exam.examType.name,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      exam.preparation ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatPrice(exam.price),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () =>
                                        context.push('/exam/${exam.id}'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.atmosphericBlue,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Detalhes',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

            // Tab 2: Avaliações
            ReviewsTab(clinicId: clinic.id),

            // Tab 3: Horários e Informações
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  if (clinic.phoneNumber != null)
                    _buildInfoTile(
                      'Telefone Fixo',
                      clinic.phoneNumber!,
                      Icons.phone,
                    ),
                  if (clinic.whatsappNumber != null)
                    _buildInfoTile(
                      'WhatsApp de Agendamento',
                      clinic.whatsappNumber!,
                      Icons.chat,
                    ),
                  _buildInfoTile(
                    'Cidade',
                    '${clinic.city} - ${clinic.state}',
                    Icons.location_city,
                  ),
                  for (final h in clinic.operatingHours)
                    _buildInfoTile(
                      h.dayLabel,
                      '${h.opensAt} às ${h.closesAt}',
                      Icons.schedule,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.slateDeep,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.slateSecondary),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderOutline),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.slateSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slateDeep,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}
