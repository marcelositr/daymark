import 'dart:convert';
import 'dart:typed_data';

import 'package:daymark/core/export/export_file_gateway.dart';
import 'package:daymark/core/export/open_export_service.dart';
import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'export_file_gateway_provider.dart';

Future<void> showOpenExportDialog(BuildContext context) async {
  final bool? saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => const OpenExportDialog(),
  );

  if (saved == true && context.mounted) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.openExportSaved)));
  }
}

final class OpenExportDialog extends ConsumerStatefulWidget {
  const OpenExportDialog({super.key});

  @override
  ConsumerState<OpenExportDialog> createState() => _OpenExportDialogState();
}

final class _OpenExportDialogState extends ConsumerState<OpenExportDialog> {
  bool _busy = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.openExportTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.openExportMessage),
            const SizedBox(height: 12),
            Text(
              l10n.openExportWarning,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        OutlinedButton(
          onPressed: _busy ? null : () => _export(OpenExportFormat.markdown),
          child: Text(l10n.exportMarkdown),
        ),
        FilledButton(
          onPressed: _busy ? null : () => _export(OpenExportFormat.json),
          child: _busy
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.exportJson),
        ),
      ],
    );
  }

  Future<void> _export(OpenExportFormat format) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _errorMessage = null;
    });

    Uint8List? bytes;
    try {
      final OpenExportDocument document = await ref
          .read(journalSessionControllerProvider.notifier)
          .createOpenExport(format: format);
      bytes = Uint8List.fromList(utf8.encode(document.contents));

      final bool saved = await ref
          .read(exportFileGatewayProvider)
          .saveExport(
            bytes: bytes,
            suggestedName: _exportFileName(DateTime.now(), format),
            dialogTitle: l10n.openExportTitle,
          );

      if (!saved) {
        if (mounted) {
          setState(() => _busy = false);
        }
        return;
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on ExportFileSelectionException {
      _setError(l10n.openExportFileSelectionFailed);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: FlutterError(
            'Open export operation failed (${error.runtimeType}).',
          ),
          stack: stackTrace,
          library: 'daymark',
        ),
      );
      _setError(l10n.openExportFailed);
    } finally {
      bytes?.fillRange(0, bytes.length, 0);
    }
  }

  void _setError(String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _errorMessage = message;
    });
  }
}

String _exportFileName(DateTime dateTime, OpenExportFormat format) {
  final DateTime utc = dateTime.toUtc();
  String twoDigits(int value) => value.toString().padLeft(2, '0');

  return 'daymark-open-export-'
      '${utc.year.toString().padLeft(4, '0')}'
      '${twoDigits(utc.month)}'
      '${twoDigits(utc.day)}T'
      '${twoDigits(utc.hour)}'
      '${twoDigits(utc.minute)}'
      '${twoDigits(utc.second)}Z.'
      '${format.extension}';
}
