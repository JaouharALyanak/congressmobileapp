// lib/views/committee/committee_detail_view.dart
import 'package:event_app/models/app_theme_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../utils/html_utils.dart';
import 'package:provider/provider.dart';
import '../../models/committee_member_model.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_bar_widget.dart';

class CommitteeDetailView extends StatelessWidget {
  final CommitteeMember member;

  const CommitteeDetailView({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().theme;

    return Scaffold(
      backgroundColor: t.eventBgColor,
      appBar: AppBarWidget(title: member.titreLabel ?? ''),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 48),
        child: Column(
          children: [
            // ── Header violet comme "Mot de président" ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: t.headerBg,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Photo
                  _buildAvatar(member, t, 56),
                  const SizedBox(height: 16),

                  // Nom
                  Text(
                    member.fullName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: t.headerColorTitle,
                    ),
                  ),

                  // Titre badge
                  if (member.titreLabel != null &&
                      member.titreLabel!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        member.titreLabel!,
                        style: TextStyle(
                          fontSize: 13,
                          color: t.headerColorTitle,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Description HTML ──
            if (!isHtmlEmpty(member.description)) ...[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Html(
                  data: member.description!,
                  style: {
                    'p': Style(
                      fontSize: FontSize(15),
                      lineHeight: const LineHeight(1.7),
                      color: t.mainTextPrimaryColor,
                      margin: Margins.only(bottom: 12),
                    ),
                    'a': Style(
                      color: t.mainBtnPrimaryColor,
                      textDecoration: TextDecoration.none,
                    ),
                  },
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                child: Center(
                  child: Text(
                    'Aucune information fournie',
                    style: TextStyle(
                      color: t.mainTextSecondaryColor,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(CommitteeMember member, AppThemeModel t, double radius) {
    if (member.photo != null && member.photo!.isNotEmpty) {
      return ClipRRect(
        borderRadius: t.speakerPhotoBorderRadius,
        child: SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: CachedNetworkImage(
            imageUrl: member.photo!,
            fit: BoxFit.cover,
            errorWidget: (_, _, _) => _placeholder(member.initial, t, radius),
          ),
        ),
      );
    }
    return _placeholder(member.initial, t, radius);
  }

  Widget _placeholder(String initial, AppThemeModel t, double radius) {
    return ClipRRect(
      borderRadius: t.speakerPhotoBorderRadius,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        color: Colors.white.withValues(alpha: 0.3),
        child: Center(
          child: Text(
            initial,
            style: TextStyle(
              color: t.headerColorTitle,
              fontWeight: FontWeight.bold,
              fontSize: radius * 0.7,
            ),
          ),
        ),
      ),
    );
  }
}
