import 'package:flutter/material.dart';

class TimeFoundAgoWidget extends StatelessWidget {
  final String foundDate;

  TimeFoundAgoWidget({required this.foundDate});

  static String formatTimeAgo(String foundDate) {
    final now = DateTime.now();

    // Extract the date part and remove leading/trailing whitespaces
    final datePart = foundDate.split('|')[0].trim();

    // Parse the date
    final postDate = DateTime.tryParse(datePart);

    if (postDate == null) {
      // Handle invalid date format
      return 'Invalid date format';
    }

    final difference = now.difference(postDate);

    if (difference.inDays >= 7) {
      final weeks = (difference.inDays / 7).floor();
      if (weeks >= 4) {
        final months = (weeks / 4).floor();
        if (months >= 12) {
          final years = (months / 12).floor();
          return '$years year${years > 1 ? 's' : ''} ago';
        }
        return '$months month${months > 1 ? 's' : ''} ago';
      }
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inHours >= 24) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes >= 60) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    String timeAgo = formatTimeAgo(foundDate);

    return Text(timeAgo);
  }
}
