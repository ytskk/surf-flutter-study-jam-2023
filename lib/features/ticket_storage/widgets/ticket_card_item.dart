import 'dart:math';

import 'package:flutter/material.dart';

class TicketCardItem extends StatelessWidget {
  const TicketCardItem({
    super.key,
    required this.title,
    this.icon,
  });

  final String title;
  final Icon? icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon ?? Icon(_getRandomIconData()),
      title: Text(title),
    );
  }
}

IconData _getRandomIconData() {
  final icons = [
    Icons.airplane_ticket_rounded,
    Icons.train_rounded,
  ];

  return icons[Random().nextInt(icons.length)];
}
