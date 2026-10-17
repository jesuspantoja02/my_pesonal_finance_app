import 'package:flutter/material.dart';

/// Dirección del préstamo desde el punto de vista del usuario.
enum LoanDirection {
  /// Me prestaron dinero (yo debo pagar).
  borrowed,

  /// Yo presté dinero (me deben pagar).
  lent,
}

extension LoanDirectionX on LoanDirection {
  String get storageKey => name;

  String get label => switch (this) {
        LoanDirection.borrowed => 'Me prestaron',
        LoanDirection.lent => 'Yo presté',
      };

  String get shortLabel => switch (this) {
        LoanDirection.borrowed => 'Debo',
        LoanDirection.lent => 'Me deben',
      };

  IconData get icon => switch (this) {
        LoanDirection.borrowed => Icons.call_received_rounded,
        LoanDirection.lent => Icons.call_made_rounded,
      };

  static LoanDirection fromStorage(String value) {
    return LoanDirection.values.firstWhere(
      (e) => e.storageKey == value,
      orElse: () => LoanDirection.borrowed,
    );
  }
}

enum LoanCounterpartyType {
  person,
  bank,
}

extension LoanCounterpartyTypeX on LoanCounterpartyType {
  String get storageKey => name;

  String get label => switch (this) {
        LoanCounterpartyType.person => 'Persona',
        LoanCounterpartyType.bank => 'Banco',
      };

  IconData get icon => switch (this) {
        LoanCounterpartyType.person => Icons.person_outline_rounded,
        LoanCounterpartyType.bank => Icons.account_balance_outlined,
      };

  static LoanCounterpartyType fromStorage(String value) {
    return LoanCounterpartyType.values.firstWhere(
      (e) => e.storageKey == value,
      orElse: () => LoanCounterpartyType.person,
    );
  }
}

class LoanModel {
  const LoanModel({
    required this.id,
    required this.direction,
    required this.counterpartyType,
    required this.counterpartyName,
    required this.amountCents,
    required this.dueDate,
    required this.notifyEnabled,
    required this.isSettled,
    required this.createdAt,
    this.note = '',
    this.bankId,
    this.notifyHour = 9,
    this.notifyMinute = 0,
    this.notifyRepeatHourly = false,
  });

  final String id;
  final LoanDirection direction;
  final LoanCounterpartyType counterpartyType;
  final String counterpartyName;
  final int amountCents;
  final DateTime dueDate;
  final String note;
  final bool notifyEnabled;
  final bool isSettled;
  final DateTime createdAt;

  /// Banco del catálogo cuando [counterpartyType] es bank.
  final String? bankId;

  /// Hora del recordatorio (0-23).
  final int notifyHour;

  /// Minuto del recordatorio (0-59).
  final int notifyMinute;

  /// Si es true, avisa cada hora desde la hora elegida.
  final bool notifyRepeatHourly;

  TimeOfDay get notifyTimeOfDay =>
      TimeOfDay(hour: notifyHour.clamp(0, 23), minute: notifyMinute.clamp(0, 59));

  bool get isOverdue {
    if (isSettled) return false;
    final today = DateTime.now();
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final now = DateTime(today.year, today.month, today.day);
    return due.isBefore(now);
  }

  int get daysUntilDue {
    final today = DateTime.now();
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final now = DateTime(today.year, today.month, today.day);
    return due.difference(now).inDays;
  }
}
