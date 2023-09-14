import 'package:flutter/material.dart';
import 'package:lost_and_find_app/pages/items/Items_grid_main.dart';
import 'package:lost_and_find_app/test/cagory.dart';
import 'package:lost_and_find_app/test/items_category.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFF131A2C),
      appBar: AppBar(
        title: Text("GridView"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ItemsGridMain(),
          ],
        ),
      ),
    );
  }
}
