import 'package:flutter/material.dart';
import 'package:tareas_app/src/config/app_config.dart';
import 'package:tareas_app/src/ui/pantalla_tareas.dart';

/// Widget raíz. En entornos que no son producción muestra una cinta
/// (banner) con el nombre del entorno para evitar confusiones.
class TareasApp extends StatelessWidget {
  const TareasApp({super.key, required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final Widget pantalla = PantallaTareas(config: config);
    return MaterialApp(
      title: 'TareasApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: config.esProduccion
          ? pantalla
          : Banner(
              message: config.entorno.etiqueta,
              location: BannerLocation.bottomEnd,
              color: colorDeEntorno(config.entorno),
              child: pantalla,
            ),
    );
  }

  /// Color de la cinta según el entorno.
  static Color colorDeEntorno(Entorno entorno) {
    return switch (entorno) {
      Entorno.desarrollo => const Color(0xFF2E7D32),
      Entorno.pruebas => const Color(0xFFEF6C00),
      Entorno.produccion => const Color(0xFF1565C0),
    };
  }
}
