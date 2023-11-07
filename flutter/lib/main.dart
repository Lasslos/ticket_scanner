import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:ticket_scanner/screens/loading_screen.dart';

void main() {
  Intl.defaultLocale = 'de_DE';
  initializeDateFormatting(Intl.defaultLocale!, null);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
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
    home: const LoadingScreen(),
  );
}
