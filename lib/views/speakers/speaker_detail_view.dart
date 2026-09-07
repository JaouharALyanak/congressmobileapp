import 'package:event_app/models/app_theme_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/speaker_model.dart';
import '../../providers/theme_provider.dart';
import '../../utils/html_utils.dart';
import '../../widgets/app_bar_widget.dart';


class SpeakerDetailView extends StatelessWidget {
  final Speaker speaker;
  final String? heroTag;

  const SpeakerDetailView({super.key, required this.speaker, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().theme;

    return Scaffold(
      backgroundColor: t.eventBgColor,
      appBar: AppBarWidget(title: speaker.fullName),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header violet arrondi (même style comité) ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: t.headerBg,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // ── Photo avec Hero ──
                  _buildAvatar(t),

                  const SizedBox(height: 16),

                  // ── Nom ──
                  Text(
                    speaker.fullName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: t.headerColorTitle,
                    ),
                  ),

                  // ── Titre / poste ──
                  if (speaker.title.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      speaker.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: t.headerColorTitle.withValues(alpha: 0.8),
                      ),
                    ),
                  ],

                  // ── Spécialités en chips ──
                  if (speaker.specialityList.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: speaker.specialityList.map((e) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            e,
                            style: TextStyle(
                              fontSize: 11,
                              color: t.headerColorTitle,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: htmlContentOrEmpty(
                speaker.biography,
                textStyle: TextStyle(
                  fontSize: 14,
                  color: t.mainTextPrimaryColor,
                  height: 1.7,
                ),
                emptyColor: t.mainTextSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(AppThemeModel t) {
    final hasImage = speaker.photo != null && speaker.photo!.isNotEmpty;
    final avatar = ClipRRect(
      borderRadius: t.speakerPhotoBorderRadius,
      child: SizedBox(
        width: 110,
        height: 110,
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: speaker.photo!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => _placeholder(t),
              )
            : _placeholder(t),
      ),
    );

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: avatar);
    }
    return avatar;
  }

  Widget _placeholder(AppThemeModel t) {
    final first = speaker.firstName.isNotEmpty ? speaker.firstName[0] : '';
    final last = speaker.lastName.isNotEmpty ? speaker.lastName[0] : '';
    final initials = (first + last).toUpperCase();
    return Container(
      color: Colors.white.withValues(alpha: 0.2),
      child: Center(
        child: Text(
          initials.isNotEmpty ? initials : '?',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
