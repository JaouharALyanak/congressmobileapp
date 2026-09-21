import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      onTap: () {
        HapticFeedback.lightImpact();
        onNavigate(index);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.06),
            width: 0.75,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: theme.mainBtnPrimaryColor.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AppIcon(
                  iconKey: iconKey,
                  size: 15,
                  color: theme.mainBtnPrimaryColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: theme.cardTitleColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
