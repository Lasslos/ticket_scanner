import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_scanner/provider/qr_code_information_provider.dart';
import 'package:ticket_scanner/provider/ticket_provider.dart';

class ValidationDisplay extends ConsumerWidget {
  const ValidationDisplay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var qrCodeInformation = ref.watch(qrCodeInformationProvider.select((value) => value?.code));
    if (qrCodeInformation == null) {
      return const SizedBox.shrink();
    }

    qrCodeInformation = qrCodeInformation.split('?').last;

    AsyncValue<Ticket> ticket = ref.watch(ticketValidationProvider(qrCodeInformation));

    return ticket.when(
      data: (ticket) {
        IconData icon = ticket.isValid && !ticket.isDevaluated ? Icons.check_circle : Icons.error;
        Color color = ticket.isValid && !ticket.isDevaluated
            ? ticket.ticketType.color
            : Colors.red;
        String text;
        if (!ticket.isValid) {
          text = "Ungültig";
        } else if (ticket.isDevaluated) {
          text = "Bereits entwertet";
        } else {
          text = ticket.ticketType.displayName;
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
                const SizedBox(
                  width: 12,
                ),
                Text(
                  text,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),

            if (ticket.isValid && ticket.isDevaluated) Text(
              ticket.ticketType.displayName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
              ),
            ),
          ],
        );
      },
      error: (error, stackTrace) => Center(
        child: Text(error.toString()),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
