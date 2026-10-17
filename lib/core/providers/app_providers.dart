import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:my_personal_finance_app/data/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_personal_finance_app/core/cloud/firebase_bootstrap.dart';
import 'package:my_personal_finance_app/core/cloud/firebase_user_registry.dart';
import 'package:my_personal_finance_app/core/cloud/user_registry.dart';
import 'package:my_personal_finance_app/core/services/app_lock_service.dart';
import 'package:my_personal_finance_app/core/services/auth_service.dart';
import 'package:my_personal_finance_app/domain/models/auth_user.dart';
import 'package:my_personal_finance_app/core/services/backup_service.dart';
import 'package:my_personal_finance_app/core/services/export_service.dart';
import 'package:my_personal_finance_app/domain/models/app_preferences.dart';
import 'package:my_personal_finance_app/data/repositories/finance_repository.dart';
import 'package:my_personal_finance_app/domain/models/account.dart';
import 'package:my_personal_finance_app/domain/models/analytics.dart';
import 'package:my_personal_finance_app/domain/models/budget.dart';
import 'package:my_personal_finance_app/domain/models/category.dart';
import 'package:my_personal_finance_app/domain/models/month_transaction_filter.dart';
import 'package:my_personal_finance_app/domain/models/loan.dart';
import 'package:my_personal_finance_app/domain/models/transaction.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository(ref.watch(databaseProvider));
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(ref.watch(financeRepositoryProvider));
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(financeRepositoryProvider));
});

final appLockServiceProvider = Provider<AppLockService>((ref) {
  return AppLockService();
});

final firebaseReadyProvider = FutureProvider<bool>((ref) {
  return FirebaseBootstrap.tryInitialize();
});

final userRegistryProvider = Provider<UserRegistry>((ref) {
  if (FirebaseBootstrap.isReady) {
    return FirebaseUserRegistry(FirebaseFirestore.instance);
  }
  return NoOpUserRegistry();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.watch(databaseProvider),
    userRegistry: ref.watch(userRegistryProvider),
  );
});

final currentAuthUserProvider = FutureProvider<AuthUser?>((ref) {
  return ref.watch(authServiceProvider).getCurrentUser();
});

final appPreferencesProvider = StreamProvider<AppPreferences>((ref) {
  return ref.watch(financeRepositoryProvider).watchAppPreferences();
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appPreferencesProvider).valueOrNull?.themeMode ??
      ThemeMode.dark;
});

final bootstrapProvider = FutureProvider<void>((ref) async {
  await ref.watch(financeRepositoryProvider).ensureInitialized();
});

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

final appVersionLabelProvider = Provider<String>((ref) {
  final info = ref.watch(packageInfoProvider).valueOrNull;
  if (info == null) return '…';
  return '${info.version}+${info.buildNumber}';
});

final currencyProvider = StreamProvider<String>((ref) {
  return ref.watch(financeRepositoryProvider).watchCurrencyCode();
});

final accountsProvider = StreamProvider<List<AccountModel>>((ref) {
  return ref.watch(financeRepositoryProvider).watchAccounts();
});

final transactionsProvider = StreamProvider<List<TransactionModel>>((ref) {
  return ref.watch(financeRepositoryProvider).watchRecentTransactions();
});

final monthFilteredTransactionsProvider =
    StreamProvider.family<List<TransactionModel>, MonthTransactionFilter>((ref, filter) {
  return ref.watch(financeRepositoryProvider).watchTransactionsForMonth(
        filter.month,
        isIncome: filter.isIncome,
      );
});

final categoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  return ref.watch(financeRepositoryProvider).watchCategories();
});

final selectedMonthProvider = StateProvider<DateTime>(
  (ref) {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  },
);

final monthlySummaryProvider = StreamProvider<MonthlySummary>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(financeRepositoryProvider).watchMonthlySummary(month);
});

final categoryExpensesProvider =
    StreamProvider<List<CategoryExpenseSlice>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(financeRepositoryProvider).watchCategoryExpensesForMonth(month);
});

final monthlyTrendProvider = StreamProvider<List<MonthlyTrendPoint>>((ref) {
  return ref.watch(financeRepositoryProvider).watchMonthlyTrend(months: 6);
});

final budgetProgressProvider = StreamProvider<List<BudgetProgress>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(financeRepositoryProvider).watchBudgetProgress(month);
});

final totalBalanceProvider = Provider<int>((ref) {
  final accounts = ref.watch(accountsProvider).valueOrNull ?? [];
  return accounts.fold<int>(0, (total, a) => total + a.balanceCents);
});

final loansProvider = StreamProvider<List<LoanModel>>((ref) {
  return ref.watch(financeRepositoryProvider).watchLoans();
});
