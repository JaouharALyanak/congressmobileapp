import 'package:flutter/material.dart';
import '../models/app_theme_model.dart';
import 'app_icon.dart';

class ThemedIconBox extends StatelessWidget {
  final String iconKey;
  final double size;
  final AppThemeModel theme;

  const ThemedIconBox({
    super.key,
    required this.iconKey,
    required this.theme,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            theme.gridBtnBgColor, // Fond de l'icône (ex: blanc ou violet clair)
        // Logique Cercle vs Carré/Arrondi
        shape: theme.gridPictureStyle == 'circle'
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: theme.gridPictureStyle == 'circle'
            ? null
            : BorderRadius.circular(theme.gridRoundedValue.toDouble()),
      ),
      child: AppIcon(
        iconKey: iconKey,
        size: size,
        color: theme.gridBtnIconeColor, // Couleur de l'icône
      ),
    );
  }
}
