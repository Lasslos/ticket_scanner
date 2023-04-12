import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:ticket_scanner/provider/server_connection_provider.dart';

enum TicketType {
  regular("Regulär", Colors.green), reduced("Ermäßigt", Colors.yellow), volunteer("Helfer", Colors.blue), unknown("Ungültig", Colors.red);

  final String displayName;
  final Color color;
  const TicketType(this.displayName, this.color);
}

class Ticket {
  final String ticketId;
  final TicketType ticketType;
  final bool isDevaluated;
  final bool isValid;

  Ticket(this.ticketId, this.ticketType, this.isDevaluated, this.isValid);

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      json["ticketId"].toString(),
      TicketType.values.firstWhere(
        (element) => element.toString().split(".").last == json["ticketType"],
        orElse: () => TicketType.unknown,
      ),
      json["isDevaluated"],
      json["isValid"],
    );
  }
  Map<String, dynamic> toJSON() => {
      "ticketId": ticketId,
      "ticketType": ticketType.toString(),
      "isDevaluated": isDevaluated,
      "isValid": isValid,
    };
}

final ticketValidationProvider = FutureProvider.autoDispose.family<Ticket, String>((ref, ticketId) async {
  var result = await http.get(ref.watch(serverConnectionProvider).uri.resolve("?d=$ticketId"));
  return Ticket.fromJson(jsonDecode(result.body));
});
