# Firebase (app móvil + panel admin)

Guía detallada **por plataforma** (Android → Web → iOS): [FIREBASE_CONEXION_POR_PLATAFORMA.md](FIREBASE_CONEXION_POR_PLATAFORMA.md).

La app móvil guarda **finanzas solo en el dispositivo**. En la nube: identidad (Google/correo), metadatos de usuario e **historial de ingresos** para el panel web. Sin transacciones ni montos.

## 1. Crear proyecto Firebase

1. [Firebase Console](https://console.firebase.google.com/) → nuevo proyecto.
2. **Authentication** → **Google**, **Apple** y **Correo/contraseña** (Apple requiere capability en Xcode + Apple Developer).
3. Apps: **Android**, **iOS** (móvil) y **Web** (panel admin).
4. **Firestore** en modo producción (despliega reglas del repo).

## 2. FlutterFire (móvil)

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Genera `google-services.json`, `GoogleService-Info.plist` y opcionalmente opciones.

```bash
cp config/firebase_defines.json.example config/firebase_defines.json
# Completa valores
flutter run --dart-define-from-file=config/firebase_defines.json \
  --dart-define=ADMIN_EMAIL=tu@gmail.com
```

iOS: URL scheme con `REVERSED_CLIENT_ID` en `Info.plist` (ver guía FlutterFire).

## 3. Panel admin web

Ver [ADMIN_WEB.md](ADMIN_WEB.md): `admin_web/env.example` → `.env`, `npm run dev` o `firebase deploy --only hosting`.

## 4. Backend (reglas, índices, functions)

```bash
cd functions && npm install && cd ..
firebase login
firebase use tu-proyecto-id
```

Variable de entorno para admins (Cloud Functions v2):

```bash
# En functions/.env o en la consola de Google Cloud / Firebase al desplegar:
ADMIN_EMAILS=tu@gmail.com
```

```bash
firebase deploy --only firestore:rules,firestore:indexes,functions,hosting
```

## 5. Flujo de login

1. Usuario inicia sesión en la app (Google o correo con Firebase).
2. La app llama `syncLoginMetadata` → actualiza `app_users` y crea `login_events`.
3. Tú entras en el panel web con el mismo Gmail admin → `getAdminAnalytics` devuelve tablas y gráficos.

## 6. Sin Firebase

`flutter run` sin defines: cuenta local SQLite, sin Google ni panel en la nube.
