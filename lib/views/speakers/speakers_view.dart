import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_theme_model.dart';
import '../../models/app_settings_model.dart';
import '../../providers/speaker_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/storage_service.dart';
import '../../utils/responsive.dart';
import 'speaker_card.dart';
import '../../widgets/app_icon.dart';

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

  /// SEARCH
  Widget _buildSearchBar(AppThemeModel t, AppSettingsModel s, SpeakerProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: t.searchBarBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: provider.setSearchQuery,
          decoration: InputDecoration(
            hintText: '${s.searchText}...',
            prefixIcon: Padding(
                    padding: const EdgeInsets.all(10),
                    child: AppIcon(iconKey: s.searchIcon, size: 20, color: t.searchBarTextColor),
                  ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  /// TOGGLE LIST / GRID
  Widget _buildToggle(AppThemeModel t) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _toggleBtn(Icons.grid_view, true, t),
          const SizedBox(width: 8),
          _toggleBtn(Icons.view_list, false, t),
        ],
      ),
    );
  }

  Widget _toggleBtn(IconData icon, bool value, t) {
    final active = isGrid == value;

    return GestureDetector(
      onTap: () {
        setState(() => isGrid = value);
        StorageService.saveLayoutPreference('speakers', value);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active ? t.mainBtnPrimaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: active ? Colors.white : Colors.grey),
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
