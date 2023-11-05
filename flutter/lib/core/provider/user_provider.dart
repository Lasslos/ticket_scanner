import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticket_scanner/core/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:dartlin/control_flow.dart';

part 'user_provider.g.dart';

const String url = 'http://localhost:8000/';

@riverpod
class Session extends _$Session {
  @override
  Future<Token?> build() async {
    final prefs = await SharedPreferences.getInstance();
    User? user = prefs.getString('user')?.let((it) => User.fromJson(jsonDecode(it)));
    if (user == null) {
      return null;
    }

    final response = await http.post(
      Uri(host: url, path: "token/"),
      headers: <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      },
      body: user.toJson(),
    );
    if (response.statusCode == 200) {
      return Token.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login: ${jsonDecode(response.body)}');
    }
  }

  Future<void> save(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    ref.refresh(sessionProvider);
  }
}

