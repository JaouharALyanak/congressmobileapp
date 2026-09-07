import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Ouvre une WebView dans un bottom sheet plein écran.
/// Utilisation :
///   WebViewSheet.show(context, url: 'https://...', title: 'Vote');
class WebViewSheet extends StatefulWidget {
  final String url;
  final String title;
  final Color accentColor;

  const WebViewSheet({
    super.key,
    required this.url,
    required this.title,
    required this.accentColor,
  });

  /// Méthode statique pratique pour ouvrir depuis n'importe où.
  static Future<void> show(
    BuildContext context, {
    required String url,
    required String title,
    Color accentColor = const Color(0xFF702670),
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false, // désactivé pour ne pas capturer les gestes WebView
      backgroundColor: Colors.transparent,
      builder: (_) => WebViewSheet(
        url: url,
        title: title,
        accentColor: accentColor,
      ),
    );
  }

  @override
  State<WebViewSheet> createState() => _WebViewSheetState();
}

class _WebViewSheetState extends State<WebViewSheet> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── Handle bar ──
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _titleIcon,
                    size: 16,
                    color: widget.accentColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: widget.accentColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22),
                  color: Colors.grey.shade600,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          // ── WebView ──
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(
                      color: widget.accentColor,
                      strokeWidth: 2.5,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData get _titleIcon {
    final lower = widget.title.toLowerCase();
    if (lower.contains('vote') || lower.contains('sondage')) {
      return Icons.how_to_vote_rounded;
    }
    if (lower.contains('question') || lower.contains('ask')) {
      return Icons.help_outline_rounded;
    }
    return Icons.open_in_browser_rounded;
  }
}
