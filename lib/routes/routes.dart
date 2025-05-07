import 'package:flutter/material.dart';
import 'package:openearth_mobile/screen/login_screen.dart';
import 'package:openearth_mobile/screen/register_screen.dart';

class Routes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  static final routes = <String, WidgetBuilder>{
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
  };
}