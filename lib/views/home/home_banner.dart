import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/app_theme_model.dart';
import '../../utils/responsive.dart';
import 'badge_detail_view.dart';

class HomeBanner extends StatefulWidget {
  final AppThemeModel theme;
  const HomeBanner({super.key, required this.theme});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.theme.bannerChoice == 'slider' &&
        widget.theme.sliderImageUrls.length > 1) {
      _timer = Timer.periodic(Duration(seconds: widget.theme.sliderDuration), (_) {
        if (!mounted) return;
        final next = (_currentPage + 1) % widget.theme.sliderImageUrls.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.theme.bannerChoice == 'slider') {
      return _buildSlider(context);
    }
    return _buildClassicBanner(context);
  }

  Widget _buildSlider(BuildContext context) {
    final urls = widget.theme.sliderImageUrls;
    if (urls.isEmpty) return const SizedBox.shrink();

    final double height = isTablet(context) ? 280 : 200;

    return Container(
      width: double.infinity,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: widget.theme.cardBgColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: urls.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) => CachedNetworkImage(
                imageUrl: urls[index],
                width: double.infinity,
                height: height,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: widget.theme.headerBg.withValues(alpha: 0.08),
                ),
                errorWidget: (_, _, _) => Container(
                  color: widget.theme.headerBg.withValues(alpha: 0.08),
                ),
              ),
            ),
            // Dots
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(urls.length, (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassicBanner(BuildContext context) {
    if (widget.theme.bannerState != 'visible') return const SizedBox.shrink();

    final double maxHeight = isTablet(context) ? 280 : 200;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: widget.theme.cardBgColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Stack(
            children: [
              if (widget.theme.bannerPictureUrl != null)
                CachedNetworkImage(
                  imageUrl: widget.theme.bannerPictureUrl!,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  placeholder: (_, _) => Container(
                    height: 160,
                    color: widget.theme.headerBg.withValues(alpha: 0.08),
                  ),
                  errorWidget: (_, _, _) => Container(
                    height: 160,
                    color: widget.theme.headerBg.withValues(alpha: 0.08),
                  ),
                ),
              if (widget.theme.bannerBtnState == 'visible')
                Positioned(
                  top: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BadgeDetailView(),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: widget.theme.bannerBtnColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        widget.theme.bannerBtnText.isNotEmpty
                            ? widget.theme.bannerBtnText
                            : 'Voir',
                        style: TextStyle(
                          color: widget.theme.bannerBtnTextColor,
                          fontWeight: FontWeight.w900,
                          fontSize: rFs(context, 13),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
