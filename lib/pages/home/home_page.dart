import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lost_and_find_app/pages/account/account_page.dart';
import 'package:lost_and_find_app/pages/account/profile_page.dart';
import 'package:lost_and_find_app/pages/home/home_screen.dart';
import 'package:lost_and_find_app/pages/message/message_page.dart';
import 'package:lost_and_find_app/pages/post/post_screen.dart';

import '../../utils/colors.dart';
import '../giveaway/giveaway_screen.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  HomePage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState(initialIndex);
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex;

  _HomePageState(this._selectedIndex);
  int _selectIndex = 0;
  List pages =[
    HomeScreen(),
    PostScreen(),
    GiveawayScreen(),
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
    _selectIndex = _selectedIndex;
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
              icon: Icon(FontAwesomeIcons.receipt, size: 20,),
              label: "Post"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard,),
              label: "Giveaway"
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
