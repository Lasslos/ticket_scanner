import 'package:dartlin/control_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_scanner/core/models/ticket.dart';
import 'package:ticket_scanner/core/provider/ticket_provider.dart';
import 'package:ticket_scanner/screens/shared/form_fields.dart';
import 'package:ticket_scanner/screens/shared/ticket_widget.dart';
import 'package:ticket_scanner/util/logger.dart';

class CreateTicket extends ConsumerStatefulWidget {
  final int? id;

  const CreateTicket({required this.id, super.key});

  @override
  ConsumerState createState() => _CreateTicketState();
}

class _CreateTicketState extends ConsumerState<CreateTicket> {
  List<FocusNode> focusNodes = [];

  TicketCreate _ticketCreate = const TicketCreate(
    name: '',
    type: TicketType.student,
    notes: null,
  );
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
      (id) => ref.watch(ticketsProvider(id)).maybeWhen(
        data: (data) => data,
        orElse: () => null,
      ),
    );

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ticket == null) ...[
            NameField(
              focusNode: focusNodes[0],
              nextFocusNode: focusNodes[1],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte gib einen Namen ein.';
                }
                return null;
              },
              onSaved: (value) {
                _ticketCreate = _ticketCreate.copyWith(name: value!);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TicketTypeSelection(
                selected: _ticketCreate.type,
                onSelectionChanged: (selected) => setState(() {
                  _ticketCreate = _ticketCreate.copyWith(type: selected!);
                }),
              ),
            ),
            const SizedBox(height: 8),
            NotesField(
              focusNode: focusNodes[1],
              nextFocusNode: focusNodes[2],
              onSaved: (value) {
                _ticketCreate = _ticketCreate.copyWith(notes: value);
              },
            ),
            const SizedBox(height: 32),
            ErrorSubmitRow(
              error: _error,
              isLoading: _isLoading,
              submitButton: FilledButton(
                focusNode: focusNodes[2],
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  if (_formKey.currentState!.validate() && widget.id != null) {
                    _formKey.currentState!.save();
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      await ref.read(ticketsProvider(widget.id!).notifier).createTicket(_ticketCreate);
                    } catch (e, s) {
                      getLogger().e('Failed to create ticket', error: e, stackTrace: s);
                      setState(() {
                        _error = e.toString();
                        _isLoading = false;
                      });
                      return;
                    }
                    _formKey.currentState!.reset();
                    setState(() {
                      _ticketCreate = const TicketCreate(name: '', type: TicketType.student, notes: null);
                      _error = null;
                      _isLoading = false;
                    });
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 3),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        content: const Text('Ticket erstellt', style: TextStyle(color: Colors.white)),
                        action: SnackBarAction(
                          label: 'Ok',
                          textColor: Colors.white,
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          },
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Verkaufen'),
              ),
            ),
          ],
          if (ticket != null) ...[
            const SizedBox(height: 16),
            Text("Ticket ${ticket.id} wurde erfolreich erstellt.", style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TicketWidget(ticket: ticket),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
