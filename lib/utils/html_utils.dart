import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

/// Returns true if [html] has no visible text content.
/// Handles null, empty string, and tags-only content like <p></p>.
bool isHtmlEmpty(String? html) {
  if (html == null || html.trim().isEmpty) return true;
  final stripped = html
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', '')
      .trim();
  return stripped.isEmpty;
}

/// Renders [html] as rich text, or shows a fallback message if empty.
Widget htmlContentOrEmpty(
  String? html, {
  required TextStyle textStyle,
  required Color emptyColor,
  String emptyMessage = 'Aucune information fournie',
}) {
  if (isHtmlEmpty(html)) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          emptyMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: emptyColor,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
  return HtmlWidget(
    html!,
    textStyle: textStyle,
  );
}
