class FaqItem {
  final int id;
  final int faqCategoryId;
  final String question;
  final String answer;
  final int sort;

  FaqItem({
    required this.id,
    required this.faqCategoryId,
    required this.question,
    required this.answer,
    required this.sort,
  });

  factory FaqItem.fromJson(Map<String, dynamic> j) {
    return FaqItem(
      id: j['id'],
      faqCategoryId: j['faq_category_id'] ?? 0,
      question: j['question'] ?? '',
      answer: j['answer'] ?? '',
      sort: j['sort'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'faq_category_id': faqCategoryId,
    'question': question,
    'answer': answer,
    'sort': sort,
  };
}

class FaqCategory {
  final int id;
  final String name;
  final String? icon;
  final List<FaqItem> faqs;

  FaqCategory({
    required this.id,
    required this.name,
    this.icon,
    required this.faqs,
  });

  factory FaqCategory.fromJson(Map<String, dynamic> j) {
    return FaqCategory(
      id: j['id'],
      name: j['name'] ?? '',
      icon: j['icon'],
      faqs: (j['faqs'] as List? ?? [])
          .map((f) => FaqItem.fromJson(f))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'faqs': faqs.map((f) => f.toJson()).toList(),
  };
}
