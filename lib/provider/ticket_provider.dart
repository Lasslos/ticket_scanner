import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class TicketsNotifier extends StateNotifier<Set<Ticket>> {
  TicketsNotifier() : super({});

  void initialize() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? ticketList = prefs.getStringList("ticketList");
    if (ticketList == null) {
      return;
    }
    Set<Ticket> tickets = ticketList.map((e) => Ticket.fromJson(jsonDecode(e))).toSet();
    state = tickets;
  }
  void save() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> ticketList = state.map((e) => jsonEncode(e.toJSON())).toList();
    prefs.setStringList("ticketList", ticketList);
  }

  void loadTicketListFromFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Ticketliste auswählen",
      type: FileType.custom,
      allowedExtensions: ["json"],
    );

    if (result == null) {
      return;
    }
    File file = File(result.files.single.path!);
    String content = await file.readAsString();
    List<dynamic> ticketList = jsonDecode(content);
    Set<Ticket> tickets = ticketList.map((e) => Ticket.fromJson(e)).toSet();
    state = tickets;
    save();
  }
}

final ticketsProvider = StateNotifierProvider<TicketsNotifier, Set<Ticket>>((ref) => TicketsNotifier());

final ticketValidationProvider = FutureProvider.autoDispose.family<Ticket, String>((ref, ticketId) async {
  return ref.read(ticketsProvider).firstWhere(
    (element) => element.ticketId == ticketId,
    orElse: () => Ticket(ticketId, TicketType.unknown, false, false),
  );
});
