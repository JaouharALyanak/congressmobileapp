class Vod {
  final int id;
  final String title;
  final String? description;
  final String? youtubeLink;
  final String? thumbnailUrl;
  final String? category;

  Vod({
    required this.id,
    required this.title,
    this.description,
    this.youtubeLink,
    this.thumbnailUrl,
    this.category,
  });

  factory Vod.fromJson(Map<String, dynamic> j) {
    return Vod(
      id: j['id'],
      title: j['title'] ?? '',
      description: j['description'],
      youtubeLink: j['video_url'],       // API field: video_url
      thumbnailUrl: j['thumbnail'],       // API field: thumbnail
      category: j['category'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'video_url': youtubeLink,
    'thumbnail': thumbnailUrl,
    'category': category,
  };
}
