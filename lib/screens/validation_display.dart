import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_scanner/provider/qr_code_information_provider.dart';

import '../provider/ticket_validation_provider.dart';

class ValidationDisplay extends ConsumerWidget {
  const ValidationDisplay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrCodeInformation = ref.watch(qrCodeInformationProvider);
    if (qrCodeInformation == null || qrCodeInformation.code == null) {
      return const SizedBox.shrink();
    }

    //TODO: Extract ticket id from link

    AsyncValue<Ticket> ticket = ref.watch(ticketValidationProvider(qrCodeInformation.code!));
    return ticket.when(
      data: (ticket) => Column(
        children: [
          Text(ticket.ticketId),
          Text(ticket.ticketType.toString()),
          Text(ticket.isDevaluated.toString()),
          Text(ticket.isValid.toString()),
        ],
      ),
      error: (error, stackTrace) => Center(
        child: Text(error.toString()),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
