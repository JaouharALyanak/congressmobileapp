import 'package:flutter/material.dart';

/// Screen is considered a tablet when its shorter side is >= 600 dp.
bool isTablet(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return size.shortestSide >= 600;
}

/// Largeur maximale du contenu sur grand écran (liste, détail…).
const double kMaxContentWidth = 720;

/// Responsive font size: +20% on tablets.
double rFs(BuildContext context, double size) =>
    isTablet(context) ? size * 1.2 : size;

/// Responsive sizing for dimensions (icons, images, paddings): +25% on tablets.
double rS(BuildContext context, double size) =>
    isTablet(context) ? size * 1.25 : size;

/// Enveloppe un widget dans une contrainte de largeur max centrée.
/// Utilisé pour éviter que les listes ne s'étirent sur toute la largeur tablette.
Widget maxWidthBox({required Widget child, double maxWidth = kMaxContentWidth}) {
  return Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}
