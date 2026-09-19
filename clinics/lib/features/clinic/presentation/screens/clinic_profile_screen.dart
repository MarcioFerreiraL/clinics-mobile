import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/whatsapp_helper.dart';
import '../../../search/data/mock_data.dart';
import '../../../search/domain/entities/clinic.dart';
import '../../../search/domain/entities/exam.dart';

class ClinicProfileScreen extends StatefulWidget {
  final String clinicId;

  const ClinicProfileScreen({super.key, required this.clinicId});

  @override
  State<ClinicProfileScreen> createState() => _ClinicProfileScreenState();
}

class _ClinicProfileScreenState extends State<ClinicProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Clinic get _clinic {
    return MockData.clinics.firstWhere(
      (c) => c.id == widget.clinicId,
      orElse: () => MockData.clinics.first,
    );
  }

  List<Exam> get _clinicExams {
    return MockData.exams.where((e) => e.clinicId == _clinic.id).toList();
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
    final clinic = _clinic;
    final exams = _clinicExams;

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        title: const Text('Ficha da Clínica'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link da clínica copiado!')),
              );
            },
          ),
        ],
      ),
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
                                    child: const Icon(Icons.local_hospital, size: 36, color: AppColors.primary),
                                  ),
                                  const Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 11,
                                      backgroundColor: AppColors.primary,
                                      child: Icon(Icons.check, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatColumn('Exames', '${exams.length}'),
                                    Container(width: 1, height: 28, color: AppColors.borderOutline),
                                    _buildStatColumn('Avaliação', '${clinic.rating} ★'),
                                    Container(width: 1, height: 28, color: AppColors.borderOutline),
                                    _buildStatColumn('Pacientes', '${clinic.patientCount}+'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Text(
                                clinic.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                            clinic.description,
                            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slateDeep),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(clinic.address, style: theme.textTheme.bodySmall),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(clinic.operatingHours, style: theme.textTheme.bodySmall),
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
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.chat, size: 16),
                                  label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onPressed: () {
                                    WhatsAppHelper.openChat(
                                      context: context,
                                      phone: clinic.whatsappNumber,
                                      message: 'Olá ${clinic.name}! Gostaria de informações sobre exames.',
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(42),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.map_outlined, size: 16),
                                  label: const Text('Rotas'),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Endereço: ${clinic.address}')),
                                    );
                                  },
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
                    Tab(icon: Icon(Icons.receipt_long, size: 20), text: 'Exames'),
                    Tab(icon: Icon(Icons.grid_view, size: 20), text: 'Estrutura'),
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
                ? const Center(child: Text('Nenhum exame cadastrado no momento.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: exams.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final exam = exams[index];
                      return Container(
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
                                    exam.title,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    exam.preparation,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  exam.formattedPrice,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: () => context.push('/exam/${exam.id}'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.atmosphericBlue,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Detalhes',
                                      style: theme.textTheme.labelSmall?.copyWith(
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
                      );
                    },
                  ),

            // Tab 2: Fotos da Estrutura
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildPhotoPlaceholder('Recepção Climatizada', Icons.store),
                  _buildPhotoPlaceholder('Sala de Coleta', Icons.bloodtype),
                  _buildPhotoPlaceholder('Ultrassonografia', Icons.personal_injury),
                  _buildPhotoPlaceholder('Eletrocardiograma', Icons.monitor_heart),
                ],
              ),
            ),

            // Tab 3: Horários e Informações
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  _buildInfoTile('Telefone Fixo', clinic.phoneNumber, Icons.phone),
                  _buildInfoTile('WhatsApp de Agendamento', clinic.whatsappNumber, Icons.chat),
                  _buildInfoTile('Horário de Atendimento', clinic.operatingHours, Icons.schedule),
                  _buildInfoTile('Cidade', '${clinic.city} - ${clinic.state}', Icons.location_city),
                  _buildInfoTile('Convênios', 'Particular, Unimed, Bradesco Saúde, Cassi', Icons.health_and_safety),
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
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.slateDeep)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.slateSecondary)),
      ],
    );
  }

  Widget _buildPhotoPlaceholder(String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.atmosphericBlueLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.atmosphericBlue),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.slateDeep),
          ),
        ],
      ),
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
                Text(title, style: const TextStyle(fontSize: 11, color: AppColors.slateSecondary)),
                const SizedBox(height: 2),
                Text(content, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.slateDeep)),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}
