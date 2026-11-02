// =====================================================================
// EJERCICIO 10 - Métricas DORA: medir el desempeño de DevOps
// Destino : tool/dora.dart
// Probar  : dart run tool/dora.dart
//           Luego cambia los datos de la lista "despliegues" (por ejemplo,
//           marca otro despliegue como fallido) y vuelve a ejecutar.
// =====================================================================
import 'dart:io';

/// Un despliegue a producción (una versión publicada).
class Despliegue {
  const Despliegue(
    this.version,
    this.horasDesdeCommit, {
    this.fallido = false,
    this.horasParaCorregir = 0,
  });

  final String version;
  final double horasDesdeCommit; // del commit a producción
  final bool fallido; // ¿causó un error en producción?
  final double horasParaCorregir; // cuánto tardó en solucionarse
}

// Historial de ejemplo de un equipo durante 4 semanas.
const int diasDelPeriodo = 28;
const List<Despliegue> despliegues = <Despliegue>[
  Despliegue('1.0.0', 30),
  Despliegue('1.1.0', 26),
  Despliegue('1.2.0', 20, fallido: true, horasParaCorregir: 3),
  Despliegue('1.2.1', 1),
  Despliegue('1.3.0', 40),
  Despliegue('1.4.0', 28),
  Despliegue('1.5.0', 22),
  Despliegue('1.6.0', 33),
];

void main() {
  // 1) Calcular las 4 métricas.
  final double porSemana = despliegues.length / (diasDelPeriodo / 7);
  final double entrega = mediana(<double>[
    for (final Despliegue d in despliegues) d.horasDesdeCommit,
  ]);
  final List<Despliegue> fallidos =
      despliegues.where((Despliegue d) => d.fallido).toList();
  final double tasaFallos = fallidos.length * 100 / despliegues.length;
  final double restauracion = fallidos.isEmpty
      ? 0.0
      : mediana(<double>[
          for (final Despliegue d in fallidos) d.horasParaCorregir,
        ]);

  // 2) Clasificar cada métrica según los umbrales de DORA.
  final List<String> nombres = <String>[
    'Frecuencia de despliegue',
    'Tiempo de entrega (mediana)',
    'Tasa de fallos',
    'Tiempo de restauración',
  ];
  final List<String> valores = <String>[
    '${porSemana.toStringAsFixed(1)} por semana',
    '${entrega.toStringAsFixed(1)} horas',
    '${tasaFallos.toStringAsFixed(1)} %',
    '${restauracion.toStringAsFixed(1)} horas',
  ];
  final List<String> niveles = <String>[
    nivel(porSemana >= 7, porSemana >= 1, porSemana >= 0.25),
    nivel(entrega < 24, entrega < 24 * 7, entrega < 24 * 30),
    nivel(tasaFallos <= 5, tasaFallos <= 10, tasaFallos <= 15),
    nivel(restauracion < 1, restauracion < 24, restauracion < 24 * 7),
  ];

  // 3) Mostrar el reporte.
  stdout.writeln('MÉTRICAS DORA '
      '(${despliegues.length} despliegues en $diasDelPeriodo días)');
  stdout.writeln('-' * 60);
  for (int i = 0; i < nombres.length; i++) {
    stdout.writeln(
      '${nombres[i].padRight(30)}${valores[i].padRight(18)}${niveles[i]}',
    );
  }
  stdout.writeln('-' * 60);

  // 4) El nivel global es el del indicador más débil.
  int peor = 0;
  for (int i = 1; i < niveles.length; i++) {
    if (ordenNivel.indexOf(niveles[i]) > ordenNivel.indexOf(niveles[peor])) {
      peor = i;
    }
  }
  stdout.writeln('Nivel global: ${niveles[peor]} '
      '(mejorar primero: ${nombres[peor]})');
}

/// Niveles de DORA, del mejor al peor.
const List<String> ordenNivel = <String>['ÉLITE', 'ALTO', 'MEDIO', 'BAJO'];

/// Devuelve el nivel según qué umbral se cumple primero.
String nivel(bool elite, bool alto, bool medio) {
  if (elite) {
    return 'ÉLITE';
  }
  if (alto) {
    return 'ALTO';
  }
  if (medio) {
    return 'MEDIO';
  }
  return 'BAJO';
}

/// Valor central de una lista (no se deja afectar por casos extremos).
double mediana(List<double> valores) {
  final List<double> copia = List<double>.of(valores)..sort();
  final int mitad = copia.length ~/ 2;
  if (copia.length.isOdd) {
    return copia[mitad];
  }
  return (copia[mitad - 1] + copia[mitad]) / 2;
}
