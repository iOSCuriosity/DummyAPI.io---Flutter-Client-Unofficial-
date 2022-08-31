import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List<User>> fetchUsers({int page = 0, int limit = 10}) async {
  final response = await http.get(Uri.parse('https://dummyapi.io/data/v1/user?limit=$limit&page=$page'),headers: {'app-id': '62a1e48bb626c76a3892a2d7'});

  if (response.statusCode == 200) {
    final responseObj = UserResponse.fromJson(jsonDecode(response.body));
    final posts = responseObj.data ?? <User>[];
    return posts;
  }else {
    throw Exception('Failed to fetch Posts. \n Reason: ${response.reasonPhrase}');
  }
}

Future<User> fetchUserById({required String id}) async {
  final response = await http.get(Uri.parse('https://dummyapi.io/data/v1/user/$id'),headers: {'app-id': '62a1e48bb626c76a3892a2d7'});

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  }else {
    throw Exception('Failed to fetch User Profile. \n Reason: ${response.reasonPhrase}');
  }
}

class UserResponse {
  final List<User>? data;
  final int? total;
  final int? page;
  final int? limit;

  UserResponse({ this.data, this.total, this.page, this.limit });

  factory UserResponse.fromJson(Map<String, dynamic>json) {
    return UserResponse(
      data: List<User>.from(json['data'].map((x) => User.fromJson(x))),
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      );
  }
}

class User {
  final String? id;
  final String? title;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? email;
  final String? dateOfBirth;
  final String? registerDate;
  final String? phone;
  final String? picture;
  final Location? location;

  User({this.id, this.title, this.firstName, this.lastName, this.gender, this.email,  this.dateOfBirth, this.registerDate, this.phone, this.picture, this.location});

  factory User.fromJson(Map<String, dynamic> json) {
    return User (
      id: json['id'],
      title: json['title'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      gender: json['gender'],
      email: json['email'],
      dateOfBirth: json['dateOfBirth'],
      registerDate: json['registerDate'],
      phone: json['phone'],
      picture: json['picture'],
      location: Location.fromJson(json['location'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['gender'] = gender;
    data['email'] = email;
    data['dateOfBirth'] = dateOfBirth;
    data['registerDate'] = registerDate;
    data['phone'] = phone;
    data['picture'] = picture;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    return data;
  }
}

class Location {
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? timezone;

  Location({this.street, this.city, this.state, this.country, this.timezone});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      street: json['street'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      timezone: json['timezone'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['street'] = street;
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['timezone'] = timezone;
    return data;
  }
}