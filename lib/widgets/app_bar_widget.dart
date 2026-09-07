import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/responsive.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const AppBarWidget({
    super.key,
    required this.title,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final t = tp.theme;

    final bool showLogo =
        t.headerLogoState == 'visible' && t.headerLogoUrl != null;

    return AppBar(
      backgroundColor: t.headerBg,
      elevation: 0,
      leading: showBackButton ? BackButton(color: t.headerColorTitle) : null,
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: t.headerColorTitle, fontSize: rFs(context, 18)),
      ),
      iconTheme: IconThemeData(color: t.headerColorTitle),
      actions: [
        if (showLogo)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Transform.rotate(
                angle:
                    t.headerRotateDegree *
                    (3.14159 / 180), // degrees to radians
                child: Image.network(
                  t.headerLogoUrl!,
                  height: rS(context, 36),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) => const SizedBox(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
