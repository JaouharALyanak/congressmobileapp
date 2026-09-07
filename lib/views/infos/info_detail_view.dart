// views/infos/info_detail_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_bar_widget.dart';

class InfoDetailView extends StatelessWidget {
  final String title;
  final String content;
  final String icon;
  final String buttonLabel;
  final String urlAction;

  const InfoDetailView({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.buttonLabel,
    required this.urlAction,
  });

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final t = tp.theme;

    return Scaffold(
      backgroundColor: t.eventBgColor,
      appBar: AppBarWidget(title: title),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: t.cardBgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: t.cardShadow,
              ),
              child: Column(
                children: [
                  // Icône stylisée
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: t.mainBtnPrimaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: AppIcon(
                      iconKey: icon,
                      color: t.mainBtnPrimaryColor,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Contenu (Adresse ou Téléphone)
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: t.mainTextPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Bouton d'action
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchURL(urlAction),
                      icon: const Icon(Icons.open_in_new),
                      label: Text(buttonLabel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: t.mainBtnPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
