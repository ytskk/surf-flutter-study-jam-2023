class TicketModel {
  const TicketModel({
    required this.id,
    required this.title,
    required this.url,
    this.downloadStatus = TicketDownloadStatus.notDownloaded,
  });

  final String id;
  final String title;
  final String url;
  final TicketDownloadStatus downloadStatus;

  TicketModel copyWith({
    String? id,
    String? title,
    String? url,
    TicketDownloadStatus? downloadStatus,
  }) {
    return TicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      downloadStatus: downloadStatus ?? this.downloadStatus,
    );
  }
}

enum TicketDownloadStatus {
  notDownloaded,
  downloading,
  downloaded,
}
