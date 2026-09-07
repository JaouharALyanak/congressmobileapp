import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/program_model.dart';
import '../../models/speaker_model.dart';
import '../../providers/program_provider.dart';
import '../../providers/speaker_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/app_theme_model.dart';
import '../program/session_detail_view.dart';
import '../speakers/speaker_detail_view.dart';

class SearchResultsView extends StatefulWidget {
  const SearchResultsView({super.key});

  @override
  State<SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<SearchResultsView> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Charge tous les speakers si pas encore chargés
    Future.microtask(() {
      if (mounted) {
        final sp = context.read<SpeakerProvider>();
        if (sp.speakers.isEmpty) sp.loadInitial();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Combine tous les speakers disponibles (all + random, dédupliqués)
  List<Speaker> _allAvailableSpeakers(SpeakerProvider sp) {
    final seen = <int>{};
    final combined = <Speaker>[];
    for (final s in [...sp.speakers, ...sp.randomSpeakers]) {
      if (seen.add(s.id)) combined.add(s);
    }
    return combined;
  }

  List<ProgramItem> _searchSessions(ProgramProvider pp) {
    if (_query.length < 2) return [];
    final q = _query.toLowerCase();
    final seen = <int>{};
    final List<ProgramItem> results = [];
    for (final day in pp.days) {
      for (final root in day.items) {
        for (final item in [root, ...root.children]) {
          if (!item.isSession) continue;
          if (!seen.add(item.id)) continue;
          final title = item.displayTitle.toLowerCase();
          final desc = (item.session?.description ?? item.description)?.toLowerCase() ?? '';
          final location = (item.session?.room ?? item.location)?.toLowerCase() ?? '';
          final participants = item.session?.allParticipants
              .map((p) => p.fullName.toLowerCase())
              .join(' ') ?? '';
          if (title.contains(q) ||
              desc.contains(q) ||
              location.contains(q) ||
              participants.contains(q)) {
            results.add(item);
          }
        }
      }
    }
    return results;
  }

  List<Speaker> _searchSpeakers(SpeakerProvider sp) {
    if (_query.length < 2) return [];
    final q = _query.toLowerCase();
    return _allAvailableSpeakers(sp).where((s) {
      return s.firstName.toLowerCase().contains(q) ||
          s.lastName.toLowerCase().contains(q) ||
          s.title.toLowerCase().contains(q) ||
          s.cityName.toLowerCase().contains(q) ||
          s.specialityList.any((e) => e.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().theme;
    final s = context.watch<ThemeProvider>().settings;
    final pp = context.watch<ProgramProvider>();
    final sp = context.watch<SpeakerProvider>();

    final sessions = _searchSessions(pp);
    final speakers = _searchSpeakers(sp);
    final hasResults = sessions.isNotEmpty || speakers.isNotEmpty;

    return Scaffold(
      backgroundColor: t.eventBgColor,
      appBar: AppBar(
        backgroundColor: t.headerBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: '${s.searchText}...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
            border: InputBorder.none,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
          onChanged: (v) => setState(() => _query = v.trim()),
        ),
      ),
      body: _query.length < 2
          ? _buildHint(t, sp)
          : !hasResults
              ? _buildEmpty(t)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (sessions.isNotEmpty) ...[
                      _buildSectionTitle(s.programText, Icons.calendar_today, t),
                      const SizedBox(height: 10),
                      ...sessions.map((item) => _buildSessionTile(item, t, context)),
                      const SizedBox(height: 20),
                    ],
                    if (speakers.isNotEmpty) ...[
                      _buildSectionTitle(s.speakerText, Icons.people_alt_outlined, t),
                      const SizedBox(height: 10),
                      ...speakers.map((spk) => _buildSpeakerTile(spk, t, context)),
                    ],
                  ],
                ),
    );
  }

  Widget _buildHint(AppThemeModel t, SpeakerProvider sp) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: t.mainBtnPrimaryColor.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Rechercher dans le programme\net les speakers',
            textAlign: TextAlign.center,
            style: TextStyle(color: t.mainTextSecondaryColor, fontSize: 15),
          ),
          if (sp.isLoading) ...[
            const SizedBox(height: 20),
            SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: t.mainBtnPrimaryColor, strokeWidth: 2)),
            const SizedBox(height: 8),
            Text('Chargement des speakers...', style: TextStyle(color: t.mainTextSecondaryColor, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty(AppThemeModel t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: t.mainBtnPrimaryColor.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Aucun résultat pour\n"$_query"',
            textAlign: TextAlign.center,
            style: TextStyle(color: t.mainTextSecondaryColor, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, AppThemeModel t) {
    return Row(
      children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(color: t.mainBtnPrimaryColor, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 16, color: t.mainBtnPrimaryColor),
        const SizedBox(width: 6),
        Text(
          title.toUpperCase(),
          style: TextStyle(color: t.mainTextPrimaryColor, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildSessionTile(ProgramItem item, AppThemeModel t, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SessionDetailView(item: item, theme: t),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: t.cardBgColor,
          borderRadius: BorderRadius.circular(12),
          border: t.cardBorderSize > 0
              ? Border.all(color: t.cardBorderColor, width: t.cardBorderSize.toDouble())
              : null,
          boxShadow: t.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 4, height: 44,
              decoration: BoxDecoration(color: t.mainBtnPrimaryColor, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayTitle,
                    style: TextStyle(fontWeight: FontWeight.bold, color: t.cardTitleColor, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.startTime.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: t.mainTextSecondaryColor),
                        const SizedBox(width: 4),
                        Text(
                          '${item.startTime} - ${item.endTime}',
                          style: TextStyle(color: t.mainTextSecondaryColor, fontSize: 12),
                        ),
                        if (item.location != null && item.location!.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Icon(Icons.location_on_outlined, size: 12, color: t.mainTextSecondaryColor),
                          const SizedBox(width: 2),
                          Text(item.location!, style: TextStyle(color: t.mainTextSecondaryColor, fontSize: 12)),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: t.mainTextSecondaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeakerTile(Speaker speaker, AppThemeModel t, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SpeakerDetailView(speaker: speaker)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: t.cardBgColor,
          borderRadius: BorderRadius.circular(12),
          border: t.cardBorderSize > 0
              ? Border.all(color: t.cardBorderColor, width: t.cardBorderSize.toDouble())
              : null,
          boxShadow: t.cardShadow,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: SizedBox(
                width: 52, height: 52,
                child: speaker.photo != null && speaker.photo!.isNotEmpty
                    ? CachedNetworkImage(imageUrl: speaker.photo!, fit: BoxFit.cover)
                    : Container(
                        color: t.mainBtnPrimaryColor.withValues(alpha: 0.15),
                        child: Center(
                          child: Text(
                            speaker.firstName.isNotEmpty ? speaker.firstName[0].toUpperCase() : '?',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: t.mainBtnPrimaryColor),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${speaker.firstName} ${speaker.lastName}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: t.cardTitleColor, fontSize: 14),
                  ),
                  if (speaker.title.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      speaker.title,
                      style: TextStyle(color: t.mainTextSecondaryColor, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (speaker.cityName.isNotEmpty || speaker.countryName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      [speaker.cityName, speaker.countryName].where((e) => e.isNotEmpty).join(', '),
                      style: TextStyle(color: t.mainTextSecondaryColor.withValues(alpha: 0.7), fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: t.mainTextSecondaryColor),
          ],
        ),
      ),
    );
  }
}
