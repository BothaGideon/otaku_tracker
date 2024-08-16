import 'package:flutter/material.dart';
import 'package:otaku_tracker/pages/landing_page.dart';
import 'package:otaku_tracker/pages/my_list_page.dart';
import 'package:otaku_tracker/pages/seasonal_page.dart';

// Define route names and paths here
const Map<int, String> routePaths = {
  0: '/', // Home page
  1: '/seasonal',
  2: '/my-list', // Details page
  // Add more routes as needed
};

final Map<String, Widget> routes = {
  '/': LandingPage(),
  '/seasonal': SeasonalPage(),
  '/my-list': MyListPage(),
};
