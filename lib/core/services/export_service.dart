import 'dart:io';

import 'package:intl/intl.dart';
import 'package:my_personal_finance_app/core/utils/money_format.dart';
import 'package:my_personal_finance_app/data/repositories/finance_repository.dart';
import 'package:my_personal_finance_app/domain/models/transaction.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  ExportService(this._repository);

  final FinanceRepository _repository;

  /// Comparte CSV; el usuario puede abrirlo con Google Sheets desde el menú compartir.
  Future<void> shareTransactionsCsv({String currencyCode = 'PEN'}) async {
    final transactions = await _repository.getAllTransactionsForExport();
    final csv = _buildCsv(transactions, currencyCode);
    final dir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/finanza_movimientos_$stamp.csv');
    await file.writeAsString(csv);

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(
            file.path,
            mimeType: 'text/csv',
            name: file.uri.pathSegments.last,
          ),
        ],
        subject: 'Exportación Finanza',
        text: 'Movimientos exportados desde Finanza',
      ),
    );
  }

  Future<void> shareTransactionsForGoogleSheets({
    String currencyCode = 'PEN',
  }) async {
    final transactions = await _repository.getAllTransactionsForExport();
    final csv = _buildCsv(transactions, currencyCode);
    final dir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/finanza_sheets_$stamp.csv');
    await file.writeAsString(csv);

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(
            file.path,
            mimeType: 'text/csv',
            name: file.uri.pathSegments.last,
          ),
        ],
        subject: 'Finanza → Google Sheets',
        text:
            'Abre este archivo con Google Sheets (o Excel). '
            'Tus datos no se suben a servidores de Finanza.',
      ),
    );
  }

  String _buildCsv(List<TransactionModel> transactions, String currencyCode) {
    final buffer = StringBuffer('fecha,tipo,categoria,cuenta,monto,moneda,nota\n');
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (final t in transactions) {
      final type = t.isIncome ? 'ingreso' : 'gasto';
      final amount = MoneyFormat.format(t.amountCents, currencyCode: currencyCode);
      buffer.writeln(
        '${dateFormat.format(t.date)},'
        '$type,'
        '"${t.categoryName ?? ''}",'
        '"${t.accountName ?? ''}",'
        '$amount,'
        '$currencyCode,'
        '"${t.note.replaceAll('"', '""')}"',
      );
    }
    return buffer.toString();
  }
}
