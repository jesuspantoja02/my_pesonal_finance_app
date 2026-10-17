# Conectar Finanza con Firebase (paso a paso por plataforma)

Esta guía enlaza **tu repo** con un **único proyecto Firebase**. El orden es intencional:

1. **Preparación** (una sola vez, en la consola).
2. **Android** — termina Android por completo antes de seguir.
3. **Web** — panel admin (`admin_web/`).
4. **iOS** — cuando vayas a compilar en iPhone/iPad.
5. **Backend** — reglas Firestore, índices y Cloud Functions (necesario para login en la nube y el panel).

La app móvil guarda **transacciones y saldos solo en SQLite**. Firebase se usa para **Auth**, metadatos de usuario e **historial de ingresos** (panel admin). Ver también [FIREBASE.md](FIREBASE.md) y [ADMIN_WEB.md](ADMIN_WEB.md).

---

## Mapa de la consola Firebase (2026)

Google actualiza la consola con frecuencia. Los **nombres pueden estar en español o inglés** según el idioma de tu cuenta. Esta guía indica **ambos** cuando importa.

### Pantalla inicial (sin proyecto abierto)

1. Abre [console.firebase.google.com](https://console.firebase.google.com/).
2. Arriba verás el **selector de proyecto** (nombre del proyecto o “Seleccionar proyecto”).
3. Para crear uno nuevo: botón **Agregar proyecto** / **Add project** (tarjeta o botón principal en el centro).
4. Desde 2025–2026 también aparecen **workspaces de Firebase Studio** y búsqueda por nombre / **Project ID**; para Finanza solo necesitas un **proyecto Firebase clásico**, no hace falta Firebase Studio.

### Dentro de un proyecto (lo que verás siempre)

```
┌─────────────────────────────────────────────────────────────────┐
│ [≡]  Selector de proyecto ▼          [?]  [⚙ Configuración]   │
├──────────────┬──────────────────────────────────────────────────┤
│  MENÚ IZQ.   │  ÁREA CENTRAL (dashboard / producto activo)      │
│              │                                                  │
│  • Descripción general / Project overview                      │
│  • Accesos directos / Project shortcuts (fijados)              │
│  • Compilación / Build  ▼                                      │
│  • Ejecución / Run  ▼                                          │
│  • Bases de datos y almacenamiento / Databases & storage  ▼    │
│  • …                                                           │
└──────────────┴──────────────────────────────────────────────────┘
```

| Qué buscas | Dónde suele estar en 2026 | Atajo de URL (cambia `TU_PROJECT_ID`) |
|------------|---------------------------|----------------------------------------|
| Resumen y **Agregar app** | **Descripción general del proyecto** / **Project overview** | `https://console.firebase.google.com/project/TU_PROJECT_ID/overview` |
| **Configuración del proyecto** (apps, claves, facturación) | Icono **⚙** arriba → **Configuración del proyecto** / **Project settings** | `.../project/TU_PROJECT_ID/settings/general` |
| **Authentication** | Menú izquierdo: **Compilación → Authentication** o acceso directo fijado | `.../project/TU_PROJECT_ID/authentication/users` |
| Proveedores de login | Authentication → pestaña **Método de acceso** / **Sign-in method** | `.../project/TU_PROJECT_ID/authentication/providers` |
| Dominios OAuth (web) | Authentication → **Configuración** / **Settings** → **Dominios autorizados** / **Authorized domains** | `.../project/TU_PROJECT_ID/authentication/settings` |
| **Firestore** | **Bases de datos y almacenamiento → Firestore** *o* **Compilación → Firestore Database** (según versión de UI) | `.../project/TU_PROJECT_ID/firestore` |
| Reglas / índices Firestore | Dentro de Firestore: pestañas **Reglas**, **Índices**, **Datos** | Misma URL base + pestaña |
| **Hosting** | **Compilación → Hosting** / **Build → Hosting** | `.../project/TU_PROJECT_ID/hosting` |
| **Functions** | **Compilación → Functions** / **Build → Functions** | `.../project/TU_PROJECT_ID/functions` |
| Plan **Blaze** / facturación | ⚙ **Configuración del proyecto** → **Uso y facturación** / **Usage and billing** → **Modificar plan** | `.../project/TU_PROJECT_ID/settings/usage` |

**Tip:** Si no encuentras un producto, usa la **barra de búsqueda** dentro del proyecto (cuando aparece) o abre la URL de la tabla sustituyendo `TU_PROJECT_ID` por el ID real (ej. `my-personal-finance-app-cdf58`).

### Sección “Tus apps” (crítica para Android / iOS / Web)

1. Icono **⚙** → **Configuración del proyecto**.
2. Pestaña **General** / **General**.
3. Baja hasta **Tus apps** / **Your apps**.
4. Ahí ves iconos **Android**, **Apple**, **Web** con el **App ID**, **ID del paquete**, etc.
5. Para **descargar de nuevo** `google-services.json` o `GoogleService-Info.plist`: selecciona la app → botón de descarga del config file.

### Google Cloud Console (OAuth, no es Firebase pero lo necesitas)

Firebase y Google Cloud comparten el **mismo Project ID**.

1. [console.cloud.google.com](https://console.cloud.google.com/) → selector de proyecto arriba → elige **el mismo ID** que en Firebase.
2. Menú **☰** → **APIs y servicios** → **Credenciales** / **APIs & Services → Credentials**.
3. Ahí están los **ID de cliente OAuth 2.0** (Web, Android, iOS).

---

## Identificadores de este proyecto (no los cambies en Firebase sin cambiarlos también en el código)

| Plataforma | Campo en Firebase | Valor en el repo |
|------------|-------------------|------------------|
| Android | Package name / Nombre del paquete | `com.example.my_personal_finance_app` (`android/app/build.gradle.kts`) |
| iOS | Bundle ID / ID del paquete iOS | `com.example.myPersonalFinanceApp` (`ios/Runner.xcodeproj`) |

Android e iOS usan **IDs distintos**; debes registrar **dos apps** en el mismo proyecto Firebase.

---

## Parte 0 — Preparación (una sola vez)

Haz esto **antes** de Android, Web o iOS. Solo creas **un** proyecto Firebase; luego añades una app por plataforma.

### 0.1 Crear proyecto

**En la consola (2026):**

1. [Firebase Console](https://console.firebase.google.com/) → **Agregar proyecto** / **Add project**.
2. **Paso 1 — Nombre:** visible solo para ti (ej. `Finanza prod`). **Siguiente**.
3. **Paso 2 — Google Analytics:** puedes **desactivar** el interruptor si no lo quieres → **Crear proyecto** / **Continue**.
4. Espera la barra de progreso → **Continuar** / **Continue** al panel del proyecto.
5. Anota el **Project ID** (no se puede cambiar fácilmente): ⚙ **Configuración del proyecto** → **General** → campo **ID del proyecto** / **Project ID**.

### 0.2 Authentication

**En la consola (2026):**

1. Menú izquierdo → **Compilación** / **Build** → **Authentication** / **Autenticación**.
2. Si es la primera vez: botón grande **Comenzar** / **Get started** en el centro.
3. Pestaña **Método de acceso** / **Sign-in method** (arriba, junto a Usuarios / Users).
4. **Google:**
   - Clic en la fila **Google** → interruptor **Habilitar** / **Enable** → elige **Correo de asistencia del proyecto** / **Project support email** (tu Gmail) → **Guardar** / **Save**.
5. **Correo/Contraseña:**
   - Fila **Correo/Contraseña** / **Email/Password** → **Habilitar** → deja activado solo **Correo/contraseña** (no hace falta “Enlace por email” para Finanza) → **Guardar**.

**Comprobación:** en **Sign-in method** deben aparecer **Google** y **Correo/Contraseña** como **Habilitado** / **Enabled**.

### 0.3 Firestore

**En la consola (2026):**

1. Menú izquierdo → **Bases de datos y almacenamiento** → **Firestore**  
   *Si no lo ves:* **Compilación** → **Firestore Database**.
2. Botón **Crear base de datos** / **Create database**.
3. **Edición:** elige **Standard** (edición estándar) → **Siguiente** / **Next**.
4. **ID y ubicación:** deja el ID `(default)`; región cercana (ej. `southamerica-east1` o `nam5` según lo que ofrezca la lista) → **Siguiente**.
5. **Modo de inicio:**
   - Elige **Producción** / **Start in production mode** (deniega lecturas/escrituras hasta publicar reglas).  
   - Las reglas correctas las subes desde tu Mac en la [Parte 5](#parte-5--backend-compartido-reglas-índices-y-functions).
6. **Crear** / **Create** y espera 1–2 minutos.

**Comprobación:** entras a Firestore y ves pestañas **Datos**, **Reglas**, **Índices**, **Uso**.

### 0.4 Herramientas en tu Mac (recomendado)

```bash
# FlutterFire (opcional pero útil para generar archivos nativos)
dart pub global activate flutterfire_cli

# Firebase CLI (Web hosting + deploy de reglas/functions)
npm install -g firebase-tools
firebase login
```

`firebase login` abre **tu navegador** para elegir cuenta Google; debe ser la misma que usa el proyecto Firebase.

Asegúrate de tener `~/.pub-cache/bin` en tu `PATH` si usas `flutterfire`.

---

## Parte 1 — Android

Objetivo: instalar la app en tu teléfono con **Google / correo Firebase**, ver en consola `Finanza: Firebase listo.` y que el login sincronice metadatos (cuando Functions estén desplegadas).

### 1.1 Registrar la app Android en Firebase

**En la consola (2026):**

1. Ve a **Descripción general del proyecto** / **Project overview** (primer ítem del menú o logo Firebase).
2. En el **centro de la página**, bajo el nombre del proyecto, verás tarjetas **Agregar app** con iconos. Clic en **Android** (robot verde).  
   *Alternativa:* ⚙ **Configuración del proyecto** → **General** → **Tus apps** → **Agregar app** → **Android**.
3. **Paso 1 — Registrar app:**
   - **Nombre del paquete de Android** / **Android package name:**  
     `com.example.my_personal_finance_app`  
     (copia exacta; si Firebase marca error, revisa `android/app/build.gradle.kts` → `applicationId`).
   - **Apodo de la app** (opcional): `Finanza Android`.
   - **Certificado de firma SHA-1:** puedes **dejarlo vacío** ahora y añadirlo en [1.3](#13-huella-sha-1-obligatorio-para-google-sign-in).
4. **Registrar app** / **Register app**.
5. **Paso 2 — Descargar config:** ver [1.2](#12-descargar-google-servicesjson) (puedes hacerlo en el mismo asistente).
6. Los pasos 3–4 del asistente (“Agregar SDK”) puedes **Omitir** / **Next** hasta **Continuar en la consola**; Flutter ya trae los SDKs.

### 1.2 Descargar `google-services.json`

**En la consola (2026):**

- En el asistente: botón **Descargar google-services.json** / **Download google-services.json**.  
- Más tarde: ⚙ → **General** → **Tus apps** → app Android → **google-services.json**.

**En tu Mac:**

Coloca el archivo en:

```
android/app/google-services.json
```

Este archivo está en `.gitignore`; no lo subas a git.

El proyecto ya aplica el plugin de Google Services **solo si ese archivo existe** (`android/app/build.gradle.kts`).

### 1.3 Huella SHA-1 (obligatorio para Google Sign-In)

**En tu Mac:**

```bash
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android -keypass android
```

Copia la línea **SHA-1** (40 caracteres hex con `:`).

**En la consola (2026):**

1. ⚙ **Configuración del proyecto** → **General**.
2. En **Tus apps**, clic en la app **Android** (no en iOS/Web).
3. Baja a **Huellas digitales del certificado SHA** / **SHA certificate fingerprints**.
4. **Agregar huella digital** / **Add fingerprint** → pega SHA-1 → **Guardar**.

Espera **1–5 minutos** antes de probar Google Sign-In otra vez.

Si más adelante firmas release con otro keystore, repite con el SHA-1 de release.

### 1.4 Clientes OAuth (Google Sign-In)

Al habilitar Google en Authentication, Firebase suele crear un cliente **Web** automáticamente.

**En Google Cloud Console (2026):**

1. [console.cloud.google.com/apis/credentials](https://console.cloud.google.com/apis/credentials) (proyecto = mismo **Project ID**).
2. Lista **ID de cliente de OAuth 2.0**:
   - Tipo **Aplicación web** / **Web application** → copia el **ID de cliente** → `GOOGLE_WEB_CLIENT_ID`.
   - Tipo **Android** (nombre con tu package `com.example.my_personal_finance_app`) → **ID de cliente** → `GOOGLE_ANDROID_CLIENT_ID`.  
     Si **no** hay cliente Android: **+ Crear credenciales** → **ID de cliente de OAuth** → tipo **Android** → package + SHA-1 iguales a Firebase.

La app usa el client **Web** como `serverClientId` en Android (ver `lib/core/cloud/firebase_bootstrap.dart`).

### 1.5 Archivo `config/firebase_defines.json` (Android)

La app **no** basta con `google-services.json`: en runtime lee variables con `--dart-define-from-file`.

**En tu Mac:**

```bash
cp config/firebase_defines.json.example config/firebase_defines.json
```

**En la consola (2026) — de dónde copiar cada valor:**

1. ⚙ **Configuración del proyecto** → **General**:
   - **ID del proyecto** → `FIREBASE_PROJECT_ID`
   - **Número del proyecto** / **Project number** → `FIREBASE_MESSAGING_SENDER_ID`
   - **Bucket de Storage** (si aparece) → `FIREBASE_STORAGE_BUCKET`
2. En **Tus apps** → selecciona la app **Android**:
   - **ID de la app** / **App ID** (formato `1:123456789:android:abcdef`) → `FIREBASE_APP_ID` (**solo Android**).
   - A veces la **Clave de API web** / **Web API Key** en la misma pantalla → `FIREBASE_API_KEY` (también está dentro de `google-services.json`).

| Clave en JSON | Dónde obtenerla (Android) |
|---------------|---------------------------|
| `FIREBASE_API_KEY` | ⚙ General o `google-services.json` → `current_key` |
| `FIREBASE_APP_ID` | App **Android** → App ID `1:xxx:android:yyy` |
| `FIREBASE_MESSAGING_SENDER_ID` | Número del proyecto |
| `FIREBASE_PROJECT_ID` | ID del proyecto |
| `FIREBASE_STORAGE_BUCKET` | `*.appspot.com` o `*.firebasestorage.app` |
| `FIREBASE_IOS_BUNDLE_ID` | Déjalo `com.example.myPersonalFinanceApp` para más adelante |
| `GOOGLE_WEB_CLIENT_ID` | Google Cloud → Credenciales → Web |
| `GOOGLE_ANDROID_CLIENT_ID` | Google Cloud → Credenciales → Android |
| `ADMIN_EMAIL` | Tu Gmail admin |

`config/firebase_defines.json` también está en `.gitignore`.

### 1.6 Ejecutar en dispositivo Android

```bash
cd /ruta/a/my_personal_finance_app
flutter pub get
flutter devices   # copia el ID del teléfono
flutter run -d TU_DEVICE_ID \
  --dart-define-from-file=config/firebase_defines.json
```

Opcional:

```bash
flutter run -d TU_DEVICE_ID \
  --dart-define-from-file=config/firebase_defines.json \
  --dart-define=ADMIN_EMAIL=tu@gmail.com
```

### 1.7 Comprobar que Android quedó bien

| Señal | OK | Problema |
|-------|-----|----------|
| Log al arrancar | `Finanza: Firebase listo.` | `Finanza: Firebase omitido...` → falta defines |
| Login Google | Selector de cuenta | Error 10 → SHA-1 / package en Firebase |
| Login email | Usuario en Authentication → pestaña **Usuarios** | Método email no habilitado |
| Sin defines | Cuenta local SQLite | Esperado |

**En consola:** **Authentication → Users** debería mostrar usuarios nuevos tras login email/Google.

### 1.8 Android — resumen checklist

- [ ] App Android en **Tus apps** con package `com.example.my_personal_finance_app`
- [ ] `android/app/google-services.json` presente
- [ ] SHA-1 en la ficha de la app Android en ⚙ General
- [ ] `config/firebase_defines.json` con App ID **android** + OAuth IDs
- [ ] `flutter run` con `--dart-define-from-file=...`
- [ ] Log: `Finanza: Firebase listo.`

**Cuando todo lo anterior esté marcado, pasa a Web.**

---

## Parte 2 — Web (panel admin)

Objetivo: correr `admin_web` en local (o publicarlo en Firebase Hosting) e iniciar sesión con tu Gmail admin para ver analytics.

### 2.1 Registrar app Web en Firebase

**En la consola (2026):**

1. **Descripción general** → **Agregar app** → icono **`</>`** **Web**  
   *o* ⚙ **General** → **Tus apps** → **Agregar app** → **Web**.
2. **Apodo:** `finanza-admin` → **Registrar app**.
3. **Paso 2 — Agregar SDK de Firebase:** verás un bloque `firebaseConfig` con:

   ```javascript
   const firebaseConfig = {
     apiKey: "...",
     authDomain: "...",
     projectId: "...",
     storageBucket: "...",
     messagingSenderId: "...",
     appId: "1:...:web:..."
   };
   ```

   **Copia esos valores** (los pegarás en `admin_web/.env`). No necesitas pegar el script en el repo; Finanza ya usa Vite + variables `VITE_*`.
4. **Continuar en la consola**. Hosting (“también configurar Hosting”) es **opcional** para desarrollo local.

### 2.2 Archivo `admin_web/.env`

```bash
cd admin_web
cp env.example .env
```

Mapeo directo desde el `firebaseConfig` del paso 2.1:

```env
VITE_FIREBASE_API_KEY=          # apiKey
VITE_FIREBASE_AUTH_DOMAIN=      # authDomain (ej. tu-proyecto.firebaseapp.com)
VITE_FIREBASE_PROJECT_ID=       # projectId
VITE_FIREBASE_APP_ID=           # appId (debe contener :web:)
VITE_FIREBASE_MESSAGING_SENDER_ID=  # messagingSenderId
```

Usa la **app Web**, no Android/iOS.

### 2.3 Dominios autorizados (Auth)

**En la consola (2026):**

1. **Compilación → Authentication**.
2. Pestaña **Configuración** / **Settings** (arriba, no confundir con ⚙ del proyecto).
3. Subsección **Dominios autorizados** / **Authorized domains**.
4. Debe existir **`localhost`**. Si no: **Agregar dominio** / **Add domain** → `localhost` → **Agregar**.

Cuando despliegues Hosting, añade también `tu-proyecto.web.app` y `tu-proyecto.firebaseapp.com`.

### 2.4 Desarrollo local

```bash
cd admin_web
npm install
npm run dev
```

Abre la URL de Vite (normalmente `http://localhost:5173`).

### 2.5 Permisos de admin en el panel

El panel llama la Cloud Function `getAdminAnalytics`. Necesitas:

1. **`ADMIN_EMAILS`** en Cloud Functions ([Parte 5](#parte-5--backend-compartido-reglas-índices-y-functions)).
2. Login al menos una vez en la **app móvil** con el mismo Gmail (`syncLoginMetadata`).

### 2.6 Publicar panel en Firebase Hosting (opcional)

**En la consola (2026)** — solo para verificar después del deploy:

**Compilación → Hosting** → verás la URL **`.web.app`**.

**En tu Mac:**

```bash
cd admin_web
npm run build
cd ..
firebase use TU_PROJECT_ID
firebase deploy --only hosting
```

Tras el deploy, añade el dominio `.web.app` en **Authentication → Settings → Authorized domains**.

### 2.7 Web — resumen checklist

- [ ] App **Web** en **Tus apps** (App ID con `:web:`)
- [ ] `admin_web/.env` completo
- [ ] `localhost` en dominios autorizados
- [ ] `npm run dev` + login Google
- [ ] (Opcional) Hosting desplegado

**Cuando el panel local te deje entrar, pasa a iOS si lo necesitas.**

---

## Parte 3 — iOS

Objetivo: compilar en simulador o dispositivo Apple con Firebase Auth y Google Sign-In.

### 3.1 Registrar app iOS en Firebase

**En la consola (2026):**

1. **Descripción general** → **Agregar app** → **iOS** (icono Apple)  
   *o* ⚙ **General** → **Tus apps** → **Agregar app** → **iOS**.
2. **ID del paquete de Apple** / **Apple bundle ID:**  
   `com.example.myPersonalFinanceApp`
3. **Apodo** (opcional) → **Registrar app**.
4. **Descargar GoogleService-Info.plist** en el asistente → [3.2](#32-colocar-googleservice-infoplist).
5. Pasos de “Agregar SDK” → puedes omitir hasta volver a la consola.

### 3.2 Colocar `GoogleService-Info.plist`

```
ios/Runner/GoogleService-Info.plist
```

En **Xcode**: abre `ios/Runner.xcworkspace` → arrastra el plist al grupo **Runner** si no está → marca **Copy items if needed** y target **Runner**.

### 3.3 URL scheme para Google Sign-In

Abre `GoogleService-Info.plist` → clave **`REVERSED_CLIENT_ID`**.

Añade en `ios/Runner/Info.plist` (si no está):

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>PEGA_AQUI_REVERSED_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

### 3.4 Cliente OAuth iOS

**Google Cloud Console → Credenciales:**

- Cliente tipo **iOS** con bundle `com.example.myPersonalFinanceApp` → `GOOGLE_IOS_CLIENT_ID`.  
- Si falta: **Crear credenciales → ID de cliente OAuth → iOS** (Firebase a veces lo crea al registrar la app Apple).

Sigue necesitando **`GOOGLE_WEB_CLIENT_ID`**.

### 3.5 `config/firebase_defines.json` en iOS

Al compilar **iOS**, `FIREBASE_APP_ID` debe ser el de la app **Apple** en ⚙ **General → Tus apps → iOS** (formato `1:xxx:ios:yyy`), igual que **`GOOGLE_APP_ID`** en el plist.

Práctica: `config/firebase_defines.ios.json` vs `.android.json` y el `--dart-define-from-file` que corresponda.

### 3.6 Ejecutar en iOS

```bash
flutter run -d ios \
  --dart-define-from-file=config/firebase_defines.json
```

### 3.7 iOS — resumen checklist

- [ ] App iOS en **Tus apps** con bundle correcto
- [ ] `GoogleService-Info.plist` en Runner
- [ ] `REVERSED_CLIENT_ID` en `Info.plist`
- [ ] Defines con App ID **ios** + client IDs
- [ ] Login Google y email OK

---

## Parte 4 — FlutterFire (opcional, todas las plataformas)

```bash
cd /ruta/a/my_personal_finance_app
flutterfire configure
```

El CLI lista proyectos Firebase de tu cuenta → eliges plataformas → escribe/actualiza archivos nativos.

Este repo sigue usando **`--dart-define-from-file=config/firebase_defines.json`**. Tras FlutterFire, completa manualmente los `GOOGLE_*_CLIENT_ID` y `ADMIN_EMAIL` (plantilla: `config/firebase_defines.json.example`).

---

## Parte 5 — Backend compartido (reglas, índices y Functions)

### 5.1 Enlazar proyecto en CLI

```bash
cd /ruta/a/my_personal_finance_app
firebase login
firebase use --add
```

El CLI muestra lista de proyectos (mismo **Project ID** que en ⚙ Firebase).

### 5.2 Variables de admin (Functions)

```bash
cp functions/.env.example functions/.env
```

```env
ADMIN_EMAILS=tu@gmail.com
```

**En la consola (2026)** — revisar después del deploy:

1. **Compilación → Functions**.
2. Clic en función (`syncLoginMetadata`, `getAdminAnalytics`).
3. Pestaña **Configuración** / detalle → **Variables de entorno** / **Environment variables** → debe existir `ADMIN_EMAILS`.

(O edita en [Google Cloud Console → Cloud Run / Functions](https://console.cloud.google.com/functions) si la UI de Firebase redirige ahí.)

### 5.3 Plan Blaze

**En la consola (2026):**

1. ⚙ **Configuración del proyecto** → **Uso y facturación** / **Usage and billing**.
2. **Modificar plan** / **Modify plan** → **Blaze (pago por uso)**.
3. Vincula cuenta de facturación (cobro suele ser **0 $** con uso bajo).

Sin Blaze, `firebase deploy --only functions` suele fallar con mensaje de plan.

### 5.4 Instalar dependencias y desplegar

```bash
cd functions && npm install && cd ..
firebase deploy --only firestore:rules,firestore:indexes,functions
```

**Ver reglas publicadas en consola:** Firestore → pestaña **Reglas** → debe coincidir con `firestore.rules` del repo.

Hosting:

```bash
cd admin_web && npm run build && cd ..
firebase deploy --only hosting
```

### 5.5 Flujo end-to-end

1. Login en app móvil.
2. **`syncLoginMetadata`** → Firestore **Datos** → colección `app_users`.
3. Panel web → **`getAdminAnalytics`**.

---

## Modo sin Firebase

```bash
flutter run
```

Sin defines: login local SQLite; log `Finanza: Firebase omitido...`.

---

## Problemas frecuentes (consola + app)

| Síntoma | Dónde mirar en consola / cloud | Qué hacer |
|---------|--------------------------------|-----------|
| `Firebase omitido` | — | `firebase_defines.json` + `flutter run --dart-define-from-file` |
| Google error 10 (Android) | ⚙ → app Android → SHA-1 | [1.3](#13-huella-sha-1-obligatorio-para-google-sign-in) |
| Google iOS vuelve con error | — | [3.3](#33-url-scheme-para-google-sign-in) URL scheme |
| Login OK, Firestore vacío | Firestore → Datos | Desplegar Functions [5.4](#54-instalar-dependencias-y-desplegar) |
| Panel “sin permisos” | Functions → env `ADMIN_EMAILS` | [5.2](#52-variables-de-admin-functions) + login móvil |
| `auth/unauthorized-domain` | Auth → Settings → Authorized domains | Añadir `localhost` o dominio Hosting |
| Deploy functions falla | ⚙ Usage and billing | Plan **Blaze** |
| No encuentro Firestore | Menú | **Bases de datos y almacenamiento → Firestore** |

---

## Orden recomendado (recordatorio)

1. **Parte 0** — Proyecto + Auth + Firestore  
2. **Parte 1 — Android** — checklist completo  
3. **Parte 2 — Web**  
4. **Parte 3 — iOS**  
5. **Parte 5 — Backend**  
6. **Parte 4** — FlutterFire opcional  

---

## Archivos sensibles (no commitear)

- `android/app/google-services.json`
- `config/firebase_defines.json`
- `admin_web/.env`
- `functions/.env`

Plantillas: `config/firebase_defines.json.example`, `admin_web/env.example`, `functions/.env.example`.
