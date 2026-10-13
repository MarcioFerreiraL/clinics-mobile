import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/input_masks.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/profile_repository.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  final UserProfile user;

  const EditProfileSheet({super.key, required this.user});

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final _name = TextEditingController(text: widget.user.fullName);
  late final _email = TextEditingController(text: widget.user.email);
  late final _birth = TextEditingController(
    text: widget.user.birthDate == null
        ? ''
        : formatBrDate(widget.user.birthDate!),
  );
  bool _saving = false;
  ApiException? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _birth.dispose();
    super.dispose();
  }

  Future<void> _pickBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: parseBrDate(_birth.text) ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) _birth.text = formatBrDate(picked);
  }

  Future<void> _save() async {
    final birth = parseBrDate(_birth.text);
    if (_birth.text.isNotEmpty &&
        (birth == null || birth.isAfter(DateTime.now()))) {
      setState(
        () => _error = const ApiException(
          code: 'INVALID_BIRTH_DATE',
          message: 'Informe uma data de nascimento válida (dd/mm/aaaa).',
        ),
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final user = await ref
          .read(profileRepositoryProvider)
          .updateProfile(
            fullName: _name.text.trim(),
            email: _email.text.trim(),
            birthDate: birth,
          );
      ref.read(authProvider.notifier).setUser(user);
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Editar dados', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nome completo',
                errorText: _error?.fieldMessage('full_name'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'E-mail',
                errorText: _error?.fieldMessage('email'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _birth,
              keyboardType: TextInputType.number,
              inputFormatters: [MaskFormatter.date],
              decoration: InputDecoration(
                labelText: 'Data de nascimento',
                hintText: 'dd/mm/aaaa',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month_outlined),
                  onPressed: _pickBirth,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: widget.user.phone,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'WhatsApp / Celular',
                prefixIcon: Icon(Icons.lock_outline, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: widget.user.cpf ?? 'Não informado',
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'CPF',
                prefixIcon: Icon(Icons.lock_outline, size: 18),
                helperText: 'Telefone e CPF identificam sua conta e não podem ser alterados.',
                helperMaxLines: 2,
              ),
            ),
            if (_error != null && _error!.fieldErrors.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!.message,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryDeep,
                      ),
                    )
                  : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
