import 'package:flutter/material.dart';

/// Affiche un bottom sheet permettant à l'utilisateur de choisir
/// le délai de notification avant une session.
///
/// Retourne le nombre de minutes choisi, ou `null` si annulé.
///
/// Usage :
/// ```dart
/// final minutes = await showNotificationDelayPicker(context, accentColor: primaryColor);
/// if (minutes != null) provider.toggleAgendaItem(item, delayMinutes: minutes);
/// ```
Future<int?> showNotificationDelayPicker(
  BuildContext context, {
  Color accentColor = const Color(0xFF6A1B62),
}) {
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _NotificationDelaySheet(accentColor: accentColor),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _NotificationDelaySheet extends StatefulWidget {
  final Color accentColor;
  const _NotificationDelaySheet({required this.accentColor});

  @override
  State<_NotificationDelaySheet> createState() =>
      _NotificationDelaySheetState();
}

class _NotificationDelaySheetState extends State<_NotificationDelaySheet> {
  int _selected = 10;

  static const List<_DelayOption> _options = [
    _DelayOption(minutes: 5,  label: '5 minutes avant'),
    _DelayOption(minutes: 10, label: '10 minutes avant'),
    _DelayOption(minutes: 15, label: '15 minutes avant'),
    _DelayOption(minutes: 30, label: '30 minutes avant'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Titre
          Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                color: widget.accentColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Me rappeler…',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: widget.accentColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Options
          ..._options.map(
            (opt) => _DelayTile(
              option: opt,
              selected: _selected == opt.minutes,
              accentColor: widget.accentColor,
              onTap: () => setState(() => _selected = opt.minutes),
            ),
          ),

          const SizedBox(height: 20),

          // Bouton confirmer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(_selected),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              child: const Text('Ajouter au programme'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DelayOption {
  final int minutes;
  final String label;
  const _DelayOption({required this.minutes, required this.label});
}

class _DelayTile extends StatelessWidget {
  final _DelayOption option;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _DelayTile({
    required this.option,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: 0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? accentColor : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.alarm_rounded,
              size: 18,
              color: selected ? accentColor : Colors.grey.shade400,
            ),
            const SizedBox(width: 12),
            Text(
              option.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? accentColor : Colors.grey.shade700,
              ),
            ),
            const Spacer(),
            AnimatedOpacity(
              opacity: selected ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: Icon(Icons.check_circle_rounded,
                  size: 20, color: accentColor),
            ),
          ],
        ),
      ),
    );
  }
}
