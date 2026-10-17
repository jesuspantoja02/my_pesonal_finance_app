# Finanza

**Finanzas personales local-first para Android e iOS**, pensada para el día a día en Perú (moneda PEN). Registra cuentas, movimientos, presupuestos y préstamos; analiza hábitos con insights; protege el acceso con PIN o biometría. Los datos financieros permanecen en el dispositivo. La nube, si la usas, solo sincroniza autenticación y metadatos agregados para el panel de administración.

| | |
|---|---|
| **Versión** | 1.0.0 |
| **Autor** | [Jesús Pantoja](https://github.com/jesuspantoja02) |
| **Licencia** | [MIT](LICENSE) |
| **APK Android** | [Releases → `Finanza-release.apk`](https://github.com/jesuspantoja02/my_pesonal_finance_app/releases) |

---

## Contenido

- [Características](#características)
- [Arquitectura y privacidad](#arquitectura-y-privacidad)
- [Stack técnico](#stack-técnico)
- [Requisitos](#requisitos)
- [Inicio rápido](#inicio-rápido)
- [Configuración sensible](#configuración-sensible)
- [Compilar APK de release](#compilar-apk-de-release)
- [Panel admin web](#panel-admin-web)
- [Documentación](#documentación)
- [Estructura del repositorio](#estructura-del-repositorio)

---

## Características

- **Cuentas** — efectivo, billeteras digitales peruanas (Yape, Plin, etc.) y tarjetas (débito, crédito, prepago) con catálogo de bancos locales.
- **Movimientos** — ingresos y gastos con categorías, filtros y flujo rápido desde la barra principal.
- **Presupuestos e insights** — seguimiento por período y gráficos para entender en qué se va el dinero.
- **Préstamos** — prestado / me prestaron, contraparte, vencimiento y recordatorios locales (hora fija o repetición horaria).
- **Seguridad** — bloqueo con PIN y biometría; exportación CSV / JSON y compartir hacia hojas de cálculo.
- **Autenticación** — modo local (SQLite) o Firebase (correo, Google, Apple).
- **Admin web** — métricas de uso y usuarios registrados; **no** expone saldos ni transacciones (ver [docs/ADMIN_WEB.md](docs/ADMIN_WEB.md)).

---

## Arquitectura y privacidad

```text
┌─────────────────┐     opcional      ┌──────────────────┐
│  App Flutter    │ ─── Firebase Auth ─▶│ Metadatos login  │
│  Drift / SQLite │                     │ (Firestore)      │
│  (datos $)      │                     └────────┬─────────┘
└─────────────────┘                              │
                                                 ▼
                                        ┌──────────────────┐
                                        │  admin_web       │
                                        │  (solo analytics)│
                                        └──────────────────┘
```

- **Fuente de verdad financiera:** base SQLite en el teléfono (Drift).
- **Firebase:** autenticación y, si está activo, registro ligero de sesión para estadísticas del panel admin.
- **Borrado de datos:** desde ajustes puedes eliminar toda la información local y volver al onboarding.

---

## Stack técnico

| Capa | Tecnología |
|------|------------|
| Cliente móvil | Flutter, Dart ^3.12, Riverpod, go_router |
| Persistencia | Drift, sqlite3 |
| Gráficos / UI | fl_chart, google_fonts, animate_do |
| Auth / nube | Firebase Auth, Firestore, Cloud Functions |
| Admin | Vite, React, TypeScript |
| Notificaciones | flutter_local_notifications, timezone |

---

## Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (canal estable, compatible con Dart ^3.12)
- Android Studio / SDK para Android; Xcode para iOS
- Para Firebase y el panel admin: proyecto Firebase propio o credenciales locales (no incluidas en el repo)

---

## Inicio rápido

```bash
git clone https://github.com/jesuspantoja02/my_pesonal_finance_app.git
cd my_pesonal_finance_app

flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

Equivalente con el script del proyecto:

```bash
bash tool/setup.sh
flutter run
```

Si aparecen errores del tipo `app_database.g.dart` no generado, vuelve a ejecutar `dart run build_runner build`.

**Iconos del launcher**

```bash
dart run flutter_launcher_icons
bash tool/fix_adaptive_icon.sh
```

La versión mostrada en la app proviene del campo `version:` en `pubspec.yaml`.

---

## Configuración sensible

Estos archivos **no** están en GitHub (ver `.gitignore`). Debes crearlos o copiarlos en tu entorno:

| Archivo | Uso |
|---------|-----|
| `android/app/google-services.json` | Firebase Android |
| `ios/Runner/GoogleService-Info.plist` | Firebase iOS |
| `config/firebase_defines.json` | OAuth / defines opcionales (`config/firebase_defines.json.example`) |
| `admin_web/.env` | `VITE_*` del panel (`admin_web/.env.example`) |

El cliente incluye `lib/firebase_options.dart` generado con FlutterFire. Para otro proyecto Firebase:

```bash
flutterfire configure
```

Ejecución con defines personalizados:

```bash
cp config/firebase_defines.json.example config/firebase_defines.json
# edita valores
flutter run --dart-define-from-file=config/firebase_defines.json
```

En Firebase Console habilita los proveedores que uses (Email/Password, Google, Apple) y registra el **SHA-1** de debug/release en la app Android. Guías detalladas: [docs/FIREBASE.md](docs/FIREBASE.md) y [docs/FIREBASE_CONEXION_POR_PLATAFORMA.md](docs/FIREBASE_CONEXION_POR_PLATAFORMA.md).

---

## Compilar APK de release

```bash
flutter build apk --release
```

El artefacto queda en `build/app/outputs/flutter-apk/`. Las builds publicadas en GitHub Releases usan el nombre `Finanza-release.apk`.

> **Nota:** el `applicationId` Android puede seguir el identificador de plantilla de Flutter hasta que lo migres a un ID de producción propio en Gradle y en la consola de Firebase.

---

## Panel admin web

```bash
cd admin_web
cp .env.example .env   # define VITE_ADMIN_EMAILS y claves Firebase web
npm install
npm run dev
```

Despliegue y reglas Firestore: [docs/ADMIN_WEB.md](docs/ADMIN_WEB.md).

---

## Documentación

| Documento | Descripción |
|-----------|-------------|
| [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md) | Capas `lib/`, features y convenciones |
| [docs/FIREBASE.md](docs/FIREBASE.md) | Configuración Firebase |
| [docs/FIREBASE_CONEXION_POR_PLATAFORMA.md](docs/FIREBASE_CONEXION_POR_PLATAFORMA.md) | Android / iOS / web |
| [docs/ADMIN_WEB.md](docs/ADMIN_WEB.md) | Panel de administración |

---

## Estructura del repositorio

```text
lib/           # App Flutter (features, data, domain, core)
admin_web/     # Panel admin (Vite + React)
functions/     # Cloud Functions (metadatos / analytics admin)
config/        # Plantillas de configuración
docs/          # Guías del proyecto
tool/          # Scripts de setup e iconos
assets/        # Iconos, bancos y billeteras
android/ ios/  # Proyectos nativos
```

---

## Autor y licencia

Proyecto creado y mantenido por **Jesús Pantoja** ([@jesuspantoja02](https://github.com/jesuspantoja02)).

Distribuido bajo la licencia [MIT](LICENSE). Puedes usar, modificar y distribuir el software según los términos de la licencia.

Si este proyecto te resulta útil, una estrella en el repositorio ayuda a darle visibilidad.
