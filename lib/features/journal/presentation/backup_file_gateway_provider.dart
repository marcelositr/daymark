import 'package:daymark/core/backup/backup_file_gateway.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<BackupFileGateway> backupFileGatewayProvider =
    Provider<BackupFileGateway>((ref) => const NativeBackupFileGateway());
