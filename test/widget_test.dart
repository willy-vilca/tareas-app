import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tareas_app/src/app.dart';
import 'package:tareas_app/src/config/app_config.dart';

const AppConfig configDesarrollo = AppConfig(
  entorno: Entorno.desarrollo,
  version: '1.0.0',
  numeroBuild: '7',
  gitSha: 'abc1234',
  estadisticasActivas: false,
);

const AppConfig configProduccion = AppConfig(
  entorno: Entorno.produccion,
  version: '1.0.0',
  numeroBuild: '8',
  gitSha: 'def5678',
  estadisticasActivas: true,
);

Future<void> agregarTarea(WidgetTester tester, String titulo) async {
  await tester.enterText(find.byKey(const Key('campo-titulo')), titulo);
  await tester.tap(find.byKey(const Key('boton-agregar')));
  await tester.pump();
}

void main() {
  testWidgets('inicia vacía y muestra la cinta del entorno DEV',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TareasApp(config: configDesarrollo));

    expect(find.text('No hay tareas para mostrar.'), findsOneWidget);
    expect(find.text('Avance: 0% (0 de 0)'), findsOneWidget);
    expect(find.byType(Banner), findsOneWidget);
    expect(find.byKey(const Key('tarjeta-estadisticas')), findsNothing);
  });

  testWidgets(
      'en producción no hay cinta y el feature flag muestra '
      'las estadísticas', (WidgetTester tester) async {
    await tester.pumpWidget(const TareasApp(config: configProduccion));

    expect(find.byType(Banner), findsNothing);
    expect(find.byKey(const Key('tarjeta-estadisticas')), findsOneWidget);
  });

  testWidgets('agrega una tarea válida y limpia el campo',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TareasApp(config: configDesarrollo));

    await agregarTarea(tester, 'Configurar GitHub Actions');

    expect(find.text('Configurar GitHub Actions'), findsOneWidget);
    expect(find.text('Prioridad Media'), findsOneWidget);
    expect(find.text('Avance: 0% (0 de 1)'), findsOneWidget);
    final TextField campo = tester.widget<TextField>(
      find.byKey(const Key('campo-titulo')),
    );
    expect(campo.controller!.text, isEmpty);
  });

  testWidgets('muestra un error si el título está vacío',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TareasApp(config: configDesarrollo));

    await agregarTarea(tester, '   ');

    expect(find.text('El título no puede estar vacío.'), findsOneWidget);
    expect(find.text('No hay tareas para mostrar.'), findsOneWidget);
  });

  testWidgets('permite elegir la prioridad con los chips',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TareasApp(config: configDesarrollo));

    await tester.tap(find.widgetWithText(ChoiceChip, 'Alta'));
    await tester.pump();
    await agregarTarea(tester, 'Corregir bug crítico');

    expect(find.text('Prioridad Alta'), findsOneWidget);
  });

  testWidgets('completar, filtrar y eliminar una tarea',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TareasApp(config: configDesarrollo));
    await agregarTarea(tester, 'Escribir pruebas');
    await agregarTarea(tester, 'Publicar release');

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(find.text('Avance: 50% (1 de 2)'), findsOneWidget);

    await tester.tap(find.text('Hechas'));
    await tester.pumpAndSettle();
    expect(find.text('Escribir pruebas'), findsOneWidget);
    expect(find.text('Publicar release'), findsNothing);

    await tester.tap(find.text('Pendientes'));
    await tester.pumpAndSettle();
    expect(find.text('Escribir pruebas'), findsNothing);
    expect(find.text('Publicar release'), findsOneWidget);

    await tester.tap(find.byTooltip('Eliminar'));
    await tester.pumpAndSettle();
    expect(find.text('No hay tareas para mostrar.'), findsOneWidget);
  });

  testWidgets('el diálogo "Acerca de" muestra versión, build y commit',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TareasApp(config: configDesarrollo));

    await tester.tap(find.byKey(const Key('boton-acerca-de')));
    await tester.pumpAndSettle();

    expect(find.text('Versión: 1.0.0'), findsOneWidget);
    expect(find.text('Build: 7'), findsOneWidget);
    expect(find.text('Commit: abc1234'), findsOneWidget);
    expect(find.text('Entorno: desarrollo'), findsOneWidget);

    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();
    expect(find.text('Versión: 1.0.0'), findsNothing);
  });

  test('cada entorno tiene un color de cinta distinto', () {
    final Set<Color> colores = <Color>{
      for (final Entorno entorno in Entorno.values)
        TareasApp.colorDeEntorno(entorno),
    };
    expect(colores.length, Entorno.values.length);
  });
}
