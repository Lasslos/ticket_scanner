import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TicketType { regular, reduced, volunteer, unknown }

class Ticket {
  final String ticketId;
  final TicketType ticketType;
  final bool isDevaluated;
  final bool isValid;

  Ticket(this.ticketId, this.ticketType, this.isDevaluated, this.isValid);
}

final ticketValidationProvider = FutureProvider.autoDispose.family<Ticket, String>((ref, ticketId) async {
  await Future.delayed(const Duration(seconds: 2));
  return Ticket(
    ticketId,
    TicketType.regular,
    false,
    true,
  );
});