import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String id;
  final String title;

  CategoryItem(this.id, this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Text(
        title,
        style: TextStyle(fontSize: 20),
      ),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.orange.withOpacity(0.8), Colors.grey],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight), borderRadius:BorderRadius.circular(15)),
    );
  }
}
