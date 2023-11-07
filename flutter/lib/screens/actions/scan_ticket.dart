import 'package:dartlin/dartlin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_scanner/core/models/ticket.dart';
import 'package:ticket_scanner/core/provider/ticket_provider.dart';
import 'package:ticket_scanner/screens/shared/ticket_widget.dart';

class ScanTicket extends ConsumerStatefulWidget {
  final int? id;
  
  const ScanTicket({required this.id, super.key});

  @override
  ConsumerState createState() => _ScanTicketState();
}

class _ScanTicketState extends ConsumerState<ScanTicket> {
  @override
  Widget build(BuildContext context) {
    Ticket? ticket = widget.id?.let((it) => ref.watch(ticketsProvider(it)).valueOrNull);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        if (ticket != null) Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TicketWidget(ticket: ticket),
          ),
        ),
        const SizedBox(height: 16),
        if (ticket != null) Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                ref.read(ticketsProvider(ticket.id).notifier).updateTicket(
                  const TicketUpdate(
                    isPresent: false,
                  ),
                );
              },
              child: const Text("Auslass"),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () {
                ref.read(ticketsProvider(ticket.id).notifier).updateTicket(
                  TicketUpdate(
                    entered: DateTime.now(),
                    isPresent: true,
                  ),
                );
              },
              child: const Text("Einlass"),
            ),
          ],
        ),
      ],
    );
  }
}
