import 'package:flutter/material.dart';
import '../../models/program_model.dart';
import '../../models/app_theme_model.dart';
import '../../utils/color_parser.dart';
import '../../widgets/app_icon.dart';
import 'program_item_card.dart';

class ProgramGroupCard extends StatefulWidget {
  final ProgramItem item;
  final AppThemeModel theme;
  final bool isLast;
  final String programDayDate;

  const ProgramGroupCard({
    super.key,
    required this.item,
    required this.theme,
    this.isLast = false,
    required this.programDayDate,
  });

  @override
  State<ProgramGroupCard> createState() => _ProgramGroupCardState();
}

class _ProgramGroupCardState extends State<ProgramGroupCard> {
  bool _expanded = true; // default: expanded per spec

  @override
  Widget build(BuildContext context) {
    final style = widget.item.cardStyle;

    final Color resolvedBg = ColorParser.parse(
      style.cardBgColor,
      fallback: widget.theme.cardBgColor,
    );
    final Color resolvedTitle = ColorParser.parse(
      style.cardTitleColor,
      fallback: widget.theme.cardTitleColor,
    );
    final Color resolvedIcon = ColorParser.parse(
      style.cardIconeColor,
      fallback: widget.theme.cardIconeColor,
    );
    final Color resolvedBorder = ColorParser.parse(
      style.cardBorderColor,
      fallback: widget.theme.cardBorderColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Group header row (timeline + header card) ────────────────────
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTimeline(resolvedIcon),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeaderCard(
                  resolvedBg,
                  resolvedTitle,
                  resolvedIcon,
                  resolvedBorder,
                  style,
                ),
              ),
            ],
          ),
        ),

        // ── Children (AnimatedSize expand/collapse) ──────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Column(
                    children: widget.item.children.asMap().entries.map((e) {
                      return ProgramItemCard(
                        item: e.value,
                        theme: widget.theme,
                        isLast: e.key == widget.item.children.length - 1,
                        programDayDate: widget.programDayDate,
                      );
                    }).toList(),
                  ),
                )
              : const SizedBox(width: double.infinity, height: 20),
        ),
      ],
    );
  }

  Widget _buildHeaderCard(
    Color bg,
    Color title,
    Color icon,
    Color border,
    ProgramCardStyle style,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: style.cardBorderSize > 0
            ? Border.all(
                color: border,
                width: style.cardBorderSize.toDouble(),
              )
            : null,
        boxShadow: widget.theme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppIcon(iconKey: widget.item.icon, size: 18, color: icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.item.displayTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: title,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Children count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: icon.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.item.children.length}',
                    style: TextStyle(
                      color: icon,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Animated chevron
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 280),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: icon,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(Color resolvedIcon) {
    return SizedBox(
      width: 50,
      child: Column(
        children: [
          Text(
            widget.item.startTime,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: widget.theme.mainTextPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: resolvedIcon,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              width: 1.5,
              color: resolvedIcon.withValues(alpha: 0.2),
            ),
          ),
          if (!widget.isLast)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: resolvedIcon.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            widget.item.endTime,
            style: TextStyle(
              fontSize: 11,
              color: widget.theme.mainTextSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
