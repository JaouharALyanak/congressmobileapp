import 'package:flutter/material.dart';
import '../config/app_config.dart';

class AppThemeModel {
  // Global
  final List<BoxShadow> cardShadow;

  final Color eventBgColor;
  final String fontFamily;

  final String eventTitle;
  final String eventSubtitle;

  // Header
  final Color headerBg;
  final Color headerColorTitle;
  final Color headerColorSubtitle;
  final String? headerLogoUrl;
  final String headerLogoState;
  final int headerRotateDegree;

  // Search
  final Color searchBarBg;
  final Color searchBarTextColor;

  // Banner
  final String? bannerPictureUrl;
  final Color bannerBtnColor;
  final Color bannerBtnTextColor;
  final String bannerBtnText;
  final String bannerBtnState;
  final String bannerState;
  final String bannerChoice;
  final List<String> sliderImageUrls;
  final int sliderDuration;

  // Cards
  final int cardBorderSize;
  final Color cardBorderColor;
  final Color cardBgColor;
  final Color cardTitleColor;
  final Color cardDescriptionColor;
  final Color cardTimesColor;
  final Color cardIconeColor;

  // Timeline
  final Color timelineBtnColor;
  final Color timelineBtnInactiveColor;
  final Color timelineTextColor;
  final Color timelineTextInactiveColor;

  // Grid speakers
  final Color gridTextColor;
  final String gridPictureStyle; // 'circle' | 'rounded' | 'square'
  final int gridRoundedValue;

  // Grid boutons
  final Color gridBtnBgColor;
  final Color gridBtnIconeColor;

  // Textes globaux
  final Color mainTextPrimaryColor;
  final Color mainTextSecondaryColor;
  final Color mainBtnPrimaryColor;
  final Color mainBtnSecondaryColor;

  // Footer
  final Color footerBgColor;
  final Color footerIconeBgColor;
  final Color footerIconeColor;
  final Color footerActiveBgColor;
  final Color footerActiveIconeColor;

  // URLs images
  final String? eventLogoUrl;
  final String? eventBgImageUrl;

  // Popup publicitaire
  final String? popupImageUrl;
  final int popupTimerToShow;

  const AppThemeModel({
    required this.cardShadow,
    required this.eventTitle,
    required this.eventSubtitle,
    required this.eventBgColor,
    required this.fontFamily,
    required this.headerBg,
    required this.headerColorTitle,
    required this.headerColorSubtitle,
    this.headerLogoUrl,
    required this.headerLogoState,
    required this.headerRotateDegree,
    required this.searchBarBg,
    required this.searchBarTextColor,
    this.bannerPictureUrl,
    required this.bannerBtnColor,
    required this.bannerBtnTextColor,
    required this.bannerBtnText,
    required this.bannerBtnState,
    required this.bannerState,
    this.bannerChoice = 'picture',
    this.sliderImageUrls = const [],
    this.sliderDuration = 4,
    required this.cardBorderSize,
    required this.cardBorderColor,
    required this.cardBgColor,
    required this.cardTitleColor,
    required this.cardDescriptionColor,
    required this.cardTimesColor,
    required this.cardIconeColor,
    required this.timelineBtnColor,
    required this.timelineBtnInactiveColor,
    required this.timelineTextColor,
    required this.timelineTextInactiveColor,
    required this.gridTextColor,
    required this.gridPictureStyle,
    required this.gridRoundedValue,
    required this.gridBtnBgColor,
    required this.gridBtnIconeColor,
    required this.mainTextPrimaryColor,
    required this.mainTextSecondaryColor,
    required this.mainBtnPrimaryColor,
    required this.mainBtnSecondaryColor,
    required this.footerBgColor,
    required this.footerIconeBgColor,
    required this.footerIconeColor,
    required this.footerActiveBgColor,
    required this.footerActiveIconeColor,
    this.eventLogoUrl,
    this.eventBgImageUrl,
    this.popupImageUrl,
    this.popupTimerToShow = 3,
  });

