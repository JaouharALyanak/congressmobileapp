import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/sponsor_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/responsive.dart';

class HomeSponsors extends StatefulWidget {
  final Function(int) onNavigateToSponsorsTab;
  const HomeSponsors({super.key, required this.onNavigateToSponsorsTab});

  @override
  State<HomeSponsors> createState() => _HomeSponsorsState();
}

class _HomeSponsorsState extends State<HomeSponsors> {
  final ScrollController _scrollController = ScrollController();
  bool _autoSlideStarted = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<SponsorProvider>().loadSponsors();
    });
  }

  void _startAutoScroll(int itemCount) {
    if (_autoSlideStarted || itemCount == 0) return;
    _autoSlideStarted = true;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || !_scrollController.hasClients) return false;

      final max = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;
      final cardWidth = _scrollController.position.viewportDimension > 600 ? 140.0 : 110.0;

      if (current >= max) {
        // Retour au début
        await _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      } else {
        await _scrollController.animateTo(
          current + cardWidth,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
      return mounted;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SponsorProvider>();
    final t = context.watch<ThemeProvider>().theme;

    final allSponsors = provider.groups.expand((g) => g.items).toList();

    if (provider.isLoading && allSponsors.isEmpty) return const SizedBox.shrink();
    if (allSponsors.isEmpty) return const SizedBox.shrink();

    _startAutoScroll(allSponsors.length);

    final double cardSize = isTablet(context) ? 130 : 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sponsors',
                style: TextStyle(
                  color: t.mainTextPrimaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => widget.onNavigateToSponsorsTab(3),
                child: Text(
                  'Voir plus',
                  style: TextStyle(color: t.mainBtnPrimaryColor),
                ),
              ),
            ],
          ),
        ),

        // Slider horizontal auto-scroll
        SizedBox(
          height: cardSize,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: allSponsors.length,
            itemBuilder: (context, index) {
              final sponsor = allSponsors[index];
              return Container(
                width: cardSize,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: t.cardBgColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: t.cardShadow,
                ),
                padding: const EdgeInsets.all(10),
                child: sponsor.image != null && sponsor.image!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: sponsor.image!,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            sponsor.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          sponsor.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}