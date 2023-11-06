import 'package:dartlin/control_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_scanner/core/models/ticket.dart';
import 'package:ticket_scanner/core/provider/ticket_provider.dart';
import 'package:ticket_scanner/screens/qr_code_scanner.dart';
import 'package:ticket_scanner/util/logger.dart';

class CreateTicket extends ConsumerStatefulWidget {
  const CreateTicket({super.key});

  @override
  ConsumerState createState() => _CreateTicketState();
}

class _CreateTicketState extends ConsumerState<CreateTicket> {
  int? _id;
  TextEditingController? _idController;
  TicketCreate _ticketCreate = const TicketCreate(
    name: '',
    type: TicketType.student,
    notes: null,
  );
  final _formKey = GlobalKey<FormState>();
  String? _error;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    //A dialog with fields for id, name, type and notes
    _id?.let(
      (it) => ref.listen(
        ticketsProvider(it),
        (oldState, newState) {
          newState.when(
            data: (data) {
              setState(() {
                isLoading = false;
                _error = null;
                _id=null;
                _idController!.text = "";
                _ticketCreate = const TicketCreate(
                  name: '',
                  type: TicketType.student,
                  notes: null,
                );
                _formKey.currentState!.reset();
              });
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ticket ${data!.name} wurde in der Datenbank gespeichert.'),
                  showCloseIcon: true,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            error: (err, stack) {
              setState(() {
                isLoading = false;
                _error = newState.error.toString();
              });
            },
            loading: () {
              setState(() {
                isLoading = true;
                _error = null;
              });
            },
          );
        }
      ),
    );

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'ID',
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_2),
                onPressed: () async {
                  final scanData = await showScanDialog(context);
                  if (scanData == null) {
                    return;
                  }
                  int? newId = scanData.code?.let((it) => int.tryParse(it));
                  if (newId != null) {
                    setState(() {
                      _idController!.text = newId.toString();
                    });
                  }
                },
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty || int.tryParse(value) == null) {
                return 'Bitte gib eine ID ein.';
              }
              return null;
            },
            onSaved: (value) {
              _id = int.parse(value!);
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
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
            child: SegmentedButton(
              segments: TicketType.values.map(
                (type) => ButtonSegment(
                  value: type,
                  icon: Icon(type.icon),
                  label: Text(type.name),
                ),
              ).toList(),
              selected: { _ticketCreate.type },
              onSelectionChanged: (selection) {
                setState(() {
                  _ticketCreate = _ticketCreate.copyWith(type: selection.first);
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Notizen',
            ),
            onSaved: (value) {
              _ticketCreate = _ticketCreate.copyWith(notes: value);
            },
          ),
          const SizedBox(height: 48),

          Row(
            children: [
              if (_error != null && !isLoading) SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(
                  _error!,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ),
              if (isLoading) const LinearProgressIndicator(),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    try {
                      await ref.read(ticketsProvider(_id!).notifier).createTicket(_ticketCreate);
                    } catch (e, s) {
                      getLogger().e('Failed to create ticket', error: e, stackTrace: s);
                      setState(() {
                        _error = e.toString();
                      });
                      return;
                    }
                    setState(() {
                      _error = null;
                    });
                  }
                },
                child: const Text('Verkaufen'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
