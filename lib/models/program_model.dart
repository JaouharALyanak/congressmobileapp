// lib/models/program_model.dart
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../utils/color_parser.dart';

class ProgramDay {
  final int id;
  final String title;

  final String date;
  final List<ProgramItem> items;
  final String? startDate;
  final String? endDate;
  final Color btnColor;
  final Color btnInactiveColor;
  final Color textColor;
  final Color textInactiveColor;

  // Store raw hex strings so toJson() can write them back
  final String? _btnColorRaw;
  final String? _btnInactiveColorRaw;
  final String? _textColorRaw;
  final String? _textInactiveColorRaw;

  ProgramDay({
    required this.id,
    required this.title,
    required this.date,
    required this.items,
    required this.btnColor,
    required this.btnInactiveColor,
    required this.textColor,
    required this.textInactiveColor,
    this.startDate,
    this.endDate,
    String? btnColorRaw,
    String? btnInactiveColorRaw,
    String? textColorRaw,
    String? textInactiveColorRaw,
  }) : _btnColorRaw = btnColorRaw,
       _btnInactiveColorRaw = btnInactiveColorRaw,
       _textColorRaw = textColorRaw,
       _textInactiveColorRaw = textInactiveColorRaw;

  factory ProgramDay.fromJson(Map<String, dynamic> j) {
    return ProgramDay(
      id: j['id'],
      title: j['title'] ?? '',
      date: j['date'] ?? '',
      items: (j['items'] as List).map((i) => ProgramItem.fromJson(i)).toList(),
      btnColor: ColorParser.parse(
        j['timeline_btn_color'],
        fallback: const Color(0xFF702670),
      ),
      btnInactiveColor: ColorParser.parse(
        j['timeline_btn_inactive_color'],
        fallback: Colors.white,
      ),
      textColor: ColorParser.parse(
        j['timeline_text_color'],
        fallback: Colors.white,
      ),
      textInactiveColor: ColorParser.parse(
        j['timeline_text_inactive_color'],
        fallback: Colors.black,
      ),
      startDate: j['startDate'],
      endDate: j['endDate'],
      // Store raw strings for round-trip
      btnColorRaw: j['timeline_btn_color'],
      btnInactiveColorRaw: j['timeline_btn_inactive_color'],
      textColorRaw: j['timeline_text_color'],
      textInactiveColorRaw: j['timeline_text_inactive_color'],
    );
  }

  // ── toJson ──────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,

      'items': items.map((i) => i.toJson()).toList(),
      'timeline_btn_color': _btnColorRaw,
      'timeline_btn_inactive_color': _btnInactiveColorRaw,
      'timeline_text_color': _textColorRaw,
      'timeline_text_inactive_color': _textInactiveColorRaw,
    };
  }
}

class ProgramItem {
  final int id;
  final String? title;
  final String startTime;
  final String endTime;
  final String? description;
  final String? location;
  final String icon;
  final String type;
  final ProgramCardStyle cardStyle;
  final ProgramSession? session;
  final List<ProgramItem> children;

  ProgramItem({
    required this.id,
    this.title,
    required this.startTime,
    required this.endTime,
    this.description,
    this.location,
    required this.icon,
    required this.type,
    required this.cardStyle,
    this.session,
    this.children = const [],
  });

  bool get isSession => type == 'session';
  bool get isGroup => children.isNotEmpty;
  String get displayTitle =>
      (isSession ? session?.title : title) ?? 'Sans titre';

  factory ProgramItem.fromJson(Map<String, dynamic> j) {
    return ProgramItem(
      id: j['id'],
      title: j['title'],
      startTime: j['start_time'] ?? '',
      endTime: j['end_time'] ?? '',
      description: j['description'],
      location: j['location'],
      icon: j['icon'] ?? 'lucide-circle',
      type: j['type'] ?? 'other',
      cardStyle: ProgramCardStyle.fromJson(j['card_style'] ?? {}),
      session: j['session'] != null
          ? ProgramSession.fromJson(j['session'])
          : null,
      children: (j['children'] as List? ?? [])
          .map((c) => ProgramItem.fromJson(c))
          .toList(),
    );
  }

  // ── toJson ──────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'start_time': startTime,
      'end_time': endTime,
      'description': description,
      'location': location,
      'icon': icon,
      'type': type,
      'card_style': cardStyle.toJson(),
      'session': session?.toJson(),
      'children': children.map((c) => c.toJson()).toList(),
    };
  }
}

