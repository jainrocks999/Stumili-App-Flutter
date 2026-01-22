import 'package:flutter/material.dart';
import 'package:weather_app/navigation/main_tabs.dart';
import 'package:weather_app/screens/Intro/ask_reminder_screen.dart';
import 'package:weather_app/screens/Intro/choose_affirmation_screen.dart';
import 'package:weather_app/screens/Intro/interested_screen.dart';
import 'package:weather_app/screens/Intro/welcome_screen.dart';
import 'package:weather_app/screens/auth/login_screen.dart';
import 'package:weather_app/screens/auth/signup_screen.dart';
import 'package:weather_app/screens/main/player/player_screen.dart';
import 'package:weather_app/screens/main/playlist_dailts_screen.dart';
import 'package:weather_app/screens/main/user_plalist/select_affirmation_screen.dart';
import 'package:weather_app/screens/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String welcome = "/welcome";
  static const String chooseaffirmation = "/chooseaffirmation";
  static const String askreminder = "/askreminder";
  static const String interested = "/interested";
  static const String playlistdailts = "/playlistdailts";
  static const String player = "/player";
  static const String selectaffirmation = "/selectaffirmation";

  // ✅ Bottom tab entry
  static const String mainTabs = "/main-tabs";

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignUpScreen(),
    welcome: (context) => const WelcomeScreen(),
    chooseaffirmation: (context) => const ChooseAffirmationScreen(),
    askreminder: (context) => const AskReminderScreen(),
    interested: (context) => const InterestedScreen(),
 //main screen
    mainTabs: (context) => const MainTabs(),
    playlistdailts: (context) => const PlaylistDailtsScreen(),
    player: (context) => const PlayerScreen(),
    selectaffirmation: (context) => const SelectAffirmationScreen(),
  };
}
