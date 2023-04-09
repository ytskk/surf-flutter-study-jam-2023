import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surf_flutter_study_jam_2023/constants/app_strings.dart';
import 'package:surf_flutter_study_jam_2023/features/features.dart';

/// The height of the toolbar component of the [AppBar].
const double kToolbarHeight = 56.0;

class TicketsAppBar extends StatelessWidget with PreferredSizeWidget {
  const TicketsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(AppStrings.ticketsAppBarTitle),
      actions: [
        const SortOrderButton(),

        // TODO: delete
        IconButton(
          onPressed: () {
            TicketStorageController.to.removeAllTickets();
          },
          icon: Icon(Icons.delete),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SortOrderButton extends StatelessWidget {
  const SortOrderButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<TicketStorageController>(
      builder: (controller) {
        final sortOrder = controller.sortOrder.value;

        return PopupMenuButton<TicketSortOrder>(
          onSelected: (sortOrder) {
            controller.setSortOrder(sortOrder);
          },
          itemBuilder: (context) {
            return TicketSortOrder.values.map((sortOrder) {
              return PopupMenuItem<TicketSortOrder>(
                value: sortOrder,
                child: Text(
                  sortOrder.toString().split('.').last,
                ),
              );
            }).toList();
          },
          child: Row(
            children: [
              Text(
                sortOrder.toString().split('.').last,
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        );
      },
    );
  }
}
