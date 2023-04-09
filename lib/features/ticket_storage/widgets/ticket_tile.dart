import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.ticket.filename),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: _downloadStatus == TicketDownloadStatus.downloading
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: _downloadProgress.received /
                                  _downloadProgress.total,
                            ),
                            Text(
                              '${(_downloadProgress.received / 1024 / 1024).toStringAsFixed(2)} MB / ${(_downloadProgress.total / 1024 / 1024).toStringAsFixed(2)} MB',
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PDFScreen(
                  path: widget.ticket.filePath,
                  title: widget.ticket.titlename,
                ),
              ),
            );
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

class PDFScreen extends StatefulWidget {
  const PDFScreen({
    super.key,
    this.path,
    required this.title,
  });

  final String? path;
  final String title;

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation:
                false, // if set to true the link is handled in flutter
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              print(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onLinkHandler: (String? uri) {
              print('goto uri: $uri');
            },
            onPageChanged: (int? page, int? total) {
              print('page change: $page/$total');
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container()
              : Center(
                  child: Text(errorMessage),
                )
        ],
      ),
      floatingActionButton: FutureBuilder<PDFViewController>(
        future: _controller.future,
        builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
          if (snapshot.hasData) {
            return FloatingActionButton.extended(
              label: Text("Go to ${pages! ~/ 2}"),
              onPressed: () async {
                await snapshot.data!.setPage(pages! ~/ 2);
              },
            );
          }

          return Container();
        },
      ),
    );
  }
}
