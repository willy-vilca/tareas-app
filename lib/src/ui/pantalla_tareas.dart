import 'package:flutter/material.dart';
import 'package:tareas_app/src/config/app_config.dart';
import 'package:tareas_app/src/logica/gestor_tareas.dart';
import 'package:tareas_app/src/modelo/tarea.dart';
import 'package:tareas_app/src/ui/tarjeta_estadisticas.dart';

/// Pantalla principal: crear, completar, filtrar y eliminar tareas.
class PantallaTareas extends StatefulWidget {
  const PantallaTareas({super.key, required this.config});

  final AppConfig config;

  @override
  State<PantallaTareas> createState() => _PantallaTareasState();
}

class _PantallaTareasState extends State<PantallaTareas> {
  final GestorTareas _gestor = GestorTareas();
  final TextEditingController _controlador = TextEditingController();
  Prioridad _prioridad = Prioridad.media;
  FiltroTareas _filtro = FiltroTareas.todas;
  String? _error;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _agregar() {
    final String? error = _gestor.validarTitulo(_controlador.text);
    setState(() {
      _error = error;
      if (error == null) {
        _gestor.agregar(_controlador.text, prioridad: _prioridad);
        _controlador.clear();
      }
    });
  }

  void _mostrarAcercaDe() {
    final AppConfig config = widget.config;
    showDialog<void>(
      context: context,
      builder: (BuildContext contextoDialogo) {
        return AlertDialog(
          title: const Text('Acerca de TareasApp'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Versión: ${config.version}'),
              Text('Build: ${config.numeroBuild}'),
              Text('Commit: ${config.gitSha}'),
              Text('Entorno: ${config.entorno.name}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(contextoDialogo).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Tarea> visibles = _gestor.filtrar(_filtro);
    final double avance =
        _gestor.total == 0 ? 0.0 : _gestor.completadas / _gestor.total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TareasApp'),
        actions: <Widget>[
          IconButton(
            key: const Key('boton-acerca-de'),
            tooltip: 'Acerca de',
            icon: const Icon(Icons.info_outline),
            onPressed: _mostrarAcercaDe,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      key: const Key('campo-titulo'),
                      controller: _controlador,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (String _) {
                        // Agregar con la tecla Enter. No tiene prueba propia:
                        // por eso la cobertura no llega al 100 % (ej. 04).
                        _agregar();
                      },
                      decoration: InputDecoration(
                        labelText: 'Nueva tarea',
                        errorText: _error,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: const Key('boton-agregar'),
                    onPressed: _agregar,
                    child: const Text('Agregar'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: <Widget>[
                  for (final Prioridad prioridad in Prioridad.values)
                    ChoiceChip(
                      label: Text(prioridad.etiqueta),
                      selected: _prioridad == prioridad,
                      onSelected: (bool _) {
                        setState(() => _prioridad = prioridad);
                      },
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'Avance: ${_gestor.porcentajeAvance}% '
                '(${_gestor.completadas} de ${_gestor.total})',
                key: const Key('texto-avance'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(value: avance),
            ),
            if (widget.config.estadisticasActivas)
              TarjetaEstadisticas(gestor: _gestor),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SegmentedButton<FiltroTareas>(
                segments: const <ButtonSegment<FiltroTareas>>[
                  ButtonSegment<FiltroTareas>(
                    value: FiltroTareas.todas,
                    label: Text('Todas'),
                  ),
                  ButtonSegment<FiltroTareas>(
                    value: FiltroTareas.pendientes,
                    label: Text('Pendientes'),
                  ),
                  ButtonSegment<FiltroTareas>(
                    value: FiltroTareas.completadas,
                    label: Text('Hechas'),
                  ),
                ],
                selected: <FiltroTareas>{_filtro},
                showSelectedIcon: false,
                onSelectionChanged: (Set<FiltroTareas> seleccion) {
                  setState(() => _filtro = seleccion.first);
                },
              ),
            ),
            Expanded(
              child: visibles.isEmpty
                  ? const Center(child: Text('No hay tareas para mostrar.'))
                  : ListView.builder(
                      itemCount: visibles.length,
                      itemBuilder: (BuildContext context, int indice) {
                        final Tarea tarea = visibles[indice];
                        return _FilaTarea(
                          tarea: tarea,
                          alCambiar: () {
                            setState(() => _gestor.alternar(tarea.id));
                          },
                          alEliminar: () {
                            setState(() => _gestor.eliminar(tarea.id));
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaTarea extends StatelessWidget {
  const _FilaTarea({
    required this.tarea,
    required this.alCambiar,
    required this.alEliminar,
  });

  final Tarea tarea;
  final VoidCallback alCambiar;
  final VoidCallback alEliminar;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey<String>('tarea-${tarea.id}'),
      leading: Checkbox(
        value: tarea.completada,
        onChanged: (bool? _) => alCambiar(),
      ),
      title: Text(
        tarea.titulo,
        style: tarea.completada
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text('Prioridad ${tarea.prioridad.etiqueta}'),
      trailing: IconButton(
        tooltip: 'Eliminar',
        icon: const Icon(Icons.delete_outline),
        onPressed: alEliminar,
      ),
    );
  }
}
