import 'package:tareas_app/src/modelo/tarea.dart';

/// Filtros disponibles para la lista de tareas.
enum FiltroTareas { todas, pendientes, completadas }

/// Lógica de negocio de la app. No depende de Flutter, por eso se puede
/// probar con pruebas unitarias rápidas (ideal para un pipeline de CI).
class GestorTareas {
  /// Cantidad máxima de caracteres permitida en un título.
  static const int longitudMaxima = 60;

  final List<Tarea> _tareas = <Tarea>[];
  int _siguienteId = 1;

  /// Copia de solo lectura de todas las tareas, en orden de creación.
  List<Tarea> get tareas => List<Tarea>.unmodifiable(_tareas);

  int get total => _tareas.length;

  int get completadas => _tareas.where((Tarea t) => t.completada).length;

  int get pendientes => total - completadas;

  /// Tareas pendientes de prioridad alta.
  int get urgentes => _tareas
      .where((Tarea t) => !t.completada && t.prioridad == Prioridad.alta)
      .length;

  /// Porcentaje de avance redondeado (0 a 100).
  int get porcentajeAvance {
    if (total == 0) {
      return 0;
    }
    return (completadas * 100 / total).round();
  }

  /// Devuelve un mensaje de error si el título no es válido, o `null`.
  String? validarTitulo(String titulo) {
    final String limpio = titulo.trim();
    if (limpio.isEmpty) {
      return 'El título no puede estar vacío.';
    }
    if (limpio.length > longitudMaxima) {
      return 'El título no puede superar $longitudMaxima caracteres.';
    }
    final String clave = limpio.toLowerCase();
    final bool duplicado =
        _tareas.any((Tarea t) => t.titulo.toLowerCase() == clave);
    if (duplicado) {
      return 'Ya existe una tarea con ese título.';
    }
    return null;
  }

  /// Agrega una tarea nueva. Lanza [ArgumentError] si el título no es
  /// válido.
  Tarea agregar(String titulo, {Prioridad prioridad = Prioridad.media}) {
    final String? error = validarTitulo(titulo);
    if (error != null) {
      throw ArgumentError(error);
    }
    final Tarea nueva = Tarea(
      id: _siguienteId,
      titulo: titulo.trim(),
      prioridad: prioridad,
    );
    _siguienteId++;
    _tareas.add(nueva);
    return nueva;
  }

  /// Marca la tarea como completada o pendiente (alterna su estado).
  void alternar(int id) {
    final int indice = _indiceDe(id);
    final Tarea actual = _tareas[indice];
    _tareas[indice] = actual.copyWith(completada: !actual.completada);
  }

  /// Elimina la tarea con el [id] indicado.
  void eliminar(int id) {
    _tareas.removeAt(_indiceDe(id));
  }

  /// Elimina todas las tareas completadas y devuelve cuántas se borraron.
  int limpiarCompletadas() {
    final int antes = _tareas.length;
    _tareas.removeWhere((Tarea t) => t.completada);
    return antes - _tareas.length;
  }

  /// Devuelve las tareas según el filtro, ordenadas por prioridad
  /// (alta primero) y luego por orden de creación.
  List<Tarea> filtrar(FiltroTareas filtro) {
    final List<Tarea> resultado = _tareas
        .where(
          (Tarea t) => switch (filtro) {
            FiltroTareas.todas => true,
            FiltroTareas.pendientes => !t.completada,
            FiltroTareas.completadas => t.completada,
          },
        )
        .toList();
    resultado.sort(_compararPorPrioridad);
    return resultado;
  }

  static int _compararPorPrioridad(Tarea a, Tarea b) {
    final int porPrioridad = a.prioridad.index.compareTo(b.prioridad.index);
    if (porPrioridad != 0) {
      return porPrioridad;
    }
    return a.id.compareTo(b.id);
  }

  int _indiceDe(int id) {
    final int indice = _tareas.indexWhere((Tarea t) => t.id == id);
    if (indice == -1) {
      throw StateError('No existe una tarea con id $id.');
    }
    return indice;
  }
}
