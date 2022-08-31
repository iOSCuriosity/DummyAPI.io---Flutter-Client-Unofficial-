import 'package:social/common/user_store.dart';
import 'package:flutter/material.dart';
import 'package:social/pages/home_page.dart';
import 'package:social/pages/users_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key, this.message = 'Launching...'}) : super(key: key);

  final String message;
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      UserStore.shared.getCurrentUser().then((usr) {
        if (UserStore.shared.currentUser == null) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const UsersPage()));
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: SafeArea(
        child: Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.message,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
        ),
        const LinearProgressIndicator()
      ],
    ),
        ),
      ));
  }
}
