import 'package:drift/drift.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';
import 'package:my_personal_finance_app/core/constants/peruvian_digital_wallets.dart';
import 'package:my_personal_finance_app/data/database/app_database.dart';
import 'package:my_personal_finance_app/data/seed/default_seed.dart';
import 'package:my_personal_finance_app/domain/models/account.dart';
import 'package:my_personal_finance_app/domain/models/card_kind.dart';
import 'package:my_personal_finance_app/domain/models/card_network.dart';
import 'package:my_personal_finance_app/domain/models/analytics.dart';
import 'package:my_personal_finance_app/domain/models/app_preferences.dart';
import 'package:my_personal_finance_app/domain/models/budget.dart';
import 'package:my_personal_finance_app/domain/models/category.dart';
import 'package:my_personal_finance_app/domain/models/loan.dart';
import 'package:my_personal_finance_app/domain/models/transaction.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class FinanceRepository {
  FinanceRepository(this._db);

  final AppDatabase _db;
  bool _seeded = false;

  Future<void> ensureInitialized() async {
    if (_seeded) return;
    await seedDatabaseIfEmpty(_db);
    _seeded = true;
  }

  /// Borra cuentas, movimientos, presupuestos y categorías; restaura datos por defecto.
  Future<void> resetAllUserData() async {
    await _db.transaction(() async {
      await _db.delete(_db.transactions).go();
      await _db.delete(_db.budgets).go();
      await _db.delete(_db.loans).go();
      await _db.delete(_db.accounts).go();
      await _db.delete(_db.categories).go();
      await _db.delete(_db.appSettings).go();
    });
    await seedAfterUserReset(_db);
  }

  Stream<String> watchCurrencyCode() {
    return (_db.select(_db.appSettings)..where((t) => t.id.equals(1)))
        .watchSingleOrNull()
        .map((row) => row?.currencyCode ?? kDefaultCurrencyCode);
  }

  Future<void> setCurrencyCode(String code) async {
    await updateAppPreferences(currencyCode: code);
  }

  Stream<AppPreferences> watchAppPreferences() {
    return (_db.select(_db.appSettings)..where((t) => t.id.equals(1)))
        .watchSingleOrNull()
        .map(_mapPreferences);
  }

  Future<AppPreferences> getAppPreferences() async {
    final row = await (_db.select(_db.appSettings)..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    return _mapPreferences(row);
  }

  Future<void> updateAppPreferences({
    String? currencyCode,
    AppThemePreference? themePreference,
    bool? onboardingCompleted,
    bool? appLockEnabled,
  }) async {
    final current = await getAppPreferences();
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion(
            id: const Value(1),
            currencyCode: Value(currencyCode ?? current.currencyCode),
            themeMode: Value(
              _themeToString(themePreference ?? current.themePreference),
            ),
            onboardingCompleted: Value(
              onboardingCompleted ?? current.onboardingCompleted,
            ),
            appLockEnabled: Value(appLockEnabled ?? current.appLockEnabled),
          ),
        );
  }

  AppPreferences _mapPreferences(AppSetting? row) {
    if (row == null) {
      return const AppPreferences(
        currencyCode: kDefaultCurrencyCode,
        themePreference: AppThemePreference.dark,
        onboardingCompleted: false,
        appLockEnabled: false,
      );
    }
    return AppPreferences(
      currencyCode: row.currencyCode,
      themePreference: _parseTheme(row.themeMode),
      onboardingCompleted: row.onboardingCompleted,
      appLockEnabled: row.appLockEnabled,
    );
  }

  AppThemePreference _parseTheme(String value) {
    return AppThemePreference.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppThemePreference.dark,
    );
  }

  String _themeToString(AppThemePreference preference) => preference.name;

  Future<Map<String, dynamic>> exportBackupPayload() async {
    final accounts = await _db.select(_db.accounts).get();
    final categories = await _db.select(_db.categories).get();
    final transactions = await _db.select(_db.transactions).get();
    final budgets = await _db.select(_db.budgets).get();
    final settings = await getAppPreferences();

    return {
      'backupVersion': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': {
        'currencyCode': settings.currencyCode,
        'themeMode': settings.themePreference.name,
        'onboardingCompleted': settings.onboardingCompleted,
        'appLockEnabled': settings.appLockEnabled,
      },
      'accounts': accounts.map((a) => a.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'budgets': budgets.map((b) => b.toJson()).toList(),
    };
  }

  Future<void> importBackupPayload(Map<String, dynamic> payload) async {
    await _db.transaction(() async {
      await _db.delete(_db.transactions).go();
      await _db.delete(_db.budgets).go();
      await _db.delete(_db.accounts).go();
      await _db.delete(_db.categories).go();

      final categories = payload['categories'] as List<dynamic>? ?? [];
      for (final raw in categories) {
        final map = Map<String, dynamic>.from(raw as Map);
        await _db.into(_db.categories).insert(
              CategoriesCompanion.insert(
                id: map['id'] as String,
                name: map['name'] as String,
                iconCodePoint: map['iconCodePoint'] as int,
                isExpense: Value(map['isExpense'] as bool? ?? true),
              ),
            );
      }

      final accounts = payload['accounts'] as List<dynamic>? ?? [];
      for (final raw in accounts) {
        final map = Map<String, dynamic>.from(raw as Map);
        await _db.into(_db.accounts).insert(
              AccountsCompanion.insert(
                id: map['id'] as String,
                name: map['name'] as String,
                type: map['type'] as String,
                initialBalanceCents: Value(
                  map['initialBalanceCents'] as int? ?? 0,
                ),
                colorValue: map['colorValue'] as int,
                bankId: Value(map['bankId'] as String?),
                cardKind: Value(map['cardKind'] as String?),
                cardNetwork: Value(map['cardNetwork'] as String?),
              ),
            );
      }

      final budgets = payload['budgets'] as List<dynamic>? ?? [];
      for (final raw in budgets) {
        final map = Map<String, dynamic>.from(raw as Map);
        await _db.into(_db.budgets).insert(
              BudgetsCompanion.insert(
                id: map['id'] as String,
                categoryId: map['categoryId'] as String,
                year: map['year'] as int,
                month: map['month'] as int,
                limitCents: map['limitCents'] as int,
              ),
            );
      }

      final transactions = payload['transactions'] as List<dynamic>? ?? [];
      for (final raw in transactions) {
        final map = Map<String, dynamic>.from(raw as Map);
        await _db.into(_db.transactions).insert(
              TransactionsCompanion.insert(
                id: map['id'] as String,
                accountId: map['accountId'] as String,
                categoryId: map['categoryId'] as String,
                amountCents: map['amountCents'] as int,
                isIncome: map['isIncome'] as bool,
                date: DateTime.parse(map['date'] as String),
                note: Value(map['note'] as String? ?? ''),
                createdAt: DateTime.parse(map['createdAt'] as String),
              ),
            );
      }

      final settings = payload['settings'] as Map<String, dynamic>?;
      if (settings != null) {
        await updateAppPreferences(
          currencyCode: settings['currencyCode'] as String?,
          themePreference: settings['themeMode'] != null
              ? _parseTheme(settings['themeMode'] as String)
              : null,
          onboardingCompleted: settings['onboardingCompleted'] as bool?,
          appLockEnabled: settings['appLockEnabled'] as bool?,
        );
      }
    });
  }

  Stream<List<AccountModel>> watchAccounts() {
    return Stream.multi((controller) async {
      Future<void> emitAccounts() async {
        controller.add(await _loadAccounts());
      }

      final accountsSub = _db.select(_db.accounts).watch().listen((_) {
        emitAccounts();
      });
      final txSub = _db.select(_db.transactions).watch().listen((_) {
        emitAccounts();
      });

      await emitAccounts();

      controller.onCancel = () async {
        await accountsSub.cancel();
        await txSub.cancel();
      };
    });
  }

  Future<List<AccountModel>> _loadAccounts() async {
    final accounts = await _db.select(_db.accounts).get();
    final txs = await _db.select(_db.transactions).get();
    return accounts.map((account) {
      final delta = txs.where((t) => t.accountId == account.id).fold<int>(
            0,
            (sum, t) => sum + (t.isIncome ? t.amountCents : -t.amountCents),
          );
      final normalized = AccountTypeDisplay.normalizeFromStorage(
        typeKey: account.type,
        providerId: account.bankId,
      );
      return AccountModel(
        id: account.id,
        name: account.name,
        type: normalized.type,
        initialBalanceCents: account.initialBalanceCents,
        colorValue: account.colorValue,
        bankId: normalized.providerId,
        cardKind: normalized.type == AccountType.card
            ? CardKind.fromStorage(account.cardKind)
            : null,
        cardNetwork: normalized.type == AccountType.card
            ? CardNetwork.fromStorage(account.cardNetwork)
            : null,
        balanceCents: account.initialBalanceCents + delta,
      );
    }).toList();
  }

  Stream<List<TransactionModel>> watchRecentTransactions({int limit = 50}) {
    final query = _db.select(_db.transactions)
      ..orderBy([(t) => OrderingTerm.desc(t.date)])
      ..limit(limit);

    return query.watch().asyncMap((rows) => _mapTransactions(rows));
  }

  Stream<List<TransactionModel>> watchTransactionsForMonth(
    DateTime month, {
    bool? isIncome,
  }) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);

    return _db.select(_db.transactions)
        .watch()
        .asyncMap((rows) async {
      final filtered = rows.where((t) {
        if (t.date.isBefore(start) || !t.date.isBefore(end)) return false;
        if (isIncome != null && t.isIncome != isIncome) return false;
        return true;
      }).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return _mapTransactions(filtered);
    });
  }

  Stream<MonthlySummary> watchMonthlySummary(DateTime month) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);

    return _db.select(_db.transactions).watch().map((rows) {
      final inMonth = rows.where(
        (t) => !t.date.isBefore(start) && t.date.isBefore(end),
      );
      var income = 0;
      var expense = 0;
      for (final t in inMonth) {
        if (t.isIncome) {
          income += t.amountCents;
        } else {
          expense += t.amountCents;
        }
      }
      return MonthlySummary(
        incomeCents: income,
        expenseCents: expense,
        month: start,
      );
    });
  }

  Stream<List<CategoryModel>> watchCategories({bool? expenseOnly}) {
    final query = _db.select(_db.categories);
    return query.watch().map((rows) {
      var list = rows
          .map(
            (c) => CategoryModel(
              id: c.id,
              name: c.name,
              iconCodePoint: c.iconCodePoint,
              isExpense: c.isExpense,
            ),
          )
          .toList();
      if (expenseOnly != null) {
        list = list.where((c) => c.isExpense == expenseOnly).toList();
      }
      return list;
    });
  }

  Stream<List<BudgetProgress>> watchBudgetProgress(DateTime month) {
    final year = month.year;
    final monthNum = month.month;

    return Stream.multi((controller) async {
      Future<void> emitProgress() async {
        controller.add(await _loadBudgetProgress(year, monthNum));
      }

      final budgetSub = _db.select(_db.budgets).watch().listen((_) {
        emitProgress();
      });
      final txSub = _db.select(_db.transactions).watch().listen((_) {
        emitProgress();
      });

      await emitProgress();

      controller.onCancel = () async {
        await budgetSub.cancel();
        await txSub.cancel();
      };
    });
  }

  Future<List<BudgetProgress>> _loadBudgetProgress(int year, int monthNum) async {
    final categories = await (_db.select(_db.categories)
          ..where((c) => c.isExpense.equals(true)))
        .get();
    final budgets = await (_db.select(_db.budgets)
          ..where((b) => b.year.equals(year) & b.month.equals(monthNum)))
        .get();
    final txs = await _db.select(_db.transactions).get();
    final start = DateTime(year, monthNum);
    final end = DateTime(year, monthNum + 1);
    final categoryById = {for (final c in categories) c.id: c};

    return budgets.map((budget) {
      final category = categoryById[budget.categoryId];
      final spent = txs
          .where(
            (t) =>
                !t.isIncome &&
                t.categoryId == budget.categoryId &&
                !t.date.isBefore(start) &&
                t.date.isBefore(end),
          )
          .fold<int>(0, (sum, t) => sum + t.amountCents);

      return BudgetProgress(
        categoryId: budget.categoryId,
        categoryName: category?.name ?? 'Categoría',
        iconCodePoint: category?.iconCodePoint ?? 0xe88e,
        limitCents: budget.limitCents,
        spentCents: spent,
        year: year,
        month: monthNum,
      );
    }).toList()
      ..sort((a, b) => b.progress.compareTo(a.progress));
  }

  Future<void> upsertBudget({
    required String categoryId,
    required int year,
    required int month,
    required int limitCents,
  }) async {
    final existing = await (_db.select(_db.budgets)
          ..where(
            (b) =>
                b.categoryId.equals(categoryId) &
                b.year.equals(year) &
                b.month.equals(month),
          ))
        .getSingleOrNull();

    if (limitCents <= 0) {
      if (existing != null) {
        await (_db.delete(_db.budgets)..where((b) => b.id.equals(existing.id)))
            .go();
      }
      return;
    }

    await _db.into(_db.budgets).insertOnConflictUpdate(
          BudgetsCompanion(
            id: Value(existing?.id ?? _uuid.v4()),
            categoryId: Value(categoryId),
            year: Value(year),
            month: Value(month),
            limitCents: Value(limitCents),
          ),
        );
  }

  Future<void> addTransaction({
    required String accountId,
    required String categoryId,
    required int amountCents,
    required bool isIncome,
    required DateTime date,
    String note = '',
  }) async {
    await _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            id: _uuid.v4(),
            accountId: accountId,
            categoryId: categoryId,
            amountCents: amountCents,
            isIncome: isIncome,
            date: date,
            note: Value(note),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> updateTransaction({
    required String id,
    required String accountId,
    required String categoryId,
    required int amountCents,
    required bool isIncome,
    required DateTime date,
    String note = '',
  }) async {
    await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
          TransactionsCompanion(
            accountId: Value(accountId),
            categoryId: Value(categoryId),
            amountCents: Value(amountCents),
            isIncome: Value(isIncome),
            date: Value(date),
            note: Value(note),
          ),
        );
  }

  Future<void> deleteTransaction(String id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  Future<void> upsertAccount({
    String? id,
    required String name,
    required AccountType type,
    int initialBalanceCents = 0,
    required int colorValue,
    String? bankId,
    CardKind? cardKind,
    CardNetwork? cardNetwork,
  }) async {
    final resolvedBankId =
        type.needsProvider || type.isBank ? bankId : null;
    final resolvedCardKind =
        type == AccountType.card ? cardKind ?? CardKind.debit : null;
    final resolvedCardNetwork =
        type == AccountType.card ? cardNetwork ?? CardNetwork.visa : null;
    final int resolvedColor;
    if (resolvedCardNetwork != null) {
      resolvedColor = resolvedCardNetwork.brandColor.toARGB32();
    } else if (type == AccountType.digitalWallet) {
      resolvedColor = PeruvianDigitalWallets.colorForId(resolvedBankId).toARGB32();
    } else {
      resolvedColor = colorValue;
    }
    await _db.into(_db.accounts).insertOnConflictUpdate(
          AccountsCompanion(
            id: Value(id ?? _uuid.v4()),
            name: Value(name),
            type: Value(type.storageKey),
            initialBalanceCents: Value(initialBalanceCents),
            colorValue: Value(resolvedColor),
            bankId: Value(resolvedBankId),
            cardKind: Value(resolvedCardKind?.storageKey),
            cardNetwork: Value(resolvedCardNetwork?.storageKey),
          ),
        );
  }

  /// Elimina una cuenta y sus movimientos. La cuenta de efectivo no se puede borrar.
  Future<void> deleteAccount(String id) async {
    final row = await (_db.select(_db.accounts)
          ..where((a) => a.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return;

    final type = AccountTypeDisplay.fromStorage(row.type);
    if (type == AccountType.cash) {
      throw StateError('La cuenta de efectivo no se puede eliminar');
    }

    await _db.transaction(() async {
      await (_db.delete(_db.transactions)
            ..where((t) => t.accountId.equals(id)))
          .go();
      await (_db.delete(_db.accounts)..where((a) => a.id.equals(id))).go();
    });
  }

  Future<void> deleteAccounts(Iterable<String> ids) async {
    for (final id in ids) {
      await deleteAccount(id);
    }
  }

  Future<bool> hasCashAccount({String? exceptAccountId}) async {
    final rows = await _db.select(_db.accounts).get();
    return rows.any((row) {
      if (exceptAccountId != null && row.id == exceptAccountId) return false;
      return row.type == AccountType.cash.storageKey;
    });
  }

  Stream<List<CategoryExpenseSlice>> watchCategoryExpensesForMonth(
    DateTime month,
  ) {
    return _db.select(_db.transactions).watch().asyncMap((_) {
      return _loadCategoryExpensesForMonth(month);
    });
  }

  Future<List<CategoryExpenseSlice>> _loadCategoryExpensesForMonth(
    DateTime month,
  ) async {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final categories = await _db.select(_db.categories).get();
    final categoryById = {for (final c in categories) c.id: c};
    final txs = await _db.select(_db.transactions).get();

    final totals = <String, int>{};
    for (final t in txs) {
      if (t.isIncome) continue;
      if (t.date.isBefore(start) || !t.date.isBefore(end)) continue;
      final category = categoryById[t.categoryId];
      if (category != null && !category.isExpense) continue;
      totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amountCents;
    }

    final slices = totals.entries
        .map((entry) {
          final category = categoryById[entry.key];
          return CategoryExpenseSlice(
            categoryId: entry.key,
            categoryName: category?.name ?? 'Otro',
            iconCodePoint: category?.iconCodePoint ?? 0xe88e,
            amountCents: entry.value,
          );
        })
        .where((slice) => slice.amountCents > 0)
        .toList()
      ..sort((a, b) => b.amountCents.compareTo(a.amountCents));

    return slices;
  }

  Stream<List<MonthlyTrendPoint>> watchMonthlyTrend({int months = 6}) {
    return _db.select(_db.transactions).watch().asyncMap((_) {
      return _loadMonthlyTrend(months: months);
    });
  }

  Future<List<MonthlyTrendPoint>> _loadMonthlyTrend({int months = 6}) async {
    final now = DateTime.now();
    final txs = await _db.select(_db.transactions).get();
    final points = <MonthlyTrendPoint>[];

    for (var i = months - 1; i >= 0; i--) {
      final anchor = DateTime(now.year, now.month - i);
      final start = DateTime(anchor.year, anchor.month);
      final end = DateTime(anchor.year, anchor.month + 1);
      var expense = 0;
      var income = 0;
      for (final t in txs) {
        if (t.date.isBefore(start) || !t.date.isBefore(end)) continue;
        if (t.isIncome) {
          income += t.amountCents;
        } else {
          expense += t.amountCents;
        }
      }
      points.add(
        MonthlyTrendPoint(
          month: start,
          expenseCents: expense,
          incomeCents: income,
        ),
      );
    }
    return points;
  }

  Future<List<TransactionModel>> getAllTransactionsForExport() async {
    final rows = await (_db.select(_db.transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
    return _mapTransactions(rows);
  }

  Future<List<TransactionModel>> _mapTransactions(
    List<Transaction> rows,
  ) async {
    if (rows.isEmpty) return [];

    final accounts = await _db.select(_db.accounts).get();
    final categories = await _db.select(_db.categories).get();
    final accountById = {for (final a in accounts) a.id: a};
    final categoryById = {for (final c in categories) c.id: c};

    return rows.map((t) {
      final account = accountById[t.accountId];
      final category = categoryById[t.categoryId];
      return TransactionModel(
        id: t.id,
        accountId: t.accountId,
        categoryId: t.categoryId,
        amountCents: t.amountCents,
        isIncome: t.isIncome,
        date: t.date,
        note: t.note,
        createdAt: t.createdAt,
        accountName: account?.name,
        categoryName: category?.name,
        categoryIconCodePoint: category?.iconCodePoint,
      );
    }).toList();
  }

  Stream<List<LoanModel>> watchLoans({bool includeSettled = true}) {
    return (_db.select(_db.loans)
          ..orderBy([
            (l) => OrderingTerm.asc(l.isSettled),
            (l) => OrderingTerm.asc(l.dueDate),
          ]))
        .watch()
        .map((rows) {
      final loans = rows.map(_mapLoan).toList();
      if (includeSettled) return loans;
      return loans.where((l) => !l.isSettled).toList();
    });
  }

  LoanModel _mapLoan(Loan row) {
    return LoanModel(
      id: row.id,
      direction: LoanDirectionX.fromStorage(row.direction),
      counterpartyType:
          LoanCounterpartyTypeX.fromStorage(row.counterpartyType),
      counterpartyName: row.counterpartyName,
      amountCents: row.amountCents,
      dueDate: row.dueDate,
      note: row.note,
      notifyEnabled: row.notifyEnabled,
      notifyHour: row.notifyHour,
      notifyMinute: row.notifyMinute,
      notifyRepeatHourly: row.notifyRepeatHourly,
      isSettled: row.isSettled,
      bankId: row.bankId,
      createdAt: row.createdAt,
    );
  }

  Future<LoanModel> upsertLoan({
    String? id,
    required LoanDirection direction,
    required LoanCounterpartyType counterpartyType,
    required String counterpartyName,
    required int amountCents,
    required DateTime dueDate,
    String note = '',
    bool notifyEnabled = true,
    int notifyHour = 9,
    int notifyMinute = 0,
    bool notifyRepeatHourly = false,
    bool isSettled = false,
    String? bankId,
    DateTime? createdAt,
  }) async {
    final loanId = id ?? _uuid.v4();
    final now = DateTime.now();
    await _db.into(_db.loans).insertOnConflictUpdate(
          LoansCompanion(
            id: Value(loanId),
            direction: Value(direction.storageKey),
            counterpartyType: Value(counterpartyType.storageKey),
            counterpartyName: Value(counterpartyName.trim()),
            amountCents: Value(amountCents),
            dueDate: Value(
              DateTime(dueDate.year, dueDate.month, dueDate.day),
            ),
            note: Value(note.trim()),
            notifyEnabled: Value(notifyEnabled),
            notifyHour: Value(notifyHour.clamp(0, 23)),
            notifyMinute: Value(notifyMinute.clamp(0, 59)),
            notifyRepeatHourly: Value(notifyRepeatHourly),
            isSettled: Value(isSettled),
            bankId: Value(
              counterpartyType == LoanCounterpartyType.bank ? bankId : null,
            ),
            createdAt: Value(createdAt ?? now),
          ),
        );

    final row = await (_db.select(_db.loans)
          ..where((l) => l.id.equals(loanId)))
        .getSingle();
    return _mapLoan(row);
  }

  Future<void> setLoanSettled(String id, {required bool settled}) async {
    await (_db.update(_db.loans)..where((l) => l.id.equals(id))).write(
      LoansCompanion(isSettled: Value(settled)),
    );
  }

  Future<void> deleteLoan(String id) async {
    await (_db.delete(_db.loans)..where((l) => l.id.equals(id))).go();
  }
}
