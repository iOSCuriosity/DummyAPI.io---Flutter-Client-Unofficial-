import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/user.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

String getTimeAgoFromDate(String? strDate) {
  if (strDate != null && strDate.isNotEmpty) {
    final dt = DateFormat('yyyy-mm-ddThh:mm:ss.SSSZ').parse(strDate);
    return timeago.format(dt);
  } else {
    return '';
  }
}

String getFormattedAddressFromLocation(Location? location) {
  String tmpStr = '';
  if (location == null) {
    return tmpStr;
  }

  if (location.city != null && location.city!.isNotEmpty) {
    tmpStr += '${location.city}';
  }

  if (location.state != null && location.state!.isNotEmpty) {
    tmpStr += ', ${location.state}';
  }

  if (location.country != null && location.country!.isNotEmpty) {
    tmpStr += '${location.country}';
  }

  return tmpStr;
}
