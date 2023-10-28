import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:ticket_scanner/provider/server_provider.dart';
import 'package:vibration/vibration.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_provider.freezed.dart';
part 'ticket_provider.g.dart';

@freezed
class Ticket with _$Ticket {
  const factory Ticket.regular({
    required String ticketId,
    required bool isDevaluated,
    required bool isValid,
  }) = _RegularTicket;

  const factory Ticket.reduced({
    required String ticketId,
    required bool isDevaluated,
    required bool isValid,
  }) = _ReducedTicket;

  const factory Ticket.volunteer({
    required String ticketId,
    required bool isDevaluated,
    required bool isValid,
  }) = _VolunteerTicket;

  const factory Ticket.unknown({
    required String ticketId,
    required bool isDevaluated,
    required bool isValid,
  }) = _UnknownTicket;

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);
}

final ticketValidationProvider = FutureProvider.autoDispose.family<Ticket, String>((ref, ticketId) async {
  Vibration.vibrate(amplitude: 64, duration: 50);
  var result = await http.get(ref.watch(serverConnectionProvider).uri.resolve("?$ticketId"));
  return Ticket.fromJson(jsonDecode(result.body));
});
