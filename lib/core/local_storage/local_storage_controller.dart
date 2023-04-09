import 'dart:convert';

import 'package:get/get.dart';
import 'package:surf_flutter_study_jam_2023/core/core.dart';
import 'package:surf_flutter_study_jam_2023/features/features.dart';

class LocalStorageController extends GetxController {
  static LocalStorageController get to => Get.find();

  LocalStorageController({
    required LocalStorageService localStorageService,
  }) : _localStorageService = localStorageService;

  final LocalStorageService _localStorageService;

  // getters.

  /// Loads tickets from local storage.
  List<TicketModel> getTickets() {
    final ticketsJson = _localStorageService.getString(
      LocalStorageKeys.tickets.name,
    );

    if (ticketsJson.isEmpty) {
      return [];
    }

    final tickets = jsonDecode(ticketsJson) as List;

    return tickets.map((ticket) => TicketModel.fromJson(ticket)).toList();
  }

  TicketSortOrder getSortOrder() {
    final sortOrder = _localStorageService.getInt(
      LocalStorageKeys.sortOrder.name,
    );

    return TicketSortOrder.values[sortOrder];
  }

  // methods.

  void saveTickets(List<TicketModel>? tickets) {
    if (tickets == null) {
      return;
    }

    final ticketsJson = jsonEncode(tickets);

    _localStorageService.setString(
      LocalStorageKeys.tickets.name,
      ticketsJson,
    );
  }

  void saveSortOrder(TicketSortOrder? sortOrder) {
    if (sortOrder == null) {
      return;
    }

    _localStorageService.setInt(
      LocalStorageKeys.sortOrder.name,
      sortOrder.index,
    );
  }
}
