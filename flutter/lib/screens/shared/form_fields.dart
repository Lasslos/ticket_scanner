import 'package:flutter/material.dart';
import 'package:ticket_scanner/core/models/ticket.dart';

// Builds a TextFormField suitable for name imput.
// Takes a focusNode of the textField, a focusNode of the next form field,
// and a validate and an onSaved function.
class NameField extends StatelessWidget {
  final FocusNode focusNode;
  final FocusNode nextFocusNode;
  final String? Function (String?)? validator;
  final Function (String?)? onSaved;

  const NameField({
    required this.focusNode,
    required this.nextFocusNode,
    required this.validator,
    required this.onSaved,
    super.key,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    focusNode: focusNode,
    autocorrect: false,
    keyboardType: TextInputType.name,
    textInputAction: TextInputAction.next,
    onEditingComplete: () {
      FocusScope.of(context).requestFocus(nextFocusNode);
    },
    validator: validator,
    onSaved: onSaved,
    decoration: const InputDecoration(
      labelText: 'Name',
    ),
  );
}


// Builds a TextFormField suitable for ticket type selection.
// Takes a selected ticket type, a function to call when the selection changes,
// and a bool to allow the selection of no ticket.
class TicketTypeSelection extends StatelessWidget {
  final TicketType? selected;
  final Function (TicketType?) onSelectionChanged;
  final bool allowNone;

  const TicketTypeSelection({
    required this.selected,
    required this.onSelectionChanged,
    this.allowNone = false,
    super.key,
  }) : assert(allowNone || selected != null, "Selected must not be null if allowNone is false");

  @override
  Widget build(BuildContext context) {
    final List<ButtonSegment<TicketType?>> segments = [
      if (allowNone) const ButtonSegment(
        value: null,
        icon: Icon(Icons.remove),
        label: Text('Keine Änderung'),
      ),
      ...TicketType.values.map(
            (type) => ButtonSegment(
          value: type,
          icon: Icon(type.icon),
          label: Text(type.name),
        ),
      ),
    ];
    return SegmentedButton(
      segments: segments,
      selected: { selected },
      onSelectionChanged: (selection) {
        onSelectionChanged(selection.first);
      },
    );
  }
}

// Builds a TextFormField suitable for notes imput.
// Takes a focusNode of the textField, a focusNode of the next form field,
// and an onSaved function.
class NotesField extends StatelessWidget {
  final FocusNode focusNode;
  final FocusNode nextFocusNode;
  final Function (String?)? onSaved;

  const NotesField({
    required this.focusNode,
    required this.nextFocusNode,
    required this.onSaved,
    super.key,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
      focusNode: focusNode,
      autocorrect: true,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      textInputAction: TextInputAction.newline,
      enableSuggestions: true,
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(nextFocusNode);
      },
      decoration: const InputDecoration(
        labelText: 'Notizen',
      ),
      onSaved: onSaved,
  );
}


// Builds a TextFormField suitable for ticket price input.
// Takes a focusNode of the textField, a focusNode of the next form field,
// and a validate and an onSaved function.
class ErrorSubmitRow extends StatelessWidget {
  final String? error;
  final bool isLoading;
  final Widget? clearButton;
  final Widget submitButton;

  const ErrorSubmitRow({
    required this.submitButton,
    required this.error,
    required this.isLoading,
    this.clearButton,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (error != null && !isLoading) Expanded(
        child: Text(
          error!,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.error),
        ),
      ),
      if (isLoading) const Expanded(child: LinearProgressIndicator()),
      const Spacer(),
      if (clearButton != null) clearButton!,
      if (clearButton != null) const SizedBox(width: 8),
      submitButton,
    ],
  );
}
