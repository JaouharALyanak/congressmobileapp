import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_theme_model.dart';
import '../../models/app_settings_model.dart';
import '../../providers/abstract_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/storage_service.dart';
import '../../utils/responsive.dart';
import 'abstract_card.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/app_icon.dart';

class AbstractsView extends StatefulWidget {
  const AbstractsView({super.key});

  @override
  State<AbstractsView> createState() => _AbstractsViewState();
}

class _AbstractsViewState extends State<AbstractsView> {
  final ScrollController _scrollController = ScrollController();
  bool isGrid = false;

  @override
  void initState() {
    super.initState();
    _loadLayoutPref();
    Future.microtask(() {
      if (mounted) context.read<AbstractProvider>().loadInitial();
    });
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadLayoutPref() async {
    final saved = await StorageService.getLayoutPreference('abstracts');
    if (saved != null && mounted) setState(() => isGrid = saved);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AbstractProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AbstractProvider>();
    final t = context.watch<ThemeProvider>().theme;
    final s = context.watch<ThemeProvider>().settings;

    return Scaffold(
      backgroundColor: t.eventBgColor,
      appBar: AppBarWidget(title: s.posterText),
      body: Column(
        children: [
          _buildSearchBar(t, s, provider),
          _buildToggle(t),
          Expanded(child: _buildContent(provider, t)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppThemeModel t, AppSettingsModel s, AbstractProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: t.searchBarBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
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
      ),
    );
  }

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
        StorageService.saveLayoutPreference('abstracts', value);
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

  Widget _buildContent(AbstractProvider provider, t) {
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator(color: t.headerBg));
    }

    if (provider.abstracts.isEmpty) {
      return Center(
        child: Text(
          'Aucun abstract disponible',
          style: TextStyle(color: t.mainTextSecondaryColor),
        ),
      );
    }

    if (isGrid) {
      return GridView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 200,
        ),
        itemCount: provider.abstracts.length + (provider.hasNext ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.abstracts.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: t.headerBg),
              ),
            );
          }
          return AbstractCard(
            abstract: provider.abstracts[index],
            isGrid: true,
          );
        },
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
        child: ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: provider.abstracts.length + (provider.hasNext ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == provider.abstracts.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(color: t.headerBg)),
              );
            }
            return AbstractCard(abstract: provider.abstracts[index], isGrid: false);
          },
        ),
      ),
    );
  }
}
