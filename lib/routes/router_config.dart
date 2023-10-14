import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:lost_and_find_app/pages/home/home_page.dart';

import '../pages/auth/login_google_page.dart';

class AppRouter {
  static GoRouter returnRouter() {
    final GoRouter router = GoRouter(
        initialLocation: '/home',
        routes: <GoRoute>[
          GoRoute(
              name: 'home',
              path: '/home',
              builder: (BuildContext context, GoRouterState state) {
                return HomePage();
              },
              routes: []),
          GoRoute(
            name: 'login',
            path: '/login',
            builder: (BuildContext context, GoRouterState state) {
              // Your login page content
              return LoginGooglePage();
            },
          ),
        ],
        redirect: (BuildContext context, GoRouterState state) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            context.goNamed('home');
          } else {
            context.goNamed('login');
          }
        });
  return router;
  }

}
