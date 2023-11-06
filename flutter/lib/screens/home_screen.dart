import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _selectedIndex,
      children: const [
        Center(
          child: Text('Create Ticket'),
        ),
        Center(
          child: Text('Edit Ticket'),
        ),
        Center(
          child: Text('Scan Ticket'),
        ),
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      items: const [
        // Create Ticket
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Create Ticket',
        ),
        // Edit Ticket
        BottomNavigationBarItem(
          icon: Icon(Icons.edit),
          label: 'Edit Ticket',
        ),
        // Scan Ticket
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scan Ticket',
        ),
      ],
      onTap: (index) => setState(() => _selectedIndex = index),
    ),
  );
}
