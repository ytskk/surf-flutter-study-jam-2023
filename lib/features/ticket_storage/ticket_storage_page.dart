import 'dart:async';

import 'package:flutter/material.dart';
import 'package:surf_flutter_study_jam_2023/constants/constants.dart';
import 'package:surf_flutter_study_jam_2023/features/features.dart';

class TicketStoragePage extends StatelessWidget {
  const TicketStoragePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TicketsAppBar(),
      floatingActionButton: TicketAddFloatingButton(),
      body: Scrollbar(
        child: ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) => TicketCardItem(
            title: 'Ticket $index',
          ),
        ),
      ),
    );
  }
}

class TicketAddFloatingButton extends StatelessWidget {
  const TicketAddFloatingButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      // Awaits bottom sheet magic. If the user has added a ticket, then
      // the response will be true. Otherwise, the response will be null.
      onPressed: () => _showAddTicketBottomSheet(context),
      label: const Text(AppStrings.addTicketButtonTitle),
    );
  }

  Future<void> _showAddTicketBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => const TicketsAddBottomSheet(),
    );

    if (result == null) {
      return;
    }

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.ticketAddedMessage),
        ),
      );
    }
  }
}
