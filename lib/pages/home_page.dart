import 'package:provider/provider.dart';
import 'package:social/pages/posts_page.dart';
import 'package:flutter/material.dart';
import 'package:social/pages/profile_page.dart';
import 'package:social/pages/explore_page.dart';
import 'package:social/provider/bottom_tab_provider.dart';
import 'package:social/provider/tag_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _widgetOptions = [
    const PostsPage(),
    const ExplorePage(),
    const ProfilePage()
  ];

  Widget _buildBottomNavigationBar(BuildContext context, BottomTabBarItems tabItem) {
    return BottomNavigationBar(
          landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
          selectedItemColor: Colors.black,
          onTap: (selIndex) {
            // 
            Provider.of<BottomTabProvider>(context, listen: false).selectedTab = BottomTabBarItems.values[selIndex];
          },
          currentIndex: tabItem.index,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.grid_3x3), 
                label: 'Explore'),
            BottomNavigationBarItem(
              icon: Icon(Icons.person), 
              label: 'Profile')
          ],
        );
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<BottomTabProvider>(
      builder: (context, data, child) {
        return Scaffold(
      bottomNavigationBar: _buildBottomNavigationBar(context, data.selectedTab),
      backgroundColor: Colors.white.withAlpha(240),
      body: SafeArea(
        child: _widgetOptions[data.selectedTab.index],
      )
      );
      },
    );
  }
}
