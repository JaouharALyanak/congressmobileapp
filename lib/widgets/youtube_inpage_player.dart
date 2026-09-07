import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Extraits l'ID YouTube depuis n'importe quel format d'URL.
/// Supporte : youtu.be/, /watch?v=, /embed/, /live/, /v/
String? extractYoutubeId(String url) {
  final regExp = RegExp(
    r'^.*(youtu\.be\/|\/v\/|\/u\/\w\/|embed\/|watch\?v=|&v=|live\/)([^#&?]*).*',
  );
  final match = regExp.firstMatch(url);
  final id = match?.group(2);
  return (id != null && id.length == 11) ? id : null;
}

// ─────────────────────────────────────────────────────────────────────────────

/// Lecteur YouTube natif embarqué, utilisé en mode `inpage`.
///
/// Affiche une vignette avec bouton play par défaut.
/// Au tap (ou si [autoPlay] est vrai), lance le lecteur officiel YouTube.
///
/// Utilise [youtube_player_iframe] qui s'appuie sur l'IFrame Player API
/// officielle de YouTube — pas d'erreur de lecteur, fullscreen intégré,
/// contrôles natifs.
class YoutubeInPagePlayer extends StatefulWidget {
  final String youtubeUrl;
  final Color accentColor;

  /// Si true, lance la lecture immédiatement sans attendre le tap.
  final bool autoPlay;

  const YoutubeInPagePlayer({
    super.key,
    required this.youtubeUrl,
    required this.accentColor,
    this.autoPlay = false,
  });

  @override
  State<YoutubeInPagePlayer> createState() => _YoutubeInPagePlayerState();
}

class _YoutubeInPagePlayerState extends State<YoutubeInPagePlayer> {
  late bool _playing;
  YoutubePlayerController? _controller;

  String? get _videoId => extractYoutubeId(widget.youtubeUrl);

  String? get _thumbnailUrl => _videoId != null
      ? 'https://img.youtube.com/vi/$_videoId/hqdefault.jpg'
      : null;

  @override
  void initState() {
    super.initState();
    _playing = widget.autoPlay;
    if (_playing) _initController();
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  void _initController() {
    final id = _videoId;
    if (id == null) return;

    _controller = YoutubePlayerController.fromVideoId(
      videoId: id,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: true,
        loop: false,
        mute: false,
      ),
    );
  }

  void _startPlaying() {
    if (_videoId == null) return;
    _initController();
    setState(() => _playing = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_playing && _controller != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayer(controller: _controller!),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: _buildThumbnail(),
      ),
    );
  }

  // ── Vignette + bouton play ─────────────────────────────────────────────────

  Widget _buildThumbnail() {
    return GestureDetector(
      onTap: _startPlaying,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_thumbnailUrl != null)
            Image.network(
              _thumbnailUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildPlaceholder(),
            )
          else
            _buildPlaceholder(),

          // Gradient bas
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
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),

          // Bouton play
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.93),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                size: 40,
                color: widget.accentColor,
              ),
            ),
          ),

          // Label
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Appuyer pour lire',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Placeholder ────────────────────────────────────────────────────────────

  Widget _buildPlaceholder() {
    return ColoredBox(
      color: widget.accentColor.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          size: 56,
          color: widget.accentColor.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page dédiée (utilisée depuis program_item_card en mode inpage)
// ─────────────────────────────────────────────────────────────────────────────

/// Page plein écran avec le lecteur YouTube natif.
class YoutubeInPageView extends StatelessWidget {
  final String url;
  final String title;
  final Color accentColor;

  const YoutubeInPageView({
    super.key,
    required this.url,
    required this.title,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: YoutubeInPagePlayer(
          youtubeUrl: url,
          accentColor: accentColor,
          autoPlay: true,
        ),
      ),
    );
  }
}
