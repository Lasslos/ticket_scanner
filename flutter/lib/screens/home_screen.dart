import 'package:dartlin/dartlin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_scanner/screens/actions/create_ticket.dart';
import 'package:ticket_scanner/screens/actions/edit_ticket.dart';
import 'package:ticket_scanner/screens/actions/scan_ticket.dart';
import 'package:ticket_scanner/screens/qr_code_scanner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  late TextEditingController _idController;
  late FocusNode _idFocusNode;
  int? _id;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _idController = TextEditingController(text: "");
    _idFocusNode = FocusNode()..addListener(() {
      if (!_idFocusNode.hasFocus && _formKey.currentState!.validate()) {
        setState(() {
          _formKey.currentState!.save();
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _idController.dispose();
    _idFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String appBarText = "Ticket ";
    switch (_selectedIndex) {
      case 0:
        appBarText += "verkaufen";
        break;
      case 1:
        appBarText += "bearbeiten";
        break;
      case 2:
        appBarText += "scannen";
        break;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarText),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  focusNode: _idFocusNode,
                  autocorrect: false,
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty || int.tryParse(value) == null) {
                      return 'Bitte gib eine ID ein.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _id = int.parse(value!);
                  },
                  decoration: InputDecoration(
                    labelText: 'ID',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_2),
                      onPressed: () async {
                        final scanData = await showScanDialog(context);
                        if (scanData == null) {
                          return;
                        }
                        int? newId = scanData.code?.let((it) => int.tryParse(it));
                        if (newId != null) {
                          setState(() {
                            _idController.text = newId.toString();
                          });
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _formKey.currentState!.save();
                            });
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),

              IndexedStack(
                index: _selectedIndex,
                children: [
                  CreateTicket(id: _id),
                  EditTicket(id: _id),
                  ScanTicket(id: _id),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.shifting,
        useLegacyColorScheme: false,
        items: const [
          // Create Ticket
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Verkaufen',
            tooltip: 'Verkaufe ein neues Ticket',
          ),
          // Edit Ticket
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Bearbeiten',
            tooltip: 'Bearbeite ein bestehendes Ticket',
          ),
          // Scan Ticket
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scannen',
            tooltip: 'Scanne ein Ticket',
          ),
        ],
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
