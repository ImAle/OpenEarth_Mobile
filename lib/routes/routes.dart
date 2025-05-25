import 'package:flutter/material.dart';
import 'package:openearth_mobile/screen/account_screen.dart';
import 'package:openearth_mobile/screen/chat_screen.dart';
import 'package:openearth_mobile/screen/home_screen.dart';
import 'package:openearth_mobile/screen/login_screen.dart';
import 'package:openearth_mobile/screen/register_screen.dart';
import 'package:openearth_mobile/screen/rent_screen.dart';

class Routes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String account = '/account';
  static const String chat = '/chat';
  static const String rents = '/rents';

  static final routes = <String, WidgetBuilder>{
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    account: (context) => const AccountScreen(),
    chat: (context) => const ChatScreen(),
    rents: (context) => const RentScreen(),
  };
}