import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:my_personal_finance_app/data/repositories/finance_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  BackupService(this._repository);

  final FinanceRepository _repository;

  Future<void> shareBackup() async {
    final payload = await _repository.exportBackupPayload();
    final json = const JsonEncoder.withIndent('  ').convert(payload);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/finanza_backup.json');
    await file.writeAsString(json);

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(
            file.path,
            mimeType: 'application/json',
            name: 'finanza_backup.json',
          ),
        ],
        subject: 'Respaldo Finanza',
        text: 'Copia de seguridad de tus datos locales',
      ),
    );
  }

  Future<bool> importBackupFromPicker() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (files.isEmpty) return false;

    final picked = files.first;
    final bytes = await picked.readAsBytes();

    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Archivo de respaldo inválido');
    }

    await _repository.importBackupPayload(decoded);
    return true;
  }
}
