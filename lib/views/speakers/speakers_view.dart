import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/app_theme_model.dart';
import '../../models/app_settings_model.dart';
import '../../providers/speaker_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/storage_service.dart';
import '../../utils/responsive.dart';
import 'speaker_card.dart';

class SpeakersView extends StatefulWidget {
  const SpeakersView({super.key});

  @override
  State<SpeakersView> createState() => _SpeakersViewState();
}

class _SpeakersViewState extends State<SpeakersView> {
  final ScrollController _scrollController = ScrollController();

  bool isGrid = false;

  @override
  void initState() {
    super.initState();
    _loadLayoutPref();
    Future.microtask(() {
      if (mounted) context.read<SpeakerProvider>().loadInitial();
    });
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadLayoutPref() async {
    final saved = await StorageService.getLayoutPreference('speakers');
    if (saved != null && mounted) setState(() => isGrid = saved);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SpeakerProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SpeakerProvider>();
    final t = context.watch<ThemeProvider>().theme;
    final s = context.watch<ThemeProvider>().settings;

    return Column(
      children: [
        _buildSearchBar(t, s, provider),
        _buildToggle(t),
        Expanded(child: _buildContent(provider, t)),
      ],
    );
  }

  /// SEARCH (Apple SearchField)
  Widget _buildSearchBar(AppThemeModel t, AppSettingsModel s, SpeakerProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: t.cardBgColor,
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
          onChanged: provider.setSearchQuery,
          style: TextStyle(
            color: t.mainTextPrimaryColor,
            fontSize: 15,
            letterSpacing: -0.2,
          ),
          decoration: InputDecoration(
            hintText: '${s.searchText}...',
            hintStyle: TextStyle(
              color: t.mainTextSecondaryColor.withValues(alpha: 0.65),
              fontSize: 15,
              letterSpacing: -0.2,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(11),
              child: Icon(
                Icons.search_rounded,
                size: 20,
                color: t.mainTextSecondaryColor.withValues(alpha: 0.7),
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  /// TOGGLE LIST / GRID (Apple Segmented Control)
  Widget _buildToggle(AppThemeModel t) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 8),
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
    );
  }

  Widget _segmentBtn(IconData icon, bool value, AppThemeModel t) {
    final active = isGrid == value;

    return GestureDetector(
      onTap: () {
        if (!active) {
          HapticFeedback.selectionClick();
          setState(() => isGrid = value);
          StorageService.saveLayoutPreference('speakers', value);
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

  /// CONTENT
  Widget _buildContent(SpeakerProvider provider, t) {
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator(color: t.headerBg));
    }

    if (provider.speakers.isEmpty) {
      return Center(child: Text('Aucun résultat'));
    }

    /// 🔥 MODE GRID
    if (isGrid) {
      return GridView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),

        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 180,
        ),

        itemCount: provider.speakers.length + (provider.hasNext ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.speakers.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: t.headerBg),
              ),
            );
          }
          return SpeakerCard(speaker: provider.speakers[index], isGrid: true);
        },
      );
    }

    /// MODE LIST
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
        child: ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: provider.speakers.length + (provider.hasNext ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == provider.speakers.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(color: t.headerBg)),
              );
            }
            return SpeakerCard(speaker: provider.speakers[index], isGrid: false);
          },
        ),
      ),
    );
  }
}
