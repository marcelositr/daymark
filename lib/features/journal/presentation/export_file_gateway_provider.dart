import 'package:daymark/core/export/export_file_gateway.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<ExportFileGateway> exportFileGatewayProvider =
    Provider<ExportFileGateway>((ref) => const NativeExportFileGateway());
