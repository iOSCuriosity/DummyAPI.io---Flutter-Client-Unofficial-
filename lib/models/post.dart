import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:social/models/user.dart';

Future<List<Post>> fetchPosts({int page = 0, int limit = 10, String tag = '', String userId = '', bool fromExplore = false}) async {
  String url = 'https://dummyapi.io/data/v1/';
  if (tag.isNotEmpty) {
    String strTag = tag.toLowerCase();
    url += 'tag/$strTag';
  }else if (userId.isNotEmpty) {
    url += 'user/$userId';
  }
  final response = await http.get(Uri.parse('$url/post?limit=$limit&page=$page'),headers: {'app-id': '62a1e48bb626c76a3892a2d7'});

  if (response.statusCode == 200) {
    final responseObj = PostResponse.fromJson(jsonDecode(response.body));
    final posts = responseObj.data ?? <Post>[];
    if (kDebugMode) {
    print('${response.request?.url} | ${responseObj.total}');
  }
    if (fromExplore && tag.isEmpty) {
      posts.shuffle();
    }
    return posts;
  }else {
    throw Exception('Failed to fetch Posts. \n Reason: ${response.reasonPhrase}');
  }
}

Future<int> fetchTotalPostsCountByUserId({required String id, int page = 0, int limit = 10}) async {
  final response = await http.get(Uri.parse('https://dummyapi.io/data/v1/user/$id/post?limit=$limit&page=$page'),headers: {'app-id': '62a1e48bb626c76a3892a2d7'});

  if (response.statusCode == 200) {
    final responseObj = PostResponse.fromJson(jsonDecode(response.body));
    return responseObj.total ?? 0;
  }else {
    throw Exception('Failed to fetch total posts count. \n Reason: ${response.reasonPhrase}');
  }
}

class PostResponse {
  final List<Post>? data;
  final int? total;
  final int? page;
  final int? limit;
  // final Owner owner;

  PostResponse({ this.data, this.total, this.page, this.limit });

  factory PostResponse.fromJson(Map<String, dynamic>json) {
    return PostResponse(
      data: List<Post>.from(json['data'].map((x) => Post.fromJson(x))),
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      );
  }
}

class Post {
  final String id;
  final String? text;
  final String? image;
  final int? likes;
  final String? link;
  final List<String>? tags;
  final String? publishDate;
  final User? owner;

  Post({ required this.id, this.text, this.image, this.likes, this.link, this.tags, this.publishDate, this.owner});

  factory Post.fromJson(Map<String, dynamic>json) {
    return Post(
      id: json['id'],
      text: json['text'],
      image: json['image'],
      likes: json['likes'],
      link: json['link'],
      tags: json['tags'].cast<String>(),
      publishDate: json['publishDate'],
      owner: User.fromJson(json['owner'])
      );
  }
}

// class User {
//   final String id;
//   final String? title;
//   final String? firstName;
//   final String? lastName;
//   final String? picture;
//   // final Owner owner;

//   User({ required this.id, this.title, this.firstName, this.lastName, this.picture});

//   factory User.fromJson(Map<String, dynamic>json) {
//     return User(
//       id: json['id'],
//       title: json['title'],
//       firstName: json['firstName'],
//       lastName: json['lastName'],
//       picture: json['picture'],
//       );
//   }
// }
/*{
id: string(autogenerated)
text: string(length: 6-1000)
image: string(url)
likes: number(init value: 0)
link: string(url, length: 6-200)
tags: array(string)
publishDate: string(autogenerated)
owner: object(User Preview)
}*/

// Future<List<Post>> fetchPosts() async {
//   final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));

//   if (response.statusCode == 200) {
//     return List<Post>.from(jsonDecode(response.body).map((x) => Post.fromJson(x)));
//   }else {
//     throw Exception('Failed to fetch Posts. \n Reason: ${response.reasonPhrase}');
//   }
// }

// class Post {
//   final int albumId;
//   final int id;
//   final String? title;
//   final String? url;
//   final String? thumbnailUrl;

//   Post({ required this.albumId, required this.id, this.title, this.url, this.thumbnailUrl});

//   factory Post.fromJson(Map<String, dynamic>json) {
//     return Post(
//       albumId: json['albumId'],
//       id: json['id'],
//       title: json['title'],
//       url: json['url'],
//       thumbnailUrl: json['thumbnailUrl'],
//       );
//   }
// }