import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/abstract_model.dart';
import '../../models/app_theme_model.dart';
import '../../providers/theme_provider.dart';
import 'abstract_detail_view.dart';

class AbstractCard extends StatelessWidget {
  final AbstractModel abstract;
  final bool isGrid;

  const AbstractCard({super.key, required this.abstract, this.isGrid = false});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().theme;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AbstractDetailView(
            abstract: abstract,
            heroTag: 'abstract-${abstract.id}',
          ),
        ),
      ),

      // ── GRID ──
      child: isGrid
          ? Container(
              decoration: BoxDecoration(
                color: t.cardBgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: t.cardShadow,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'abstract-${abstract.id}',
                    child: _avatar(t, 60),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    abstract.fullName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: t.cardTitleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (abstract.title != null && abstract.title!.isNotEmpty)
                    Text(
                      abstract.title!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: t.mainTextSecondaryColor,
                      ),
                    ),
                  // ✅ Poster indicator
                  if (abstract.posterUrl != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: t.mainBtnPrimaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            size: 10,
                            color: t.mainBtnPrimaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Poster',
                            style: TextStyle(
                              fontSize: 9,
                              color: t.mainBtnPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            )
          // ── LIST ──
          : Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.cardBgColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: t.cardShadow,
              ),
              child: Row(
                children: [
                  Hero(
                    tag: 'abstract-${abstract.id}',
                    child: _avatar(t, 50),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          abstract.fullName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: t.cardTitleColor,
                          ),
                        ),
                        if (abstract.title != null &&
                            abstract.title!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            abstract.title!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: t.mainTextSecondaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // ✅ PDF badge
                  if (abstract.posterUrl != null)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: t.mainBtnPrimaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.picture_as_pdf,
                        size: 16,
                        color: t.mainBtnPrimaryColor,
                      ),
                    ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
    );
  }

  Widget _avatar(AppThemeModel t, double size) {
    final hasImage = abstract.photo != null && abstract.photo!.isNotEmpty;
    return ClipRRect(
      borderRadius: t.speakerPhotoBorderRadius,
      child: SizedBox(
        width: size,
        height: size,
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: abstract.photo!,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (context, url) => Container(
                  color: t.cardIconeColor.withValues(alpha: 0.2),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: t.cardIconeColor,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    _placeholderAvatar(t, size),
              )
            : _placeholderAvatar(t, size),
      ),
    );
  }

  Widget _placeholderAvatar(AppThemeModel t, double size) {
    return Container(
      color: t.cardIconeColor.withValues(alpha: 0.2),
      child: Center(
        child: Text(
          abstract.initials,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: size * 0.35,
            color: t.cardIconeColor,
          ),
        ),
      ),
    );
  }
}
