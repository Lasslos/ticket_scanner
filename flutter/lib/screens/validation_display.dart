import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_scanner/screens/provider/qr_code_information_provider.dart';
import 'package:ticket_scanner/core/provider/ticket_provider.dart';

class ValidationDisplay extends ConsumerWidget {
  const ValidationDisplay({
    super.key,
  });

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
        Color color;
        if (ticket.isDevaluated || !ticket.isValid) {
          color = Colors.red;
        } else {
          color = ticket.map(regular: (_) => Colors.green, reduced: (_) => Colors.yellow, volunteer: (_) => Colors.blue, unknown: (_) => Colors.red);
        }
        String text;
        if (!ticket.isValid) {
          text = "Ungültig";
        } else if (ticket.isDevaluated) {
          text = "Bereits entwertet";
        } else {
          text = ticket.map(regular: (_) => "Regulär", reduced: (_) => "Reduziert", volunteer: (_) => "Helfende Person", unknown: (_) => "Unbekannt");
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
              text,
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
