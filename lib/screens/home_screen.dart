import 'package:flutter/material.dart';
import 'package:ticket_scanner/screens/qr_code_scanner.dart';
import 'package:ticket_scanner/screens/settings_screen.dart';
import 'package:ticket_scanner/screens/validation_display.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Ticket Scanner'),
      //implement hamburger menu

    ),
    drawer: const MyDrawer(),
    body: ListView(
      children: [
        const SizedBox(
          height: 12,
        ),
        Container(
          height: 0.5 * MediaQuery.of(context).size.height,
          margin: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(42),
            child: /*const QRCodeScanner()*/const ColoredBox(color: Colors.black),
          ),
        ),
        const ValidationDisplay(),
      ],
    ),
  );
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Drawer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Colors.green,
          ),
          child: SafeArea(
            minimum: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                const Icon(
                  Icons.local_activity,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Ticket-Scanner',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
        ListTile(
          title: const Text('Scanner'),
          onTap: () {
            Navigator.pop(context);
          },
          leading: const Icon(Icons.qr_code_scanner),
        ),
        ListTile(
          title: const Text('Einstellungen'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          leading: const Icon(Icons.settings),
        ),
      ],
    ),
  );
}
