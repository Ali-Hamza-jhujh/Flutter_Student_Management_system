import 'package:flutter/material.dart';
import 'package:frontened/secreens/addMarks.dart';
import 'package:frontened/secreens/dashboard.dart';
import 'package:frontened/secreens/login.dart';
import 'package:frontened/secreens/register.dart';

class AppRouter {
  static const String register = "/register";
  static const String login = "/login";
  static const String students = "/students";
  static const String dashboard = "/dashboard";

  static Route<dynamic> generateRoute(RouteSettings setting) {
    switch (setting.name) {
      case register:
        return MaterialPageRoute(builder: (_) => const Register());
      case login:
        return MaterialPageRoute(builder: (_) => const Login());

      case students:
        return MaterialPageRoute(builder: (_) => const Students());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const Dashboard());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text("Page '${setting.name}' not found!")),
          ),
        );
    }
  }
}
