import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeAgoFoundWidget extends StatelessWidget {
  final DateTime postDate;

  TimeAgoFoundWidget({required this.postDate});

  static String formatTimeAgo(DateTime postDate) {
    final now = DateTime.now();
    final difference = now.difference(postDate);

    if (difference.inDays >= 1) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays <= 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays > 7 && difference.inDays <= 14) {
        return '1 week ago';
      } else if (difference.inDays > 14 && difference.inDays <= 21) {
        return '2 weeks ago';
      } else if (difference.inDays > 21 && difference.inDays <= 28) {
        return '3 weeks ago';
      } else {
        final months = (difference.inDays / 30).floor();
        if (months <= 1) {
          return '1 month ago';
        } else if (months <= 2) {
          return '2 months ago';
        } else if (months <= 12) {
          return '$months months ago';
        } else {
          final years = (months / 12).floor();
          return '$years year${years > 1 ? 's' : ''} ago';
        }
      }
    } else {
      return 'Today';
    }
  }

  @override
  Widget build(BuildContext context) {
    String timeAgo = formatTimeAgo(postDate);

    return Text(timeAgo);
  }
}
