import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_personal_finance_app/app.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  testWidgets('Splash shows app branding', (tester) async {
    await tester.pumpWidget(ProviderScope(child: FinanceApp()));
    await tester.pump();
    expect(find.text('Finanza'), findsOneWidget);
    expect(find.textContaining('Creado por $kAppAuthor'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
