import 'package:event_app/views/abstracts/abstracts_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/app_theme_model.dart';
import '../../providers/theme_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/app_icon.dart';
import 'president_word_view.dart';
import 'event_info_view.dart';
import '../committee/committee_view.dart';
import '../vod/vod_list_view.dart';
import '../faq/faq_view.dart';

class InfosView extends StatefulWidget {
  const InfosView({super.key});

  @override
  State<InfosView> createState() => _InfosViewState();
}

class _InfosViewState extends State<InfosView> {
  bool _isGrid = true;

  @override
  void initState() {
    super.initState();
    _loadLayoutPref();
  }

  Future<void> _loadLayoutPref() async {
    final saved = await StorageService.getLayoutPreference('infos');
    if (saved != null && mounted) setState(() => _isGrid = saved);
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final t = tp.theme;
    final s = tp.settings;

    final List<Map<String, dynamic>> menuItems = [
      if (tp.motMenu == 1)
        {
          'text': s.presidentWordText,
          'icon': s.presidentWordIcon,
          'enabled': true,
          'action': () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PresidentWordView()),
          ),
        },
      if (tp.membreMenu == 1)
        {
          'text': s.committeeText,
          'icon': s.committeeIcon,
          'enabled': true,
          'action': () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CommitteeView()),
          ),
        },
      if (tp.abstractMenu == 1)
        {
          'text': s.posterText,
          'icon': s.posterIcon,
          'enabled': true,
          'action': () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AbstractsView()),
          ),
        },
      if (tp.videoMenu == 1)
        {
          'text': s.vodText,
          'icon': s.vodIcon,
          'enabled': true,
          'action': () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VodListView()),
          ),
        },
      if (tp.infosMenu == 1)
        {
          'text': s.infoText,
          'icon': s.infoIcon,
          'enabled': true,
          'action': () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EventInfoView()),
          ),
        },
      if (tp.faqMenu == 1)
        {
          'text': s.faqText,
          'icon': s.faqIcon,
          'enabled': true,
          'action': () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FaqView()),
          ),
        },
    ];

    return Column(
      children: [
        // ── Header avec Apple Segmented Control à DROITE ─────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0x14767680), // Apple recessed segment background
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _segmentBtn(Icons.grid_view_rounded, true, t),
                    _segmentBtn(Icons.view_list_rounded, false, t),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Contenu CENTRÉ verticalement et horizontalement ──
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 48),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isGrid
                    ? _buildGrid(context, menuItems, t)
                    : _buildList(context, menuItems, t),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _segmentBtn(IconData icon, bool value, AppThemeModel t) {
    final active = _isGrid == value;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!active) {
          HapticFeedback.selectionClick();
          setState(() => _isGrid = value);
          StorageService.saveLayoutPreference('infos', value);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 17,
          color: active ? t.mainBtnPrimaryColor : const Color(0xFF8E8E93),
        ),
      ),
    );
  }

  // ── VUE GRID (Apple Control Center / Widget style) ────────
  Widget _buildGrid(BuildContext context, List<Map<String, dynamic>> items, AppThemeModel t) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: GridView.builder(
        key: const ValueKey('grid'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) =>
            _buildGridCard(context, items[index], t),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, Map<String, dynamic> item, AppThemeModel t) {
    final bool enabled = item['enabled'] as bool;
    final Color accent = t.mainBtnPrimaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled
            ? () {
                HapticFeedback.lightImpact();
                (item['action'] as VoidCallback)();
              }
            : null,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          decoration: BoxDecoration(
            color: enabled
                ? (isDark ? const Color(0xFF1C1C1E) : Colors.white)
                : (isDark ? const Color(0xFF1C1C1E).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.16)
                  : Colors.white.withValues(alpha: 0.95),
              width: 1.0,
            ),
            boxShadow: enabled
                ? [
                    // Apple-style soft ambient occlusion shadow
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.28 : 0.06,
                      ),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                    // Active accent color ambient glow (like navbar pill)
                    if (!isDark)
                      BoxShadow(
                        color: accent.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 3),
                        spreadRadius: 0,
                      ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 200),
                child: AppIcon(
                  iconKey: item['icon'],
                  size: 34,
                  color: enabled
                      ? accent
                      : t.mainTextSecondaryColor.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  item['text'] as String,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? accent
                        : t.mainTextSecondaryColor.withValues(alpha: 0.4),
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── VUE LIST (Apple Inset Grouped style) ───────────────────
  Widget _buildList(BuildContext context, List<Map<String, dynamic>> items, AppThemeModel t) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 450),
      padding: const EdgeInsets.all(24),
      child: ListView.separated(
        key: const ValueKey('list'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _buildListCard(context, items[index], t),
      ),
    );
  }

  Widget _buildListCard(BuildContext context, Map<String, dynamic> item, AppThemeModel t) {
    final bool enabled = item['enabled'] as bool;
    final Color accent = t.mainBtnPrimaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled
            ? () {
                HapticFeedback.lightImpact();
                (item['action'] as VoidCallback)();
              }
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: enabled
                ? (isDark ? const Color(0xFF1C1C1E) : Colors.white)
                : (isDark ? const Color(0xFF1C1C1E).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.16)
                  : Colors.white.withValues(alpha: 0.95),
              width: 1.0,
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.28 : 0.05,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                    if (!isDark)
                      BoxShadow(
                        color: accent.withValues(alpha: 0.10),
                        blurRadius: 14,
                        offset: const Offset(0, 2),
                      ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              AppIcon(
                iconKey: item['icon'],
                size: 24,
                color: enabled
                    ? accent
                    : t.mainTextSecondaryColor.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item['text'],
                  style: TextStyle(
                    color: enabled
                        ? accent
                        : t.mainTextSecondaryColor.withValues(alpha: 0.4),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (enabled)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: accent.withValues(alpha: 0.45),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
