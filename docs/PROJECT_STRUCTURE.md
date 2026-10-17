# Estructura del proyecto Finanza

## Raíz

| Ruta | Propósito |
|------|-----------|
| `lib/` | App Flutter (UI, dominio, datos, servicios) |
| `admin_web/` | Panel admin (Vite + React + Firebase) |
| `functions/` | Cloud Functions (`syncLoginMetadata`, `getAdminAnalytics`) |
| `config/` | Plantillas Firebase (`firebase_defines.json.example`) |
| `docs/` | Guías (Firebase, admin web, estructura) |
| `tool/` | Scripts (`setup.sh`, iconos) |
| `assets/` | Iconos e imágenes |
| `android/`, `ios/` | Proyectos nativos + Firebase (`google-services.json`, plist) |
| `firebase.json` | Deploy Hosting, Firestore, Functions |
| `firestore.rules`, `firestore.indexes.json` | Reglas e índices |

## `lib/` (capas)

```
lib/
├── main.dart                 # Entrada
├── firebase_options.dart     # Config Firebase (flutterfire)
├── routing/                  # go_router
├── core/
│   ├── cloud/                # Firebase bootstrap, registro usuario
│   ├── config/               # Env, OAuth defaults, cloud admin
│   ├── constants/            # App name, billeteras PE
│   ├── motion/               # Duraciones, transiciones, press scale
│   ├── ui/                   # Headers, empty states, fondos animados
│   ├── providers/            # Riverpod
│   ├── services/             # Auth, export, backup
│   ├── theme/                # Colores, tema
│   └── widgets/              # Cards, scaffolds compartidos
├── data/                     # Drift DB, repositorios, seed
├── domain/models/            # Modelos puros
└── features/                 # Pantallas por funcionalidad
    ├── auth/                 # Login + widgets sociales
    ├── onboarding/
    ├── splash/
    ├── home/, dashboard/, accounts/, transactions/, budgets/, insights/
    ├── settings/, security/
```

## Autenticación

- **Local** (SQLite): correo/contraseña sin Firebase.
- **Firebase**: correo, **Google**, **Apple** → metadatos en Cloud Functions / Firestore.
- Finanzas **no** suben a la nube.

## Configuración sensible (no commitear)

- `config/firebase_defines.json`
- `admin_web/.env`
- `functions/.env`
- `android/app/google-services.json` (opcional en git según `.gitignore`)

## Comandos habituales

```bash
bash tool/setup.sh              # pub get + build_runner + analyze
flutter run                     # Firebase embebido tras flutterfire configure
firebase deploy --only functions,firestore  # Backend
cd admin_web && npm run dev     # Panel admin
```

Guía Firebase: [FIREBASE_CONEXION_POR_PLATAFORMA.md](FIREBASE_CONEXION_POR_PLATAFORMA.md).
