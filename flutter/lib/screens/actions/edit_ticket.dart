import 'package:dartlin/dartlin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_scanner/core/models/ticket.dart';
import 'package:ticket_scanner/core/provider/ticket_provider.dart';

class EditTicket extends ConsumerStatefulWidget {
  final int? id;

  const EditTicket({required this.id, super.key});

  @override
  ConsumerState createState() => _EditTicketState();
}

class _EditTicketState extends ConsumerState<EditTicket> {
  List<FocusNode> focusNodes = [];

  TicketUpdate _ticketUpdate = const TicketUpdate();
  final _formKey = GlobalKey<FormState>();

  String? _error;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    focusNodes = List.generate(4, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var element in focusNodes) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Ticket? ticket = widget.id?.let(
      (it) => ref.watch(ticketsProvider(it)).maybeWhen(
        data: (data) => data,
        orElse: () => null,
      ),
    );

    return Form(
      key: _formKey,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [],
      ),
    );
  }
}
