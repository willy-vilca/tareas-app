/// Entornos en los que puede ejecutarse la app.
enum Entorno {
  desarrollo('DEV'),
  pruebas('QA'),
  produccion('PROD');

  const Entorno(this.etiqueta);

  /// Etiqueta corta que se muestra en la cinta (banner) de la app.
  final String etiqueta;

  /// Convierte un texto (por ejemplo, el valor de `--dart-define`) en un
  /// [Entorno]. Si el texto no coincide, se asume [Entorno.desarrollo].
  static Entorno desdeTexto(String valor) {
    final String normalizado = valor.trim().toLowerCase();
    for (final Entorno entorno in Entorno.values) {
      if (entorno.name == normalizado) {
        return entorno;
      }
    }
    return Entorno.desarrollo;
  }
}

/// Configuración que el pipeline inyecta al compilar con `--dart-define`.
///
/// Ejemplo:
/// `flutter build web --dart-define=ENTORNO=produccion
///  --dart-define=APP_VERSION=1.2.0 --dart-define=BUILD_NUMBER=15
///  --dart-define=GIT_SHA=a1b2c3d --dart-define=FLAG_ESTADISTICAS=true`
class AppConfig {
  const AppConfig({
    required this.entorno,
    required this.version,
    required this.numeroBuild,
    required this.gitSha,
    required this.estadisticasActivas,
  });

  /// Lee los valores definidos en tiempo de compilación. Si no se definen
  /// (por ejemplo, con un `flutter run` normal), usa valores locales.
  factory AppConfig.desdeEntorno() {
    const String entorno =
        String.fromEnvironment('ENTORNO', defaultValue: 'desarrollo');
    const String version =
        String.fromEnvironment('APP_VERSION', defaultValue: 'local');
    const String numeroBuild =
        String.fromEnvironment('BUILD_NUMBER', defaultValue: '0');
    const String gitSha =
        String.fromEnvironment('GIT_SHA', defaultValue: 'sin-commit');
    const bool estadisticas = bool.fromEnvironment('FLAG_ESTADISTICAS');
    return AppConfig(
      entorno: Entorno.desdeTexto(entorno),
      version: version,
      numeroBuild: numeroBuild,
      gitSha: gitSha,
      estadisticasActivas: estadisticas,
    );
  }

  final Entorno entorno;
  final String version;
  final String numeroBuild;
  final String gitSha;

  /// Feature flag: muestra u oculta la tarjeta de estadísticas.
  final bool estadisticasActivas;

  bool get esProduccion => entorno == Entorno.produccion;

  /// Texto completo de la versión, por ejemplo `v1.2.0+15 (a1b2c3d)`.
  String get versionCompleta => 'v$version+$numeroBuild ($gitSha)';
}
