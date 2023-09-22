import 'package:flutter/material.dart';
import 'package:lost_and_find_app/pages/account/profile_page.dart';
import 'package:lost_and_find_app/pages/home/home_screen.dart';
import 'package:lost_and_find_app/pages/message/message_page.dart';
import 'package:lost_and_find_app/pages/post/post_screen.dart';

import '../../test/another_home_screen.dart';
import '../../utils/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectIndex = 0;
  List pages =[
    HomeScreen(),
    PostScreen(),
    MessagePage(),
    AccountPage(),
  ];


  void onTapNav(int index){
    setState(() {
      _selectIndex = index;
    });
  }

  void initState() {
    // TODO: implement initState
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.secondPrimaryColor,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectIndex,
        onTap: onTapNav,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined,),
              label: "Home"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_post_office,),
              label: "Post"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.message_outlined,),
              label: "Message"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person,),
              label: "Me"
          ),
        ],
      ),
    );
  }
}
