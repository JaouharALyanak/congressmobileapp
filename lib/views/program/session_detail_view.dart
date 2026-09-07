import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/html_utils.dart';
import '../../utils/responsive.dart';
import '../../models/program_model.dart';
import '../../models/app_theme_model.dart';
import '../../providers/theme_provider.dart';
import '../../providers/program_provider.dart';
import '../../utils/color_parser.dart';
import '../speakers/speaker_detail_view.dart';
import '../../models/speaker_model.dart';
import '../../providers/speaker_provider.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/webview_sheet.dart';
import '../../widgets/youtube_inpage_player.dart';

class SessionDetailView extends StatelessWidget {
  final ProgramItem item;
  final AppThemeModel theme;

  const SessionDetailView({super.key, required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    final session = item.session;
    // On récupère les settings et le thème depuis le ThemeProvider
    final themeProvider = context.watch<ThemeProvider>();
    final settings = themeProvider.settings;

    final Color primaryColor = ColorParser.parse(
      item.cardStyle.cardIconeColor,
      fallback: theme.timelineBtnColor,
    );

    return Scaffold(
      backgroundColor: theme.eventBgColor,
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () => context.read<ProgramProvider>().loadProgram(forceRefresh: true),
        child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: isTablet(context) ? 220 : 180,
            pinned: true,
            backgroundColor: primaryColor,
            leading: const BackButton(color: Colors.white),
            actions: [
              if (themeProvider.theme.headerLogoState == 'visible' &&
                  themeProvider.theme.headerLogoUrl != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: Transform.rotate(
                      angle:
                          themeProvider.theme.headerRotateDegree *
                          (3.14159 / 180),
                      child: Image.network(
                        themeProvider.theme.headerLogoUrl!,
                        height: 36,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) =>
                            const SizedBox(),
                      ),
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'SESSION :',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: rFs(context, 12),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.displayTitle,
                        maxLines: 3,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: rFs(context, 18),
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoBar(primaryColor),

                  // ── Lecteur inpage ──────────────────────────────────────
                  if (session?.youtubeLink != null &&
                      session?.youtubeStatus == 'live' &&
                      session?.youtubeOpenMode == 'inpage') ...[
                    const SizedBox(height: 20),
                    YoutubeInPagePlayer(
                      youtubeUrl: session!.youtubeLink!,
                      accentColor: primaryColor,
                    ),
                  ],

                  // ── Boutons d'action (popup / external / ask / vote) ────
                  if ((session?.youtubeLink != null &&
                          session?.youtubeStatus == 'live' &&
                          session?.youtubeOpenMode != 'inpage') ||
                      (session?.askUrl != null &&
                          session?.messageStatus == 'enabled') ||
                      (session?.voteUrl != null &&
                          session?.pollStatus == 'published')) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.end,
                      children: [
                        if (session?.youtubeLink != null &&
                            session?.youtubeStatus == 'live' &&
                            session?.youtubeOpenMode != 'inpage')
                          _buildActionButton(
                            context: context,
                            iconKey: settings.vodIcon,
                            label: settings.vodText,
                            color: primaryColor,
                            onTap: () => session!.youtubeOpenMode == 'popup'
                                ? WebViewSheet.show(
                                    context,
                                    url: session.youtubeLink!,
                                    title: settings.vodText,
                                    accentColor: primaryColor,
                                  )
                                : _launchYoutube(session.youtubeLink!),
                          ),
                        if (session?.askUrl != null &&
                            session?.messageStatus == 'enabled')
                          _buildActionButton(
                            context: context,
                            icon: Icons.help_outline_rounded,
                            label: settings.askText,
                            color: primaryColor,
                            onTap: () => WebViewSheet.show(
                              context,
                              url: session!.askUrl!,
                              title: settings.askText,
                              accentColor: primaryColor,
                            ),
                          ),
                        if (session?.voteUrl != null &&
                            session?.pollStatus == 'published')
                          _buildActionButton(
                            context: context,
                            icon: Icons.how_to_vote_rounded,
                            label: settings.pollText,
                            color: primaryColor,
                            onTap: () => WebViewSheet.show(
                              context,
                              url: session!.voteUrl!,
                              title: settings.pollText,
                              accentColor: primaryColor,
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),
                  ...[
                    _buildSectionTitle("À propos de la session", primaryColor),
                    const SizedBox(height: 12),
                    htmlContentOrEmpty(
                      session?.description ?? item.description,
                      textStyle: TextStyle(
                        color: theme.mainTextPrimaryColor,
                        fontSize: 14,
                        height: 1.6,
                      ),
                      emptyColor: theme.mainTextSecondaryColor,
                    ),
                    const SizedBox(height: 32),
                  ],

                  // --- SECTION PARTICIPANTS COMPACTE (CÔTE À CÔTE) ---
                  if (session != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (session.speakers.isNotEmpty)
                          Expanded(
                            child: _buildCompactPeopleList(
                              settings.speakerText,
                              session.speakers,
                              primaryColor,
                              theme,
                              context,
                            ),
                          ),

                        if (session.speakers.isNotEmpty &&
                            session.moderators.isNotEmpty)
                          const SizedBox(width: 16),

                        if (session.moderators.isNotEmpty)
                          Expanded(
                            child: _buildCompactPeopleList(
                              settings.moderatorText,
                              session.moderators,
                              primaryColor,
                              theme,
                              context,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _launchYoutube(String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } catch (_) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    }
  }

  Widget _buildActionButton({
    required BuildContext context,
    String? iconKey,
    IconData? icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: iconKey != null
          ? AppIcon(iconKey: iconKey, size: 14, color: Colors.white)
          : Icon(icon, size: 14, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  Widget _buildInfoBar(Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: theme.cardShadow,
      ),
      child: Row(
        children: [
          _infoItem(
            Icons.access_time_rounded,
            "Horaire",
            "${item.startTime} - ${item.endTime}",
            color,
          ),
          const Spacer(),
          if (item.session?.room != null) ...[
            Container(
              width: 1,
              height: 30,
              color: Colors.grey.shade200,
              margin: const EdgeInsets.symmetric(horizontal: 20),
            ),
            _infoItem(
              Icons.location_on_rounded,
              "Salle",
              item.session!.room!,
              color,
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactPeopleList(
    String title,
    List<ProgramPerson> persons,
    Color color,
    AppThemeModel theme,
    BuildContext context, // Context ajouté
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- TITRE DE LA SECTION (Ligne verticale + Texte) ---
        Row(
          children: [
            Container(width: 3, height: 12, color: color.withValues(alpha: 0.5)),
            const SizedBox(width: 6),
            Text(
              "$title (${persons.length})",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // --- LISTE DES PERSONNES ---
        ...persons.map((p) => _buildPersonItem(p, color, theme, context)),
      ],
    );
  }

  Widget _buildPersonItem(
    ProgramPerson p,
    Color color,
    AppThemeModel theme,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        // On met le clic ici
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // --- LOGIQUE DE NAVIGATION ---
          final speakerProvider = context.read<SpeakerProvider>();
          Speaker speaker;
          try {
            speaker = speakerProvider.speakers.firstWhere((s) => s.id == p.id);
          } catch (_) {
            speaker = Speaker(
              id: p.id,
              firstName: p.firstName,
              lastName: p.lastName,
              photo: p.photo,
              title: p.title ?? '',
              biography: '',
              specialityList: [],
              email: '',
              cityId: 0,
              countryName: '',
              countryId: 0,
              cityName: '',
              cityIdNested: 0,
              countryIdNested: 0,
            );
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SpeakerDetailView(speaker: speaker),
            ),
          );
        },
        child: Row(
          // --- TON DESIGN ORIGINAL ---
          children: [
            // AVATAR
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.1),
                image: p.photo != null
                    ? DecorationImage(
                        image: NetworkImage(p.photo!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: p.photo == null
                  ? Center(
                      child: Text(
                        (p.firstName.isNotEmpty ? p.firstName[0] : '') +
                            (p.lastName.isNotEmpty ? p.lastName[0] : ''),
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            // TEXTES (NOM + TITRE)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  if (p.title != null)
                    Text(
                      p.title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.mainTextSecondaryColor,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            // Petite flèche pour indiquer que c'est cliquable
            Icon(Icons.chevron_right, size: 14, color: color.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}
