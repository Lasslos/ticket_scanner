import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ticket_scanner/core/models/error.dart';
import 'package:ticket_scanner/core/models/ticket.dart';
import 'package:ticket_scanner/core/models/user.dart';
import 'package:ticket_scanner/core/provider/session_provider.dart';
import 'package:http/http.dart' as http;

part 'ticket_provider.g.dart';

@riverpod
class Tickets extends _$Tickets {
  late final int _id;

  @override
  Future<Ticket?> build(int id) async {
    _id = id;
    final response = await authenticatedRequest(
      ref.watch(sessionProvider),
          (defaultHeaders, token) => http.get(
        baseUri.replace(path: 'ticket', queryParameters: {"ticket_id": id.toString()}),
        headers: defaultHeaders,
      ),
    );
    if (response == null) {
      return null;
    }

    switch (response.statusCode) {
      case 200: // Ticket found
        return Ticket.fromJson(jsonDecode(response.body));
      case 404: // Ticket not found
        return null;
      case 401: // Unauthorized request
        throw HttpException.fromJson(jsonDecode(response.body));
      case 422: // Malformed request
        throw HTTPValidationError.fromJson(jsonDecode(response.body));
      default:
        throw Exception('Failed to load tickets: ${response.body}');
    }
  }

  Future<void> createTicket(TicketCreate ticketCreate) async {
    final response = await authenticatedRequest(
      ref.watch(sessionProvider),
          (defaultHeaders, token) => http.post(
        baseUri.replace(path: 'ticket/new'),
        headers: defaultHeaders,
        body: jsonEncode(ticketCreate.toJson()..['id'] = _id),
      ),
    );
    if (response == null) {
      throw Exception('Not Authenticated');
    }
    switch (response.statusCode) {
      case 200: // Ticket created
        state = AsyncData(Ticket.fromJson(jsonDecode(response.body)));
        return;
      case 409: //Ticket id or name already exists
      case 401: // Unauthorized request
        throw HttpException.fromJson(jsonDecode(response.body));
      case 422: // Malformed request
        throw HTTPValidationError.fromJson(jsonDecode(response.body));
      default:
        throw Exception('Failed to load tickets: ${response.body}');
    }
  }

  Future<void> updateTicket(TicketUpdate ticketUpdate) async {
    final response = await authenticatedRequest(
      ref.watch(sessionProvider),
      (defaultHeaders, token) => http.put(
        baseUri.replace(path: 'ticket/update'),
        headers: defaultHeaders,
        body: jsonEncode(ticketUpdate.toJson()..['id'] = _id),
      ),
    );
    if (response == null) {
      throw Exception('Not Authenticated');
    }

    switch (response.statusCode) {
      case 200: // Ticket updated
        state = AsyncData(Ticket.fromJson(jsonDecode(response.body)));
        return;
      case 404: // Ticket not found
      case 409: //Ticket name conflicts
      case 401: // Unauthorized request
        throw HttpException.fromJson(jsonDecode(response.body));
      case 422: // Malformed request
        throw HTTPValidationError.fromJson(jsonDecode(response.body));
      default:
        throw Exception('Failed to load tickets: ${response.body}');
    }
  }

  Future<void> deleteTicket() async {
    final response = await authenticatedRequest(
      ref.watch(sessionProvider),
      (defaultHeaders, token) => http.delete(
        baseUri.replace(path: 'ticket/delete', queryParameters: {"ticket_id": id.toString()}),
        headers: defaultHeaders,
      ),
    );

    if (response == null) {
      throw Exception('Not Authenticated');
    }

    switch (response.statusCode) {
      case 200: // Ticket deleted
        state = const AsyncData(null);
        return;
      case 404: // Ticket not found
      case 401: // Unauthorized request
        throw HttpException.fromJson(jsonDecode(response.body));
      case 422: // Malformed request
        throw HTTPValidationError.fromJson(jsonDecode(response.body));
      default:
        throw Exception('Failed to load tickets: ${response.body}');
    }
  }
}

@riverpod
Future<List<Ticket>> allTickets(AllTicketsRef ref) async {
  final response = await authenticatedRequest(
    ref.watch(sessionProvider),
    (defaultHeaders, token) => http.get(
      baseUri.replace(path: 'tickets'),
      headers: defaultHeaders,
    ),
  );
  if (response == null) {
    return [];
  }

  if (response.statusCode == 200) {
    return List<Ticket>.from(jsonDecode(response.body).map((it) => Ticket.fromJson(it)));
  } else {
    throw Exception('Failed to load tickets: ${response.body}');
  }
}

Future<http.Response?> authenticatedRequest(
  AsyncValue<Token?> tokenAsync,
  Future<http.Response> Function(
    Map<String, String> defaultHeaders,
    Token token,
  ) request,
) async {
  if (tokenAsync.hasError) {
    throw Exception('Failed to load tickets: ${tokenAsync.error}');
  } else if (tokenAsync.isLoading || tokenAsync.requireValue == null) {
    return null;
  }

  Token token = tokenAsync.requireValue!;

  return request(
    <String, String>{
      'accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${token.accessToken}',
    },
    token,
  );
}
