import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/speaker_model.dart';
import '../../../models/app_theme_model.dart';
import '../../../utils/responsive.dart';
import '../../speakers/speaker_detail_view.dart';

class SpeakerHomeCard extends StatelessWidget {
  final Speaker speaker;
  final AppThemeModel theme;

  const SpeakerHomeCard({
    super.key,
    required this.speaker,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = speaker.photo != null && speaker.photo!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SpeakerDetailView(
              speaker: speaker,
              heroTag: 'speaker-home-${speaker.id}',
            ),
          ),
        );
      },
      child: Container(
        width: rS(context, 110),
        height: rS(context, 145),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
        decoration: BoxDecoration(
          color: theme.cardBgColor,
          borderRadius: BorderRadius.circular(
            theme.gridRoundedValue.toDouble(),
          ),
          boxShadow: theme.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'speaker-home-${speaker.id}',
              child: ClipRRect(
                borderRadius: theme.speakerPhotoBorderRadius,
                child: SizedBox(
                  width: rS(context, 52),
                  height: rS(context, 52),
                  child: hasImage
                      ? CachedNetworkImage(
                          imageUrl: speaker.photo!,
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 200),
                          placeholder: (context, url) => Container(
                            color: theme.cardIconeColor.withValues(alpha: 0.2),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.cardIconeColor,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _placeholderAvatar(theme),
                        )
                      : _placeholderAvatar(theme),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              speaker.fullName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.cardTitleColor,
                fontSize: rFs(context, 12),
                fontWeight: FontWeight.w600,
              ),
            ),

            if (speaker.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  speaker.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.mainTextSecondaryColor,
                    fontSize: rFs(context, 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderAvatar(AppThemeModel t) {
    return Container(
      color: t.cardIconeColor.withValues(alpha: 0.2),
      child: Center(
        child: Text(
          _getInitials(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
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
