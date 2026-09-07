import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/faq_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/faq_model.dart';
import '../../models/app_theme_model.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/app_icon.dart';

class FaqView extends StatefulWidget {
  const FaqView({super.key});

  @override
  State<FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  final Set<int> _expandedFaqs = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FaqProvider>().loadFaqs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  bool _faqMatches(FaqItem faq) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    return faq.question.toLowerCase().contains(q) ||
        faq.answer.toLowerCase().contains(q);
  }

  List<FaqCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return context.read<FaqProvider>().categories;
    return context
        .read<FaqProvider>()
        .categories
        .map((cat) {
          final matched = cat.faqs.where(_faqMatches).toList();
          if (matched.isEmpty) return null;
          return FaqCategory(
            id: cat.id,
            name: cat.name,
            icon: cat.icon,
            faqs: matched,
          );
        })
        .whereType<FaqCategory>()
        .toList();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim();
      // Auto-expand all matching items while searching
      if (_searchQuery.isNotEmpty) {
        for (final cat in context.read<FaqProvider>().categories) {
          for (final faq in cat.faqs) {
            if (_faqMatches(faq)) _expandedFaqs.add(faq.id);
          }
        }
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final t = tp.theme;
    final s = tp.settings;
    final provider = context.watch<FaqProvider>();

    return Scaffold(
      backgroundColor: t.eventBgColor,
      appBar: AppBarWidget(title: s.faqText),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator(color: t.headerBg))
          : provider.errorMessage != null
          ? _buildError(t, provider)
          : provider.categories.isEmpty
          ? _buildEmpty(t, noData: true)
          : Column(
              children: [
                _buildSearchBar(t, s),
                Expanded(child: _buildContent(t, s)),
              ],
            ),
    );
  }

  Widget _buildSearchBar(AppThemeModel t, s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: t.searchBarBg,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: TextStyle(color: t.searchBarTextColor),
          decoration: InputDecoration(
            hintText: s.searchText,
            hintStyle: TextStyle(
              color: t.searchBarTextColor.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(10),
              child: AppIcon(
                iconKey: s.searchIcon,
                size: 20,
                color: t.headerBg,
              ),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: t.mainTextSecondaryColor,
                    ),
                    onPressed: _clearSearch,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AppThemeModel t, s) {
    final categories = _filteredCategories;

    if (categories.isEmpty) {
      return _buildEmpty(t, noData: false);
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
        child: RefreshIndicator(
          color: t.headerBg,
          onRefresh: () => context.read<FaqProvider>().loadFaqs(forceRefresh: true),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
            itemCount: categories.length,
            itemBuilder: (context, index) =>
                _buildCategory(categories[index], t, s.faqIcon),
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(FaqCategory category, AppThemeModel t, String faqIcon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          child: Row(
            children: [
              AppIcon(
                iconKey: category.icon ?? faqIcon,
                size: 18,
                color: t.mainBtnPrimaryColor,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: t.mainTextPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Divider(
                  color: t.mainTextSecondaryColor.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ),
        ...category.faqs.map((faq) => _buildFaqItem(faq, t)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFaqItem(FaqItem faq, AppThemeModel t) {
    final isExpanded = _expandedFaqs.contains(faq.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: t.cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: t.cardBorderSize > 0
            ? Border.all(
                color: t.cardBorderColor,
                width: t.cardBorderSize.toDouble(),
              )
            : Border.all(
                color: t.mainTextSecondaryColor.withValues(alpha: 0.08),
              ),
        boxShadow: t.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() {
            if (isExpanded) {
              _expandedFaqs.remove(faq.id);
            } else {
              _expandedFaqs.add(faq.id);
            }
          }),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _searchQuery.isNotEmpty
                          ? _buildHighlightedText(
                              faq.question,
                              _searchQuery,
                              TextStyle(
                                color: t.cardTitleColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              t.mainBtnPrimaryColor,
                            )
                          : Text(
                              faq.question,
                              style: TextStyle(
                                color: t.cardTitleColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: t.mainBtnPrimaryColor,
                      ),
                    ),
                  ],
                ),
                // Answer
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: isExpanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(
                                color: t.mainTextSecondaryColor.withValues(
                                  alpha: 0.12,
                                ),
                                height: 1,
                              ),
                              const SizedBox(height: 10),
                              _searchQuery.isNotEmpty
                                  ? _buildHighlightedText(
                                      faq.answer,
                                      _searchQuery,
                                      TextStyle(
                                        color: t.cardDescriptionColor,
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                      t.mainBtnPrimaryColor,
                                    )
                                  : Text(
                                      faq.answer,
                                      style: TextStyle(
                                        color: t.cardDescriptionColor,
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                    ),
                            ],
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Highlights [query] occurrences inside [text] with [highlightColor].
  Widget _buildHighlightedText(
    String text,
    String query,
    TextStyle baseStyle,
    Color highlightColor,
  ) {
    final lower = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lower.indexOf(lowerQuery, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      spans.add(
        TextSpan(
          text: text.substring(idx, idx + query.length),
          style: baseStyle.copyWith(
            color: highlightColor,
            fontWeight: FontWeight.bold,
            backgroundColor: highlightColor.withValues(alpha: 0.12),
          ),
        ),
      );
      start = idx + query.length;
    }

    return RichText(
      text: TextSpan(style: baseStyle, children: spans),
    );
  }

  Widget _buildEmpty(AppThemeModel t, {required bool noData}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            noData ? Icons.help_outline_rounded : Icons.search_off_rounded,
            size: 64,
            color: t.mainTextSecondaryColor.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            noData ? 'Aucune FAQ disponible' : 'Aucun résultat pour "$_searchQuery"',
            style: TextStyle(color: t.mainTextSecondaryColor, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          if (!noData) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _clearSearch,
              child: Text(
                'Effacer la recherche',
                style: TextStyle(color: t.mainBtnPrimaryColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildError(AppThemeModel t, FaqProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: t.mainTextSecondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            provider.errorMessage!,
            style: TextStyle(color: t.mainTextSecondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.loadFaqs(forceRefresh: true),
            style: ElevatedButton.styleFrom(backgroundColor: t.headerBg),
            child: Text(
              'Réessayer',
              style: TextStyle(color: t.headerColorTitle),
            ),
          ),
        ],
      ),
    );
  }
}
