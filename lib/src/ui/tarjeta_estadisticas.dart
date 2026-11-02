import 'package:flutter/material.dart';
import 'package:tareas_app/src/logica/gestor_tareas.dart';

/// Tarjeta de estadísticas. Solo se muestra cuando el feature flag
/// `FLAG_ESTADISTICAS` está activo (ver ejercicio 08).
class TarjetaEstadisticas extends StatelessWidget {
  const TarjetaEstadisticas({super.key, required this.gestor});

  final GestorTareas gestor;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('tarjeta-estadisticas'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _Dato(titulo: 'Total', valor: gestor.total),
            _Dato(titulo: 'Pendientes', valor: gestor.pendientes),
            _Dato(titulo: 'Urgentes', valor: gestor.urgentes),
          ],
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.titulo, required this.valor});

  final String titulo;
  final int valor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textos = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        Text('$valor', style: textos.headlineSmall),
        Text(titulo, style: textos.bodySmall),
      ],
    );
  }
}
