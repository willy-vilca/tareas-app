// =====================================================================
// EJERCICIO 04 - Puerta de calidad: cobertura mínima de pruebas
// Destino : tool/cobertura.dart
// Probar  : flutter test --coverage
//           dart run tool/cobertura.dart 80     -> APROBADO
//           dart run tool/cobertura.dart 99.9   -> RECHAZADO (código 1)
// =====================================================================
import 'dart:io';

void main(List<String> argumentos) {
  // 1) Porcentaje mínimo exigido: primer argumento o 80 por defecto.
  final double minimo =
      argumentos.isEmpty ? 80.0 : double.tryParse(argumentos.first) ?? 80.0;

  // 2) Leer el reporte que genera "flutter test --coverage".
  final File reporte = File('coverage/lcov.info');
  if (!reporte.existsSync()) {
    stderr.writeln('No existe coverage/lcov.info. '
        'Ejecuta primero: flutter test --coverage');
    exitCode = 2;
    return;
  }

  // 3) Cada línea "DA:numero,veces" es una línea de código ejecutable.
  //    Si "veces" es mayor que 0, las pruebas la ejecutaron.
  int lineas = 0;
  int cubiertas = 0;
  for (final String linea in reporte.readAsLinesSync()) {
    if (linea.startsWith('DA:')) {
      final List<String> partes = linea.substring(3).split(',');
      final int veces = partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0;
      lineas++;
      if (veces > 0) {
        cubiertas++;
      }
    }
  }
  final double porcentaje = lineas == 0 ? 0.0 : cubiertas * 100 / lineas;

  // 4) Mostrar el resultado y terminar con el código de salida correcto:
  //    0 = aprobado, 1 = rechazado. El pipeline se detiene con 1.
  stdout.writeln('Líneas cubiertas: $cubiertas de $lineas');
  stdout.writeln('Cobertura: ${porcentaje.toStringAsFixed(1)} % '
      '(mínimo exigido: ${minimo.toStringAsFixed(1)} %)');
  if (porcentaje >= minimo) {
    stdout.writeln('APROBADO: la puerta de calidad se abre.');
  } else {
    stdout.writeln('RECHAZADO: faltan pruebas.');
    exitCode = 1;
  }
}
