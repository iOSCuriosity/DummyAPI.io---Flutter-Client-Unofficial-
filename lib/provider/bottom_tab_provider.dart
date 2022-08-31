import 'package:flutter/material.dart';

enum BottomTabBarItems {
  home,
  explore,
  profile
}

class BottomTabProvider extends ChangeNotifier {
  BottomTabBarItems _selectedTab = BottomTabBarItems.home;

  BottomTabBarItems get selectedTab => _selectedTab;

  set selectedTab(BottomTabBarItems tab) {
    _selectedTab = tab;
    notifyListeners();
  }
}