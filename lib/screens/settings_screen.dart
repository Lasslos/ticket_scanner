import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_scanner/provider/server_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
            child: ListTile(
              title: const Text('Server'),
              subtitle: Text(ref.watch(serverConnectionProvider).uri.toString()),
              onTap: () =>_showServerDialog(context, ref),
            ),
          ),
        ],
      ),
    );
  }


  void _showServerDialog(BuildContext context, WidgetRef ref) {
    showDialog(
        context: context,
        builder: (context) => const ServerDialog(),
    );
  }
}

class ServerDialog extends ConsumerStatefulWidget {
  const ServerDialog({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _ServerDialogState();
}

class _ServerDialogState extends ConsumerState<ServerDialog> {
  bool obscurePassword = true;
  late TextEditingController uriController;

  @override
  void initState() {
    super.initState();
    uriController = TextEditingController(text: ref.read(serverConnectionProvider).uri.toString());
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Server'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: uriController,
            onChanged: (value) {
              Uri? uri = Uri.tryParse(value);
              if (uri == null) {
                return;
              }
              ref.read(serverConnectionProvider.notifier).uri = uri;
            },
            decoration: const InputDecoration(
              labelText: 'URL',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
            autofillHints: const [AutofillHints.url],
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () {
          ref.read(serverConnectionProvider.notifier).save();
          Navigator.of(context).pop();
        },
        child: const Text('OK'),
      ),
    ],
  );
}
