import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_bar_widget.dart';

class EventInfoView extends StatelessWidget {
  const EventInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final t = tp.theme;
    final s = tp.settings;

    // Ville + Pays groupés
    final String cityCountry = [
      if (tp.city.isNotEmpty) tp.city,
      if (tp.country.isNotEmpty) tp.country,
    ].join(', ');

    final List<Map<String, dynamic>> fields = [
      // Adresse complète
      if (tp.address.isNotEmpty)
        {
          'label': s.addressText,
          'value': tp.address,
          'icon': s.addressIcon,
          'urlAction': tp.googleMapsUrl.isNotEmpty
              ? tp.googleMapsUrl
              : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(tp.address)}',
          'actionIcon': Icons.map_outlined,
          'hasAction': true,
        },
      // Ville, Pays
      if (cityCountry.isNotEmpty)
        {
          'label': s.cityText,
          'value': cityCountry,
          'icon': s.cityIcon,
          'urlAction': '',
          'actionIcon': null,
          'hasAction': false,
        },
      // Email
      if (tp.email.isNotEmpty)
        {
          'label': s.contactText,
          'value': tp.email,
          'icon': s.contactIcon, 
          'urlAction': 'mailto:${tp.email}',
          'actionIcon': Icons.mail_outline,
          'hasAction': true,
        },
      // Téléphone
      if (tp.phone.isNotEmpty)
        {
          'label': s.phoneText,
          'value': tp.phone,
          'icon': s.phoneIcon, // String
          'urlAction': 'tel:${tp.phone.replaceAll(' ', '')}',
          'actionIcon': Icons.phone_outlined,
          'hasAction': true,
        },
    ];

    return Scaffold(
      backgroundColor: t.eventBgColor,
      appBar: AppBarWidget(title: s.infoText),
      body: fields.isEmpty
          ? Center(
              child: Text(
                'Aucune information disponible',
                style: TextStyle(color: t.mainTextSecondaryColor, fontSize: 15),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: t.cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: t.cardBorderSize > 0
                      ? Border.all(
                          color: t.cardBorderColor,
                          width: t.cardBorderSize.toDouble(),
                        )
                      : null,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: List.generate(fields.length, (index) {
                    final isLast = index == fields.length - 1;
                    return _buildRow(fields[index], t, isLast);
                  }),
                ),
              ),
            ),
    );
  }

  Widget _buildRow(Map<String, dynamic> field, t, bool isLast) {
    final bool hasAction = field['hasAction'] as bool;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icône gauche — style identique cliquable ou non
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: t.mainBtnPrimaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: AppIcon(
              iconKey: field['icon'] as String,
              size: 18,
              color: t.mainBtnPrimaryColor,
            ),
          ),
          const SizedBox(width: 12),

          // Label + Valeur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field['label'],
                  style: TextStyle(
                    color: t.mainTextSecondaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  field['value'],
                  style: TextStyle(
                    color: t.mainTextPrimaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Column(
      children: [
        hasAction
            ? InkWell(
                onTap: () => _launchURL(field['urlAction']),
                borderRadius: isLast
                    ? const BorderRadius.vertical(bottom: Radius.circular(16))
                    : BorderRadius.zero,
                child: content,
              )
            : content,
        if (!isLast)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: t.cardBorderColor.withValues(alpha: 0.5),
          ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
