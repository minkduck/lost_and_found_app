import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/pages/items/Items_grid_main.dart';
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

  @override
  void initState() {
    // TODO: implement initState
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  BigText(
                    text: "Alls",
                    size: 17,
                    color: AppColors.primaryColor,
                    fontW: FontWeight.w500,
                  ),
                  BigText(
                    text: "Mobile",
                    size: 17,
                    color: AppColors.secondPrimaryColor,
                    fontW: FontWeight.w500,
                  ),
                  BigText(
                    text: "Documents",
                    size: 17,
                    color: AppColors.secondPrimaryColor,
                    fontW: FontWeight.w500,
                  ),
                  BigText(
                    text: "Laptop",
                    size: 17,
                    color: AppColors.secondPrimaryColor,
                    fontW: FontWeight.w500,
                  ),
                ],
              ),
              Gap(AppLayout.getHeight(25)),
              ItemsGridMain()

            ],
          ),
        ),
      ),
    );
  }
}
