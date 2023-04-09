import 'package:flutter/material.dart';

/// The height of the toolbar component of the [AppBar].
const double kToolbarHeight = 56.0;

class TicketsAppBar extends StatelessWidget with PreferredSizeWidget {
  const TicketsAppBar({super.key});

  static const _ticketsStorageAppBarTitle = 'Хранение билетов';

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(_ticketsStorageAppBarTitle),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
