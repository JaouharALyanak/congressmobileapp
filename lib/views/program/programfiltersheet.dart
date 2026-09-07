import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/program_provider.dart';
import '../../../widgets/app_icon.dart';

class ProgramFilterSheet extends StatelessWidget {
  final dynamic t;
  final dynamic s;

  const ProgramFilterSheet({super.key, required this.t, required this.s});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgramProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: t.cardBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AppIcon(
                      iconKey: s.filterIcon,
                      size: 18,
                      color: t.mainTextPrimaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filtre',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: t.mainTextPrimaryColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (provider.allAvailableRooms.isNotEmpty) ...[
              _buildLabel('Salles / Hall', t),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.allAvailableRooms.map((room) {
                  final isSelected = provider.selectedRooms.contains(room);
                  return _FilterChip(
                    label: room,
                    isSelected: isSelected,
                    onTap: () => provider.toggleRoom(room),
                    t: t,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // --- SECTION SPEAKERS ---
            if (provider.allAvailableSpeakers.isNotEmpty) ...[
              _buildLabel(s.speakerText, t),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.allAvailableSpeakers.map((speaker) {
                  final isSelected = provider.selectedSpeakerIds.contains(
                    speaker.id,
                  );
                  return _FilterChip(
                    label: speaker.fullName,
                    isSelected: isSelected,
                    onTap: () => provider.toggleSpeaker(speaker.id),
                    t: t,
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
            ],

            // --- BOUTONS ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      provider.clearFilters();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: t.mainTextSecondaryColor.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Réinitialiser',
                      style: TextStyle(color: t.mainTextSecondaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t.headerBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Appliquer',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, dynamic t) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: t.headerBg,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final dynamic t;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? t.headerBg : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? t.headerBg
                : t.mainTextSecondaryColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : t.mainTextPrimaryColor,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check, size: 14, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}
