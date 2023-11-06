import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_scanner/screens/actions/create_ticket.dart';
import 'package:ticket_scanner/screens/actions/edit_ticket.dart';
import 'package:ticket_scanner/screens/actions/scan_ticket.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

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
          child: IndexedStack(
            index: _selectedIndex,
            children: const [
              CreateTicket(),
              EditTicket(),
              ScanTicket(),
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
