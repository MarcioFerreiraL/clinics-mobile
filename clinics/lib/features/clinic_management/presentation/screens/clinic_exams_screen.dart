import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/clinic_management_repository.dart';

class ClinicExamsScreen extends ConsumerWidget {
  const ClinicExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exams = ref.watch(managedClinicExamsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Exames da clínica')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Novo exame'),
      ),
      body: exams.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error is ApiException
              ? error.message
              : 'Não foi possível carregar os exames.',
          onRetry: () => ref.invalidate(managedClinicExamsProvider),
        ),
        data: (items) => items.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Sua clínica ainda não cadastrou exames. Toque em “Novo exame” para começar.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await ref.refresh(managedClinicExamsProvider.future);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final exam = items[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          exam.examType.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('R\$ ${exam.price.toStringAsFixed(2)}'),
                              Text(
                                exam.available ? 'Ativo' : 'Inativo',
                                style: TextStyle(
                                  color: exam.available
                                      ? AppColors.successText
                                      : AppColors.slateSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          tooltip: 'Editar exame',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _openForm(context, ref, exam: exam),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    ManagedClinicExam? exam,
  }) async {
    late final List<ClinicExamType> catalog;
    try {
      catalog = await ref.read(clinicExamCatalogProvider.future);
    } catch (error) {
      if (!context.mounted) return;
      final message = error is ApiException
          ? error.message
          : 'Não foi possível carregar o catálogo de exames.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }
    if (!context.mounted) return;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ClinicExamForm(exam: exam, catalog: catalog),
    );
    if (saved == true) {
      ref.invalidate(managedClinicExamsProvider);
      ref.invalidate(clinicDashboardProvider);
    }
  }
}

class _ClinicExamForm extends ConsumerStatefulWidget {
  final ManagedClinicExam? exam;
  final List<ClinicExamType> catalog;

  const _ClinicExamForm({this.exam, required this.catalog});

  @override
  ConsumerState<_ClinicExamForm> createState() => _ClinicExamFormState();
}

class _ClinicExamFormState extends ConsumerState<_ClinicExamForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _price;
  late final TextEditingController _description;
  late final TextEditingController _preparation;
  late final TextEditingController _payments;
  late String? _examTypeId;
  late bool _available;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final exam = widget.exam;
    _price = TextEditingController(
      text: exam == null ? '' : exam.price.toStringAsFixed(2),
    );
    _description = TextEditingController(
      text: exam?.description ?? exam?.examType.description ?? '',
    );
    _preparation = TextEditingController(text: exam?.preparation ?? '');
    _payments = TextEditingController(text: exam?.paymentMethods ?? '');
    _examTypeId = exam?.examType.id;
    _available = exam?.available ?? true;
  }

  @override
  void dispose() {
    _price.dispose();
    _description.dispose();
    _preparation.dispose();
    _payments.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _examTypeId == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(clinicManagementRepositoryProvider).saveExam(
        id: widget.exam?.id,
        examTypeId: _examTypeId!,
        price: double.parse(_price.text.trim().replaceAll(',', '.')),
        description: _description.text.trim(),
        preparation: _preparation.text.trim(),
        paymentMethods: _payments.text.trim(),
        available: _available,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        final message = error is ApiException
            ? error.message
            : 'Não foi possível salvar o exame.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      12,
      20,
      20 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.exam == null ? 'Cadastrar exame' : 'Editar exame',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: _examTypeId,
              decoration: const InputDecoration(labelText: 'Nome do exame'),
              items: widget.catalog
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(item.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _examTypeId = value);
                for (final item in widget.catalog) {
                  if (item.id == value) {
                    _description.text = item.description ?? '';
                    break;
                  }
                }
              },
              validator: (value) => value == null ? 'Selecione um exame.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _price,
              decoration: const InputDecoration(
                labelText: 'Preço',
                prefixText: 'R\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                final text = (value ?? '').trim();
                if (!RegExp(r'^\d+([,.]\d{1,2})?$').hasMatch(text)) {
                  return 'Use um preço com até 2 casas decimais.';
                }
                final parsed = double.tryParse(
                  text.replaceAll(',', '.'),
                );
                if (parsed == null || parsed < 0 || parsed > 99999999.99) {
                  return 'Informe um preço válido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Descrição'),
              minLines: 2,
              maxLines: 4,
              maxLength: 2000,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _preparation,
              decoration: const InputDecoration(labelText: 'Preparo (opcional)'),
              maxLength: 255,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _payments,
              decoration: const InputDecoration(
                labelText: 'Formas de pagamento (opcional)',
              ),
              maxLength: 255,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Exame ativo'),
              value: _available,
              onChanged: (value) => setState(() => _available = value),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar'),
            ),
            if (widget.exam != null && _available) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _saving ? null : _deactivate,
                child: const Text('Desativar exame'),
              ),
            ],
          ],
        ),
      ),
    ),
  );

  Future<void> _deactivate() async {
    final exam = widget.exam!;
    setState(() => _saving = true);
    try {
      await ref
          .read(clinicManagementRepositoryProvider)
          .deactivateExam(exam.id);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        final message = error is ApiException
            ? error.message
            : 'Não foi possível desativar o exame.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    ),
  );
}
