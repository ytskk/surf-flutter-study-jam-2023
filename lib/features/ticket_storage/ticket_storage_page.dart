import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surf_flutter_study_jam_2023/features/features.dart';

class TicketStoragePage extends StatelessWidget {
  const TicketStoragePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TicketsAppBar(),
      floatingActionButton: TicketAddFloatingButton(
        onTicketAdded: _onTicketAdded,
      ),
      body: Scrollbar(
        child: GetX<TicketStorageController>(
          init: TicketStorageController(),
          builder: (controller) {
            final tickets = controller.tickets.value;

            return TicketsList(tickets: tickets);
          },
        ),
      ),
    );
  }

  void _onTicketAdded(ticketUrl) {
    final ticket = TicketModel(
      url: ticketUrl,
    );
    TicketStorageController.to.addTicket(ticket);
  }
}

class TicketsList extends StatelessWidget {
  const TicketsList({
    super.key,
    required this.tickets,
  });

  final List<TicketModel> tickets;

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return const Center(
        child: Text('No tickets'),
      );
    }

    return ListView.builder(
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];

        return TicketTile(
          key: ValueKey(ticket.id),
          title: ticket.url,
          downloadStatus: ticket.downloadStatus,
        );
      },
    );
  }
}
