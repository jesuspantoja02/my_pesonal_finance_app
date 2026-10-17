# Panel web Finanza Admin

Dashboard para ver **usuarios**, **frecuencia de ingresos** y **gráficos** (últimos 30 días). No muestra transacciones ni saldos.

## Requisitos

- Proyecto Firebase con Auth (Google), Firestore y Cloud Functions desplegadas.
- Tu Gmail en `ADMIN_EMAILS` (Functions) y/o `--dart-define=ADMIN_EMAIL=...` en la app móvil.
- App web registrada en Firebase (icono web) para obtener `appId` y `apiKey`.

## Configuración local

```bash
cd admin_web
cp env.example .env
# Edita .env con los valores de Firebase Console → Tu app web
npm install
npm run dev
```

Abre la URL que muestra Vite (normalmente `http://localhost:5173`).

En Firebase Console → Authentication → Settings → **Authorized domains**, añade `localhost` si no está.

## Despliegue en Firebase Hosting (plan Spark / gratis)

URL de producción (este proyecto):

- https://my-personal-finance-app-1ff47.web.app
- https://my-personal-finance-app-1ff47.firebaseapp.com

Antes del build, `admin_web/.env` debe tener las `VITE_FIREBASE_*` correctas.

```bash
cd admin_web
npm install
npm run build
cd ..
firebase use my-personal-finance-app-1ff47
firebase deploy --only hosting,firestore:rules
```

En Firebase Console → Authentication → Settings → **Authorized domains**, añade:
`my-personal-finance-app-1ff47.web.app` (si no aparece solo).

O todo junto:

```bash
firebase deploy --only firestore:rules,firestore:indexes,functions,hosting
```

## Functions usadas

| Función | Quién la llama |
|---------|----------------|
| `syncLoginMetadata` | App móvil en cada login |
| `getAdminAnalytics` | Panel web (solo admin) |

## Datos en Firestore

- `app_users/{uid}` — perfil, `lastLoginAt`, `loginCount`
- `app_users/{uid}/login_events/{id}` — un documento por cada ingreso (`at`, `platform`, `appVersion`)

Solo Cloud Functions escriben `login_events`.

## Permisos

Tras el primer login con tu Gmail admin, `syncLoginMetadata` asigna el claim `admin: true`. Si el panel dice “sin permisos”, vuelve a iniciar sesión en la app móvil una vez con ese correo o revisa `ADMIN_EMAILS` en Functions.
