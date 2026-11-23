import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/input_masks.dart';
import '../../data/auth_repository.dart';

/// Recuperar senha em dois passos: pede o código pelo celular e redefine com ele.
class ForgotPasswordSheet extends ConsumerStatefulWidget {
  const ForgotPasswordSheet({super.key});

  @override
  ConsumerState<ForgotPasswordSheet> createState() =>
      _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends ConsumerState<ForgotPasswordSheet> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  final _next = TextEditingController();
  bool _codeSent = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, VoidCallback onDone) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) onDone();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _requestCode() => _run(
    () => ref
        .read(authRepositoryProvider)
        .forgotPassword(onlyDigits(_phone.text)),
    () => setState(() => _codeSent = true),
  );

  void _reset() => _run(
    () => ref
        .read(authRepositoryProvider)
        .resetPassword(_code.text.trim(), _next.text),
    () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha redefinida. Entre com a nova senha.')),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Recuperar senha',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (!_codeSent) ...[
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [MaskFormatter.phone],
              decoration: const InputDecoration(labelText: 'Seu celular'),
            ),
          ] else ...[
            const Text(
              'Se o celular tiver conta, um código de 6 dígitos foi gerado. '
              'Digite-o abaixo com a nova senha.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Código'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _next,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nova senha',
                helperText: 'Mínimo de 8 caracteres, com letras e números',
              ),
            ),
          ],
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loading ? null : (_codeSent ? _reset : _requestCode),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryDeep,
                    ),
                  )
                : Text(_codeSent ? 'Redefinir senha' : 'Enviar código'),
          ),
        ],
      ),
    );
  }
}
