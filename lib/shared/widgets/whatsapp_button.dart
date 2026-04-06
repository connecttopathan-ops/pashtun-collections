import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/api_constants.dart';

class WhatsappButton extends StatelessWidget {
  final String? message;
  const WhatsappButton({super.key, this.message});

  Future<void> _openWhatsApp() async {
    final phone = ApiConstants.whatsappNumber.replaceAll('+', '');
    final encodedMsg = Uri.encodeComponent(
        message ?? 'Hello! I have a query about Pashtun Collections.');
    final uri = Uri.parse('https://wa.me/$phone?text=$encodedMsg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _openWhatsApp,
      backgroundColor: const Color(0xFF25D366),
      elevation: 4,
      child: Image.network(
        'https://upload.wikimedia.org/wikipedia/commons/6/6b/WhatsApp.svg',
        width: 28,
        height: 28,
        errorBuilder: (_, __, ___) => const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}
