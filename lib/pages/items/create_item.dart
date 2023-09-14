import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/app_text_filed_title.dart';
import '../../widgets/big_text.dart';

class CreateItem extends StatefulWidget {
  const CreateItem({super.key});

  @override
  State<CreateItem> createState() => _CreateItemState();
}

class _CreateItemState extends State<CreateItem> {
  var categoryController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var phoneController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(AppLayout.getHeight(20)),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
                BigText(
                  text: "Items",
                  size: 20,
                  color: AppColors.secondPrimaryColor,
                  fontW: FontWeight.w500,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: 30, top: 10),
              child: Text('Create ad', style: Theme.of(context).textTheme.displayMedium,),
            ),
            Gap(AppLayout.getHeight(20)),
            AppTextFieldTitle(
                textController: categoryController,
                hintText: "",
                titleText: "Category"),

          ],
        ),
      ),
    );
  }
}
