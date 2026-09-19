import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  /// Opens WhatsApp with a pre-filled booking message.
  static Future<bool> openChat({
    required BuildContext context,
    required String phone,
    required String message,
  }) async {
    // Clean non-numeric characters from phone
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final fullPhone = cleanPhone.startsWith('55') ? cleanPhone : '55$cleanPhone';
    final encodedMessage = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$fullPhone?text=$encodedMessage');

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o WhatsApp.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir WhatsApp: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }
}
