import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/whatsapp_helper.dart';
import '../data/exam_repository.dart';

/// Registra o contato na API (UC07) e abre o WhatsApp da clínica.
Future<void> openExamWhatsApp(BuildContext context, WidgetRef ref, String examId) async {
  try {
    final contact = await ref.read(examRepositoryProvider).registerContact(examId);
    if (context.mounted) await WhatsAppHelper.openUrl(context, contact.whatsappUrl);
  } on ApiException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}
