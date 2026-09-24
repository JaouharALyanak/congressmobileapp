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
            // ── Search bar (Apple SearchField capsule) ─────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SearchResultsView(),
                  ),
                ),
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
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      Icon(
                        Icons.search_rounded,
                        color: t.mainTextSecondaryColor.withValues(alpha: 0.7),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${s.searchText}...',
                          style: TextStyle(
                            color: t.mainTextSecondaryColor.withValues(
                              alpha: 0.65,
                            ),
                            fontSize: 15,
                            letterSpacing: -0.2,
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
