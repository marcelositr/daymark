import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

abstract interface class BackupFileGateway {
  Future<bool> saveBackup({
    required File sourceFile,
    required String suggestedName,
    required String dialogTitle,
  });

  Future<File?> pickBackup({required String dialogTitle});
}

final class NativeBackupFileGateway implements BackupFileGateway {
  const NativeBackupFileGateway();

  @override
  Future<bool> saveBackup({
    required File sourceFile,
    required String suggestedName,
    required String dialogTitle,
  }) async {
    final Uint8List bytes = await sourceFile.readAsBytes();
    try {
      try {
        final Uri? destination = await FilePicker.saveFile(
          dialogTitle: dialogTitle,
          fileName: suggestedName,
          type: FileType.any,
          bytes: bytes,
        );
        return destination != null;
      } on Exception {
        throw const BackupFileSelectionException();
      }
    } finally {
      bytes.fillRange(0, bytes.length, 0);
    }
  }

  @override
  Future<File?> pickBackup({required String dialogTitle}) async {
    final PlatformFile? selectedFile;
    try {
      selectedFile = await FilePicker.pickFile(
        dialogTitle: dialogTitle,
        type: FileType.any,
      );
    } on Exception {
      throw const BackupFileSelectionException();
    }
    if (selectedFile == null) {
      return null;
    }

    final String? path = selectedFile.path;
    if (path == null || path.isEmpty) {
      throw const BackupFileSelectionException();
    }
    return File(path);
  }
}

final class BackupFileSelectionException implements Exception {
  const BackupFileSelectionException();
}
