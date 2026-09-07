import 'package:event_app/models/app_theme_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/sponsor_model.dart';
import '../../providers/theme_provider.dart';
import '../../utils/responsive.dart';

class SponsorCard extends StatelessWidget {
  final SponsorItem sponsor;
  final String displayMode; // 'list' or 'grid'

  const SponsorCard({
    super.key,
    required this.sponsor,
    this.displayMode = 'grid',
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().theme;

    return GestureDetector(
      onTap: () async {
        final url = sponsor.link;
        if (url != null && url.isNotEmpty) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: t.cardBgColor,
          borderRadius: BorderRadius.circular(14),
          border: t.cardBorderSize > 0
              ? Border.all(
                  color: t.cardBorderColor,
                  width: t.cardBorderSize.toDouble(),
                )
              : null,
          boxShadow: t.cardShadow,
        ),
        child: displayMode == 'list'
            ? _buildListLayout(context, t)
            : _buildGridLayout(t),
      ),
    );
  }

  // ── LIST : logo gauche + infos contact droite ─────────────────────────────
  Widget _buildListLayout(BuildContext context, AppThemeModel t) {
    final hasContact = (sponsor.phone != null && sponsor.phone!.isNotEmpty) ||
        (sponsor.email != null && sponsor.email!.isNotEmpty) ||
        (sponsor.link != null && sponsor.link!.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: rS(context, 100),
              height: rS(context, 80),
              child: sponsor.image != null && sponsor.image!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: sponsor.image!,
                      fit: BoxFit.contain,
                      placeholder: (_, _) => const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, _, _) => _buildFallback(t),
                    )
                  : _buildFallback(t),
            ),
          ),
          const SizedBox(width: 16),
          // Infos droite
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Titre uniquement si show_title = true
                if (sponsor.showTitle) ...[
                  Text(
                    sponsor.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: t.cardTitleColor,
                    ),
                  ),
                  if (hasContact) const SizedBox(height: 6),
                ],
                // Infos de contact
                if (sponsor.phone != null && sponsor.phone!.isNotEmpty)
                  _buildContactRow(Icons.phone, sponsor.phone!, t),
                if (sponsor.email != null && sponsor.email!.isNotEmpty)
                  _buildContactRow(Icons.email_outlined, sponsor.email!, t),
                if (sponsor.link != null && sponsor.link!.isNotEmpty)
                  _buildContactRow(Icons.language, sponsor.link!, t),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, AppThemeModel t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: t.mainBtnPrimaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: t.mainTextSecondaryColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── GRID : logo + optional title ─────────────────────────────────────────
  Widget _buildGridLayout(AppThemeModel t) {
    final image = sponsor.image != null && sponsor.image!.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: sponsor.image!,
            fit: BoxFit.contain,
            placeholder: (_, _) => const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (_, _, _) => _buildFallback(t),
          )
        : _buildFallback(t);

    if (!sponsor.showTitle) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: image,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: image),
          const SizedBox(height: 6),
          Text(
            sponsor.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: t.cardTitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback(AppThemeModel t) {
    return Center(
      child: Text(
        sponsor.title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: t.cardTitleColor,
        ),
      ),
    );
  }
}
