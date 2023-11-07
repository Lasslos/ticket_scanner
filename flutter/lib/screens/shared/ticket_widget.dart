import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticket_scanner/core/models/ticket.dart';

class TicketWidget extends StatelessWidget {
  final Ticket ticket;

  const TicketWidget({required this.ticket, super.key});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ListTile(
        title: Text(ticket.name),
        subtitle: Text(ticket.id.toString()),
        trailing: SegmentedButton(
          segments: [
            ButtonSegment(
              value: ticket.type,
              icon: Icon(ticket.type.icon),
              label: Text(ticket.type.name),
            ),
          ],
          selected: { ticket.type },
          showSelectedIcon: false,
          onSelectionChanged: (_) {},
        ),
      ),
      if (ticket.notes.isNotEmpty) ListTile(
        title: const Text("Notizen"),
        subtitle: Text(ticket.notes),
      ),
      ListTile(
        title: Text("Am ${DateFormat("dd. MMMM yyyy").format(ticket.created)} um ${DateFormat("HH:mm").format(ticket.created)} erstellt"),
      ),
      if (ticket.entered != null) ListTile(
        title: Text("Am ${DateFormat("dd. MMMM yyyy").format(ticket.entered!)} um ${DateFormat("HH:mm").format(ticket.entered!)} eingelassen"),
      ),
      ListTile(
        title: Text("${ticket.isPresent ? "A" : "Nicht a"}nwesend"),
      ),
    ],
  );
}
