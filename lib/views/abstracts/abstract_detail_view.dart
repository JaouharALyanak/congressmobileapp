import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/abstract_model.dart';
import '../../models/app_theme_model.dart';
import '../../providers/theme_provider.dart';
import '../../utils/html_utils.dart';
import '../../widgets/app_bar_widget.dart';

class AbstractDetailView extends StatelessWidget {
  final AbstractModel abstract;
  final String? heroTag;

  const AbstractDetailView({super.key, required this.abstract, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().theme;

    return Scaffold(
      backgroundColor: t.eventBgColor,
      appBar: AppBarWidget(title: abstract.fullName),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
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
                  heroTag != null
                      ? Hero(tag: heroTag!, child: _buildAvatar(t, 110))
                      : _buildAvatar(t, 110),
                  const SizedBox(height: 16),
                  Text(
                    abstract.fullName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: t.headerColorTitle,
                    ),
                  ),
                  if (abstract.title != null && abstract.title!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      abstract.title!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: t.headerColorTitle.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                  if (abstract.specialityList.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: abstract.specialityList.map((e) {
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

            // ── Poster button ──
            if (abstract.posterUrl != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchPoster(abstract.posterUrl!),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Voir le Poster'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t.mainBtnPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: htmlContentOrEmpty(
                abstract.biography,
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

  Widget _buildAvatar(AppThemeModel t, double size) {
    final hasImage = abstract.photo != null && abstract.photo!.isNotEmpty;
    return ClipRRect(
      borderRadius: t.speakerPhotoBorderRadius,
      child: SizedBox(
        width: size,
        height: size,
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: abstract.photo!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => _placeholder(t, size),
              )
            : _placeholder(t, size),
      ),
    );
  }

  Widget _placeholder(AppThemeModel t, double size) {
    return Container(
      color: Colors.white.withValues(alpha: 0.2),
      child: Center(
        child: Text(
          abstract.initials,
          style: TextStyle(
            fontSize: size * 0.3,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _launchPoster(String url) async {
    final uri = Uri.parse(url);
    // canLaunchUrl est peu fiable pour les PDF sur Android 11+.
    // On essaie d'abord le navigateur externe, puis le navigateur intégré en fallback.
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (_) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    }
  }
}
