// lib/views/program/widgets/session_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/program_model.dart';
import '../../../models/app_theme_model.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/app_icon.dart';
import '../../../utils/color_parser.dart'; // Import crucial

class SessionDetailSheet extends StatelessWidget {
  final ProgramItem item;
  final AppThemeModel theme;

  const SessionDetailSheet({
    super.key,
    required this.item,
    required this.theme,
  });

  static void showSession(
    BuildContext context, {
    required ProgramItem item,
    required AppThemeModel theme,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        barrierDismissible: true,
        pageBuilder: (_, _, _) => _SessionFullPage(item: item, theme: theme),
        transitionsBuilder: (_, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
      ),
    );
  }

  static void showOther(
    BuildContext context, {
    required ProgramItem item,
    required AppThemeModel theme,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _OtherBottomSheet(item: item, theme: theme),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _SessionFullPage extends StatelessWidget {
  final ProgramItem item;
  final AppThemeModel theme;

  const _SessionFullPage({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    final cardStyle = item.cardStyle;
    final session = item.session;

    // --- RÉSOLUTION DES COULEURS ---
    final Color resolvedBg = ColorParser.parse(
      cardStyle.cardBgColor,
      fallback: theme.cardBgColor,
    );
    final Color resolvedIcon = ColorParser.parse(
      cardStyle.cardIconeColor,
      fallback: theme.cardIconeColor,
    );
    final Color resolvedTitle = ColorParser.parse(
      cardStyle.cardTitleColor,
      fallback: theme.cardTitleColor,
    );
    final Color resolvedTime = ColorParser.parse(
      cardStyle.cardTimesColor,
      fallback: theme.cardTimesColor,
    );
    final Color resolvedBorder = ColorParser.parse(
      cardStyle.cardBorderColor,
      fallback: theme.cardBorderColor,
    );

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.88,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: theme.eventBgColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: resolvedBg,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      border: cardStyle.cardBorderSize > 0
                          ? Border.all(
                              color: resolvedBorder,
                              width: cardStyle.cardBorderSize.toDouble(),
                            )
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: resolvedIcon.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: resolvedIcon,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: resolvedIcon.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: AppIcon(
                                iconKey: item.icon,
                                size: 20,
                                color: resolvedIcon,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: resolvedIcon.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Session',
                                style: TextStyle(
                                  color: resolvedIcon,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.displayTitle,
                          style: TextStyle(
                            color: resolvedTitle,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: resolvedTime,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.startTime} – ${item.endTime}',
                              style: TextStyle(
                                color: resolvedTime,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            if (session?.room != null) ...[
                              const SizedBox(width: 12),
                              Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: resolvedTime,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                session!.room!,
                                style: TextStyle(
                                  color: resolvedTime,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Corps
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.description != null ||
                              session?.description != null) ...[
                            _SectionLabel(
                              label: 'Description',
                              color: theme.timelineBtnColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.description ?? session!.description!,
                              style: TextStyle(
                                color: theme.mainTextSecondaryColor,
                                fontSize: 13,
                                height: 1.55,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (session != null &&
                              session.speakers.isNotEmpty) ...[
                            _SectionLabel(
                              label: context.read<ThemeProvider>().settings.speakerText,
                              color: theme.timelineBtnColor,
                            ),
                            const SizedBox(height: 10),
                            _PersonList(
                              persons: session.speakers,
                              theme: theme,
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (session != null &&
                              session.moderators.isNotEmpty) ...[
                            _SectionLabel(
                              label: context.read<ThemeProvider>().settings.moderatorText,
                              color: theme.timelineBtnColor,
                            ),
                            const SizedBox(height: 10),
                            _PersonList(
                              persons: session.moderators,
                              theme: theme,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OtherBottomSheet extends StatelessWidget {
  final ProgramItem item;
  final AppThemeModel theme;

  const _OtherBottomSheet({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    final cardStyle = item.cardStyle;
    final Color resolvedIcon = ColorParser.parse(
      cardStyle.cardIconeColor,
      fallback: theme.cardIconeColor,
    );
    final Color resolvedTime = ColorParser.parse(
      cardStyle.cardTimesColor,
      fallback: theme.cardTimesColor,
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.88,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: theme.eventBgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: resolvedIcon.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: AppIcon(
                          iconKey: item.icon,
                          size: 18,
                          color: resolvedIcon,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.displayTitle,
                              style: TextStyle(
                                color: theme.mainTextPrimaryColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.startTime} – ${item.endTime}',
                              style: TextStyle(
                                color: resolvedTime,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.location != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: resolvedTime,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.location!,
                          style: TextStyle(color: resolvedTime, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 10),
                  Text(
                    item.description ?? 'Aucune description disponible.',
                    style: TextStyle(
                      color: theme.mainTextSecondaryColor,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          color: color,
          margin: const EdgeInsets.only(right: 8),
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _PersonList extends StatelessWidget {
  final List<ProgramPerson> persons;
  final AppThemeModel theme;
  const _PersonList({required this.persons, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: persons
          .map((p) => _PersonTile(person: p, theme: theme))
          .toList(),
    );
  }
}

class _PersonTile extends StatelessWidget {
  final ProgramPerson person;
  final AppThemeModel theme;
  const _PersonTile({required this.person, required this.theme});

  @override
  Widget build(BuildContext context) {
    final initials =
        (person.firstName.isNotEmpty ? person.firstName[0] : '') +
        (person.lastName.isNotEmpty ? person.lastName[0] : '');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.timelineBtnColor.withValues(alpha: 0.12),
              shape: theme.gridPictureStyle == 'circle'
                  ? BoxShape.circle
                  : BoxShape.rectangle,
              borderRadius: theme.gridPictureStyle == 'circle'
                  ? null
                  : BorderRadius.circular(theme.gridRoundedValue.toDouble()),
            ),
            child: person.photo != null
                ? ClipRRect(
                    borderRadius: theme.speakerPhotoBorderRadius,
                    child: Image.network(
                      person.photo!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: theme.timelineBtnColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: theme.timelineBtnColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.fullName,
                  style: TextStyle(
                    color: theme.mainTextPrimaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (person.title != null)
                  Text(
                    person.title!,
                    style: TextStyle(
                      color: theme.mainTextSecondaryColor,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
/*
class _YoutubeButton extends StatelessWidget {
  final String url;
  final AppThemeModel theme;
  const _YoutubeButton({required this.url, required this.theme});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.play_circle_outline_rounded),
        label: const Text('Voir la vidéo'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFEF4444)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
*/