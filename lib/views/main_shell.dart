import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/views/program/program_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../utils/responsive.dart';
import '../providers/connectivity_provider.dart';
import '../providers/program_provider.dart';
import '../services/update_service.dart';
import '../widgets/app_icon.dart';
import 'speakers/speakers_view.dart';
import 'sponsors/sponsors_view.dart';
import 'infos/infos_view.dart';
import 'home/home_view.dart';
import 'program/agenda_view.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Empêche un double-affichage dans la même session (ex: rebuild)
  // Remis à false à chaque nouveau démarrage car _MainShellState est recréé
  bool _popupShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _schedulePopup();
      _checkUpdate();
    });
  }

  void _schedulePopup() {
    if (!mounted) return;
    final tp = context.read<ThemeProvider>();
    final url = tp.theme.popupImageUrl;

    // Pas d'URL configurée → pas de popup
    if (url == null || url.isEmpty) return;

    final delay = tp.theme.popupTimerToShow;
    Future.delayed(Duration(seconds: delay), () {
      if (!mounted || _popupShown) return;
      _popupShown = true;
      _showPopup(url);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showPopup(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => _PopupAd(imageUrl: imageUrl),
    );
  }

  Future<void> _checkUpdate() async {
    if (!mounted) return;
    final dismissed = await UpdateService.wasDismissedToday();
    if (dismissed) return;
    final info = await UpdateService.check();
    if (info == null || !info.hasUpdate) return;
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _UpdateDialog(info: info),
    );
  }

  void _navigateTo(int index) {
    setState(() => _selectedIndex = index);
    _scaffoldKey.currentState?.closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();

    if (tp.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final t = tp.theme;
    final s = tp.settings;

    final List<Widget> pages = [
      HomeView(
        onTabChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      const ProgramView(),
      const SpeakersView(),
      const SponsorsView(),
      const InfosView(),
    ];

    final List<String> titles = [
      s.homeText,
      s.programText,
      s.speakerText,
      s.sponsorText,
      s.infoText,
    ];

    final List<String> icons = [
      s.homeIcon,
      s.programIcon,
      s.speakerIcon,
      s.sponsorIcon,
      s.infoIcon,
    ];

    final bool showLogo =
        t.headerLogoState == 'visible' && t.headerLogoUrl != null;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: t.eventBgColor,

      // ── Drawer latéral gauche (iOS 27 Apple Style) ───────────────────
      drawer: Drawer(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF141416)
            : const Color(0xFFF6F8FA),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            // ── En-tête du drawer avec bordure spéculaire & bouton fermer ──
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 16,
                16,
                20,
              ),
              decoration: BoxDecoration(
                color: t.headerBg,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                  topRight: Radius.circular(30),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 0.75,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showLogo)
                          Opacity(
                            opacity: 0.95,
                            child: Image.network(
                              t.headerLogoUrl!,
                              height: rS(context, 42),
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const SizedBox(),
                            ),
                          ),
                        if (showLogo) const SizedBox(height: 10),
                        Text(
                          t.eventTitle,
                          style: TextStyle(
                            color: t.headerColorTitle,
                            fontSize: rFs(context, 20),
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                        ),
                        if (t.eventSubtitle.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              t.eventSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: t.headerColorSubtitle.withValues(
                                  alpha: 0.85,
                                ),
                                fontSize: rFs(context, 12),
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Bouton fermer circulaire dépoli
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 0.75,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.close_rounded,
                          color: t.headerColorTitle,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Items de navigation (iOS 27 Floating Capsule style) ──
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: titles.length,
                itemBuilder: (context, i) {
                  final isSelected = _selectedIndex == i;
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  final Color activeCol = t.footerActiveBgColor;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _navigateTo(i);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? const Color(0xFF1C1C1E) : Colors.white)
                                : (isDark
                                    ? const Color(0xFF1C1C1E).withValues(alpha: 0.35)
                                    : Colors.white.withValues(alpha: 0.82)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark
                                      ? Colors.white.withValues(alpha: 0.16)
                                      : Colors.white.withValues(alpha: 0.95))
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.04)),
                              width: isSelected ? 1.0 : 0.75,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isDark ? 0.28 : 0.06,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                    if (!isDark)
                                      BoxShadow(
                                        color: activeCol.withValues(alpha: 0.14),
                                        blurRadius: 14,
                                        offset: const Offset(0, 2),
                                      ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isDark ? 0.10 : 0.02,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? activeCol.withValues(alpha: 0.12)
                                      : Colors.black.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: AppIcon(
                                    iconKey: icons[i],
                                    size: 20,
                                    color: isSelected
                                        ? activeCol
                                        : const Color(0xFF8E8E93),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  titles[i],
                                  style: TextStyle(
                                    color: isSelected
                                        ? activeCol
                                        : t.mainTextPrimaryColor,
                                    fontSize: rFs(context, 15.5),
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    letterSpacing: -0.25,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: isSelected
                                    ? activeCol
                                    : const Color(0xFFC7C7CC),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Footer du drawer : ASCREA branding ──
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 4),
                child: Opacity(
                  opacity: 0.45,
                  child: Image.asset(
                    'assets/images/logo-ascrea.png',
                    height: 14,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Header (Apple Frosted Curved AppBar) ─────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(88),
        child: Container(
          height: 88 + MediaQuery.of(context).padding.top,
          decoration: BoxDecoration(
            color: t.headerBg,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.18),
                width: 0.75,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Bouton hamburger (gauche) : Apple Circular Glass ──
                Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _scaffoldKey.currentState?.openDrawer();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 0.75,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.menu_rounded,
                            color: t.headerColorTitle,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Centre : titre home ou icône+texte autres onglets ──
                _selectedIndex == 0
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            t.eventTitle,
                            style: TextStyle(
                              color: t.headerColorTitle,
                              fontSize: rFs(context, 21),
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                            ),
                          ),
                          if (t.eventSubtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet(context) ? 80 : 60,
                              ),
                              child: Text(
                                t.eventSubtitle,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: t.headerColorSubtitle.withValues(
                                    alpha: 0.88,
                                  ),
                                  fontSize: rFs(context, 12),
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ),
                          ],
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(
                            iconKey: icons[_selectedIndex],
                            size: 22,
                            color: t.headerColorTitle,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            titles[_selectedIndex],
                            style: TextStyle(
                              color: t.headerColorTitle,
                              fontSize: rFs(context, 20),
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),

                // ── Bouton agenda (Programme tab) : Apple Circular Glass ──
                if (_selectedIndex == 1)
                  Positioned(
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Consumer<ProgramProvider>(
                        builder: (context, pp, _) {
                          final count = pp.agendaCount;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AgendaView(),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.25,
                                      ),
                                      width: 0.75,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      count > 0
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_outline_rounded,
                                      color: t.headerColorTitle,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              if (count > 0)
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF3B30),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    child: Text(
                                      '$count',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                // ── Logo coin droit ──
                if (showLogo && _selectedIndex != 1)
                  Positioned(
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Opacity(
                        opacity: 0.85,
                        child: Transform.rotate(
                          angle: t.headerRotateDegree * (3.14159 / 180),
                          child: Image.network(
                            t.headerLogoUrl!,
                            height: rS(context, 38),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stack) =>
                                const SizedBox(),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),

      // ── Body + Offline banner ────────────────────────────────────────────
      body: Stack(
        children: [
          Column(
            children: [
              // ── Offline banner ──
              Consumer<ConnectivityProvider>(
                builder: (context, conn, _) {
                  if (conn.isOnline) return const SizedBox.shrink();
                  return Container(
                    width: double.infinity,
                    color: Colors.orange.shade700,
                    padding: const EdgeInsets.symmetric(
                      vertical: 7,
                      horizontal: 16,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.wifi_off, color: Colors.white, size: 15),
                        SizedBox(width: 8),
                        Text(
                          'Vous êtes hors ligne',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // ── Pages ──
              Expanded(
                child: IndexedStack(index: _selectedIndex, children: pages),
              ),
            ],
          ),
          // ── Logo ASCREA (coin bas droite) ────────────────────────────────
          Positioned(
            bottom: 10,
            right: 12,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.45,
                child: Image.asset(
                  'assets/images/logo-ascrea.png',
                  height: 14,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),

      // ── iOS 27 Futuristic Frosted Dock Navigation Bar ────────────────────
      bottomNavigationBar: _IosModernNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        activeColor: t.footerActiveBgColor,
        inactiveColor: t.footerIconeColor,
        backgroundColor: t.footerBgColor,
        items: [
          _NavBarItemData(iconKey: s.homeIcon, label: s.homeText),
          _NavBarItemData(iconKey: s.programIcon, label: s.programText),
          _NavBarItemData(iconKey: s.speakerIcon, label: s.speakerText),
          _NavBarItemData(iconKey: s.sponsorIcon, label: s.sponsorText),
          _NavBarItemData(iconKey: s.infoIcon, label: s.infoText),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// iOS 27 Style Floating Glassmorphic Dock Navigation Bar
// ─────────────────────────────────────────────────────────────────────────────

class _NavBarItemData {
  final String iconKey;
  final String label;
  const _NavBarItemData({required this.iconKey, required this.label});
}

class _IosModernNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color activeColor;
  final Color inactiveColor;
  final Color backgroundColor;
  final List<_NavBarItemData> items;

  const _IosModernNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
    required this.backgroundColor,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        bottomPadding > 0 ? bottomPadding : 12,
      ),
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            // Apple-style soft ambient occlusion shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.07),
              blurRadius: 28,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xE01C1C1E)
                    : const Color(0xF2FFFFFF),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.85),
                  width: 1.0,
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double totalWidth = constraints.maxWidth;
                  final double itemWidth = totalWidth / items.length;
                  const double pillMarginH = 2.0;
                  const double pillMarginV = 2.0;
                  final double pillWidth = itemWidth - (pillMarginH * 2);
                  final double pillHeight = 54.0 - (pillMarginV * 2);

                  return Stack(
                    children: [
                      // ── Smooth Sliding Liquid Capsule (Apple HIG) ──
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        left: (currentIndex * itemWidth) + pillMarginH,
                        top: pillMarginV,
                        width: pillWidth,
                        height: pillHeight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.25 : 0.06,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                              if (!isDark)
                                BoxShadow(
                                  color: activeColor.withValues(alpha: 0.10),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.16)
                                  : Colors.white.withValues(alpha: 0.90),
                              width: 0.8,
                            ),
                          ),
                        ),
                      ),

                      // ── Navigation Items ──
                      Row(
                        children: List.generate(items.length, (index) {
                          final item = items[index];
                          final isSelected = index == currentIndex;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (!isSelected) {
                                  HapticFeedback.selectionClick();
                                  onTap(index);
                                }
                              },
                              behavior: HitTestBehavior.opaque,
                              child: SizedBox(
                                height: 54,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedScale(
                                      scale: isSelected ? 1.08 : 0.98,
                                      duration: const Duration(milliseconds: 240),
                                      curve: Curves.easeOutBack,
                                      child: AppIcon(
                                        iconKey: item.iconKey,
                                        size: 20,
                                        color: isSelected
                                            ? activeColor
                                            : const Color(0xFF8E8E93),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeOut,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? activeColor
                                            : const Color(0xFF8E8E93),
                                        letterSpacing: -0.24,
                                      ),
                                      child: Text(
                                        item.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UpdateDialog extends StatelessWidget {
  final UpdateInfo info;
  const _UpdateDialog({required this.info});

  @override
  Widget build(BuildContext context) {
    final t = context.read<ThemeProvider>().theme;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.system_update_rounded, color: t.headerBg),
          const SizedBox(width: 8),
          const Text('Mise à jour disponible'),
        ],
      ),
      content: Text(
        'Une nouvelle version (${info.storeVersion}) est disponible.\nVous utilisez actuellement la version ${info.currentVersion}.',
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await UpdateService.saveDismissed();
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Plus tard'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: t.mainBtnPrimaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () async {
            await UpdateService.saveDismissed();
            if (context.mounted) Navigator.pop(context);
            final uri = Uri.parse(info.storeUrl);
            if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
          },
          child: const Text('Mettre à jour'),
        ),
      ],
    );
  }
}

class _PopupAd extends StatelessWidget {
  final String imageUrl;
  const _PopupAd({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Center(
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            // Image du popup
            GestureDetector(
              onTap: () {}, // absorbe les taps sur l'image pour ne pas fermer
              child: Container(
                margin: const EdgeInsets.all(24),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.88,
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (_, _) => const SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(child: CircularProgressIndicator(color: Colors.white)),
                    ),
                    errorWidget: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            // Bouton fermer
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 18, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
