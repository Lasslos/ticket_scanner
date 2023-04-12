import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_scanner/screens/home_screen.dart';
import 'package:ticket_scanner/provider/server_connection_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      debugPrint("Hallo");
      ref.read(serverConnectionProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Ticket Scanner',
    theme: ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.green,
      useMaterial3: true,
    ),
    darkTheme: ThemeData(
      primarySwatch: Colors.green,
      brightness: Brightness.dark,
      useMaterial3: true,
    ),
    themeMode: ThemeMode.dark,
    home: const HomeScreen(),
  );
}
