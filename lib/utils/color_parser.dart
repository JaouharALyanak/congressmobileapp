import 'package:flutter/material.dart';

class ColorParser {
  static Color parse(String? value, {Color fallback = Colors.grey}) {
    if (value == null || value.isEmpty) return fallback;

    final v = value.trim();

    try {
      if (v.startsWith('#')) {
        final hex = v.replaceFirst('#', '');
        if (hex.length == 3) {
          final r = hex[0] * 2;
          final g = hex[1] * 2;
          final b = hex[2] * 2;
          return Color(int.parse('0xFF$r$g$b'));
        } else if (hex.length == 6) {
          return Color(int.parse('0xFF$hex'));
        } else if (hex.length == 8) {
          return Color(int.parse('0x$hex'));
        }
        return fallback;
      }

      if (v.startsWith('rgba(') || v.startsWith('rgb(')) {
        final inner = v
            .replaceAll('rgba(', '')
            .replaceAll('rgb(', '')
            .replaceAll(')', '');
        final parts = inner.split(',').map((e) => e.trim()).toList();

        final r = int.parse(parts[0]);
        final g = int.parse(parts[1]);
        final b = int.parse(parts[2]);
        final a = parts.length > 3 ? double.parse(parts[3]) : 1.0;

        return Color.fromRGBO(r, g, b, a);
      }

      if (v == 'transparent') return Colors.transparent;

      return fallback;
    } catch (_) {
      return fallback;
    }
  }
}
