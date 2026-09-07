import '../config/app_config.dart';

class AbstractModel {
  final int id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? biography;
  final String? photo;
  final String? thumb;
  final String? poster;
  final int cityId;
  final int countryId;
  final String? email;
  final String? title;
  final String cityName;
  final String countryName;
  final List<String> specialityList;

  AbstractModel({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.biography,
    this.photo,
    this.thumb,
    this.poster,
    required this.cityId,
    required this.countryId,
    this.email,
    this.title,
    required this.cityName,
    required this.countryName,
    required this.specialityList,
  });

  String get fullName {
    if (middleName != null &&
        middleName!.isNotEmpty &&
        middleName != "middle") {
      return "$firstName $middleName $lastName";
    }
    return "$firstName $lastName";
  }

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return (first + last).toUpperCase();
  }

  String? get posterUrl {
    if (poster == null || poster!.isEmpty) return null;
    if (poster!.startsWith('http')) return poster;
    return '${AppConfig.baseUrl.replaceFirst('/api/v1', '')}/public/storage/$poster';
  }

  String? get thumbUrl {
    if (thumb == null || thumb!.isEmpty) return null;
    if (thumb!.startsWith('http')) return thumb;
    return '${AppConfig.baseUrl.replaceFirst('/api/v1', '')}/public/storage/$thumb';
  }

  factory AbstractModel.fromJson(Map<String, dynamic> json) {
    return AbstractModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'],
      lastName: json['last_name'] ?? '',
      biography: json['biography'],
      photo: json['photo'],
      thumb: json['thumb'],
      poster: json['poster'],
      cityId: json['city_id'] ?? 0,
      countryId: json['country_id'] ?? 0,
      email: json['email'],
      title: json['title'],
      cityName: json['city'] != null ? json['city']['name'] : 'N/A',
      countryName: json['country'] != null ? json['country']['name'] : 'N/A',
      specialityList: List<String>.from(json['speciality_list'] ?? []),
    );
  }

  // ── toJson ────────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'biography': biography,
      'photo': photo,
      'thumb': thumb,
      'poster': poster,
      'city_id': cityId,
      'country_id': countryId,
      'email': email,
      'title': title,
      // Rebuild nested objects so fromJson re-parses correctly
      'city': {'name': cityName},
      'country': {'name': countryName},
      'speciality_list': specialityList,
    };
  }
}
