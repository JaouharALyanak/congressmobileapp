import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/program_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/app_theme_model.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_icon.dart';
import 'day_tab_bar.dart';
import 'program_item_card.dart';
import 'program_group_card.dart';
import 'programfiltersheet.dart';
import 'programagendasheet.dart';

class ProgramView extends StatefulWidget {
  const ProgramView({super.key});
  @override
  State<ProgramView> createState() => _ProgramViewState();
}

class _ProgramViewState extends State<ProgramView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgramProvider>().loadProgram(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = themeProvider.theme;
    final settings = themeProvider.settings;
    final provider = context.watch<ProgramProvider>();

    return Scaffold(
      backgroundColor: theme.eventBgColor,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
            child: Column(
              children: [
                // --- SEARCH BAR + ACTIONS (Apple HIG) ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.cardBgColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.06),
                              width: 0.75,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            onChanged: (v) => provider.setSearch(v),
                            style: TextStyle(
                              color: theme.mainTextPrimaryColor,
                              fontSize: 15,
                              letterSpacing: -0.2,
                            ),
                            decoration: InputDecoration(
                              hintText: settings.searchText,
                              hintStyle: TextStyle(
                                color: theme.mainTextSecondaryColor.withValues(
                                  alpha: 0.65,
                                ),
                                fontSize: 15,
                                letterSpacing: -0.2,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(11),
                                child: Icon(
                                  Icons.search_rounded,
                                  size: 20,
                                  color: theme.mainTextSecondaryColor.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Action 1 : Agenda
                      _buildTopAction(
                        settings.agendaText,
                        settings.agendaIcon,
                        theme.headerBg,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) =>
                                ProgramAgendaSheet(t: theme, s: settings),
                          );
                        },
                      ),

                      const SizedBox(width: 8),

                      // Action 2 : Filter
                      _buildTopAction(
                        settings.filterText,
                        settings.filterIcon,
                        provider.hasActiveFilters
                            ? theme.mainBtnSecondaryColor
                            : theme.headerBg,
                        isActive: provider.hasActiveFilters,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) =>
                                ProgramFilterSheet(t: theme, s: settings),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                DayTabBar(
                  days: provider.days,
                  selectedIndex: provider.selectedDayIndex,
                  onDaySelected: (i) => provider.selectDay(i),
                ),

                const SizedBox(height: 6),

                Expanded(
                  child: provider.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: theme.headerBg,
                          ),
                        )
                      : RefreshIndicator(
                          color: theme.headerBg,
                          onRefresh: () => provider.loadProgram(forceRefresh: true),
                          child: provider.allFilteredItems.isEmpty
                              ? _buildEmptyState(theme, provider)
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    16,
                                    16,
                                    48,
                                  ),
                                  itemCount: provider.allFilteredItems.length,
                                  itemBuilder: (context, index) {
                                    final items = provider.allFilteredItems;
                                    final current = items[index];

                                    bool showHeader = false;
                                    String headerText = '';
                                    if (index == 0) {
                                      showHeader = true;
                                      headerText = _getPeriodName(
                                        current.startTime,
                                      );
                                    } else {
                                      final prev = items[index - 1];
                                      if (_getPeriodName(prev.startTime) !=
                                          _getPeriodName(current.startTime)) {
                                        showHeader = true;
                                        headerText = _getPeriodName(
                                          current.startTime,
                                        );
                                      }
                                    }

                                    final dayDate = provider.dateForItem(
                                      current.id,
                                    );
                                    final isLast = index == items.length - 1;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (showHeader)
                                          _buildPeriodHeader(headerText, theme),
                                        if (current.isGroup)
                                          ProgramGroupCard(
                                            item: current,
                                            theme: theme,
                                            isLast: isLast,
                                            programDayDate: dayDate,
                                          )
                                        else
                                          ProgramItemCard(
                                            item: current,
                                            theme: theme,
                                            isLast: isLast,
                                            programDayDate: dayDate,
                                          ),
                                      ],
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopAction(
    String label,
    String iconKey,
    Color color, {
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.16)
              : const Color(0x12767680),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? color.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.05),
            width: 0.75,
          ),
        ),
        child: Center(
          child: AppIcon(
            iconKey: iconKey,
            size: 19,
            color: isActive ? color : const Color(0xFF636366),
          ),
        ),
      ),
    );
  }

  String _getPeriodName(String time) {
    final hour = int.tryParse(time.split(':')[0]) ?? 0;
    return hour < 13 ? 'Matin' : 'Après-midi';
  }

  Widget _buildPeriodHeader(String text, AppThemeModel theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              color: theme.mainTextPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Divider(
              color: theme.mainTextSecondaryColor.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppThemeModel theme, ProgramProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.mainTextSecondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun résultat trouvé',
            style: TextStyle(color: theme.mainTextSecondaryColor, fontSize: 16),
          ),
          if (provider.hasActiveFilters)
            TextButton(
              onPressed: () => provider.clearFilters(),
              child: Text(
                'Effacer les filtres',
                style: TextStyle(color: theme.headerBg),
              ),
            ),
        ],
      ),
    );
  }
}
