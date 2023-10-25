import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeAgoWidget extends StatelessWidget {
  final DateTime postDate;

  TimeAgoWidget({required this.postDate});

  static formatTimeAgo(DateTime postDate) {
    final now = DateTime.now();
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
    String timeAgo = formatTimeAgo(postDate);

    return Text(timeAgo);
  }
}
