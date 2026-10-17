import 'package:flutter/material.dart';

/// Principales bancos usados en Perú (retail y digital).
class PeruvianBank {
  const PeruvianBank({
    required this.id,
    required this.name,
    required this.brandColor,
  });

  final String id;
  final String name;
  final Color brandColor;

  String get assetPath => 'assets/banks/$id.png';
}

abstract final class PeruvianBanks {
  static const String otherId = 'otro';

  static const List<PeruvianBank> all = [
    PeruvianBank(id: 'bcp', name: 'BCP', brandColor: Color(0xFF00468C)),
    PeruvianBank(id: 'bbva', name: 'BBVA Perú', brandColor: Color(0xFF004481)),
    PeruvianBank(
      id: 'interbank',
      name: 'Interbank',
      brandColor: Color(0xFF00A86B),
    ),
    PeruvianBank(
      id: 'scotiabank',
      name: 'Scotiabank Perú',
      brandColor: Color(0xFFEC111A),
    ),
    PeruvianBank(
      id: 'nacion',
      name: 'Banco de la Nación',
      brandColor: Color(0xFFC8102E),
    ),
    PeruvianBank(id: 'banbif', name: 'BanBif', brandColor: Color(0xFF003366)),
    PeruvianBank(
      id: 'pichincha',
      name: 'Banco Pichincha',
      brandColor: Color(0xFFFFD100),
    ),
    PeruvianBank(id: 'mibanco', name: 'MiBanco', brandColor: Color(0xFFE87722)),
    PeruvianBank(
      id: 'crediscotia',
      name: 'Crediscotia',
      brandColor: Color(0xFFEC008C),
    ),
    PeruvianBank(
      id: 'compartamos',
      name: 'Compartamos Banco',
      brandColor: Color(0xFF00A0DF),
    ),
    PeruvianBank(id: 'gnb', name: 'GNB Perú', brandColor: Color(0xFF0055A5)),
    PeruvianBank(
      id: 'ripley',
      name: 'Banco Ripley',
      brandColor: Color(0xFF7B2D8E),
    ),
    PeruvianBank(
      id: 'falabella',
      name: 'Banco Falabella',
      brandColor: Color(0xFF008C45),
    ),
    PeruvianBank(
      id: 'citibank',
      name: 'Citibank Perú',
      brandColor: Color(0xFF003D65),
    ),
    PeruvianBank(id: 'icbc', name: 'ICBC Perú', brandColor: Color(0xFFC8102E)),
    PeruvianBank(id: 'otro', name: 'Otro banco', brandColor: Color(0xFF0F766E)),
  ];

  static PeruvianBank? byId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final bank in all) {
      if (bank.id == id) return bank;
    }
    return null;
  }

  static String? nameForId(String? id) => byId(id)?.name;
}
