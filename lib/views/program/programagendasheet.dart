import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../providers/program_provider.dart';

class ProgramAgendaSheet extends StatefulWidget {
  final dynamic t; // Theme
  final dynamic s; // Settings

  const ProgramAgendaSheet({super.key, required this.t, required this.s});

  @override
  State<ProgramAgendaSheet> createState() => _ProgramAgendaSheetState();
}

class _ProgramAgendaSheetState extends State<ProgramAgendaSheet> {
  late DateTime _focusedDay;
  DateTime? _localRangeStart;
  DateTime? _localRangeEnd;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProgramProvider>();
    final eventDates = provider.eventDates;

    // Ouvrir directement sur la première date de l'événement
    _focusedDay =
        provider.rangeStart ??
        (eventDates.isNotEmpty ? eventDates.first : DateTime.now());
    _localRangeStart = provider.rangeStart;
    _localRangeEnd = provider.rangeEnd;
  }

  void _applyAndClose(BuildContext context) {
    context.read<ProgramProvider>().setRange(_localRangeStart, _localRangeEnd);
    Navigator.pop(context);
  }

  void _clearAndClose(BuildContext context) {
    setState(() {
      _localRangeStart = null;
      _localRangeEnd = null;
    });
    context.read<ProgramProvider>().setRange(null, null);
    Navigator.pop(context);
  }

  String _formatDate(DateTime d) {
    const months = [
      '',
      'jan',
      'fév',
      'mar',
      'avr',
      'mai',
      'juin',
      'juil',
      'août',
      'sep',
      'oct',
      'nov',
      'déc',
    ];
    return '${d.day} ${months[d.month]}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgramProvider>();
    final eventDates = provider.eventDates;

    final firstEventDay = eventDates.isNotEmpty
        ? eventDates.first
        : DateTime.utc(2025, 1, 1);
    final lastEventDay = eventDates.isNotEmpty
        ? eventDates.last
        : DateTime.utc(2027, 12, 31);

    final bool hasSelection = _localRangeStart != null;
    final bool isRange =
        _localRangeStart != null &&
        _localRangeEnd != null &&
        !isSameDay(_localRangeStart!, _localRangeEnd!);

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: widget.t.headerBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // ── HANDLE ──────────────────────────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── HEADER ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.white),
                    const SizedBox(width: 10),
                    const Text(
                      'Agenda',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // ── HINT / SELECTION LABEL ───────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: hasSelection
                ? Padding(
                    key: const ValueKey('selected'),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      isRange
                          ? 'Du ${_formatDate(_localRangeStart!)} au ${_formatDate(_localRangeEnd!)}'
                          : _localRangeEnd == null
                          ? 'Le ${_formatDate(_localRangeStart!)} — sélectionnez une 2ᵉ date ou confirmez'
                          : 'Le ${_formatDate(_localRangeStart!)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  )
                : Padding(
                    key: const ValueKey('hint'),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Appuyez sur une date de l\'événement',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                      ),
                    ),
                  ),
          ),

          // ── CALENDRIER ──────────────────────────────────────────────────
          Expanded(
            child: TableCalendar(
              firstDay: firstEventDay,
              lastDay: lastEventDay,
              focusedDay: _focusedDay,

              rangeSelectionMode: RangeSelectionMode.toggledOn,
              rangeStartDay: _localRangeStart,
              rangeEndDay: _localRangeEnd,

              // Seules les dates de l'événement sont cliquables
              enabledDayPredicate: (day) =>
                  eventDates.any((d) => isSameDay(d, day)),

              onRangeSelected: (start, end, focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                  _localRangeStart = start;
                  _localRangeEnd = end;
                });

                // Fermeture automatique quand la plage est complète
                if (start != null && end != null) {
                  context.read<ProgramProvider>().setRange(start, end);
                  Navigator.pop(context);
                }
              },

              startingDayOfWeek: StartingDayOfWeek.monday,

              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
              ),

              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.white70),
                weekendStyle: TextStyle(color: Colors.white70),
              ),

              calendarStyle: CalendarStyle(
                // Jours actifs (dates de l'événement)
                defaultTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                weekendTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                // Jours désactivés — grisés
                disabledTextStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.22),
                  fontWeight: FontWeight.normal,
                ),
                disabledDecoration: const BoxDecoration(shape: BoxShape.circle),
                // Plage
                rangeHighlightColor: Colors.white.withValues(alpha: 0.2),
                rangeStartDecoration: const BoxDecoration(
                  color: Colors.pinkAccent,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: const BoxDecoration(
                  color: Colors.pinkAccent,
                  shape: BoxShape.circle,
                ),
                withinRangeTextStyle: const TextStyle(color: Colors.white),
                withinRangeDecoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.rectangle,
                ),
                // Aujourd'hui
                todayDecoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(color: Colors.white),
                // Marqueur d'événement
                markerDecoration: const BoxDecoration(
                  color: Colors.pinkAccent,
                  shape: BoxShape.circle,
                ),
                // Jours sélectionnés (dates de l'événement surlignées)
                selectedDecoration: const BoxDecoration(
                  color: Colors.pinkAccent,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                outsideDaysVisible: false,
              ),

              // Surligner les dates de l'événement (hors sélection)
              selectedDayPredicate: (day) =>
                  eventDates.any((d) => isSameDay(d, day)) &&
                  !isSameDay(day, _localRangeStart ?? DateTime(0)) &&
                  !isSameDay(day, _localRangeEnd ?? DateTime(0)),
            ),
          ),

          // ── ACTIONS BAS DE PAGE ──────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Row(
              children: [
                // Bouton Effacer
                if (hasSelection)
                  TextButton.icon(
                    onPressed: () => _clearAndClose(context),
                    icon: const Icon(
                      Icons.clear,
                      size: 16,
                      color: Colors.white70,
                    ),
                    label: const Text(
                      'Effacer',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                const Spacer(),
                // Bouton Confirmer (surtout utile pour 1 seul jour)
                if (hasSelection)
                  ElevatedButton(
                    onPressed: () => _applyAndClose(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      isRange ? 'Voir la sélection' : 'Voir ce jour',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
