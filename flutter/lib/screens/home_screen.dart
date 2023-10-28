import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_scanner/provider/qr_code_information_provider.dart';
import 'package:ticket_scanner/screens/qr_code_scanner.dart';
import 'package:ticket_scanner/screens/settings_screen.dart';
import 'package:ticket_scanner/screens/validation_display.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool showBorder = false;

  Future<void> _animate() async {
    setState(() {
      showBorder = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 600));
    setState(() {
      showBorder = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(qrCodeInformationProvider.select((value) => value?.code), (previous, next) {
      if (next != null && next != previous) {
        _animate();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket-Scanner'),
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          const SizedBox(
            height: 12,
          ),
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: SizedBox.expand(
              child: AnimatedContainer(
                margin: const EdgeInsets.all(16),
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  boxShadow: [
                    if (showBorder) const BoxShadow(color: Colors.green, spreadRadius: 4),
                  ],
                  borderRadius: BorderRadius.circular(42),
                ),
                clipBehavior: Clip.antiAlias,
                child: const QRCodeScanner(),
              ),
            ),
          ),
          const Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: ValidationDisplay(),
          ),
        ],
      ),
    );
  }


}

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

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
