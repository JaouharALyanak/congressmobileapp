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

      // ── Drawer latéral gauche ────────────────────────────────────────────
      drawer: Drawer(
        backgroundColor: t.footerBgColor,
        child: SafeArea(
          child: Column(
            children: [
              // ── En-tête du drawer ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: t.headerBg,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showLogo)
                      Opacity(
                        opacity: 0.9,
                        child: Image.network(
                          t.headerLogoUrl!,
                          height: rS(context, 48),
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const SizedBox(),
                        ),
                      ),
                    if (showLogo) const SizedBox(height: 12),
                    Text(
                      t.eventTitle,
                      style: TextStyle(
                        color: t.headerColorTitle,
                        fontSize: rFs(context, 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (t.eventSubtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          t.eventSubtitle,
                          style: TextStyle(
                            color: t.headerColorSubtitle.withValues(
                              alpha: 0.85,
                            ),
                            fontSize: rFs(context, 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Items de navigation ──
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: titles.length,
                  itemBuilder: (context, i) {
                    final isSelected = _selectedIndex == i;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Material(
                        color: isSelected
                            ? t.footerActiveBgColor.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _navigateTo(i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                AppIcon(
                                  iconKey: icons[i],
                                  size: 22,
                                  color: isSelected
                                      ? t.footerActiveBgColor
                                      : t.footerIconeColor,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  titles[i],
                                  style: TextStyle(
                                    color: isSelected
                                        ? t.footerActiveBgColor
                                        : t.mainTextPrimaryColor,
                                    fontSize: rFs(context, 15),
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const Spacer(),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: t.footerActiveBgColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // ── Header ──────────────────────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          height: 100 + MediaQuery.of(context).padding.top,
          decoration: BoxDecoration(
            color: t.headerBg,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Bouton hamburger (gauche) ──
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: Icon(
                        Icons.menu_rounded,
                        color: t.headerColorTitle,
                        size: 26,
                      ),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
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
                              fontSize: rFs(context, 22),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet(context) ? 80 : 60,
                            ),
                            child: Text(
                              t.eventSubtitle,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: t.headerColorSubtitle,
                                fontSize: rFs(context, 13),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(
                            iconKey: icons[_selectedIndex],
                            size: 24,
                            color: t.headerColorTitle,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            titles[_selectedIndex],
                            style: TextStyle(
                              color: t.headerColorTitle,
                              fontSize: rFs(context, 22),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                // ── Bouton agenda (Programme tab) ──
                if (_selectedIndex == 1)
                  Positioned(
                    right: 12,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Consumer<ProgramProvider>(
                        builder: (context, pp, _) {
                          final count = pp.agendaCount;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                icon: Icon(
                                  count > 0 ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AgendaView()),
                                ),
                              ),
                              if (count > 0)
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: t.mainBtnPrimaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                    child: Text(
                                      '$count',
                                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
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
                        opacity: 0.7,
                        child: Transform.rotate(
                          angle: t.headerRotateDegree * (3.14159 / 180),
                          child: Image.network(
                            t.headerLogoUrl!,
                            height: rS(context, 40),
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

      // ── Footer ──────────────────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: t.footerBgColor,
        selectedItemColor: t.footerActiveBgColor,
        unselectedItemColor: t.footerIconeColor,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: AppIcon(iconKey: s.homeIcon, size: 22),
            label: s.homeText,
          ),
          BottomNavigationBarItem(
            icon: AppIcon(iconKey: s.programIcon, size: 22),
            label: s.programText,
          ),
          BottomNavigationBarItem(
            icon: AppIcon(iconKey: s.speakerIcon, size: 22),
            label: s.speakerText,
          ),
          BottomNavigationBarItem(
            icon: AppIcon(iconKey: s.sponsorIcon, size: 22),
            label: s.sponsorText,
          ),
          BottomNavigationBarItem(
            icon: AppIcon(iconKey: s.infoIcon, size: 22),
            label: s.infoText,
          ),
        ],
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
      title: const Row(
        children: [
          Icon(Icons.system_update_rounded, color: Color(0xFF6A1B62)),
          SizedBox(width: 8),
          Text('Mise à jour disponible'),
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
