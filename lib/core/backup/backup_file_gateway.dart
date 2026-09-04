import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

abstract interface class BackupFileGateway {
  Future<bool> saveBackup({
    required File sourceFile,
    required String suggestedName,
  });

  Future<File?> pickBackup();
}

final class NativeBackupFileGateway implements BackupFileGateway {
  const NativeBackupFileGateway();

  static const List<String> _extensions = <String>['daymark-backup'];

  @override
  Future<bool> saveBackup({
    required File sourceFile,
    required String suggestedName,
  }) async {
    final Uint8List bytes = await sourceFile.readAsBytes();
    final String? destination = await FilePicker.saveFile(
      dialogTitle: 'Save encrypted Daymark backup',
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: _extensions,
      bytes: bytes,
    );
    bytes.fillRange(0, bytes.length, 0);
    return destination != null;
  }

  @override
  Future<File?> pickBackup() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _extensions,
      allowMultiple: false,
      withData: false,
    );
    if (result == null) {
      return null;
    }

    final String? path = result.files.single.path;
    if (path == null || path.isEmpty) {
      throw const BackupFileSelectionException();
    }
    return File(path);
  }
}

final class BackupFileSelectionException implements Exception {
  const BackupFileSelectionException();
}
