import 'package:uuid/uuid.dart';

class TicketModel {
  TicketModel({
    String? id,
    this.title = '',
    required this.url,
    this.downloadStatus = TicketDownloadStatus.notDownloaded,
    DateTime? createdAt,
  })  : id = id ?? uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  static const uuid = Uuid();

  final String id;
  final String title;
  final String url;
  final TicketDownloadStatus downloadStatus;
  final DateTime createdAt;

  TicketModel copyWith({
    String? id,
    String? title,
    String? url,
    TicketDownloadStatus? downloadStatus,
    DateTime? createdAt,
  }) {
    return TicketModel(
      title: title ?? this.title,
      url: url ?? this.url,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'downloadStatus': downloadStatus.index,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      downloadStatus:
          TicketDownloadStatus.values[json['downloadStatus'] as int],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

enum TicketDownloadStatus {
  notDownloaded,
  downloading,
  downloaded,
}
