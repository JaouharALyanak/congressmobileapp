import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_theme_model.dart';
import '../../providers/committee_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/storage_service.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_icon.dart';
import 'committee_card.dart';

class CommitteeView extends StatefulWidget {
  const CommitteeView({super.key});

  @override
  State<CommitteeView> createState() => _CommitteeViewState();
}

class _CommitteeViewState extends State<CommitteeView> {
  final ScrollController _scrollController = ScrollController();
  bool isGrid = true;

  @override
  void initState() {
    super.initState();
    _loadLayoutPref();
    Future.microtask(() {
      if (mounted) context.read<CommitteeProvider>().load();
    });
  }

  Future<void> _loadLayoutPref() async {
    final saved = await StorageService.getLayoutPreference('committee');
    if (saved != null && mounted) setState(() => isGrid = saved);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommitteeProvider>();
    final t = context.watch<ThemeProvider>().theme;
    final s = context.watch<ThemeProvider>().settings;

    return Scaffold(
      backgroundColor: t.eventBgColor,
      appBar: AppBar(
        backgroundColor: t.headerBg,
        elevation: 0,
        title: Text(
          s.committeeText,
          style: TextStyle(color: t.headerColorTitle, fontSize: 18),
        ),
        leading: BackButton(color: t.headerColorTitle),
        actions: [
          if (t.headerLogoState == 'visible' && t.headerLogoUrl != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Transform.rotate(
                  angle: t.headerRotateDegree * (3.14159 / 180),
                  child: Image.network(
                    t.headerLogoUrl!,
                    height: 36,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox(),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(t, s, provider),
          _buildToggle(t),
          Expanded(child: _buildContent(provider, t)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppThemeModel t, s, CommitteeProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: t.searchBarBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: provider.setSearchQuery,
          style: TextStyle(color: t.searchBarTextColor),
          decoration: InputDecoration(
            hintText: '${s.searchText}...',
            hintStyle: TextStyle(color: t.searchBarTextColor.withValues(alpha: 0.6)),
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

  Widget _toggleBtn(IconData icon, bool value, AppThemeModel t) {
    final active = isGrid == value;
    return GestureDetector(
      onTap: () {
        setState(() => isGrid = value);
        StorageService.saveLayoutPreference('committee', value);
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

  Widget _buildContent(CommitteeProvider provider, AppThemeModel t) {
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator(color: t.headerBg));
    }

    final members = provider.flatMembers;

    if (members.isEmpty) {
      return Center(
        child: Text(
          'Aucun résultat',
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
          maxCrossAxisExtent: 160,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        itemCount: members.length,
        itemBuilder: (_, i) => CommitteeCard(member: members[i]),
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
          itemCount: members.length,
          itemBuilder: (_, i) => CommitteeCard(member: members[i], isGrid: false),
        ),
      ),
    );
  }
}
