# KeepInventory

Aplicación móvil de **control de inventario** desarrollada en **Flutter (Dart)** con **Android Studio**.

## Funcionalidades
- Registro, inicio de sesión, recuperación de contraseña y cierre de sesión (Firebase Authentication).
- Roles: **Administrador** y **Usuario** con permisos distintos.
- Inventario: crear, consultar, modificar y eliminar productos (CRUD) con validaciones, mensajes y confirmación.
- Persistencia **local** (SQLite + SharedPreferences) y **remota** (Cloud Firestore), con modo sin conexión.
- Consumo de API REST (GET, POST, PUT, PATCH, DELETE) en el módulo "Catálogo API".
- Perfil, configuración (modo oscuro) y gestión de usuarios (solo Administrador).

## Permisos por rol
| Acción | Usuario | Administrador |
|---|:-:|:-:|
| Ver / crear / editar productos | ✔ | ✔ |
| Eliminar productos | ✖ | ✔ |
| Catálogo API | ✖ | ✔ |
| Gestionar usuarios y roles | ✖ | ✔ |
| Editar su perfil | ✔ | ✔ |

## Arquitectura
```
lib/
├── main.dart              # arranque, inyección de dependencias, AuthGate
├── firebase_options.dart  # generado por flutterfire configure
├── models/                # AppUser, Product, CatalogItem
├── views/                 # pantallas (Presentación)
├── widgets/               # componentes reutilizables
├── controllers/           # lógica de negocio / estado (Provider)
├── repositories/          # coordinan fuentes de datos (local + remota)
├── services/              # Firebase Auth, Firestore, SQLite, API REST
├── utils/                 # tema, validaciones, constantes, helpers de UI
└── routes/                # mapa de navegación y rutas protegidas
```
Flujo: `views → controllers → repositories → services → Firebase / SQLite / API`.

## Cómo ejecutarlo (Android Studio)
1. Instala Flutter y Android Studio (con los plugins Flutter y Dart).
2. Crea la base de plataforma **dentro de esta carpeta**:
   ```bash
   flutter create --project-name keep_inventory --org com.keepinventory .
   ```
   (No sobrescribe `lib/`, `pubspec.yaml` ni `test/`; si pregunta, conserva los existentes.)
3. Crea un proyecto en https://console.firebase.google.com y activa:
   - **Authentication → Correo/contraseña**
   - **Firestore Database** (modo producción) y pega el contenido de `firestore.rules` en la pestaña *Reglas*.
4. Conecta Firebase:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Esto reemplaza `lib/firebase_options.dart`.
5. En `android/app/build.gradle` verifica `minSdk = 23` (o `minSdkVersion 23`).
6. En `android/app/src/main/AndroidManifest.xml` agrega, antes de `<application>`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   ```
7. Ejecuta:
   ```bash
   flutter pub get
   flutter test
   flutter run
   ```

## Cuenta Administrador
Registra una cuenta con el correo `admin@keepinventory.com` (definido en `lib/utils/constants.dart`
y en `firestore.rules`): nace como Administrador. Desde "Usuarios" puede promover a otros.
Cambia ese correo por el tuyo antes de entregar si lo prefieres (en ambos archivos).

## API utilizada
DummyJSON — https://dummyjson.com/products (GET, POST `/add`, PUT, PATCH, DELETE).
Es una API de pruebas: simula los cambios sin guardarlos de forma permanente.

## Control de versiones
Ver el documento de la práctica. Ramas: `main` (estable) y `feature/*` para funciones nuevas.
