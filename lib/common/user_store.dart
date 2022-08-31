import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:social/models/user.dart';

const String udCurrentUser = 'ud_current_user';

class UserStore {
  static UserStore shared = UserStore();

  User? currentUser;
  List<String?> tags = [];

  Future<User?> getCurrentUser() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String? strUser = sharedPref.getString(udCurrentUser);
    if (strUser == null) {
      return null;
    }
    User? usr = User.fromJson(jsonDecode(strUser));
    if (usr.id != null) {
      currentUser = usr;
    }
    return usr;
  }

  setCurrentUser(User? user) async {
    if (user == null || user.id == null) {
      return;
    }
    currentUser = user;
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String strUser = jsonEncode(user.toJson());
    sharedPref.setString(udCurrentUser, strUser);    
  }

  Future<bool> eraseCurrentUser() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    return await sharedPref.remove(udCurrentUser).then((success) {
      if (success) {
        currentUser = null;
      }
      return success;
    });
  }
}