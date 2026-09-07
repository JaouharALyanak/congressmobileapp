import 'package:event_app/views/abstracts/abstracts_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        // ── Header avec Toggle à DROITE ──────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end, // Aligne à droite
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: t.cardBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: t.mainTextSecondaryColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    _ToggleBtn(
                      icon: Icons.grid_view_rounded,
                      selected: _isGrid,
                      selectedColor: t.mainBtnPrimaryColor,
                      onTap: () {
                        setState(() => _isGrid = true);
                        StorageService.saveLayoutPreference('infos', true);
                      },
                    ),
                    const SizedBox(width: 4),
                    _ToggleBtn(
                      icon: Icons.view_list_rounded,
                      selected: !_isGrid,
                      selectedColor: t.mainBtnPrimaryColor,
                      onTap: () {
                        setState(() => _isGrid = false);
                        StorageService.saveLayoutPreference('infos', false);
                      },
                    ),
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

  // ── VUE GRID (Taille réduite et centrée) ──────────────────
  Widget _buildGrid(BuildContext context, List<Map<String, dynamic>> items, t) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400), // Limite la largeur max
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: GridView.builder(
        key: const ValueKey('grid'),
        shrinkWrap: true, // Prend juste la place nécessaire
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0, // Carré parfait pour plus de compacité
        ),
        itemCount: items.length,
        itemBuilder: (context, index) =>
            _buildGridCard(context, items[index], t),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, Map<String, dynamic> item, t) {
    final bool enabled = item['enabled'] as bool;
    final Color accent = t.mainBtnPrimaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? item['action'] : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: enabled
                ? t.cardBgColor
                : t.cardBgColor.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: enabled
                  ? accent.withValues(alpha: 0.15)
                  : Colors.transparent,
              width: 1,
            ),
            boxShadow: t.cardShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: enabled
                      ? accent.withValues(alpha: 0.08)
                      : Colors.grey.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppIcon(
                    iconKey: item['icon'],
                    size: 22,
                    color: enabled
                        ? accent
                        : t.mainTextSecondaryColor.withValues(alpha: 0.4),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  item['text'],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    color: enabled
                        ? t.mainTextPrimaryColor
                        : t.mainTextSecondaryColor.withValues(alpha: 0.4),
                    fontSize: 13,
                    fontWeight: enabled ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── VUE LIST (Centrée) ───────────────────────────────────
  Widget _buildList(BuildContext context, List<Map<String, dynamic>> items, t) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 450,
      ), // Largeur max pour la liste
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

  Widget _buildListCard(BuildContext context, Map<String, dynamic> item, t) {
    final bool enabled = item['enabled'] as bool;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? item['action'] : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: t.cardBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: t.mainTextSecondaryColor.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: enabled
                      ? t.mainBtnPrimaryColor.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppIcon(
                  iconKey: item['icon'],
                  size: 20,
                  color: enabled
                      ? t.mainBtnPrimaryColor
                      : t.mainTextSecondaryColor.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item['text'],
                  style: TextStyle(
                    color: enabled
                        ? t.mainTextPrimaryColor
                        : t.mainTextSecondaryColor.withValues(alpha: 0.4),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (enabled)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: t.mainTextSecondaryColor.withValues(alpha: 0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── BOUTON TOGGLE ──────────────────────────────────────────
class _ToggleBtn extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: selected ? Colors.white : Colors.grey.shade400,
        ),
      ),
    );
  }
}
