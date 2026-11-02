import 'package:flutter_test/flutter_test.dart';
import 'package:tareas_app/src/config/app_config.dart';

void main() {
  group('Entorno.desdeTexto', () {
    test('reconoce los entornos válidos sin importar mayúsculas', () {
      expect(Entorno.desdeTexto('produccion'), Entorno.produccion);
      expect(Entorno.desdeTexto(' PRUEBAS '), Entorno.pruebas);
      expect(Entorno.desdeTexto('desarrollo'), Entorno.desarrollo);
    });

    test('un valor desconocido se trata como desarrollo', () {
      expect(Entorno.desdeTexto('staging'), Entorno.desarrollo);
      expect(Entorno.desdeTexto(''), Entorno.desarrollo);
    });
  });

  group('AppConfig', () {
    test('sin --dart-define usa los valores locales por defecto', () {
      final AppConfig config = AppConfig.desdeEntorno();
      expect(config.entorno, Entorno.desarrollo);
      expect(config.version, 'local');
      expect(config.numeroBuild, '0');
      expect(config.gitSha, 'sin-commit');
      expect(config.estadisticasActivas, isFalse);
      expect(config.esProduccion, isFalse);
    });

    test('versionCompleta combina versión, build y commit', () {
      const AppConfig config = AppConfig(
        entorno: Entorno.produccion,
        version: '1.2.0',
        numeroBuild: '15',
        gitSha: 'a1b2c3d',
        estadisticasActivas: true,
      );
      expect(config.versionCompleta, 'v1.2.0+15 (a1b2c3d)');
      expect(config.esProduccion, isTrue);
      expect(config.entorno.etiqueta, 'PROD');
    });
  });
}
