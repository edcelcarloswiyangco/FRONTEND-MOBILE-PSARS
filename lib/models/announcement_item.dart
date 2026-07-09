class AnnouncementItem {
  AnnouncementItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.isPublished,
    required this.publishedAt,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String description;
  final String? imagePath;
  final bool isPublished;
  final DateTime? publishedAt;
  final DateTime? createdAt;

  factory AnnouncementItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is String) {
        return DateTime.tryParse(value);
      }

      return null;
    }

    return AnnouncementItem(
      id: int.tryParse('${json['id']}') ?? 0,
      title: '${json['title'] ?? ''}',
      description: '${json['description'] ?? ''}',
      imagePath: json['image_path']?.toString(),
      isPublished: json['is_published'] == true,
      publishedAt: parseDate(json['published_at']),
      createdAt: parseDate(json['created_at']),
    );
  }
}