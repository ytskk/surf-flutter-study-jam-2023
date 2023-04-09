import 'dart:developer';

import 'package:get/get.dart';
import 'package:surf_flutter_study_jam_2023/core/core.dart';
import 'package:surf_flutter_study_jam_2023/features/ticket_storage/models/ticket_model.dart';

class TicketStorageController extends GetxController {
  static TicketStorageController get to => Get.find();

  // definitions.

  final _tickets = <TicketModel>[].obs;
  final _sortOrder = TicketSortOrder.title.obs;

  // getters.

  get tickets => _tickets;
  get sortOrder => _sortOrder;

  // methods.

  void addTicket(TicketModel ticket) {
    _tickets.add(ticket);
  }

  void updateTicket(TicketModel ticket) {
    final newTickets = _tickets.map((t) {
      if (t.id == ticket.id) {
        return ticket;
      } else {
        return t;
      }
    }).toList();

    _tickets.value = newTickets;
  }

  void removeTicket(TicketModel ticket) {
    _tickets.remove(ticket);
  }

  void removeAllTickets() {
    _tickets.clear();
  }

  void setSortOrder(TicketSortOrder sortOrder) {
    _sortOrder.value = sortOrder;
  }

  @override
  void onInit() {
    super.onInit();

    _tickets.value = LocalStorageController.to.getTickets();
    // on every change of _tickets, save it to local storage.
    ever(
      _tickets,
      (data) {
        LocalStorageController.to.saveTickets(data);
        log(
          'Tickets updated, new data: $data',
          name: 'TicketStorageController::onInit::ever',
        );
      },
    );

    _sortOrder.value = LocalStorageController.to.getSortOrder();
    // on every change of _sortOrder, sort _tickets.
    ever(
      _sortOrder,
      (data) {
        LocalStorageController.to.saveSortOrder(data);
        // TODO: sort tickets.
      },
    );
  }
}

enum TicketSortOrder {
  title,
  date,
  downloadStatus,
}
