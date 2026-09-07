// lib/views/program/widgets/day_tab_bar.dart

import 'package:flutter/material.dart';
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

    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onDaySelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? day.btnColor : day.btnInactiveColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                day.title,
                style: TextStyle(
                  color: isSelected ? day.textColor : day.textInactiveColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
