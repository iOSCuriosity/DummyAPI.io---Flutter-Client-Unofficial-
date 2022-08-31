import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social/pages/splash_page.dart';
import 'package:social/provider/bottom_tab_provider.dart';
import 'package:social/provider/tag_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
                    ChangeNotifierProvider<BottomTabProvider>(create: (context) => BottomTabProvider(),),
                    ChangeNotifierProvider<TagProvider>(create: (context) => TagProvider(),)
                  ],
          child: MaterialApp(
        title: 'Social',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: const SplashPage(),
      ),
    );
  }
}