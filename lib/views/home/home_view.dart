import 'dart:async';
import 'package:event_app/providers/program_provider.dart';
import 'package:event_app/providers/speaker_provider.dart';
import 'package:event_app/providers/sponsor_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../search/search_results_view.dart';
import 'home_banner.dart';
import 'home_shortcuts.dart';
import 'home_speakers.dart';
import 'home_sponsors.dart';
import 'home_program.dart';

class HomeView extends StatefulWidget {
  final Function(int) onTabChanged;

  const HomeView({super.key, required this.onTabChanged});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final t = tp.theme;
    final s = tp.settings;

    return RefreshIndicator(
      color: t.mainBtnPrimaryColor,
      onRefresh: () async {
        await Future.wait([
          context.read<ThemeProvider>().loadTheme(forceRefresh: true),
          context.read<ProgramProvider>().loadProgram(forceRefresh: true),
          context.read<SpeakerProvider>().loadRandomSpeakers(),
          context.read<SponsorProvider>().loadSponsors(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SearchResultsView(),
                  ),
                ),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: t.cardBgColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: t.cardShadow,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      Icon(Icons.search, color: t.mainTextSecondaryColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${s.searchText}...',
                          style: TextStyle(
                            color: t.mainTextSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ────────────────────────────────────────────────────────
            HomeBanner(theme: t),
            HomeShortcuts(
              theme: t,
              settings: s,
              onNavigate: widget.onTabChanged,
            ),
            const SizedBox(height: 5),
            HomeProgram(onNavigateToProgramTab: widget.onTabChanged),
            const SizedBox(height: 5),
            HomeSpeakers(onNavigateToSpeakersTab: widget.onTabChanged),
            const SizedBox(height: 5),
            HomeSponsors(onNavigateToSponsorsTab: widget.onTabChanged),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
