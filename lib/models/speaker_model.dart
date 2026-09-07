class Speaker {
  // Champs de base
  final int id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String biography;
  final String? photo;
  final int cityId;
  final int countryId;
  final String email;
  final String title;
  // Listes
  final List<String> specialityList;
  // Objets imbriqués
  final int cityIdNested;
  final String cityName;
  final int countryIdNested;
  final String countryName;
  // Champ calculé
  final String category;

  Speaker({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.biography,
    this.photo,
    required this.cityId,
    required this.countryId,
    required this.email,
    required this.title,
    required this.specialityList,
    required this.cityIdNested,
    required this.cityName,
    required this.countryIdNested,
    required this.countryName,
    this.category = "INTERVENANT",
  });

  // Getter pour le nom complet
  String get fullName {
    if (middleName != null &&
        middleName!.isNotEmpty &&
        middleName != "middle") {
      return "$firstName $middleName $lastName";
    }
    return "$firstName $lastName";
  }

  // ── fromJson ─────────────────────────────────────────────────────────────
  factory Speaker.fromJson(Map<String, dynamic> json) {
    return Speaker(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'],
      lastName: json['last_name'] ?? '',
      biography: json['biography'] ?? '',
      photo: json['photo'],
      cityId: json['city_id'] ?? 0,
      countryId: json['country_id'] ?? 0,
      email: json['email'] ?? '',
      title: json['title'] ?? '',
      specialityList: List<String>.from(json['speciality_list'] ?? []),
      cityIdNested: json['city'] != null ? json['city']['id'] : 0,
      cityName: json['city'] != null ? json['city']['name'] : 'N/A',
      countryIdNested: json['country'] != null ? json['country']['id'] : 0,
      countryName: json['country'] != null ? json['country']['name'] : 'N/A',
      category: json['category'] ?? 'INTERVENANT',
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
      'city_id': cityId,
      'country_id': countryId,
      'email': email,
      'title': title,
      'speciality_list': specialityList,
      // Rebuild nested objects so fromJson can re-parse them correctly
      'city': {'id': cityIdNested, 'name': cityName},
      'country': {'id': countryIdNested, 'name': countryName},
      'category': category,
    };
  }
}
