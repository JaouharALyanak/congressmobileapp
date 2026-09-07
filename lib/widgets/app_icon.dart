import 'package:flutter/material.dart';

// Lucide
import 'package:lucide_icons_flutter/lucide_icons.dart';

// FontAwesome
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppIcon extends StatelessWidget {
  final String iconKey;
  final double size;
  final Color? color;

  const AppIcon({super.key, required this.iconKey, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    // 1. FontAwesome
    if (iconKey.startsWith('fas-')) {
      final FaIconData? faIcon = _resolveFontAwesome(iconKey);

      return FaIcon(
        faIcon ?? FontAwesomeIcons.question,
        size: size,
        color: color,
      );
    }

    // 2. Heroicons
    if (iconKey.startsWith('heroicon-')) {
      final IconData? iconData = _resolveHeroicon(iconKey);

      return Icon(iconData ?? Icons.help_outline, size: size, color: color);
    }

    // 3. Lucide (par défaut)
    final IconData? iconData = _resolveLucide(iconKey);

    return Icon(iconData ?? Icons.help_outline, size: size, color: color);
  }

  // -----------------------------
  // LUCIDE
  // -----------------------------
  static IconData? _resolveLucide(String key) {
    final String name = _toCamelCase(key.replaceFirst('lucide-', ''));

    final Map<String, IconData> lucide = {
      // ── Médical / Congrès ─────────────────────────────────────────
      'mic2': LucideIcons.micVocal,
      'micVocal': LucideIcons.micVocal,
      'mic': LucideIcons.mic,
      'gavel': LucideIcons.gavel,
      'presentation': LucideIcons.presentation,
      'stethoscope': LucideIcons.stethoscope,
      'pill': LucideIcons.pill,
      'activity': LucideIcons.activity,
      'heartPulse': LucideIcons.heartPulse,
      'hospital': LucideIcons.hospital,
      'microscope': LucideIcons.microscope,
      'syringe': LucideIcons.syringe,
      'thermometer': LucideIcons.thermometer,
      'brain': LucideIcons.brain,
      'eye': LucideIcons.eye,
      'bone': LucideIcons.bone,
      'dna': LucideIcons.dna,
      'cross': LucideIcons.cross,

      // ── Navigation / UI ───────────────────────────────────────────
      'home': LucideIcons.house,
      'house': LucideIcons.house,
      'menu': LucideIcons.menu,
      'x': LucideIcons.x,
      'check': LucideIcons.check,
      'checkCircle': LucideIcons.circleCheck,
      'checkCircle2': LucideIcons.circleCheck,
      'plus': LucideIcons.plus,
      'plusCircle': LucideIcons.circlePlus,
      'minus': LucideIcons.minus,
      'chevronRight': LucideIcons.chevronRight,
      'chevronLeft': LucideIcons.chevronLeft,
      'chevronDown': LucideIcons.chevronDown,
      'chevronUp': LucideIcons.chevronUp,
      'arrowRight': LucideIcons.arrowRight,
      'arrowLeft': LucideIcons.arrowLeft,
      'arrowUp': LucideIcons.arrowUp,
      'arrowDown': LucideIcons.arrowDown,
      'externalLink': LucideIcons.externalLink,
      'link': LucideIcons.link,
      'link2': LucideIcons.link2,
      'share': LucideIcons.share,
      'share2': LucideIcons.share2,
      'moreHorizontal': LucideIcons.ellipsis,
      'moreVertical': LucideIcons.ellipsisVertical,
      'gripVertical': LucideIcons.gripVertical,

      // ── Programme / Calendrier ────────────────────────────────────
      'calendarRange': LucideIcons.calendarRange,
      'calendar': LucideIcons.calendar,
      'calendarDays': LucideIcons.calendarDays,
      'calendarCheck': LucideIcons.calendarCheck,
      'calendarClock': LucideIcons.calendarClock,
      'clock': LucideIcons.clock,
      'clock3': LucideIcons.clock3,
      'timer': LucideIcons.timer,
      'alarm': LucideIcons.alarmClock,
      'alarmClock': LucideIcons.alarmClock,
      'sun': LucideIcons.sun,
      'moon': LucideIcons.moon,
      'sunrise': LucideIcons.sunrise,
      'sunset': LucideIcons.sunset,

      // ── Personnes / Speakers ──────────────────────────────────────
      'users': LucideIcons.users,
      'users2': LucideIcons.usersRound,
      'usersRound': LucideIcons.usersRound,
      'user': LucideIcons.user,
      'userRound': LucideIcons.userRound,
      'userCheck': LucideIcons.userCheck,
      'userPlus': LucideIcons.userPlus,
      'contact': LucideIcons.contact,
      'handshake': LucideIcons.handshake,
      'award': LucideIcons.award,
      'badge': LucideIcons.badge,
      'badgeCheck': LucideIcons.badgeCheck,
      'crown': LucideIcons.crown,
      'graduation': LucideIcons.graduationCap,
      'graduationCap': LucideIcons.graduationCap,

      // ── Fichiers / Documents ──────────────────────────────────────
      'file': LucideIcons.file,
      'fileText': LucideIcons.fileText,
      'filePdf': LucideIcons.file,
      'fileCheck': LucideIcons.fileCheck,
      'fileSearch': LucideIcons.fileSearch,
      'folder': LucideIcons.folder,
      'folderOpen': LucideIcons.folderOpen,
      'clipboard': LucideIcons.clipboard,
      'clipboardList': LucideIcons.clipboardList,
      'clipboardCheck': LucideIcons.clipboardCheck,
      'newspaper': LucideIcons.newspaper,
      'book': LucideIcons.book,
      'bookOpen': LucideIcons.bookOpen,
      'bookmark': LucideIcons.bookmark,
      'scroll': LucideIcons.scroll,
      'scrollText': LucideIcons.scrollText,

      // ── Infos / Communication ─────────────────────────────────────
      'info': LucideIcons.info,
      'helpCircle': LucideIcons.circleQuestionMark,
      'circleQuestionMark': LucideIcons.circleQuestionMark,
      'messageCircle': LucideIcons.messageCircle,
      'messageSquare': LucideIcons.messageSquare,
      'mail': LucideIcons.mail,
      'mailOpen': LucideIcons.mailOpen,
      'phone': LucideIcons.phone,
      'phoneCall': LucideIcons.phoneCall,
      'send': LucideIcons.send,
      'bell': LucideIcons.bell,
      'bellRing': LucideIcons.bellRing,
      'rss': LucideIcons.rss,
      'megaphone': LucideIcons.megaphone,
      'announcement': LucideIcons.megaphone,
      'quote': LucideIcons.quote,

      // ── Médias / Vidéo ────────────────────────────────────────────
      'playCircle': LucideIcons.circlePlay,
      'circlePlay': LucideIcons.circlePlay,
      'play': LucideIcons.play,
      'pause': LucideIcons.pause,
      'video': LucideIcons.video,
      'youtube': LucideIcons.circlePlay,
      'tv': LucideIcons.tv,
      'monitor': LucideIcons.monitor,
      'camera': LucideIcons.camera,
      'image': LucideIcons.image,
      'images': LucideIcons.images,
      'film': LucideIcons.film,
      'music': LucideIcons.music,
      'volume2': LucideIcons.volume2,
      'radio': LucideIcons.radio,

      // ── Localisation ──────────────────────────────────────────────
      'mapPin': LucideIcons.mapPin,
      'map': LucideIcons.map,
      'navigation': LucideIcons.navigation,
      'compass': LucideIcons.compass,
      'globe': LucideIcons.globe,
      'globe2': LucideIcons.globe,
      'building': LucideIcons.building,
      'building2': LucideIcons.building2,
      'hotel': LucideIcons.hotel,
      'landmark': LucideIcons.landmark,
      'flag': LucideIcons.flag,
      'flag2': LucideIcons.flag,

      // ── Recherche / Filtres ───────────────────────────────────────
      'search': LucideIcons.search,
      'filter': LucideIcons.listFilter,
      'listFilter': LucideIcons.listFilter,
      'slidersHorizontal': LucideIcons.slidersHorizontal,
      'sliders': LucideIcons.slidersHorizontal,
      'sortAsc': LucideIcons.arrowUpNarrowWide,
      'sortDesc': LucideIcons.arrowDownNarrowWide,

      // ── Favoris / Social ──────────────────────────────────────────
      'star': LucideIcons.star,
      'starOff': LucideIcons.starOff,
      'heart': LucideIcons.heart,
      'heartOff': LucideIcons.heartOff,
      'thumbsUp': LucideIcons.thumbsUp,
      'thumbsDown': LucideIcons.thumbsDown,

      // ── Agenda / Notifications ────────────────────────────────────
      'calendarPlus': LucideIcons.calendarPlus,
      'calendarMinus': LucideIcons.calendarMinus,
      'calendarX': LucideIcons.calendarX,

      // ── Statistiques / Sondages ───────────────────────────────────
      'barChart3': LucideIcons.chartNoAxesColumn,
      'chartNoAxesColumn': LucideIcons.chartNoAxesColumn,
      'barChart': LucideIcons.chartNoAxesColumn,
      'barChart2': LucideIcons.chartNoAxesColumn,
      'pieChart': LucideIcons.chartPie,
      'lineChart': LucideIcons.chartLine,
      'trendingUp': LucideIcons.trendingUp,
      'trendingDown': LucideIcons.trendingDown,

      // ── Restauration / Pause ─────────────────────────────────────
      'coffee': LucideIcons.coffee,
      'cupSoda': LucideIcons.cupSoda,
      'utensils': LucideIcons.utensils,
      'utensilsCrossed': LucideIcons.utensilsCrossed,
      'pizza': LucideIcons.pizza,
      'sandwich': LucideIcons.sandwich,
      'salad': LucideIcons.salad,
      'wine': LucideIcons.wine,
      'beer': LucideIcons.beer,
      'beerMug': LucideIcons.beer,
      'glassWater': LucideIcons.glassWater,
      'cake': LucideIcons.cakeSlice,
      'cakeSlice': LucideIcons.cakeSlice,
      'apple': LucideIcons.apple,
      'banana': LucideIcons.banana,

      // ── Divers ───────────────────────────────────────────────────
      'circle': LucideIcons.circle,
      'circleDot': LucideIcons.circleDot,
      'circleOff': LucideIcons.circleOff,
      'dot': LucideIcons.dot,
      'sparkles': LucideIcons.sparkles,
      'zap': LucideIcons.zap,
      'bolt': LucideIcons.zap,
      'settings': LucideIcons.settings,
      'settings2': LucideIcons.settings2,
      'wrench': LucideIcons.wrench,
      'tool': LucideIcons.wrench,
      'lock': LucideIcons.lock,
      'unlock': LucideIcons.lockOpen,
      'shield': LucideIcons.shield,
      'shieldCheck': LucideIcons.shieldCheck,
      'key': LucideIcons.key,
      'qrCode': LucideIcons.qrCode,
      'wifi': LucideIcons.wifi,
      'wifiOff': LucideIcons.wifiOff,
      'bluetooth': LucideIcons.bluetooth,
      'printer': LucideIcons.printer,
      'download': LucideIcons.download,
      'upload': LucideIcons.upload,
      'refresh': LucideIcons.refreshCw,
      'refreshCw': LucideIcons.refreshCw,
      'loader': LucideIcons.loader,
      'trash': LucideIcons.trash,
      'trash2': LucideIcons.trash2,
      'edit': LucideIcons.pencil,
      'pencil': LucideIcons.pencil,
      'pen': LucideIcons.pen,
      'copy': LucideIcons.copy,
      'scissors': LucideIcons.scissors,
      'tag': LucideIcons.tag,
      'tags': LucideIcons.tags,
      'layers': LucideIcons.layers,
      'layout': LucideIcons.layoutDashboard,
      'grid': LucideIcons.grid3x3,
      'grid3x3': LucideIcons.grid3x3,
      'list': LucideIcons.list,
      'listOrdered': LucideIcons.listOrdered,
      'type': LucideIcons.wholeWord,
      'text': LucideIcons.wholeWord,
      'alignLeft': LucideIcons.alignStartVertical,
      'package': LucideIcons.package,
      'box': LucideIcons.box,
      'gift': LucideIcons.gift,
      'ticket': LucideIcons.ticket,
      'trophy': LucideIcons.trophy,
      'medal': LucideIcons.medal,
      'target': LucideIcons.target,
      'rocket': LucideIcons.rocket,
      'lightbulb': LucideIcons.lightbulb,
      'flame': LucideIcons.flame,
      'leaf': LucideIcons.leaf,
      'tree': LucideIcons.treeDeciduous,
      'cloud': LucideIcons.cloud,
      'cloudRain': LucideIcons.cloudRain,
      'snowflake': LucideIcons.snowflake,
      'umbrella': LucideIcons.umbrella,
      'plane': LucideIcons.plane,
      'car': LucideIcons.car,
      'bus': LucideIcons.bus,
      'train': LucideIcons.trainFront,
      'bike': LucideIcons.bike,
    };

    return lucide[name];
  }

  // -----------------------------
  // FONT AWESOME (FIX ICI)
  // -----------------------------
  static FaIconData? _resolveFontAwesome(String key) {
    final String name = _toCamelCase(key.replaceFirst('fas-', ''));

    final Map<String, FaIconData> fa = {
      'calendarAlt': FontAwesomeIcons.calendarDays,
      'house': FontAwesomeIcons.house,
      'magnifyingGlass': FontAwesomeIcons.magnifyingGlass,
      'filter': FontAwesomeIcons.filter,
      'coffee': FontAwesomeIcons.mugSaucer,
      'mugHot': FontAwesomeIcons.mugHot,
      'mugSaucer': FontAwesomeIcons.mugSaucer,
      'utensils': FontAwesomeIcons.utensils,
      'burger': FontAwesomeIcons.burger,
      'pizzaSlice': FontAwesomeIcons.pizzaSlice,
      'wineGlass': FontAwesomeIcons.wineGlass,
      'pause': FontAwesomeIcons.pause,
    };

    return fa[name];
  }

  // -----------------------------
  // HEROICONS
  // -----------------------------
  static IconData? _resolveHeroicon(String key) {
    final String name = _toCamelCase(
      key.replaceFirst(RegExp(r'heroicon-[cos]-'), ''),
    );

    final Map<String, IconData> hero = {
      'home': Icons.home_rounded,
      'calendar': Icons.calendar_today,
    };

    return hero[name];
  }

  // -----------------------------
  // UTIL
  // -----------------------------
  static String _toCamelCase(String input) {
    final parts = input.split('-');

    if (parts.isEmpty) return input;

    return parts.first +
        parts
            .skip(1)
            .map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1))
            .join();
  }
}
