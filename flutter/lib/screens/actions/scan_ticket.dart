import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScanTicket extends ConsumerStatefulWidget {
  final int? id;
  
  const ScanTicket({required this.id, super.key});

  @override
  ConsumerState createState() => _ScanTicketState();
}

class _ScanTicketState extends ConsumerState<ScanTicket> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder(color: Colors.red);
  }
}
