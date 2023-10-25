import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerInformation {
  Uri uri;

  ServerInformation(this.uri);
}
class ServerConnectionNotifier extends StateNotifier<ServerInformation> {
  ServerConnectionNotifier() : super(ServerInformation(Uri.parse('http://localhost:8080')));

  set uri(Uri uri) {
    state = ServerInformation(uri);
    save();
  }

  void initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final uri = prefs.getString('uri');
    state = ServerInformation(Uri.parse(uri ?? 'http://localhost:8080'));
    save();
  }
  void save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uri', state.uri.toString());
  }
}

final serverConnectionProvider = StateNotifierProvider<ServerConnectionNotifier, ServerInformation>((ref) => ServerConnectionNotifier());
