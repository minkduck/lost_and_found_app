import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/pages/post/post_detail.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/widgets/icon_and_text_widget.dart';

import '../../utils/colors.dart';
import '../../widgets/big_text.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Wrap with SingleChildScrollView
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
                      text: "Post",
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
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text('Post', style: Theme.of(context).textTheme.displayMedium,),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                      onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PostDetail(), // Navigate to PostDetail
                      ),
                    );
                  },
                  child: Container(
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).cardColor,
                  ),
                  margin: EdgeInsets.only(bottom: AppLayout.getHeight(20)),
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: AssetImage(AppAssets.avatarDefault!),
                            ),
                            Gap(AppLayout.getHeight(15)),
                            Column(
                              children: [
                                Text("John", style: Theme.of(context).textTheme.titleSmall,),
                                Gap(AppLayout.getHeight(5)),
                                Text("16h ago", style: TextStyle(fontSize: 12, color: Colors.grey),)
                              ],
                            )
                          ],
                        ),
                        Gap(AppLayout.getHeight(30)),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text("Airpods lost at the library", style: Theme.of(context).textTheme.titleMedium,),
                        ),
                        Gap(AppLayout.getHeight(15)),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(left: AppLayout.getWidth(20)),
                          height: AppLayout.getHeight(151),
                          width: AppLayout.getWidth(180),
                          child: Image.asset(AppAssets.airpods, fit: BoxFit.fill),
                        ),
                        Gap(AppLayout.getHeight(10)),
                        Container(
                          child: Text(
                            'Lorem ipsum dolor sit amet consectetur. Mattis nunc eu mauris vulputate vulputate massa ipsum est. Leo adipiscing massa vitae consequat. Sagittis nunc egestas senectus mi erat eget. Purus sapien nam maecenas.',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        Gap(AppLayout.getHeight(50)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconAndTextWidget(icon: Icons.bookmark, text: "100", iconColor: Colors.grey),
                            IconAndTextWidget(icon: Icons.comment, text: "100", iconColor: Colors.grey),
                            IconAndTextWidget(icon: Icons.flag, text: "100", iconColor: Colors.grey),
                          ],
                        )
                      ],
                    ),
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