  // ── Helpers ───────────────────────────────────────────────────────────────
  static Color _c(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty || hex == 'transparent') {
      return hex == 'transparent' ? Colors.transparent : fallback;
    }
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return fallback;
    }
  }

  static const Color _purple = Color(0xFF702670);

  factory AppThemeModel.fromJson(Map<String, dynamic> json) {
    final String title = json['title'] ?? '';
    final String subtitle = json['subtitle'] ?? '';

    //final j = json['theme'] ?? json;
    final j = json['theme'] ?? {};

    /*String? fixUrl(String? url) {
      if (url == null || url.isEmpty) return null;
      if (url.startsWith('http')) return url;
      return "https://mob-app-ascrea.hashtagsante.com$url";
    }*/
    String? fixUrl(String? url) {
      if (url == null || url.isEmpty) return null;
      if (url.startsWith('http')) return url;
      final base = AppConfig.baseUrl.replaceFirst('/api/v1', '');
      return url.startsWith('/') ? '$base$url' : '$base/$url';
    }

    return AppThemeModel(
      eventTitle: title,
      eventSubtitle: subtitle,
      cardShadow: _parseShadow(j['card_shadow']),

      eventBgColor: _c(j['event_bg_color'], const Color(0xFFF3F4F6)),
      fontFamily: j['font_family'] ?? 'sans-serif',
      headerBg: _c(j['header_bg'], _purple),
      headerColorTitle: _c(j['header_color_title'], Colors.white),
      headerColorSubtitle: _c(j['header_color_subtitle'], Colors.white),
      //headerLogoUrl: j['header_logo_url'],
      headerLogoState: j['header_logo_state'] ?? 'visible',
      headerRotateDegree: (j['header_rotate_degree'] as num?)?.toInt() ?? 15,
      searchBarBg: _c(j['search_bar_bg'], Colors.white),
      searchBarTextColor: _c(
        j['search_bar_text_color'],
        const Color(0xFF6B7280),
      ),

      bannerPictureUrl: fixUrl(j['banner_picture_url']),
      headerLogoUrl: fixUrl(j['header_logo_url']),
      eventLogoUrl: fixUrl(j['event_logo_url']),
      eventBgImageUrl: fixUrl(j['event_bg_image_url']),

      bannerBtnColor: _c(j['banner_btn_color'], _purple),
      bannerBtnTextColor: _c(j['banner_btn_text_color'], Colors.white),
      bannerBtnText: j['banner_btn_text'] ?? 'Découvrir',
      bannerBtnState: j['banner_btn_state'] ?? 'visible',
      bannerState: j['banner_state'] ?? 'visible',
      bannerChoice: j['banner_choice'] ?? 'picture',
      sliderDuration: (j['slider_duration'] as num?)?.toInt() ?? 4,
      sliderImageUrls: (j['slider_images_urls'] as List<dynamic>?)
              ?.map((e) => fixUrl(e.toString()) ?? '')
              .where((url) => url.isNotEmpty)
              .toList() ??
          [],
      cardBorderSize: (j['card_border_size'] as num?)?.toInt() ?? 0,
      cardBorderColor: _c(j['card_border_color'], const Color(0xFFE5E7EB)),
      cardBgColor: _c(j['card_bg_color'], Colors.white),
      cardTitleColor: _c(j['card_title_color'], const Color(0xFF1F2937)),
      cardDescriptionColor: _c(
        j['card_description_color'],
        const Color(0xFF6B7280),
      ),
      cardTimesColor: _c(j['card_times_color'], _purple),
      cardIconeColor: _c(j['card_icone_color'], _purple),
      timelineBtnColor: _c(j['timeline_btn_color'], _purple),
      timelineBtnInactiveColor: _c(
        j['timeline_btn_inactive_color'],
        Colors.white,
      ),
      timelineTextColor: _c(j['timeline_text_color'], Colors.white),
      timelineTextInactiveColor: _c(
        j['timeline_text_inactive_color'],
        const Color(0xFF1F2937),
      ),
      gridTextColor: _c(j['grid_text_color'], const Color(0xFF1F2937)),
      gridPictureStyle: j['grid_picture_style'] ?? 'circle',
      gridRoundedValue: (j['grid_rounded_value'] as num?)?.toInt() ?? 12,
      gridBtnBgColor: _c(j['grid_btn_bg_color'], Colors.white),
      gridBtnIconeColor: _c(j['grid_btn_icone_color'], _purple),
      mainTextPrimaryColor: _c(
        j['main_text_primary_color'],
        const Color(0xFF1F2937),
      ),
      mainTextSecondaryColor: _c(
        j['main_text_secondary_color'],
        const Color(0xFF6B7280),
      ),
      mainBtnPrimaryColor: _c(j['main_btn_primary_color'], _purple),
      mainBtnSecondaryColor: _c(
        j['main_btn_secondary_color'],
        const Color(0xFFEF4444),
      ),
      footerBgColor: _c(j['footer_bg_color'], Colors.white),
      footerIconeBgColor: _c(j['footer_icone_bg_color'], Colors.transparent),
      footerIconeColor: _c(j['footer_icone_color'], const Color(0xFF9E9E9E)),
      footerActiveBgColor: _c(j['footer_active_bg_color'], _purple),
      footerActiveIconeColor: _c(j['footer_active_icone_color'], Colors.white),
      //eventLogoUrl: j['event_logo_url'],
      //eventBgImageUrl: j['event_bg_image_url'],
      popupImageUrl: fixUrl(j['popup_image_url']),
      popupTimerToShow: (j['popup_timer_to_show'] as num?)?.toInt() ?? 3,
    );
  }
  BoxDecoration get shapeDecoration {
    return BoxDecoration(
      color: gridBtnBgColor,
      shape: gridPictureStyle == 'circle'
          ? BoxShape.circle
          : BoxShape.rectangle,
      borderRadius: gridPictureStyle == 'circle'
          ? null
          : BorderRadius.circular(gridRoundedValue.toDouble()),
    );
  }

  BorderRadius get speakerPhotoBorderRadius {
    switch (gridPictureStyle) {
      case 'circle':
        return BorderRadius.circular(999);
      case 'square':
        return BorderRadius.zero;
      case 'rounded':
      default:
        return BorderRadius.circular(gridRoundedValue.toDouble());
    }
  }

  static List<BoxShadow> _parseShadow(String? css) {
    if (css == null || css.isEmpty) return [];
    // parses "0 4px 15px rgba(0,0,0,0.05)"
    try {
      final parts = css.trim().split(RegExp(r'\s+(?=\d|rgba|rgb)'));
      final dx = double.parse(parts[0]);
      final dy = double.parse(parts[1].replaceAll('px', ''));
      final blur = double.parse(parts[2].replaceAll('px', ''));
      final colorStr = parts[3]; // "rgba(0,0,0,0.05)"
      final color = _parseRgba(colorStr);
      return [
        BoxShadow(color: color, offset: Offset(dx, dy), blurRadius: blur),
      ];
    } catch (_) {
      return [];
    }
  }

  static Color _parseRgba(String rgba) {
    final match = RegExp(
      r'rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)',
    ).firstMatch(rgba);
    if (match == null) return Colors.transparent;
    final r = int.parse(match.group(1)!);
    final g = int.parse(match.group(2)!);
    final b = int.parse(match.group(3)!);
    final a = double.parse(match.group(4) ?? '1');
    return Color.fromRGBO(r, g, b, a);
  }
}
