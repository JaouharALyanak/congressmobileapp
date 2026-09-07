// lib/views/committee/committee_card.dart
import 'package:event_app/models/app_theme_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/committee_member_model.dart';
import '../../providers/theme_provider.dart';
import 'committee_detail_view.dart';

class CommitteeCard extends StatelessWidget {
  final CommitteeMember member;
  final bool isGrid;

  const CommitteeCard({super.key, required this.member, this.isGrid = true});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().theme;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CommitteeDetailView(member: member)),
      ),
      child: isGrid ? _buildGrid(t) : _buildList(t),
    );
  }

  // ── Mode grille ───────────────────────────────────────────────────────────
  Widget _buildGrid(AppThemeModel t) {
    return Container(
      decoration: BoxDecoration(
        color: t.cardBgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: t.cardShadow,
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAvatar(t, size: 52),
          const SizedBox(height: 8),
          Text(
            member.fullName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: t.cardTitleColor,
            ),
          ),
          if (member.titreLabel != null && member.titreLabel!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: t.mainBtnPrimaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                member.titreLabel!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: t.mainBtnPrimaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Mode liste ────────────────────────────────────────────────────────────
  Widget _buildList(AppThemeModel t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: t.cardBorderSize > 0
            ? Border.all(color: t.cardBorderColor, width: t.cardBorderSize.toDouble())
            : null,
        boxShadow: t.cardShadow,
      ),
      child: Row(
        children: [
          _buildAvatar(t, size: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: t.cardTitleColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (member.titreLabel != null && member.titreLabel!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    member.titreLabel!,
                    style: TextStyle(
                      fontSize: 12,
                      color: t.mainBtnPrimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (member.subtitle != null && member.subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    member.subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: t.mainTextSecondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: t.mainTextSecondaryColor, size: 18),
        ],
      ),
    );
  }

  Widget _buildAvatar(AppThemeModel t, {double size = 52}) {
    if (member.photo != null && member.photo!.isNotEmpty) {
      return ClipRRect(
        borderRadius: t.speakerPhotoBorderRadius,
        child: SizedBox(
          width: size,
          height: size,
          child: CachedNetworkImage(
            imageUrl: member.photo!,
            fit: BoxFit.cover,
            placeholder: (_, _) => _placeholder(t, size: size),
            errorWidget: (_, _, _) => _placeholder(t, size: size),
          ),
        ),
      );
    }
    return _placeholder(t, size: size);
  }

  Widget _placeholder(AppThemeModel t, {double size = 52}) {
    return ClipRRect(
      borderRadius: t.speakerPhotoBorderRadius,
      child: Container(
        width: size,
        height: size,
        color: t.mainBtnPrimaryColor.withValues(alpha: 0.15),
        child: Center(
          child: Text(
            member.initial,
            style: TextStyle(
              color: t.mainBtnPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.35,
            ),
          ),
        ),
      ),
    );
  }
}
