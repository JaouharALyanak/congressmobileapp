import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/program_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/app_theme_model.dart';
import '../../models/program_model.dart';
import 'session_detail_sheet.dart';
import 'session_detail_view.dart';

class AgendaView extends StatelessWidget {
  const AgendaView({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().theme;
    final s = context.watch<ThemeProvider>().settings;
    final provider = context.watch<ProgramProvider>();
    final agendaByDay = provider.agendaByDay;

    return Scaffold(
      backgroundColor: t.eventBgColor,
      appBar: AppBar(
        backgroundColor: t.headerBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Mon agenda',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ],
        ),
      ),
      body: agendaByDay.isEmpty
          ? _buildEmpty(t, s.programText)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final group in agendaByDay) ...[
                  _buildDayHeader(group.day, t),
                  const SizedBox(height: 10),
                  for (final item in group.items)
                    _buildSessionTile(context, item, group.day, t),
                  const SizedBox(height: 20),
                ],
              ],
            ),
    );
  }

  Widget _buildEmpty(AppThemeModel t, String programText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 72, color: t.mainBtnPrimaryColor.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Aucune session sauvegardée',
            style: TextStyle(color: t.mainTextPrimaryColor, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur ♡ dans le $programText\npour sauvegarder une session',
            textAlign: TextAlign.center,
            style: TextStyle(color: t.mainTextSecondaryColor, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeader(ProgramDay day, AppThemeModel t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: day.btnColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 15, color: day.textColor),
          const SizedBox(width: 8),
          Text(
            day.title,
            style: TextStyle(color: day.textColor, fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: day.textColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_countSessions(day)} session(s)',
              style: TextStyle(color: day.textColor, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  int _countSessions(ProgramDay day) => day.items.length;

  Widget _buildSessionTile(BuildContext context, ProgramItem item, ProgramDay day, AppThemeModel t) {
    return GestureDetector(
      onTap: () {
        if (item.isSession) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SessionDetailView(item: item, theme: t),
            ),
          );
        } else if ((item.description?.isNotEmpty ?? false) || item.location != null) {
          SessionDetailSheet.showOther(context, item: item, theme: t);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: t.cardBgColor,
          borderRadius: BorderRadius.circular(12),
          border: t.cardBorderSize > 0
              ? Border.all(color: t.cardBorderColor, width: t.cardBorderSize.toDouble())
              : null,
          boxShadow: t.cardShadow,
        ),
        child: Row(
          children: [
            // Colored left bar
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: t.mainBtnPrimaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayTitle,
                    style: TextStyle(fontWeight: FontWeight.bold, color: t.cardTitleColor, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: t.mainTextSecondaryColor),
                      const SizedBox(width: 4),
                      Text(
                        '${item.startTime} - ${item.endTime}',
                        style: TextStyle(color: t.mainTextSecondaryColor, fontSize: 12),
                      ),
                      if (item.session?.room != null && item.session!.room!.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Icon(Icons.location_on_outlined, size: 12, color: t.mainTextSecondaryColor),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            item.session!.room!,
                            style: TextStyle(color: t.mainTextSecondaryColor, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Speakers preview
                  if (item.session != null && item.session!.speakers.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.session!.speakers.map((p) => p.fullName).join(', '),
                      style: TextStyle(color: t.mainTextSecondaryColor.withValues(alpha: 0.7), fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: t.mainTextSecondaryColor),
          ],
        ),
      ),
    );
  }
}
