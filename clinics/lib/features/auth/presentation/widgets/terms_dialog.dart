import 'package:flutter/material.dart';

/// Resumo dos termos de uso e da política de privacidade (LGPD), versão 1.0.
Future<void> showTermsDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (_) => AlertDialog(
    title: const Text('Termos e privacidade'),
    content: const SingleChildScrollView(
      child: Text(
        'O Clinics compara preços de exames e consultas em clínicas de Surubim '
        'e leva você ao WhatsApp da clínica escolhida. Não agendamos nem cobramos.\n\n'
        'Dados que guardamos: nome, telefone, CPF, e-mail, data de nascimento, '
        'foto de perfil, favoritos, avaliações e os contatos feitos com clínicas.\n\n'
        'Para que usamos: criar sua conta, mostrar suas informações e contar '
        'os cliques no WhatsApp. Não vendemos nem compartilhamos seus dados com terceiros.\n\n'
        'Seus direitos (LGPD): você pode exportar todos os seus dados e excluir '
        'sua conta a qualquer momento, em Meu Perfil.\n\n'
        'Versão 1.0',
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Fechar'),
      ),
    ],
  ),
);
