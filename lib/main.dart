import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_personal_finance_app/app.dart';
import 'package:my_personal_finance_app/core/cloud/firebase_bootstrap.dart';
import 'package:my_personal_finance_app/core/services/loan_notification_service.dart';
import 'package:my_personal_finance_app/core/widgets/app_lock_lifecycle.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Permite descargar Plus Jakarta Sans en runtime si no está en assets.
  GoogleFonts.config.allowRuntimeFetching = true;
  runApp(
    ProviderScope(
      child: AppLockLifecycle(child: FinanceApp()),
    ),
  );
  unawaited(initializeDateFormatting('es', null));
  unawaited(FirebaseBootstrap.tryInitialize());
  unawaited(LoanNotificationService.instance.ensureInitialized());
}
