import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerInformation {
  Uri uri;
  String password;

  ServerInformation(this.uri, this.password);
}
class ServerConnectionNotifier extends StateNotifier<ServerInformation> {
  ServerConnectionNotifier() : super(ServerInformation(Uri.parse('http://localhost:8080'), ''));

  set uri(Uri uri) {
    state = ServerInformation(uri, state.password);
  }
  set password(String password) {
    state = ServerInformation(state.uri, password);
  }

  void initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final uri = prefs.getString('uri');
    final password = prefs.getString('password');
    state = ServerInformation(Uri.parse(uri ?? 'http://localhost:8080'), password ?? '');
  }
  void save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uri', state.uri.toString());
    await prefs.setString('password', state.password);
  }
}

final serverConnectionProvider = StateNotifierProvider<ServerConnectionNotifier, ServerInformation>((ref) => ServerConnectionNotifier());