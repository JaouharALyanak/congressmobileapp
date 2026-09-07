import 'package:event_app/models/app_theme_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sponsor_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/responsive.dart';
import 'sponsor_card.dart';

class SponsorsView extends StatefulWidget {
  const SponsorsView({super.key});

  @override
  State<SponsorsView> createState() => _SponsorsViewState();
}

class _SponsorsViewState extends State<SponsorsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<SponsorProvider>().loadSponsors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SponsorProvider>();
    final tp = context.watch<ThemeProvider>();
    final t = tp.theme;

    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator(color: t.headerBg));
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            Text(provider.errorMessage!),
            TextButton(
              onPressed: () => provider.loadSponsors(),
              child: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    if (provider.groups.isEmpty) {
      return const Center(child: Text("Aucun sponsor disponible"));
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
        child: ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      itemCount: provider.groups.length,
      itemBuilder: (context, index) {
        final group = provider.groups[index];
        final isList = group.displayMode == 'list';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupTitle(group.name, t),
            const SizedBox(height: 12),
            if (isList)
              Column(
                children: group.items
                    .map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SponsorCard(sponsor: s, displayMode: 'list'),
                        ))
                    .toList(),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.3,
                ),
                itemCount: group.items.length,
                itemBuilder: (context, i) =>
                    SponsorCard(sponsor: group.items[i], displayMode: 'grid'),
              ),
            const SizedBox(height: 25),
          ],
        );
      },
        ),
      ),
    );
  }

  Widget _buildGroupTitle(String name, AppThemeModel t) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: t.mainBtnPrimaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          name.toUpperCase(),
          style: TextStyle(
            color: t.mainTextPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
