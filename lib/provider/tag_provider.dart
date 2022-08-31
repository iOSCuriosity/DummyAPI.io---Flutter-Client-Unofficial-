import 'package:flutter/foundation.dart';

class TagProvider extends ChangeNotifier {
  String _selectedTag = '';

  String get selectedTag => _selectedTag;

  set selectedTag(String tag) {
    _selectedTag = tag;
    notifyListeners();
  }
}