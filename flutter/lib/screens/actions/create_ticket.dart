import 'package:dartlin/control_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_scanner/core/models/ticket.dart';
import 'package:ticket_scanner/core/provider/ticket_provider.dart';
import 'package:ticket_scanner/screens/qr_code_scanner.dart';
import 'package:ticket_scanner/screens/shared/ticket_widget.dart';
import 'package:ticket_scanner/util/logger.dart';

class CreateTicket extends ConsumerStatefulWidget {
  const CreateTicket({super.key});

  @override
  ConsumerState createState() => _CreateTicketState();
}

class _CreateTicketState extends ConsumerState<CreateTicket> {
  late TextEditingController _idController;
  List<FocusNode> focusNodes = [];

  int? _id;
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
    focusNodes = List.generate(4, (_) => FocusNode());
    // Listen for id changes and update id if applicable
    focusNodes[0].addListener(() {
      if (!focusNodes[0].hasFocus) {
        String value = _idController.text;
        int.tryParse(value)?.let((it) => setState(() => _id = it));
      }
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    for (var element in focusNodes) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //A dialog with fields for id, name, type and notes
    _id?.let(
      (it) => ref.listen(
        ticketsProvider(it),
        (oldState, newState) {
          newState.when(
            data: (data) {},
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

    Ticket? ticket = _id?.let(
      (id) => ref.watch(ticketsProvider(id)).maybeWhen(
        data: (data) => data,
        orElse: () => null,
      ),
    );

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          TextFormField(
            focusNode: focusNodes[0],
            autocorrect: false,
            controller: _idController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty || int.tryParse(value) == null) {
                return 'Bitte gib eine ID ein.';
              }
              return null;
            },
            onSaved: (value) {
              _id = int.parse(value!);
            },
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(focusNodes[1]);
            },
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
                      _idController.text = newId.toString();
                    });
                  }
                },
              ),
            ),
          ),
          TextFormField(
            focusNode: focusNodes[1],
            autocorrect: false,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(focusNodes[2]);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bitte gib einen Namen ein.';
              }
              return null;
            },
            onSaved: (value) {
              _ticketCreate = _ticketCreate.copyWith(name: value!);
            },
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
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
            focusNode: focusNodes[2],
            autocorrect: true,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            textInputAction: TextInputAction.newline,
            enableSuggestions: true,
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(focusNodes[3]);
            },
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
                focusNode: focusNodes[3],
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
          if (ticket != null) const Divider(height: 32),
          if (ticket != null) Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TicketWidget(ticket: ticket),
            ),
          ),
        ],
      ),
    );
  }
}
