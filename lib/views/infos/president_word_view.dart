// views/infos/president_word_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_bar_widget.dart';

class PresidentWordView extends StatelessWidget {
  const PresidentWordView({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final t = tp.theme;
    final s = tp.settings;

    return Scaffold(
      backgroundColor: t.eventBgColor,
      appBar: AppBarWidget(title: s.presidentWordText),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: t.cardBgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: HtmlWidget(
            tp.presidentWord, // Le contenu TinyMCE venant du Provider
            textStyle: TextStyle(
              color: t.mainTextPrimaryColor,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
