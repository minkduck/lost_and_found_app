import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lost_and_find_app/data/api/report/report_controller.dart';

import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/big_text.dart';


class MyReport extends StatefulWidget {
  const MyReport({super.key});

  @override
  State<MyReport> createState() => _MyReportState();
}

class _MyReportState extends State<MyReport> {
  bool _isMounted = false;

  List<dynamic> reportList = [];
  final ReportController reportController = Get.put(ReportController());

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    Future.delayed(Duration(seconds: 1), () async {
      reportController.getReportById().then((result) {
        if (_isMounted) {
          setState(() {
            reportList = result;

          });
        }
      }).whenComplete(() {
        if (_isMounted) {
          setState(() {
            if (reportList.isEmpty) {
              _isMounted = false;
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Gap(AppLayout.getHeight(50)),
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
                    text: "List Report",
                    size: 20,
                    color: AppColors.secondPrimaryColor,
                    fontW: FontWeight.w500,
                  ),

                ],
              ),
              if (reportList.isNotEmpty)
              ListView.builder(
                  shrinkWrap: true,
                  reverse: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: reportList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final report = reportList[index];
                    final item = report['item'];
                    final reportMedias = report['reportMedias'];

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).cardColor,
                      ),
                      margin: EdgeInsets.only(
                          bottom: AppLayout.getHeight(20)),
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              report['title'],
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium,
                            ),
                          ),
                          Gap(AppLayout.getHeight(20)),
                          Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              report['content'],
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                          ),
                          Gap(AppLayout.getHeight(20)),
                          Row(
                            children: [
                              Text(
                                'Create Date: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall,
                              ),
                              Gap(AppLayout.getWidth(5)),
                              Text(
                                report['createdDate'] != null
                                    ? DateFormat('dd-MM-yyyy- HH:mm:ss').format(DateTime.parse(report['createdDate']))
                                    : 'No Date',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                          Gap(AppLayout.getHeight(20)),
                          Row(
                            children: [
                              Text(
                                'Status: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall,
                              ),
                              Gap(AppLayout.getWidth(5)),
                              Text(
                                report['status'],
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall,
                              ),
                            ],
                          ),
                          Gap(AppLayout.getHeight(20)),
                          Row(
                            children: [
                              Text(
                                'Item: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall,
                              ),
                              Gap(AppLayout.getWidth(5)),
                              Text(
                                item['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall,
                              ),
                            ],
                          ),
                          Container(
                            height:
                            MediaQuery.of(context).size.height *
                                0.2,
                            // Set a fixed height or use any other value
                            child: ListView.builder(
                              padding: EdgeInsets.zero, // Add this line to set zero padding
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: item['itemMedias']
                                  .length,
                              itemBuilder: (context, indexs) {
                                return Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(
                                      left: AppLayout.getWidth(20)),
                                  height: AppLayout.getHeight(151),
                                  width: AppLayout.getWidth(180),
                                  child: Image.network(
                                      item['itemMedias']
                                      [indexs]['media']['url'] ?? 'https://www.freeiconspng.com/thumbs/no-image-icon/no-image-icon-6.png',
                                      fit: BoxFit.fill),
                                );
                              },
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Images: ',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Gap(AppLayout.getWidth(10)),
                              Expanded(
                                child: Container(
                                  height: 200,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: report['reportMedias'].length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: EdgeInsets.only(right: AppLayout.getWidth(10)),
                                        width: 225,
                                        child: Image.network(
                                          reportMedias[index]['media']['url'],
                                          fit: BoxFit.fill,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  })
              else if (reportList.isEmpty && !_isMounted)
                SizedBox(
                  width: AppLayout.getScreenWidth(),
                  height: AppLayout.getScreenHeight()-200,
                  child: const Center(
                    child: Text("You don't have any report"),
                  ),
                )
              else
                SizedBox(
                  width: AppLayout.getWidth(100),
                  height: AppLayout.getHeight(300),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
