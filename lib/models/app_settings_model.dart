// lib/models/app_settings_model.dart
class AppSettingsModel {
  // Icons
  final String homeIcon;
  final String programIcon;
  final String speakerIcon;
  final String sponsorIcon;
  final String infoIcon;
  final String moderatorIcon;
  final String sessionIcon;
  final String committeeIcon;
  final String faqIcon;
  final String pollIcon;
  final String askIcon;
  final String vodIcon;
  final String agendaIcon;
  final String favoriteIcon;
  final String filterIcon;
  final String presidentWordIcon;
  final String addressIcon;
  final String contactIcon;
  final String phoneIcon;
  final String likeIcon;
  final String searchIcon;
  final String cityIcon;

  final String posterIcon;
  final String posterText;

  // Texts
  final String homeText;
  final String programText;
  final String speakerText;
  final String sponsorText;
  final String infoText;
  final String agendaText;
  final String favoriteText;
  final String filterText;
  final String searchText;
  final String cityText;
  final String moderatorText;
  final String committeeText;
  final String sessionText;
  final String vodText;
  final String pollText;
  final String askText;
  final String likeText;
  final String presidentWordText;
  final String faqText;
  final String phoneText;
  final String addressText;
  final String contactText;

  AppSettingsModel({
    required this.posterIcon,
    required this.posterText,
    required this.homeIcon,
    required this.programIcon,
    required this.speakerIcon,
    required this.sponsorIcon,
    required this.infoIcon,
    required this.moderatorIcon,
    required this.sessionIcon,
    required this.committeeIcon,
    required this.faqIcon,
    required this.pollIcon,
    required this.askIcon,
    required this.vodIcon,
    required this.agendaIcon,
    required this.favoriteIcon,
    required this.filterIcon,
    required this.presidentWordIcon,
    required this.addressIcon,
    required this.contactIcon,
    required this.phoneIcon,
    required this.likeIcon,
    required this.searchIcon,
    required this.cityIcon,
    required this.homeText,
    required this.programText,
    required this.speakerText,
    required this.sponsorText,
    required this.infoText,
    required this.agendaText,
    required this.favoriteText,
    required this.filterText,
    required this.searchText,
    required this.cityText,
    required this.moderatorText,
    required this.committeeText,
    required this.sessionText,
    required this.vodText,
    required this.pollText,
    required this.askText,
    required this.likeText,
    required this.presidentWordText,
    required this.faqText,
    required this.phoneText,
    required this.addressText,
    required this.contactText,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> j) {
    return AppSettingsModel(
      posterIcon: j['poster_icon'] ?? j['speaker_icon'] ?? 'lucide-file-text',
      posterText: j['poster_text'] ?? 'Posters',
      homeIcon: j['home_icon'] ?? 'lucide-home',
      programIcon: j['program_icon'] ?? 'lucide-calendar-range',
      speakerIcon: j['speaker_icon'] ?? 'lucide-mic-2',
      sponsorIcon: j['sponsor_icon'] ?? 'lucide-handshake',
      infoIcon: j['info_icon'] ?? 'lucide-info',
      moderatorIcon: j['moderator_icon'] ?? 'lucide-gavel',
      sessionIcon: j['session_icon'] ?? 'lucide-presentation',
      committeeIcon: j['committee_icon'] ?? 'lucide-users-2',
      faqIcon: j['faq_icon'] ?? 'lucide-help-circle',
      pollIcon: j['poll_icon'] ?? 'lucide-bar-chart-3',
      askIcon: j['ask_icon'] ?? 'lucide-help-circle',
      vodIcon: j['vod_icon'] ?? 'lucide-play-circle',
      agendaIcon: j['agenda_icon'] ?? 'fas-calendar-alt',
      favoriteIcon: j['favorite_icon'] ?? 'lucide-star',
      filterIcon: j['filter_icon'] ?? 'lucide-sliders-horizontal',
      presidentWordIcon: j['president_word_icon'] ?? 'lucide-quote',
      addressIcon: j['address_icon'] ?? 'lucide-map-pin',
      contactIcon: j['contact_icon'] ?? 'lucide-mail',
      phoneIcon: j['phone_icon'] ?? 'lucide-phone',
      likeIcon: j['like_icon'] ?? 'lucide-heart',
      searchIcon: j['search_icon'] ?? 'lucide-search',
      cityIcon: j['city_icon'] ?? 'lucide-map-pin',
      homeText: j['home_text'] ?? 'Accueil',
      programText: j['program_text'] ?? 'Programme',
      speakerText: j['speaker_text'] ?? 'Speakers',
      sponsorText: j['sponsor_text'] ?? 'Sponsors',
      infoText: j['info_text'] ?? 'Infos',
      agendaText: j['agenda_text'] ?? 'Calendrier',
      favoriteText: j['favorite_text'] ?? 'Favoris',
      filterText: j['filter_text'] ?? 'Filtrer',
      searchText: j['search_text'] ?? 'Rechercher',
      cityText: j['city_text'] ?? 'Ville',
      moderatorText: j['moderator_text'] ?? 'Modérateurs',
      committeeText: j['committee_text'] ?? 'Comité',
      sessionText: j['session_text'] ?? 'Sessions',
      vodText: j['vod_text'] ?? 'Vidéos',
      pollText: j['poll_text'] ?? 'Sondage',
      askText: j['ask_text'] ?? 'Questions',
      likeText: j['like_text'] ?? 'Favoris',
      presidentWordText: j['president_word_text'] ?? 'Mot du président',
      faqText: j['faq_text'] ?? 'FAQ',
      phoneText: j['phone_text'] ?? 'Tél',
      addressText: j['address_text'] ?? 'Adresse',
      contactText: j['contact_text'] ?? 'Contact',
    );
  }
}