class ProgramCardStyle {
  final String? cardBgColor;
  final String? cardTitleColor;
  final String? cardDescriptionColor;
  final String? cardTimesColor;
  final String? cardIconeColor;
  final int cardBorderSize;
  final String? cardBorderColor;

  ProgramCardStyle({
    this.cardBgColor,
    this.cardTitleColor,
    this.cardDescriptionColor,
    this.cardTimesColor,
    this.cardIconeColor,
    this.cardBorderSize = 0,
    this.cardBorderColor,
  });

  factory ProgramCardStyle.fromJson(Map<String, dynamic> j) {
    return ProgramCardStyle(
      cardBgColor: j['card_bg_color'],
      cardTitleColor: j['card_title_color'],
      cardDescriptionColor: j['card_description_color'],
      cardTimesColor: j['card_times_color'],
      cardIconeColor: j['card_icone_color'],
      cardBorderSize: j['card_border_size'] ?? 0,
      cardBorderColor: j['card_border_color'],
    );
  }

  // ── toJson ──────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'card_bg_color': cardBgColor,
      'card_title_color': cardTitleColor,
      'card_description_color': cardDescriptionColor,
      'card_times_color': cardTimesColor,
      'card_icone_color': cardIconeColor,
      'card_border_size': cardBorderSize,
      'card_border_color': cardBorderColor,
    };
  }

  static ProgramCardStyle get defaultStyle => ProgramCardStyle();
}

class ProgramSession {
  final String title;
  final String? description;
  final String? room;
  final String? logo;
  final String? youtubeLink;
  final String? askUrl;
  final String? voteUrl;
  final String youtubeOpenMode; // "external" | "popup" | "inpage"
  final String youtubeStatus;  // "live" | "hidden"
  final String messageStatus;  // "enabled" | "disabled"
  final String pollStatus;     // "published" | "pending" | "ended"
  final List<ProgramPerson> speakers;
  final List<ProgramPerson> moderators;

  ProgramSession({
    required this.title,
    this.description,
    this.room,
    this.logo,
    this.youtubeLink,
    this.askUrl,
    this.voteUrl,
    this.youtubeOpenMode = 'external',
    this.youtubeStatus = 'live',
    this.messageStatus = 'disabled',
    this.pollStatus = 'pending',
    required this.speakers,
    required this.moderators,
  });

  String? get logoUrl {
    if (logo == null || logo!.isEmpty) return null;
    if (logo!.startsWith('http')) return logo;
    final base = AppConfig.baseUrl.replaceFirst('/api/v1', '');
    return '$base/public/storage/$logo';
  }

  List<ProgramPerson> get allParticipants => [...moderators, ...speakers];

  factory ProgramSession.fromJson(Map<String, dynamic> j) {
    return ProgramSession(
      title: j['title'] ?? '',
      description: j['description'],
      room: j['room'],
      logo: j['logo'],
      youtubeLink: j['youtube_link'],
      askUrl: j['ask_url'],
      voteUrl: j['vote_url'],
      youtubeOpenMode: j['youtube_open_mode'] ?? 'external',
      youtubeStatus: j['youtube_status'] ?? 'live',
      messageStatus: j['message_status'] ?? 'disabled',
      pollStatus: j['poll_status'] ?? 'pending',
      speakers: (j['speakers'] as List? ?? [])
          .map((p) => ProgramPerson.fromJson(p))
          .toList(),
      moderators: (j['moderators'] as List? ?? [])
          .map((p) => ProgramPerson.fromJson(p))
          .toList(),
    );
  }

  // ── toJson ──────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'room': room,
      'logo': logo,
      'youtube_link': youtubeLink,
      'ask_url': askUrl,
      'vote_url': voteUrl,
      'youtube_open_mode': youtubeOpenMode,
      'youtube_status': youtubeStatus,
      'message_status': messageStatus,
      'poll_status': pollStatus,
      'speakers': speakers.map((p) => p.toJson()).toList(),
      'moderators': moderators.map((p) => p.toJson()).toList(),
    };
  }
}

class ProgramPerson {
  final int id;
  final String firstName;
  final String lastName;
  final String? photo;
  final String? title;

  ProgramPerson({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.photo,
    this.title,
  });

  String get fullName => "$firstName $lastName";

  factory ProgramPerson.fromJson(Map<String, dynamic> j) {
    return ProgramPerson(
      id: j['id'],
      firstName: j['first_name'] ?? '',
      lastName: j['last_name'] ?? '',
      photo: j['photo'],
      title: j['title'],
    );
  }

  // ── toJson ──────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'photo': photo,
      'title': title,
    };
  }
}
