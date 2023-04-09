import 'dart:math';

import 'package:flutter/material.dart';
import 'package:surf_flutter_study_jam_2023/features/features.dart';

class TicketTile extends StatelessWidget {
  const TicketTile({
    super.key,
    required this.title,
    this.icon,
    required this.downloadStatus,
  });

  final String title;
  final Icon? icon;
  final TicketDownloadStatus downloadStatus;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon ?? Icon(_getRandomIconData()),
      title: Text(title),
      trailing: TicketStatus(
        downloadStatus: downloadStatus,
      ),
    );
  }
}

class TicketStatus extends StatelessWidget {
  const TicketStatus({
    super.key,
    required this.downloadStatus,
  });

  final TicketDownloadStatus downloadStatus;

  @override
  Widget build(BuildContext context) {
    switch (downloadStatus) {
      case TicketDownloadStatus.downloading:
        return const CircularProgressIndicator();
      case TicketDownloadStatus.downloaded:
        return const Icon(Icons.check);
      case TicketDownloadStatus.notDownloaded:
        return const Icon(Icons.download);
    }
  }
}

IconData _getRandomIconData() {
  final icons = [
    Icons.airplane_ticket_rounded,
    Icons.train_rounded,
  ];

  return icons[Random().nextInt(icons.length)];
}
