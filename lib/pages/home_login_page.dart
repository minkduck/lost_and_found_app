import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_find_app/pages/auth/login_google_page.dart';

import 'home/home_page.dart';

class HomeLoginPage extends StatelessWidget {
  const HomeLoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Something Went Wrong!'),);
          } else if (snapshot.hasData) {

            return HomePage();
          } else {
            return LoginGooglePage();
          }
        },
      ),
    );
  }
}
