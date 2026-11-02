/// Nivel de prioridad de una tarea. El orden de declaración define el
/// orden de la lista: primero [alta], luego [media] y al final [baja].
enum Prioridad {
  alta('Alta'),
  media('Media'),
  baja('Baja');

  const Prioridad(this.etiqueta);

  /// Texto que se muestra en la interfaz.
  final String etiqueta;
}

/// Modelo inmutable de una tarea.
class Tarea {
  const Tarea({
    required this.id,
    required this.titulo,
    this.prioridad = Prioridad.media,
    this.completada = false,
  });

  final int id;
  final String titulo;
  final Prioridad prioridad;
  final bool completada;

  /// Devuelve una copia de la tarea cambiando solo los campos indicados.
  Tarea copyWith({String? titulo, Prioridad? prioridad, bool? completada}) {
    return Tarea(
      id: id,
      titulo: titulo ?? this.titulo,
      prioridad: prioridad ?? this.prioridad,
      completada: completada ?? this.completada,
    );
  }

  @override
  String toString() {
    final String estado = completada ? 'completada' : 'pendiente';
    return 'Tarea($id, $titulo, ${prioridad.etiqueta}, $estado)';
  }
}
