import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/pages/items/create_item.dart';
import 'package:lost_and_find_app/pages/items/items_grid.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/widgets/big_text.dart';

import '../../test/other/cagory.dart';
import '../../utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> categories = ['All', 'Mobile', 'Documents', 'Laptop', 'Paper', 'Card', 'Panel'];
  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Gap(AppLayout.getHeight(20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: BigText(
                      text: "Home",
                      size: 20,
                      color: AppColors.secondPrimaryColor,
                      fontW: FontWeight.w500,
                    ),
                  ),
                  Container(
                    child: Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 40,
                    ),
                  )
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text('Items', style: Theme.of(context).textTheme.displayMedium,),
              ),
              Gap(AppLayout.getHeight(25)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: categories
                        .map((category) => GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selectedCategories.contains(category)) {
                            selectedCategories.remove(category);
                          } else {
                            selectedCategories.add(category);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: BigText(
                          text: category,
                          color: selectedCategories.contains(category)
                              ? AppColors.primaryColor // Selected text color
                              : AppColors.secondPrimaryColor,
                          fontW: FontWeight.w500,
                        ),
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ),
              Gap(AppLayout.getHeight(25)),
              GridView(
                padding: EdgeInsets.all(15),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: AppLayout.getWidth(200),
                    childAspectRatio: 0.55,
                    crossAxisSpacing: AppLayout.getWidth(20),
                    mainAxisSpacing: AppLayout.getHeight(20)
                ),
                children: DUMMY_DATA.map((item) => ItemsGird(item.id, item.title)).toList(),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => CreateItem()));
        },
        tooltip: 'Create Items',
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),

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
