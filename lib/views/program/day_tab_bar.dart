import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/program_model.dart';

class DayTabBar extends StatelessWidget {
  final List<ProgramDay> days;
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;

  const DayTabBar({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 4),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (!isSelected) {
                HapticFeedback.selectionClick();
                onDaySelected(index);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? day.btnColor
                    : (isDark
                        ? const Color(0xFF1C1C1E).withValues(alpha: 0.60)
                        : day.btnInactiveColor),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.28)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06)),
                  width: isSelected ? 1.0 : 0.75,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.28 : 0.08,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                        BoxShadow(
                          color: day.btnColor.withValues(alpha: 0.38),
                          blurRadius: 14,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.10 : 0.03,
                          ),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Text(
                day.title,
                style: TextStyle(
                  color: isSelected
                      ? day.textColor
                      : (isDark
                          ? const Color(0xFF8E8E93)
                          : day.textInactiveColor),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
