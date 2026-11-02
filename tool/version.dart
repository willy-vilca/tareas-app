// =====================================================================
// EJERCICIO 05 - Versionado semántico (SemVer)
// Destino : tool/version.dart
// Probar  : dart run tool/version.dart          (muestra la versión)
//           dart run tool/version.dart patch    (1.0.0+1 -> 1.0.1+2)
//           dart run tool/version.dart minor    (1.0.1+2 -> 1.1.0+3)
//           dart run tool/version.dart major    (1.1.0+3 -> 2.0.0+4)
// Regla   : MAYOR.MENOR.PARCHE+BUILD. El BUILD (versionCode de Android)
//           siempre sube: las tiendas rechazan un número repetido.
// =====================================================================
import 'dart:io';

void main(List<String> argumentos) {
  final File pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    stderr.writeln('Ejecuta el script desde la raíz del proyecto.');
    exitCode = 2;
    return;
  }
  final String contenido = pubspec.readAsStringSync();

  // 1) Buscar la línea "version: 1.2.3+4" con una expresión regular.
  final RegExp patron = RegExp(
    r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)',
    multiLine: true,
  );
  final RegExpMatch? m = patron.firstMatch(contenido);
  if (m == null) {
    stderr.writeln('pubspec.yaml debe tener una línea: version: 1.0.0+1');
    exitCode = 2;
    return;
  }
  int mayor = int.parse(m.group(1)!);
  int menor = int.parse(m.group(2)!);
  int parche = int.parse(m.group(3)!);
  int build = int.parse(m.group(4)!);
  final String actual = '$mayor.$menor.$parche+$build';

  // 2) Sin argumentos: solo se muestra la versión actual.
  if (argumentos.isEmpty) {
    stdout.writeln('Versión actual: $actual');
    return;
  }

  // 3) Aplicar la regla de SemVer según el tipo de cambio.
  switch (argumentos.first) {
    case 'major': // cambio incompatible
      mayor++;
      menor = 0;
      parche = 0;
    case 'minor': // nueva funcionalidad compatible
      menor++;
      parche = 0;
    case 'patch': // corrección de errores
      parche++;
    default:
      stderr.writeln('Uso: dart run tool/version.dart [major|minor|patch]');
      exitCode = 2;
      return;
  }
  build++; // el build siempre aumenta

  // 4) Guardar la nueva versión en pubspec.yaml.
  final String nueva = '$mayor.$menor.$parche+$build';
  pubspec.writeAsStringSync(contenido.replaceFirst(patron, 'version: $nueva'));
  stdout.writeln('Versión: $actual -> $nueva');
}
