import 'package:flutter/material.dart';
import '../../models/app_theme_model.dart';
import '../../models/app_settings_model.dart';
import '../../widgets/app_icon.dart';

class HomeShortcuts extends StatelessWidget {
  final AppThemeModel theme;
  final AppSettingsModel settings;
  final Function(int) onNavigate; // Pour changer d'onglet dans le MainShell

  const HomeShortcuts({
    super.key,
    required this.theme,
    required this.settings,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _buildItem(1, settings.programIcon, settings.programText),
          _buildItem(2, settings.speakerIcon, settings.speakerText),
          _buildItem(3, settings.sponsorIcon, settings.sponsorText),
          _buildItem(4, settings.infoIcon, settings.infoText),
        ],
      ),
    );
  }

  Widget _buildItem(int index, String iconKey, String label) {
    return GestureDetector(
      onTap: () => onNavigate(index), // Déclenche le changement d'onglet
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: theme.cardBgColor, // Fond blanc/clair du bouton
          borderRadius: BorderRadius.circular(30), // Forme capsule
          boxShadow: theme.cardShadow,
        ),
        child: Row(
          children: [
            AppIcon(
              iconKey: iconKey,
              size: 18,
              color: theme.cardIconeColor, // Couleur de l'icône
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: theme.cardTitleColor, // Couleur du texte
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
