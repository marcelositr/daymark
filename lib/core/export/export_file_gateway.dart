import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

abstract interface class ExportFileGateway {
  Future<bool> saveExport({
    required Uint8List bytes,
    required String suggestedName,
    required String dialogTitle,
  });
}

final class NativeExportFileGateway implements ExportFileGateway {
  const NativeExportFileGateway();

  @override
  Future<bool> saveExport({
    required Uint8List bytes,
    required String suggestedName,
    required String dialogTitle,
  }) async {
    try {
      final Uri? destination = await FilePicker.saveFile(
        dialogTitle: dialogTitle,
        fileName: suggestedName,
        type: FileType.any,
        bytes: bytes,
      );
      return destination != null;
    } on Exception {
      throw const ExportFileSelectionException();
    }
  }
}

final class ExportFileSelectionException implements Exception {
  const ExportFileSelectionException();
}
