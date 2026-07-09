import 'package:flutter/material.dart';

import '../models/announcement_item.dart';
import '../services/auth_service.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  const AnnouncementDetailScreen({
    super.key,
    required this.authService,
    required this.announcement,
  });

  final AuthService authService;
  final AnnouncementItem announcement;

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Recently posted';
    }

    final local = dateTime.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = announcement.imagePath;
    final imageUrl = imagePath == null || imagePath.isEmpty
        ? null
        : authService.apiService.mediaUrl(imagePath);

    return Scaffold(
      appBar: AppBar(title: const Text('Announcement Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD9E2EC)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFF8FAFC),
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported_outlined),
                          );
                        },
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(announcement.publishedAt ?? announcement.createdAt),
                        style: const TextStyle(color: Color(0xFF627D98), fontSize: 13),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        announcement.description,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          height: 1.6,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}