import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/speaker_provider.dart';
import '../../providers/theme_provider.dart';
import 'speaker/speaker_home_card.dart';

class HomeSpeakers extends StatefulWidget {
  final Function(int) onNavigateToSpeakersTab;
  const HomeSpeakers({super.key, required this.onNavigateToSpeakersTab});

  @override
  State<HomeSpeakers> createState() => _HomeSpeakersState();
}

class _HomeSpeakersState extends State<HomeSpeakers> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<SpeakerProvider>().loadRandomSpeakers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final speakerProvider = context.watch<SpeakerProvider>();
    final t = context.watch<ThemeProvider>().theme;
    final s = context.watch<ThemeProvider>().settings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header (Apple HIG) ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                s.speakerText,
                style: TextStyle(
                  color: t.mainTextPrimaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onNavigateToSpeakersTab(2);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: t.mainBtnPrimaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Voir plus',
                        style: TextStyle(
                          color: t.mainBtnPrimaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: t.mainBtnPrimaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Content ──
        if (speakerProvider.isLoading && speakerProvider.randomSpeakers.isEmpty)
          Center(child: CircularProgressIndicator(color: t.mainBtnPrimaryColor))
        else if (speakerProvider.errorMessage != null)
          Center(
            child: Text(
              speakerProvider.errorMessage!,
              style: TextStyle(color: t.mainBtnSecondaryColor),
            ),
          )
        else if (speakerProvider.randomSpeakers.isEmpty)
          Center(
            child: Text(
              'Aucun intervenant à afficher',
              style: TextStyle(color: t.mainTextSecondaryColor),
            ),
          )
        else
          SizedBox(
            height: 154,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: speakerProvider.randomSpeakers.length,
              itemBuilder: (context, index) {
                return SpeakerHomeCard(
                  speaker: speakerProvider.randomSpeakers[index],
                  theme: t,
                );
              },
            ),
          ),
      ],
    );
  }
}
