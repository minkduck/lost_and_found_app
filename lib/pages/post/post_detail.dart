import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utils/app_assets.dart';
import '../../utils/app_layout.dart';
import '../../widgets/icon_and_text_widget.dart';

class PostDetail extends StatefulWidget {
  const PostDetail({super.key});

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Gap(AppLayout.getHeight(50)),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).cardColor,
                ),
                // color: Colors.red,
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
                            Text(
                              "John",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Gap(AppLayout.getHeight(5)),
                            Text(
                              "16h ago",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            )
                          ],
                        )
                      ],
                    ),
                    Gap(AppLayout.getHeight(30)),
                    Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Airpods lost at the library",
                          style: Theme.of(context).textTheme.titleMedium,
                        )),
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
                        IconAndTextWidget(
                            icon: Icons.bookmark,
                            text: "100",
                            iconColor: Colors.grey),
                        IconAndTextWidget(
                            icon: Icons.comment,
                            text: "100",
                            iconColor: Colors.grey),
                        IconAndTextWidget(
                            icon: Icons.flag, text: "100", iconColor: Colors.grey),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).cardColor,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: AppLayout.getHeight(10), left: AppLayout.getWidth(10)),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Comment",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: 5,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: AppLayout.getHeight(20),left: AppLayout.getWidth(15)),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage(AppAssets.avatarDefault!),
                              ),
                              Gap(AppLayout.getWidth(10)),
                              Column(
                                children: [
                                  Text(
                                    "John",
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(
                                    "Lorem ipsum dolor sit amet",
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
