import 'package:dartlin/dartlin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_scanner/core/models/ticket.dart';
import 'package:ticket_scanner/core/provider/ticket_provider.dart';
import 'package:ticket_scanner/screens/shared/form_fields.dart';
import 'package:ticket_scanner/screens/shared/ticket_widget.dart';
import 'package:ticket_scanner/util/logger.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    focusNodes = List.generate(3, (_) => FocusNode());
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NameField(
            focusNode: focusNodes[0],
            nextFocusNode: focusNodes[1],
            onSaved: (value) {
              String? name;
              if (value != null && value.isNotEmpty) {
                name = value;
              }
              _ticketUpdate = _ticketUpdate.copyWith(name: name);
            },
            validator: (value) {
              return null;
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TicketTypeSelection(
              selected: _ticketUpdate.type,
              allowNone: true,
              onSelectionChanged: (selected) => setState(() {
                _ticketUpdate = _ticketUpdate.copyWith(type: selected);
              }),
            ),
          ),
          const SizedBox(height: 8),
          NotesField(
            focusNode: focusNodes[1],
            nextFocusNode: focusNodes[2],
            onSaved: (value) {
              String? notes;
              if (value != null && value.isNotEmpty) {
                notes = value;
              }
              _ticketUpdate = _ticketUpdate.copyWith(notes: notes);
            },
          ),
          const SizedBox(height: 48),
          ErrorSubmitRow(
            error: _error,
            isLoading: _isLoading,
            clearButton: ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                _formKey.currentState!.reset();
                setState(() {
                  _ticketUpdate = const TicketUpdate();
                  _error = null;
                  _isLoading = false;
                });
              },
              child: const Text('Leeren'),
            ),
            submitButton: ElevatedButton(
              focusNode: focusNodes[2],
              onPressed: () async {
                FocusScope.of(context).unfocus();
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    await ref.read(ticketsProvider(widget.id!).notifier).updateTicket(_ticketUpdate,);
                  } catch (e, s) {
                    getLogger().e('Failed to update ticket', error: e, stackTrace: s);
                    setState(() {
                      _error = e.toString();
                      _isLoading = false;
                    });
                    return;
                  }
                  setState(() {
                    _error = null;
                    _isLoading = false;
                  });
                }
              },
              child: const Text('Speichern'),
            ),
          ),

          if (ticket != null) const Divider(height: 32),
          if (ticket != null) Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TicketWidget(ticket: ticket),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Ticket löschen'),
                              content: const Text('Soll das Ticket wirklich gelöscht werden?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Abbrechen'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    try {
                                      await ref.read(ticketsProvider(widget.id!).notifier).deleteTicket();
                                    } catch (e, s) {
                                      getLogger().e('Failed to delete ticket', error: e, stackTrace: s);
                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Ticket konnte nicht gelöscht werden: ${e.toString()}'),
                                        ),
                                      );
                                      return;
                                    }
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Ticket gelöscht'),
                                      ),
                                    );
                                  },
                                  child: const Text('Löschen'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
