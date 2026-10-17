import 'package:drift/drift.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';
import 'package:my_personal_finance_app/data/database/app_database.dart';
import 'package:my_personal_finance_app/data/seed/default_categories.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

Future<void> ensureDefaultCategories(AppDatabase db) async {
  for (final def in kDefaultCategoryDefinitions) {
    final existing = await (db.select(db.categories)
          ..where((t) => t.name.equals(def.name)))
        .getSingleOrNull();
    if (existing != null) continue;

    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: _uuid.v4(),
            name: def.name,
            iconCodePoint: def.iconCodePoint,
            isExpense: Value(def.isExpense),
          ),
        );
  }
}

/// Instalación nueva o tras borrar datos: sin movimientos ni cuentas de ejemplo.
Future<void> seedFreshDatabase(AppDatabase db) async {
  await ensureDefaultCategories(db);

  await db.into(db.accounts).insert(
        AccountsCompanion.insert(
          id: _uuid.v4(),
          name: kDefaultCashAccountName,
          type: 'cash',
          colorValue: 0xFF14B8A6,
        ),
      );

  await db.into(db.appSettings).insertOnConflictUpdate(
        const AppSettingsCompanion(
          id: Value(1),
          currencyCode: Value('PEN'),
          themeMode: Value('dark'),
          onboardingCompleted: Value(false),
          appLockEnabled: Value(false),
        ),
      );
}

Future<void> seedAfterUserReset(AppDatabase db) => seedFreshDatabase(db);

Future<void> seedDatabaseIfEmpty(AppDatabase db) async {
  final accountCount = await db.select(db.accounts).get();
  if (accountCount.isNotEmpty) {
    await ensureDefaultCategories(db);
    return;
  }

  await seedFreshDatabase(db);
}
