# Finanza — finanzas personales

App Flutter para Android e iOS (Perú, PEN): cuentas, movimientos, presupuestos, préstamos e insights. Panel **admin web** para métricas de acceso (sin datos financieros en la nube).

**Autor:** Jesús Pantoja · [GitHub @jesuspantoja02](https://github.com/jesuspantoja02)

**APK Android:** descarga en [Releases](https://github.com/jesuspantoja02/my_pesonal_finance_app/releases) (`Finanza-release.apk`).

## Requisitos

- Flutter SDK estable (Dart ^3.12)
- Xcode (iOS) y/o Android Studio / SDK (Android)

## Configuración (importante)

Este proyecto usa **Drift** con código generado. Si ves errores como  
`Target of URI hasn't been generated: 'app_database.g.dart'` o referencias a `_$AppDatabase`:

```bash
cd my_personal_finance_app
flutter pub get
dart run build_runner build
flutter analyze
```

O ejecuta:

```bash
bash tool/setup.sh
```

Luego:

```bash
flutter run
```

Tras añadir `package_info_plus`, si iOS falla al compilar, prueba:

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..   # solo si tu proyecto usa CocoaPods
flutter run
```

## Iconos del launcher

```bash
dart run flutter_launcher_icons
bash tool/fix_adaptive_icon.sh
```

## Versión

La versión visible en la app sale de `version:` en `pubspec.yaml`.

## Funcionalidades

- Onboarding → login (local o Firebase)
- Cuentas: efectivo, billeteras peruanas, tarjetas (débito/crédito/prepago)
- Movimientos, presupuestos, insights, bloqueo con PIN/biometría
- Exportar CSV / JSON / compartir para Google Sheets (desde el dispositivo)
- Borrar todos los datos (vuelve a onboarding)
- Login correo, **Google** y **Apple** (Firebase; ver abajo)
- Panel admin web: usuarios, frecuencia de ingresos, gráficos — [docs/ADMIN_WEB.md](docs/ADMIN_WEB.md)

## Privacidad

Los datos financieros viven en **SQLite en el teléfono**. La nube, si la activas, solo recibe metadatos de cuenta al iniciar sesión.

## Firebase

El proyecto ya está enlazado con **`my-personal-finance-app-1ff47`** (`flutterfire configure`).

```bash
flutter run
```

Opcional (sobrescribir OAuth / admin):

```bash
cp config/firebase_defines.json.example config/firebase_defines.json
flutter run --dart-define-from-file=config/firebase_defines.json
```

En Firebase Console: **Authentication → Sign-in method** → habilita **Google**, **Apple** y **Email/Password**. Android: añade **SHA-1** debug en la app Android.

Guías: [docs/FIREBASE.md](docs/FIREBASE.md) · [docs/FIREBASE_CONEXION_POR_PLATAFORMA.md](docs/FIREBASE_CONEXION_POR_PLATAFORMA.md) · [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md).
