class CommitteeMember {
  final int id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? subtitle;
  final String? description;
  final String? photo;
  final String? titreLabel;

  CommitteeMember({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.subtitle,
    this.description,
    this.photo,
    this.titreLabel,
  });

  String get fullName {
    final parts = [
      firstName.trim(),
      if (middleName != null && middleName!.trim().isNotEmpty)
        middleName!.trim(),
      lastName.trim(),
    ];
    return parts.join(' ').trim();
  }

  String get initial {
    final name = firstName.trim();
    final cleaned = name.replaceAll(RegExp(r'^(Pr\.|Dr\.|Prof\.)\s*'), '');
    return cleaned.isNotEmpty ? cleaned[0].toUpperCase() : '?';
  }

  factory CommitteeMember.fromJson(Map<String, dynamic> j) {
    return CommitteeMember(
      id: j['id'],
      firstName: j['first_name'] ?? '',
      middleName: j['middle_name'],
      lastName: j['last_name'] ?? '',
      subtitle: j['subtitle'],
      description: j['description'],
      photo: j['photo'],
      titreLabel: j['titre_label'],
    );
  }

  // ── toJson ────────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'subtitle': subtitle,
      'description': description,
      'photo': photo,
      'titre_label': titreLabel,
    };
  }
}

class CommitteeCategory {
  final int categoryId;
  final String categoryName;
  final int categorySort;
  final List<CommitteeMember> members;

  CommitteeCategory({
    required this.categoryId,
    required this.categoryName,
    required this.categorySort,
    required this.members,
  });

  factory CommitteeCategory.fromJson(Map<String, dynamic> j) {
    return CommitteeCategory(
      categoryId: j['category_id'],
      categoryName: j['category_name'] ?? '',
      categorySort: j['category_sort'] ?? 0,
      members: (j['members'] as List)
          .map((m) => CommitteeMember.fromJson(m))
          .toList(),
    );
  }

  // ── toJson ────────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'category_sort': categorySort,
      'members': members.map((m) => m.toJson()).toList(),
    };
  }
}
