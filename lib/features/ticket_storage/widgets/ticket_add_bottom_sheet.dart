import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:surf_flutter_study_jam_2023/constants/constants.dart';
import 'package:surf_flutter_study_jam_2023/utils/utils.dart';

class TicketsAddBottomSheet extends StatefulWidget {
  const TicketsAddBottomSheet({super.key});

  @override
  State<TicketsAddBottomSheet> createState() => _TicketsAddBottomSheetState();
}

class _TicketsAddBottomSheetState extends State<TicketsAddBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  // TODO: reset validation message when the text field is changed.
  // TODO: track clipboard changes and if content is valid, show paste button.
  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
    _focusNode = FocusNode();

    // set the clipboard content to the text field and move the cursor to the end.
    _getClipboardContent().then((value) {
      if (value != null) {
        if (!validateTicketUrl(value)) {
          return;
        }

        _controller.text = value;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
    });
  }

  bool validateTicketUrl(String url) {
    return isUrlValid(url) && isUrlEndsWithPdf(url);
  }

  /// Get clipboard content if it is available. Otherwise, return null.
  Future<String?> _getClipboardContent() async {
    if (!await Clipboard.hasStrings()) {
      return null;
    }

    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);

    return clipboard?.text;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          top: 12,
          // move the bottom sheet up when the keyboard is open.
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close pill indicator.
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // input field.
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: AppStrings.addTicketHint,
                  ),
                  validator: (value) => validateTicketUrl(value!)
                      ? null
                      : AppStrings.addTicketNotValid,
                  onEditingComplete: _addTicket,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 0),
            ColoredBox(
              color: const Color(0xFFF5F5F7),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _addTicket,
                    child: const Text(AppStrings.addTicketButtonTitle),
                  ),
                  const Spacer(),
                  if (_focusNode.hasFocus)
                    IconButton(
                      onPressed: () {
                        _focusNode.unfocus();
                      },
                      icon: const Icon(Icons.keyboard_hide_outlined),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles the “Add” button click. Validates the input and pops the result
  /// to the parent widget (to show successful snackbar).
  void _addTicket() {
    if (_formKey.currentState!.validate()) {
      log('Ticket url: ${_controller.text}');
      // pop success status to the parent widget.
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }
}
