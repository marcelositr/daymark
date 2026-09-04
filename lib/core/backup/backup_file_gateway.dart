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
    if (Platform.isLinux) {
      try {
        final String? destination = await FilePicker.saveFile(
          dialogTitle: dialogTitle,
          fileName: suggestedName,
          type: FileType.any,
        );
        if (destination == null) {
          return false;
        }
        await sourceFile.copy(destination);
        return true;
      } on Exception {
        throw const BackupFileSelectionException();
      }
    }

    final Uint8List bytes = await sourceFile.readAsBytes();
    try {
      try {
        final String? destination = await FilePicker.saveFile(
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
    final FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(
        dialogTitle: dialogTitle,
        type: FileType.any,
        allowMultiple: false,
        withData: false,
      );
    } on Exception {
      throw const BackupFileSelectionException();
    }
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
