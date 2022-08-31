import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<String?>> fetchTags({int page = 0, int limit = 50}) async {
  final response = await http.get(Uri.parse('https://dummyapi.io/data/v1/tag?limit=$limit&page=$page'),headers: {'app-id': '62a1e48bb626c76a3892a2d7'});

  if (response.statusCode == 200) {
    final responseObj = TagResponse.fromJson(jsonDecode(response.body));
    final tags = responseObj.data ?? <String>[];
    tags.removeWhere((x) => (
      x == null 
      || x.isEmpty 
      || x.length < 2 
      || x.length > 100 
      || x.contains(' ') 
      || x.contains('[') 
      || x.contains(']') 
      || x.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')) 
      || x.contains(RegExp('[A-Z]')) 
      || x.contains(RegExp('[0-9]'))
      ));
    tags.shuffle();
    return tags;
  }else {
    throw Exception('Failed to fetch Tags. \n Reason: ${response.reasonPhrase}');
  }
}

class TagResponse {
  final List<String?>? data;
  final int? total;
  final int? page;
  final int? limit;

  TagResponse({ this.data, this.total, this.page, this.limit });

  factory TagResponse.fromJson(Map<String, dynamic>json) {
    return TagResponse(
      data: json['data'].cast<String?>(),
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      );
  }
}