import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:surf_flutter_study_jam_2023/features/features.dart';

class TicketTile extends StatefulWidget {
  const TicketTile({
    super.key,
    required this.ticket,
  });

  final TicketModel ticket;

  @override
  State<TicketTile> createState() => _TicketTileState();
}

class _TicketTileState extends State<TicketTile> {
  late TicketDownloadStatus _downloadStatus;
  DownloadProgress _downloadProgress = const DownloadProgress.empty();

  @override
  void initState() {
    super.initState();

    _downloadStatus = widget.ticket.downloadStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(widget.ticket.filename),
          ),
          const SizedBox(width: 16),
          _buildTrailing(),
        ],
      ),
    );
  }

  Widget _buildTrailing() {
    switch (_downloadStatus) {
      case TicketDownloadStatus.downloading:
        return const CircularProgressIndicator();
      case TicketDownloadStatus.downloaded:
        return IconButton(
          onPressed: () {
            // TODO: open pdf
          },
          icon: const Icon(Icons.arrow_forward_ios_rounded),
        );
      case TicketDownloadStatus.notDownloaded:
        return IconButton(
          onPressed: _downloadPdf,
          icon: const Icon(Icons.cloud_download_outlined),
        );
    }
  }

  void _downloadPdf() async {
    setState(() {
      _downloadStatus = TicketDownloadStatus.downloading;
    });

    try {
      await downloadPdfInIsolate(widget.ticket.url, widget.ticket.filename)
          .forEach(
        (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );

      setState(() {
        _downloadStatus = TicketDownloadStatus.downloaded;
      });
      final newTicket = widget.ticket.copyWith(
        id: widget.ticket.id,
        downloadStatus: TicketDownloadStatus.downloaded,
        filePath: _downloadProgress.filePath,
      );
      TicketStorageController.to.updateTicket(
        newTicket,
      );
    } catch (e) {
      setState(() {
        _downloadStatus = TicketDownloadStatus.notDownloaded;
      });
    }
  }
}

class DownloadPdfMessage {
  const DownloadPdfMessage({
    required this.url,
    required this.filename,
    required this.progressSendPort,
  });

  final String filename;
  final SendPort progressSendPort;
  final String url;
}

void _downloadPdfEntryPoint(SendPort sendPortToMainIsolate) {
  final responsePort = ReceivePort();
  sendPortToMainIsolate.send(responsePort.sendPort);

  responsePort.listen((message) {
    if (message is Map) {
      _downloadPdf(
        message['url'],
        message['filePath'],
        message['progressSendPort'],
      );
    }
  });
}

Future<void> _downloadPdf(
  url,
  filePath,
  progressSendPort,
) async {
  final dio = Dio();

  log(
    'Downloading pdf from $url to $filePath',
    name: 'DownloadPdfMessage::_downloadPdf',
  );

  await dio.download(
    url,
    filePath,
    onReceiveProgress: (count, total) {
      progressSendPort.send(
        {
          'received': count,
          'total': total,
        },
      );
    },
  );

  progressSendPort.send(0);
}

Stream<DownloadProgress> downloadPdfInIsolate(
    String url, String filename) async* {
  final mainToIsolateStream = ReceivePort();
  final isolate = await Isolate.spawn(
    _downloadPdfEntryPoint,
    mainToIsolateStream.sendPort,
  );
  final completer = Completer<SendPort>();

  mainToIsolateStream.listen((message) {
    if (message is SendPort) {
      completer.complete(message);
    }
  });
  final isolateToMainStream = await completer.future;

  final progressPort = ReceivePort();
  final tempDir = await getApplicationDocumentsDirectory();

  isolateToMainStream.send({
    'url': url,
    'filePath': '${tempDir.path}/$filename',
    'progressSendPort': progressPort.sendPort,
  });

  await for (final message in progressPort) {
    if (message is Map) {
      yield DownloadProgress(
        received: message['received'],
        total: message['total'],
        // Very bad but its 19:10, baby ;-)
        filePath: '${tempDir.path}/$filename',
      );
    }
    if (message == 0) {
      break;
    }
  }
}

class DownloadProgress {
  const DownloadProgress({
    required this.received,
    required this.total,
    required this.filePath,
  });

  const DownloadProgress.empty()
      : received = 0,
        total = -1,
        filePath = '';

  final int received;
  final int total;
  final String filePath;
}
