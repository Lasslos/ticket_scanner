import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticket_scanner/core/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:dartlin/control_flow.dart';
import 'package:ticket_scanner/util/logger.dart';

part 'session_provider.g.dart';

final Uri baseUri = Uri.parse("https://ticket-scanner.xn--sv-cjd-knigswinter-k3b.de/");

@Riverpod(keepAlive: true)
class Session extends _$Session {
  @override
  Future<Token?> build() async {
    final prefs = await SharedPreferences.getInstance();
    User? user = prefs.getString('user')?.let((it) => User.fromJson(jsonDecode(it)));
    if (user == null) {
      return null;
    }

    final response = await http.post(
      baseUri.replace(path: 'token'),
      headers: <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      },
      body: user.toJson(),
    );
    if (response.statusCode == 200) {
      return Token.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<void> save(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    try {
      await ref.refresh(sessionProvider.future);
    } catch (e) {
      getLogger().e('Failed to refresh session: $e');
    }
  }
}
