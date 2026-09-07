import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/speaker_model.dart';
import '../../providers/theme_provider.dart';
import '../../models/app_theme_model.dart';
import '../../utils/responsive.dart';
import 'speaker_detail_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SpeakerCard extends StatelessWidget {
  final Speaker speaker;
  final bool isGrid;

  const SpeakerCard({super.key, required this.speaker, this.isGrid = false});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().theme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SpeakerDetailView(
              speaker: speaker,
              heroTag: 'speaker-list-${speaker.id}',
            ),
          ),
        );
      },

      /// 🔥 GRID DESIGN
      child: isGrid
          ? Container(
              decoration: BoxDecoration(
                color: t.cardBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'speaker-list-${speaker.id}',
                    child: _avatar(t, rS(context, 60)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    speaker.fullName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: rFs(context, 14)),
                  ),
                  const SizedBox(height: 6),
                  if (speaker.title.isNotEmpty)
                    Text(
                      speaker.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: rFs(context, 11),
                        color: t.mainTextSecondaryColor,
                      ),
                    ),
                ],
              ),
            )
          /// 🔥 LIST DESIGN
          : Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.cardBgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Hero(
                    tag: 'speaker-list-${speaker.id}',
                    child: _avatar(t, rS(context, 50)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          speaker.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: rFs(context, 14),
                          ),
                        ),
                        if (speaker.title.isNotEmpty)
                          Text(
                            speaker.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: rFs(context, 12),
                              color: t.mainTextSecondaryColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
    );
  }

  Widget _avatar(AppThemeModel t, double size) {
    final hasImage = speaker.photo != null && speaker.photo!.isNotEmpty;

    return ClipRRect(
      borderRadius: t.speakerPhotoBorderRadius, // ✅ circle / rounded / square
      child: SizedBox(
        width: size,
        height: size,
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: speaker.photo!,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (context, url) => Container(
                  color: t.cardIconeColor.withValues(alpha: 0.2),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: t.cardIconeColor,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    _placeholderAvatar(t, size),
              )
            : _placeholderAvatar(t, size),
      ),
    );
  }

  Widget _placeholderAvatar(AppThemeModel t, double size) {
    return Container(
      color: t.cardIconeColor.withValues(alpha: 0.2),
      child: Center(
        child: Text(
          _getInitials(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: size * 0.35,
            color: t.cardIconeColor,
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    final first = speaker.firstName.isNotEmpty ? speaker.firstName[0] : '';
    final last = speaker.lastName.isNotEmpty ? speaker.lastName[0] : '';

    return (first + last).toUpperCase();
  }
}
