import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  IntColumn get initialBalanceCents => integer().withDefault(const Constant(0))();
  IntColumn get colorValue => integer()();
  TextColumn get bankId => text().nullable()();
  TextColumn get cardKind => text().nullable()();
  /// Marca / red: visa, mastercard, amex, diners, other.
  TextColumn get cardNetwork => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get iconCodePoint => integer()();
  BoolColumn get isExpense => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text().references(Accounts, #id)();
  TextColumn get categoryId => text().references(Categories, #id)();
  IntColumn get amountCents => integer()();
  BoolColumn get isIncome => boolean()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  IntColumn get year => integer()();
  IntColumn get month => integer()();
  IntColumn get limitCents => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get displayName => text()();
  TextColumn get passwordHash => text()();
  TextColumn get salt => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AppSettings extends Table {
  IntColumn get id => integer()();
  TextColumn get currencyCode => text().withDefault(const Constant('PEN'))();
  TextColumn get themeMode => text().withDefault(const Constant('dark'))();
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get appLockEnabled =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Loans extends Table {
  TextColumn get id => text()();
  /// borrowed | lent
  TextColumn get direction => text()();
  /// person | bank
  TextColumn get counterpartyType => text()();
  TextColumn get counterpartyName => text()();
  IntColumn get amountCents => integer()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get note => text().withDefault(const Constant(''))();
  BoolColumn get notifyEnabled =>
      boolean().withDefault(const Constant(true))();
  /// Hora del recordatorio (0-23).
  IntColumn get notifyHour => integer().withDefault(const Constant(9))();
  /// Minuto del recordatorio (0-59).
  IntColumn get notifyMinute => integer().withDefault(const Constant(0))();
  /// Si es true, avisa cada hora desde la hora elegida.
  BoolColumn get notifyRepeatHourly =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isSettled => boolean().withDefault(const Constant(false))();
  TextColumn get bankId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Accounts,
    Categories,
    Transactions,
    Budgets,
    AppSettings,
    Users,
    Loans,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'personal_finance'));

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(accounts, accounts.bankId);
          }
          if (from < 3) {
            await migrator.createTable(budgets);
          }
          if (from < 4) {
            await migrator.addColumn(appSettings, appSettings.themeMode);
            await migrator.addColumn(appSettings, appSettings.onboardingCompleted);
            await migrator.addColumn(appSettings, appSettings.appLockEnabled);
            await migrator.database.customStatement(
              'UPDATE app_settings SET onboarding_completed = 1 WHERE id = 1',
            );
          }
          if (from < 5) {
            await migrator.addColumn(accounts, accounts.cardKind);
          }
          if (from < 6) {
            await migrator.createTable(users);
          }
          if (from < 7) {
            await migrator.addColumn(accounts, accounts.cardNetwork);
          }
          if (from < 8) {
            await migrator.createTable(loans);
            await migrator.database.customStatement(
              "UPDATE accounts SET bank_id = 'otro' WHERE bank_id = 'lukita'",
            );
            await migrator.database.customStatement(
              "UPDATE accounts SET type = 'digital_wallet', bank_id = COALESCE(bank_id, 'otro') "
              "WHERE type = 'lukita'",
            );
          }
          if (from < 9) {
            await migrator.addColumn(loans, loans.notifyHour);
            await migrator.addColumn(loans, loans.notifyMinute);
            await migrator.addColumn(loans, loans.notifyRepeatHourly);
          }
        },
      );
}
