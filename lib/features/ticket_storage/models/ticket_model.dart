import 'package:surf_flutter_study_jam_2023/utils/utils.dart';
import 'package:uuid/uuid.dart';

class TicketModel {
  TicketModel({
    String? id,
    this.title = '',
    required this.url,
    this.downloadStatus = TicketDownloadStatus.notDownloaded,
    DateTime? createdAt,
    this.filePath,
  })  : id = id ?? uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  static const uuid = Uuid();

  final String id;
  final String title;
  final String url;
  final TicketDownloadStatus downloadStatus;
  final DateTime createdAt;
  final String? filePath;

  // getters.
  get filename => url.split('/').last;

  get titlename {
    String name = url.split('/').last.replaceAll('.pdf', '');
    name = removeDashes(name);
    name = removeUnderscores(name);
    name = titleCase(name);

    return name;
  }

  @override
  String toString() {
    return 'TicketModel(title: $title, url: $url, downloadStatus: $downloadStatus, createdAt: $createdAt)';
  }

  TicketModel copyWith({
    String? id,
    String? title,
    String? url,
    TicketDownloadStatus? downloadStatus,
    DateTime? createdAt,
    String? filePath,
  }) {
    return TicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      createdAt: createdAt ?? this.createdAt,
      filePath: filePath ?? this.filePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'downloadStatus': downloadStatus.index,
      'createdAt': createdAt.toIso8601String(),
      'filePath': filePath ?? '',
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
      filePath: json['filePath'] as String?,
    );
  }
}

enum TicketDownloadStatus {
  notDownloaded,
  downloading,
  downloaded,
}
