#!/usr/bin/env bash
# Crea el historial de Git de KeepInventory por etapas (commits descriptivos, 1 rama y 1 merge).
# USO (desde la carpeta raíz del proyecto, después de `flutter create .`):
#     bash scripts/historial_git.sh
# NOTA: los commits intermedios muestran el avance por etapas; solo la versión final
# (después del merge) compila completa. No hace push: al final se indican los comandos.
set -e

if [ ! -f pubspec.yaml ]; then echo "Ejecuta este script en la raíz del proyecto."; exit 1; fi
git init -b main 2>/dev/null || git init
git config user.name  >/dev/null || { echo "Configura: git config user.name \"Tu Nombre\""; exit 1; }
git config user.email >/dev/null || { echo "Configura: git config user.email \"tu@correo.com\""; exit 1; }

add() { for p in "$@"; do [ -e "$p" ] && git add "$p"; done; return 0; }

echo ">> git status inicial (todo aparece como no rastreado)"; git status --short | head -20

# 1) Versión inicial: esqueleto del proyecto (sin lib/ todavía)
add .gitignore README.md pubspec.yaml pubspec.lock analysis_options.yaml android ios web linux macos windows .metadata
git commit -m "Versión inicial del proyecto móvil"

# 2) Estructura, tema, validaciones y modelos
add lib/utils lib/models/app_user.dart lib/models/product.dart lib/firebase_options.dart
git commit -m "Se agregó estructura del proyecto, tema visual, validaciones y modelos"

# 3) Autenticación
add lib/services/auth_service.dart lib/services/firestore_service.dart lib/repositories/user_repository.dart \
    lib/controllers/auth_controller.dart lib/widgets/app_text_field.dart lib/widgets/primary_button.dart \
    lib/views/login_view.dart lib/views/register_view.dart lib/views/forgot_password_view.dart
git commit -m "Se agregó registro, inicio de sesión y recuperación de contraseña"

# 4) Productos: CRUD + persistencia local y remota
add lib/services/local_db_service.dart lib/repositories/product_repository.dart lib/controllers/product_controller.dart \
    lib/widgets/product_card.dart lib/widgets/product_thumb.dart lib/views/products_view.dart lib/views/product_form_view.dart
git commit -m "Se agregó pantalla de productos con CRUD, SQLite y Firestore"

# 5) Rama para una nueva función: catálogo API
git switch -c feature/catalogo-api
add lib/models/catalog_item.dart lib/services/api_service.dart lib/views/catalog_api_view.dart
git commit -m "Se agregó módulo de catálogo con consumo de API REST"

# 6) Vuelta a main: pantalla principal, perfil, configuración, roles y rutas
git switch main
add lib/controllers/settings_controller.dart lib/widgets/protected_route.dart lib/views/home_view.dart \
    lib/views/profile_view.dart lib/views/settings_view.dart lib/views/users_admin_view.dart \
    lib/routes lib/main.dart
git commit -m "Se modificó diseño de la pantalla principal y se agregó perfil, configuración y roles"

# 7) Merge de la rama
git merge --no-ff feature/catalogo-api -m "Se integró el módulo de catálogo API a la rama principal"

# 8) Pruebas, reglas de seguridad, scripts y documentación
add test firestore.rules scripts
git commit -m "Se agregaron pruebas unitarias, reglas de Firestore y scripts"
git tag -a v1.0.0 -m "Versión 1.0.0 de KeepInventory"

echo; echo ">> Historial:"; git log --oneline --graph --decorate
echo
echo "Siguiente paso (reemplaza la URL por la de tu repositorio de GitHub):"
echo "  git remote add origin https://github.com/USUARIO/app-control-inventario.git"
echo "  git remote -v"
echo "  git push -u origin main"
echo "  git push -u origin feature/catalogo-api"
echo "  git push --tags"
