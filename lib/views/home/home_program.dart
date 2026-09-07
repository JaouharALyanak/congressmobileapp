import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/program_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/program_model.dart';
import '../program/program_item_card.dart';

class HomeProgram extends StatefulWidget {
  final Function(int) onNavigateToProgramTab;
  const HomeProgram({super.key, required this.onNavigateToProgramTab});

  @override
  State<HomeProgram> createState() => _HomeProgramState();
}

class _HomeProgramState extends State<HomeProgram> {
  Timer? _timerLocal;
  Timer? _timerApi;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<ProgramProvider>().loadProgram(forceRefresh: true);
    });

    // Recalcule les sessions toutes les minutes (local)
    _timerLocal = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });

    // Rafraîchit depuis l'API toutes les 15 minutes (avec cache-buster)
    _timerApi = Timer.periodic(const Duration(minutes: 15), (_) {
      if (mounted) context.read<ProgramProvider>().loadProgram(forceRefresh: true);
    });
  }

  @override
  void dispose() {
    _timerLocal?.cancel();
    _timerApi?.cancel();
    super.dispose();
  }

  /// Builds a flat list of all session items across all days and all levels
  /// (root items + children of group items).
  List<({ProgramItem item, DateTime start, DateTime? end})> _flattenAllSessions(
    List<ProgramDay> days,
    Map<int, String> itemDateMap,
  ) {
    final result = <({ProgramItem item, DateTime start, DateTime? end})>[];

    for (final day in days) {
      for (final root in day.items) {
        final candidates = [root, ...root.children];

        for (final item in candidates) {
          if (item.type != 'session') continue;
          if (item.session == null) continue;

          final dateStr = itemDateMap[item.id];
          if (dateStr == null) continue;

          final dayDate = DateTime.tryParse(dateStr);
          if (dayDate == null) continue;

          final parts = item.startTime.split(':');
          if (parts.length < 2) continue;

          final start = DateTime(
            dayDate.year,
            dayDate.month,
            dayDate.day,
            int.tryParse(parts[0]) ?? 0,
            int.tryParse(parts[1]) ?? 0,
          );

          DateTime? end;
          final endParts = item.endTime.split(':');
          if (endParts.length >= 2) {
            end = DateTime(
              dayDate.year,
              dayDate.month,
              dayDate.day,
              int.tryParse(endParts[0]) ?? 0,
              int.tryParse(endParts[1]) ?? 0,
            );
          }

          result.add((item: item, start: start, end: end));
        }
      }
    }

    return result;
  }

  List<ProgramItem> _getNextSessions(
    List<ProgramDay> days,
    Map<int, String> itemDateMap,
  ) {
    final now = DateTime.now();
    final all = _flattenAllSessions(days, itemDateMap);

    all.sort((a, b) => a.start.compareTo(b.start));

    // Include ongoing sessions (started but not yet ended) + upcoming sessions.
    // Sessions with no end_time are treated as 1-hour long so they eventually
    // rotate out instead of staying frozen at the top of the list forever.
    final upcoming = all
        .where((e) {
          final effectiveEnd =
              e.end ?? e.start.add(const Duration(hours: 1));
          return !effectiveEnd.isBefore(now);
        })
        .toList();
    if (upcoming.isNotEmpty) {
      return upcoming.take(2).map((e) => e.item).toList();
    }

    // Fallback: last 2 past sessions (uses same effectiveEnd for consistency)
    final past = all.where((e) {
      final effectiveEnd = e.end ?? e.start.add(const Duration(hours: 1));
      return effectiveEnd.isBefore(now);
    }).toList();
    return past.length >= 2
        ? past.sublist(past.length - 2).map((e) => e.item).toList()
        : past.map((e) => e.item).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgramProvider>();
    final t = context.watch<ThemeProvider>().theme;
    final s = context.watch<ThemeProvider>().settings;

    if (provider.isLoading && provider.days.isEmpty) {
      return const SizedBox.shrink();
    }

    // Now correctly accessing itemDateMap through the public getter
    final sessions = _getNextSessions(
      provider.days,
      provider.itemDateMap,
    ); // <--- MODIFIED HERE
    if (sessions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.programText,
                style: TextStyle(
                  color: t.mainTextPrimaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => widget.onNavigateToProgramTab(1),
                child: Text(
                  'Voir le programme →',
                  style: TextStyle(color: t.mainBtnPrimaryColor),
                ),
              ),
            ],
          ),
        ),

        // Sessions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: List.generate(sessions.length, (i) {
              return ProgramItemCard(
                item: sessions[i],
                theme: t,
                isLast: i == sessions.length - 1,
                programDayDate: provider.dateForItem(sessions[i].id),
              );
            }),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}
