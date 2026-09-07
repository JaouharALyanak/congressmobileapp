import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/vod_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/vod_model.dart';
import '../../models/app_theme_model.dart';
import '../../widgets/app_bar_widget.dart';

class VodListView extends StatefulWidget {
  const VodListView({super.key});

  @override
  State<VodListView> createState() => _VodListViewState();
}

class _VodListViewState extends State<VodListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VodProvider>().loadVods();
    });
  }

  Future<void> _launchVideo(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    }
  }

  /// Extract YouTube video ID from any YouTube URL format
  String? _extractYoutubeId(String? url) {
    if (url == null || url.isEmpty) return null;
    final regExp = RegExp(
      r'^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*',
    );
    final match = regExp.firstMatch(url);
    final id = match?.group(2);
    return (id != null && id.length == 11) ? id : null;
  }

  /// Returns thumbnail URL: explicit field first, then auto-generated from YouTube ID
  String? _getThumbnailUrl(Vod vod) {
    if (vod.thumbnailUrl != null && vod.thumbnailUrl!.isNotEmpty) {
      return vod.thumbnailUrl;
    }
    final id = _extractYoutubeId(vod.youtubeLink);
    if (id != null) {
      // hqdefault = 480×360, good balance quality/size
      return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final t = tp.theme;
    final s = tp.settings;
    final provider = context.watch<VodProvider>();

    return Scaffold(
      backgroundColor: t.eventBgColor,
      appBar: AppBarWidget(title: s.vodText),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator(color: t.headerBg))
          : provider.errorMessage != null
          ? _buildError(t, provider)
          : provider.vods.isEmpty
          ? _buildEmpty(t)
          : LayoutBuilder(
              builder: (context, constraints) {
                final useGrid = constraints.maxWidth >= 600;
                return RefreshIndicator(
                  color: t.headerBg,
                  onRefresh: () => provider.loadVods(forceRefresh: true),
                  child: useGrid
                      ? GridView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 16, 12, 48),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 420,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 0,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: provider.vods.length,
                          itemBuilder: (context, index) =>
                              _buildVodCard(provider.vods[index], t),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 16, 12, 48),
                          itemCount: provider.vods.length,
                          itemBuilder: (context, index) =>
                              _buildVodCard(provider.vods[index], t),
                        ),
                );
              },
            ),
    );
  }

  Widget _buildVodCard(Vod vod, AppThemeModel t) {
    final thumbnailUrl = _getThumbnailUrl(vod);
    final hasLink = vod.youtubeLink != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: t.cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: t.cardBorderSize > 0
            ? Border.all(
                color: t.cardBorderColor,
                width: t.cardBorderSize.toDouble(),
              )
            : null,
        boxShadow: t.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasLink ? () => _launchVideo(vod.youtubeLink!) : null,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Thumbnail 16:9 plein largeur ─────────────────────────
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image
                      thumbnailUrl != null
                          ? Image.network(
                              thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _buildPlaceholder(t),
                            )
                          : _buildPlaceholder(t),

                      // Gradient overlay bas
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.5),
                              ],
                              stops: const [0.5, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Bouton play centré
                      if (hasLink)
                        Center(
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: 32,
                              color: t.cardIconeColor,
                            ),
                          ),
                        ),

                      // Badge catégorie haut-gauche
                      if (vod.category != null && vod.category!.isNotEmpty)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: t.cardIconeColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              vod.category!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Titre + description ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vod.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: t.cardTitleColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    if (vod.description != null &&
                        vod.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        vod.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: t.cardDescriptionColor,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(AppThemeModel t) {
    return Container(
      color: t.cardIconeColor.withValues(alpha: 0.07),
      child: Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          size: 48,
          color: t.cardIconeColor.withValues(alpha: 0.35),
        ),
      ),
    );
  }

  Widget _buildEmpty(AppThemeModel t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: t.mainTextSecondaryColor.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune vidéo disponible',
            style: TextStyle(color: t.mainTextSecondaryColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildError(AppThemeModel t, VodProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: t.mainTextSecondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            provider.errorMessage!,
            style: TextStyle(color: t.mainTextSecondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.loadVods(forceRefresh: true),
            style: ElevatedButton.styleFrom(backgroundColor: t.headerBg),
            child: Text(
              'Réessayer',
              style: TextStyle(color: t.headerColorTitle),
            ),
          ),
        ],
      ),
    );
  }
}
