import 'package:flutter/material.dart';
import 'package:surf_flutter_study_jam_2023/constants/constants.dart';
import 'package:surf_flutter_study_jam_2023/features/features.dart';

typedef TicketAddFloatingButtonCallback = void Function(String);

class TicketAddFloatingButton extends StatelessWidget {
  const TicketAddFloatingButton({
    super.key,
    this.onTicketAdded,
  });

  final TicketAddFloatingButtonCallback? onTicketAdded;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      // Awaits bottom sheet magic. If the user has added a ticket, then
      // the response will be true. Otherwise, the response will be null.
      onPressed: () => _showAddTicketBottomSheet(context),
      label: const Text(AppStrings.addTicketButtonTitle),
      heroTag: const ValueKey('addTicketButton'),
    );
  }

  Future<void> _showAddTicketBottomSheet(context) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      builder: (_) => const TicketsAddBottomSheet(),
    );

    if (result == null) {
      return;
    }

    final url = result;

    onTicketAdded?.call(url);
  }
}
