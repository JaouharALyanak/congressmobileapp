class SponsorGroup {
  final int id;
  final String name;
  final String displayMode;
  final List<SponsorItem> items;

  SponsorGroup({
    required this.id,
    required this.name,
    this.displayMode = 'grid',
    required this.items,
  });

  factory SponsorGroup.fromJson(Map<String, dynamic> json) {
    return SponsorGroup(
      id: json['id'],
      name: json['name'] ?? '',
      displayMode: json['display_mode'] ?? 'grid',
      items:
          (json['items'] as List?)
              ?.map((i) => SponsorItem.fromJson(i))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_mode': displayMode,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class SponsorItem {
  final int id;
  final String title;
  final bool showTitle;
  final String? image;
  final String? link;
  final String? phone;
  final String? email;

  SponsorItem({
    required this.id,
    required this.title,
    this.showTitle = false,
    this.image,
    this.link,
    this.phone,
    this.email,
  });

  factory SponsorItem.fromJson(Map<String, dynamic> json) {
    return SponsorItem(
      id: json['id'],
      title: json['title'] ?? '',
      showTitle: json['show_title'] == true,
      image: json['image'],
      link: json['link'],
      phone: json['phone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'show_title': showTitle,
      'image': image,
      'link': link,
      'phone': phone,
      'email': email,
    };
  }
}
