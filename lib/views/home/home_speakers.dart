import 'package:flutter/material.dart';
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
        // ── Header ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.speakerText,
                style: TextStyle(
                  color: t.mainTextPrimaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => widget.onNavigateToSpeakersTab(2),
                child: Text(
                  'Voir plus',
                  style: TextStyle(color: t.mainBtnPrimaryColor),
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
            height: 145,
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
