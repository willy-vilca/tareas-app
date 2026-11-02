import 'package:flutter_test/flutter_test.dart';
import 'package:tareas_app/src/logica/gestor_tareas.dart';
import 'package:tareas_app/src/modelo/tarea.dart';

void main() {
  late GestorTareas gestor;

  setUp(() {
    gestor = GestorTareas();
  });

  group('validarTitulo', () {
    test('rechaza un título vacío o con solo espacios', () {
      expect(gestor.validarTitulo(''), 'El título no puede estar vacío.');
      expect(gestor.validarTitulo('   '), 'El título no puede estar vacío.');
    });

    test('acepta exactamente la longitud máxima (caso límite)', () {
      final String limite = 'a' * GestorTareas.longitudMaxima;
      expect(gestor.validarTitulo(limite), isNull);
    });

    test('rechaza un título que supera la longitud máxima', () {
      final String largo = 'a' * (GestorTareas.longitudMaxima + 1);
      expect(gestor.validarTitulo(largo), contains('no puede superar'));
    });

    test('rechaza duplicados sin importar mayúsculas ni espacios', () {
      gestor.agregar('Estudiar CI/CD');
      expect(
        gestor.validarTitulo('  estudiar ci/cd '),
        'Ya existe una tarea con ese título.',
      );
    });

    test('acepta un título válido', () {
      expect(gestor.validarTitulo('Configurar pipeline'), isNull);
    });
  });

  group('agregar', () {
    test('asigna ids incrementales y recorta espacios', () {
      final Tarea primera = gestor.agregar('  Primera  ');
      final Tarea segunda =
          gestor.agregar('Segunda', prioridad: Prioridad.alta);
      expect(primera.id, 1);
      expect(primera.titulo, 'Primera');
      expect(primera.prioridad, Prioridad.media);
      expect(segunda.id, 2);
      expect(segunda.prioridad, Prioridad.alta);
      expect(gestor.total, 2);
    });

    test('lanza ArgumentError si el título no es válido', () {
      expect(() => gestor.agregar(''), throwsArgumentError);
      expect(gestor.total, 0);
    });

    test('la lista expuesta no se puede modificar desde fuera', () {
      gestor.agregar('Tarea protegida');
      expect(
        () => gestor.tareas.add(const Tarea(id: 99, titulo: 'Intrusa')),
        throwsUnsupportedError,
      );
    });
  });

  group('alternar y eliminar', () {
    test('alternar marca y desmarca una tarea', () {
      final Tarea tarea = gestor.agregar('Revisar PR');
      gestor.alternar(tarea.id);
      expect(gestor.completadas, 1);
      gestor.alternar(tarea.id);
      expect(gestor.completadas, 0);
    });

    test('eliminar quita la tarea indicada', () {
      final Tarea tarea = gestor.agregar('Borrar rama');
      gestor.eliminar(tarea.id);
      expect(gestor.total, 0);
    });

    test('un id inexistente produce StateError', () {
      expect(() => gestor.alternar(404), throwsStateError);
      expect(() => gestor.eliminar(404), throwsStateError);
    });

    test('limpiarCompletadas elimina solo las completadas', () {
      final Tarea a = gestor.agregar('A');
      gestor.agregar('B');
      final Tarea c = gestor.agregar('C');
      gestor.alternar(a.id);
      gestor.alternar(c.id);
      expect(gestor.limpiarCompletadas(), 2);
      expect(gestor.tareas.map((Tarea t) => t.titulo), <String>['B']);
    });
  });

  group('métricas', () {
    test('sin tareas el avance es 0 %', () {
      expect(gestor.porcentajeAvance, 0);
      expect(gestor.pendientes, 0);
    });

    test('el avance se redondea al entero más cercano', () {
      final Tarea a = gestor.agregar('Uno');
      gestor.agregar('Dos');
      gestor.agregar('Tres');
      gestor.alternar(a.id);
      expect(gestor.porcentajeAvance, 33);
      expect(gestor.pendientes, 2);
    });

    test('urgentes cuenta solo pendientes de prioridad alta', () {
      final Tarea alta = gestor.agregar('Hotfix', prioridad: Prioridad.alta);
      gestor.agregar('Release', prioridad: Prioridad.alta);
      gestor.agregar('Docs', prioridad: Prioridad.baja);
      expect(gestor.urgentes, 2);
      gestor.alternar(alta.id);
      expect(gestor.urgentes, 1);
    });
  });

  group('filtrar', () {
    setUp(() {
      gestor.agregar('Baja', prioridad: Prioridad.baja);
      gestor.agregar('Alta', prioridad: Prioridad.alta);
      gestor.agregar('Media', prioridad: Prioridad.media);
      gestor.alternar(1);
    });

    List<String> titulos(List<Tarea> tareas) =>
        tareas.map((Tarea t) => t.titulo).toList();

    test('todas: ordena por prioridad (alta, media, baja)', () {
      expect(
        titulos(gestor.filtrar(FiltroTareas.todas)),
        <String>['Alta', 'Media', 'Baja'],
      );
    });

    test('pendientes: excluye las completadas', () {
      expect(
        titulos(gestor.filtrar(FiltroTareas.pendientes)),
        <String>['Alta', 'Media'],
      );
    });

    test('completadas: incluye solo las completadas', () {
      expect(
        titulos(gestor.filtrar(FiltroTareas.completadas)),
        <String>['Baja'],
      );
    });
  });

  test('toString describe la tarea', () {
    const Tarea tarea = Tarea(id: 7, titulo: 'Demo', prioridad: Prioridad.baja);
    expect(tarea.toString(), 'Tarea(7, Demo, Baja, pendiente)');
    expect(
      tarea.copyWith(completada: true).toString(),
      'Tarea(7, Demo, Baja, completada)',
    );
  });
}
