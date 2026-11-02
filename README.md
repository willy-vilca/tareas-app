# TareasApp – app base del Módulo 38 (Mantenimiento, CI/CD y DevOps móvil)

Gestor de tareas sencillo hecho en Flutter. Su función es servir como
proyecto real sobre el que se construyen y prueban los 10 ejercicios de la
guía: análisis estático, hook de Git, pipelines de GitHub Actions,
versionado, releases, despliegue web, Dependabot y métricas DORA.

## Qué hace la app

- Crear tareas con prioridad (Alta, Media, Baja) y validar el título
  (vacío, longitud máxima de 60 caracteres, duplicados).
- Marcar como completada, filtrar (Todas / Pendientes / Hechas) y eliminar.
- Mostrar el porcentaje de avance.
- Cinta (banner) con el entorno: DEV, QA o PROD (oculta en producción).
- Diálogo "Acerca de" con versión, build y commit inyectados por el pipeline.
- Feature flag `FLAG_ESTADISTICAS` que muestra una tarjeta de estadísticas.

## Estructura

```
lib/
  main.dart                       punto de entrada
  src/app.dart                    MaterialApp + cinta del entorno
  src/config/app_config.dart      configuración leída con --dart-define
  src/modelo/tarea.dart           modelo Tarea y enum Prioridad
  src/logica/gestor_tareas.dart   lógica de negocio (sin Flutter)
  src/ui/pantalla_tareas.dart     pantalla principal
  src/ui/tarjeta_estadisticas.dart  tarjeta controlada por feature flag
test/
  gestor_tareas_test.dart         pruebas unitarias de la lógica
  app_config_test.dart            pruebas de configuración
  widget_test.dart                pruebas de interfaz
tool/                             scripts DevOps de los ejercicios (Dart)
```

## Preparación (una sola vez)

Requisitos: Flutter estable, Git y una cuenta de GitHub.

```bash
# 1. Generar las carpetas de plataforma (no modifica lib/ ni test/)
flutter create . --project-name tareas_app --org pe.edu.utp.moviles --platforms=android,web

# 2. Dependencias, correcciones automáticas y formato
flutter pub get
dart fix --apply
dart format .

# 3. Comprobar que todo está bien
flutter analyze
flutter test

# 4. Ejecutar
flutter run -d chrome
flutter run -d chrome --dart-define=ENTORNO=pruebas --dart-define=FLAG_ESTADISTICAS=true
```

## Variables que inyecta el pipeline (`--dart-define`)

| Variable | Valor por defecto | Uso |
|---|---|---|
| `ENTORNO` | `desarrollo` | `desarrollo`, `pruebas` o `produccion` |
| `APP_VERSION` | `local` | versión semántica (de pubspec.yaml) |
| `BUILD_NUMBER` | `0` | número de build / ejecución del pipeline |
| `GIT_SHA` | `sin-commit` | commit desplegado (7 caracteres) |
| `FLAG_ESTADISTICAS` | `false` | muestra la tarjeta de estadísticas |
