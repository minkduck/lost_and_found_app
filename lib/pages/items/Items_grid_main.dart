import 'package:flutter/material.dart';
import 'package:lost_and_find_app/pages/items/items_grid.dart';

import '../../test/cagory.dart';

class ItemsGridMain extends StatefulWidget {
  const ItemsGridMain({super.key});

  @override
  State<ItemsGridMain> createState() => _ItemsGridMainState();
}

class _ItemsGridMainState extends State<ItemsGridMain> {
  @override
  Widget build(BuildContext context) {
    return GridView(
      padding: EdgeInsets.all(15),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 0.55,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20
      ),
      children: DUMMY_DATA.map((item) => ItemsGird(item.id, item.title)).toList(),
    );
  }
}
const DUMMY_DATA = [
  Category(id: '1', title: "Item 1"),
  Category(id: '2', title: "Item 2"),
  Category(id: '3', title: "Item 3"),
  Category(id: '4', title: "Item 4"),
  Category(id: '5', title: "Item 5"),
  Category(id: '6', title: "Item 6"),
  Category(id: '7', title: "Item 7"),
  Category(id: '8', title: "Item 8"),
  Category(id: '9', title: "Item 9"),
  Category(id: '10', title: "Item 10"),
  Category(id: '11', title: "Item 11"),
  Category(id: '12', title: "Item 12"),
  Category(id: '13', title: "Item 13"),
  Category(id: '14', title: "Item 14"),
];

