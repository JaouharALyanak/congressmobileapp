import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/program_model.dart';
import '../../../models/app_theme_model.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/program_provider.dart';
import '../../../widgets/app_icon.dart';
import '../../../widgets/webview_sheet.dart';
import '../../../widgets/youtube_inpage_player.dart';
import '../../../widgets/notification_delay_picker.dart';
import '../../../utils/color_parser.dart';
import '../../../utils/responsive.dart';
import 'session_detail_view.dart';
import 'session_detail_sheet.dart';

class ProgramItemCard extends StatefulWidget {
  final ProgramItem item;
  final AppThemeModel theme;
  final bool isLast;
  final String programDayDate;

  const ProgramItemCard({
    super.key,
    required this.item,
    required this.theme,
    this.isLast = false,
    required this.programDayDate,
  });

  @override
  State<ProgramItemCard> createState() => _ProgramItemCardState();
}

class _ProgramItemCardState extends State<ProgramItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _liveController;
  late Animation<double> _liveAnimation;
  late final Timer _timer;
  bool _cachedIsLive = false;
  bool _cachedIsEnded = false;

  @override
  void initState() {
    super.initState();

    _liveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _liveAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _liveController, curve: Curves.easeInOut),
    );

    _cachedIsLive = _computeIsLive();
    _cachedIsEnded = _computeIsEnded();

    if (_cachedIsLive) {
      _liveController.repeat(reverse: true);
    }

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      final nowLive = _computeIsLive();
      final nowEnded = _computeIsEnded();
      if (nowLive != _cachedIsLive || nowEnded != _cachedIsEnded) {
        setState(() {
          _cachedIsLive = nowLive;
          _cachedIsEnded = nowEnded;
        });
        if (nowLive && !_liveController.isAnimating) {
          _liveController.repeat(reverse: true);
        } else if (!nowLive && _liveController.isAnimating) {
          _liveController.stop();
          _liveController.value = 0.0;
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant ProgramItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nowLive = _computeIsLive();
    final nowEnded = _computeIsEnded();
    if (nowLive != _cachedIsLive || nowEnded != _cachedIsEnded) {
      _cachedIsLive = nowLive;
      _cachedIsEnded = nowEnded;
      if (nowLive && !_liveController.isAnimating) {
        _liveController.repeat(reverse: true);
      } else if (!nowLive && _liveController.isAnimating) {
        _liveController.stop();
        _liveController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _liveController.dispose();
    super.dispose();
  }

  bool _computeIsLive() {
    try {
      final now = DateTime.now();
      final eventDate = DateTime.parse(widget.programDayDate);
      final startParts = widget.item.startTime.split(':');
      final endParts = widget.item.endTime.split(':');
      final start = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );
      final end = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );
      return now.isAfter(start) && now.isBefore(end);
    } catch (_) {
      return false;
    }
  }

  bool _computeIsEnded() {
    try {
      final now = DateTime.now();
      final eventDate = DateTime.parse(widget.programDayDate);
      final endParts = widget.item.endTime.split(':');
      final end = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );
      return now.isAfter(end);
    } catch (_) {
      return false;
    }
  }

  void _handleTap(BuildContext context) {
    if (widget.item.isSession) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              SessionDetailView(item: widget.item, theme: widget.theme),
        ),
      );
    } else if ((widget.item.description?.isNotEmpty ?? false) ||
        widget.item.location != null) {
      SessionDetailSheet.showOther(
        context,
        item: widget.item,
        theme: widget.theme,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<ThemeProvider>().settings;
    final programProvider = context
        .watch<ProgramProvider>(); // <--- WATCH PROGRAM PROVIDER
    final style = widget.item.cardStyle;

    final Color resolvedBg = ColorParser.parse(
      style.cardBgColor,
      fallback: widget.theme.cardBgColor,
    );
    final Color resolvedTitle = ColorParser.parse(
      style.cardTitleColor,
      fallback: widget.theme.cardTitleColor,
    );
    final Color resolvedDesc = ColorParser.parse(
      style.cardDescriptionColor,
      fallback: widget.theme.cardDescriptionColor,
    );
    final Color resolvedIcon = ColorParser.parse(
      style.cardIconeColor,
      fallback: widget.theme.cardIconeColor,
    );
    final Color resolvedTime = ColorParser.parse(
      style.cardTimesColor,
      fallback: widget.theme.cardTimesColor,
    );
    final Color resolvedBorder = ColorParser.parse(
      style.cardBorderColor,
      fallback: widget.theme.cardBorderColor,
    );

    final String? description = widget.item.isSession
        ? (widget.item.session?.description ?? widget.item.description)
        : widget.item.description;

    final String? room = widget.item.session?.room;
    final bool hasSpeakers =
        widget.item.isSession &&
        widget.item.session != null &&
        (widget.item.session!.speakers.isNotEmpty ||
            widget.item.session!.moderators.isNotEmpty);

    final bool isInAgenda = programProvider.isItemInAgenda(
      widget.item.id,
    ); // <--- CHECK AGENDA STATUS

    return Opacity(
      opacity: _cachedIsEnded ? 0.5 : 1.0,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTimeline(resolvedIcon),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: resolvedBg,
                  borderRadius: BorderRadius.circular(16),
                  border: style.cardBorderSize > 0
                      ? Border.all(
                          color: resolvedBorder,
                          width: style.cardBorderSize.toDouble(),
                        )
                      : null,
                  boxShadow: widget.theme.cardShadow,
                ),
                child: InkWell(
                  onTap: () => _handleTap(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── ROW 1: icon + badge/titre ←→ LIVE + calendar ─
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppIcon(
                              iconKey: widget.item.icon,
                              size: 18,
                              color: resolvedIcon,
                            ),
                            const SizedBox(width: 8),

                            if (widget.item.isSession) ...[
                              // Session : badge fixe, puis spacer, puis icônes
                              _buildSessionBadge(
                                settings.sessionText,
                                resolvedIcon,
                              ),
                              const Spacer(),
                              if (_cachedIsLive) ...[
                                _buildLiveBadge(),
                                const SizedBox(width: 8),
                              ],
                              if (widget.item.session?.youtubeLink != null &&
                                  widget.item.session!.youtubeStatus == 'live') ...[
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _openYoutube(
                                    context,
                                    widget.item.session!.youtubeLink!,
                                    widget.item.session!.youtubeOpenMode,
                                    resolvedIcon,
                                    settings.vodText,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: resolvedIcon.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: AppIcon(
                                      iconKey: settings.vodIcon,
                                      size: 14,
                                      color: resolvedIcon,
                                    ),
                                  ),
                                ),
                              ],
                              if (widget.item.session?.askUrl != null &&
                                  widget.item.session!.messageStatus == 'enabled') ...[
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => WebViewSheet.show(
                                    context,
                                    url: widget.item.session!.askUrl!,
                                    title: settings.askText,
                                    accentColor: resolvedIcon,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: resolvedIcon.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.help_outline_rounded,
                                      size: 14,
                                      color: resolvedIcon,
                                    ),
                                  ),
                                ),
                              ],
                              if (widget.item.session?.voteUrl != null &&
                                  widget.item.session!.pollStatus == 'published') ...[
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => WebViewSheet.show(
                                    context,
                                    url: widget.item.session!.voteUrl!,
                                    title: settings.pollText,
                                    accentColor: resolvedIcon,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: resolvedIcon.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.how_to_vote_rounded,
                                      size: 14,
                                      color: resolvedIcon,
                                    ),
                                  ),
                                ),
                              ],
                              if (!_cachedIsEnded) ...[
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () async {
                                    if (programProvider.isItemInAgenda(widget.item.id)) {
                                      // Retrait direct, pas besoin du picker
                                      programProvider.toggleAgendaItem(widget.item);
                                    } else {
                                      // Ajout : demander le délai d'abord
                                      final minutes = await showNotificationDelayPicker(
                                        context,
                                        accentColor: resolvedIcon,
                                      );
                                      if (minutes != null) {
                                        programProvider.toggleAgendaItem(
                                          widget.item,
                                          delayMinutes: minutes,
                                        );
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: resolvedIcon.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isInAgenda
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 14,
                                      color: isInAgenda
                                          ? widget.theme.mainBtnPrimaryColor
                                          : resolvedIcon,
                                    ),
                                  ),
                                ),
                              ],
                            ] else ...[
                              // Non-session : titre prend tout l'espace,
                              // le badge LIVE vient après s'il est actif
                              Expanded(
                                child: Text(
                                  widget.item.displayTitle,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: resolvedTitle,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              if (_cachedIsLive) ...[
                                const SizedBox(width: 8),
                                _buildLiveBadge(),
                              ],
                            ],
                          ],
                        ),

                        // ── ROW 2: title + logo + description ────────────
                        if (widget.item.isSession) ...[
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.item.displayTitle,
                                  style: TextStyle(
                                    color: resolvedTitle,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              if (widget.item.session?.logoUrl != null) ...[
                                const SizedBox(width: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.item.session!.logoUrl!,
                                    height: 36,
                                    width: 64,
                                    fit: BoxFit.contain,
                                    errorWidget: (ctx, url, err) =>
                                        const SizedBox.shrink(),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],

                        if (description != null && description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: resolvedDesc,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],

                        // ── ROW 3: room on the right ─────────────────────
                        if (room != null && room.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 12,
                                color: resolvedTime,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                room,
                                style: TextStyle(
                                  color: resolvedTime,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],

                        // ── ROW 4: speakers / moderators ─────────────────
                        if (hasSpeakers) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.item.session!.speakers.isNotEmpty)
                                Expanded(
                                  child: _buildPeopleGroup(
                                    label: settings.speakerText,
                                    persons: widget.item.session!.speakers,
                                    color: resolvedIcon,
                                    bg: resolvedBg,
                                  ),
                                ),
                              if (widget.item.session!.moderators.isNotEmpty)
                                Expanded(
                                  child: _buildPeopleGroup(
                                    label: settings.moderatorText,
                                    persons: widget.item.session!.moderators,
                                    color: resolvedIcon,
                                    bg: resolvedBg,
                                    alignEnd: widget
                                        .item
                                        .session!
                                        .speakers
                                        .isNotEmpty,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── YOUTUBE ───────────────────────────────────────────────────────────────

  void _openYoutube(BuildContext context, String url, String mode, Color accentColor, String label) {
    if (mode == 'popup') {
      WebViewSheet.show(context, url: url, title: label, accentColor: accentColor);
    } else if (mode == 'inpage') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => YoutubeInPageView(
            url: url,
            title: label,
            accentColor: accentColor,
          ),
        ),
      );
    } else {
      _launchYoutube(url);
    }
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

  // ── BADGES ────────────────────────────────────────────────────────────────

  Widget _buildLiveBadge() {
    return FadeTransition(
      opacity: _liveAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: widget.theme.cardIconeColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'LIVE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSessionBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ── PEOPLE ────────────────────────────────────────────────────────────────

  Widget _buildPeopleGroup({
    required String label,
    required List<ProgramPerson> persons,
    required Color color,
    required Color bg,
    bool alignEnd = false,
  }) {
    if (persons.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: color.withValues(alpha: 0.8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        _buildAvatarStack(persons, color, bg),
      ],
    );
  }

  Widget _buildAvatarStack(List<ProgramPerson> persons, Color color, Color bg) {
    final int count = persons.length > 3 ? 3 : persons.length;
    final double stackWidth = 20 + (count - 1) * 12.0;
    return SizedBox(
      height: 22,
      width: stackWidth,
      child: Stack(
        children: List.generate(count, (i) {
          return Positioned(
            left: i * 12.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: bg, width: 1.5),
              ),
              child: CircleAvatar(
                radius: 10,
                backgroundColor: color.withValues(alpha: 0.2),
                backgroundImage: persons[i].photo != null
                    ? NetworkImage(persons[i].photo!)
                    : null,
                child: persons[i].photo == null
                    ? Text(
                        persons[i].firstName.isNotEmpty
                            ? persons[i].firstName[0]
                            : '?',
                        style: TextStyle(fontSize: 8, color: color),
                      )
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── TIMELINE ──────────────────────────────────────────────────────────────

  Widget _buildTimeline(Color resolvedIcon) {
    return SizedBox(
      width: rS(context, 50),
      child: Column(
        children: [
          Text(
            widget.item.startTime,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: widget.theme.mainTextPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: resolvedIcon,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(width: 1.5, color: resolvedIcon.withValues(alpha: 0.2)),
          ),
          if (!widget.isLast)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: resolvedIcon.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            widget.item.endTime,
            style: TextStyle(
              fontSize: 11,
              color: widget.theme.mainTextSecondaryColor,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
