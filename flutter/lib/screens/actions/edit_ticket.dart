import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditTicket extends ConsumerStatefulWidget {
  const EditTicket({super.key});

  @override
  ConsumerState createState() => _EditTicketState();
}

class _EditTicketState extends ConsumerState<EditTicket> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder(color: Colors.blue);
  }
}
