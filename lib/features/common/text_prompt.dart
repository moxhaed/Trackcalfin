import 'package:flutter/material.dart';

/// Asks for one line of text in a dialog. Returns what was typed, or null on Cancel.
///
/// The dialog owns its [TextEditingController] and disposes it in [State.dispose]. A controller
/// made by the caller and disposed right after `await showDialog` dies while the dialog is still
/// animating out: the field, losing focus as the route closes, clears the keyboard's composing
/// region and rebuilds against it, which breaks the element tree (a red screen in debug builds).
Future<String?> showTextPrompt(
  BuildContext context, {
  required String title,
  String initial = '',
  TextInputType? keyboard,
  String? prefix,
  String? suffix,
  String? hint,
  String? helper,
  bool obscure = false,
  String action = 'Save',
}) => showDialog<String>(
  context: context,
  builder: (_) => TextPromptDialog(
    title: title,
    initial: initial,
    keyboard: keyboard,
    prefix: prefix,
    suffix: suffix,
    hint: hint,
    helper: helper,
    obscure: obscure,
    action: action,
  ),
);

class TextPromptDialog extends StatefulWidget {
  const TextPromptDialog({
    super.key,
    required this.title,
    this.initial = '',
    this.keyboard,
    this.prefix,
    this.suffix,
    this.hint,
    this.helper,
    this.obscure = false,
    this.action = 'Save',
  });

  final String title;
  final String initial;
  final TextInputType? keyboard;
  final String? prefix;
  final String? suffix;
  final String? hint;
  final String? helper;
  final bool obscure;
  final String action;

  @override
  State<TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<TextPromptDialog> {
  late final _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _text,
        autofocus: true,
        obscureText: widget.obscure,
        keyboardType: widget.keyboard,
        decoration: InputDecoration(
          prefixText: widget.prefix,
          suffixText: widget.suffix,
          hintText: widget.hint,
          helperText: widget.helper,
        ),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(context).pop(_text.text), child: Text(widget.action)),
      ],
    );
  }
}
