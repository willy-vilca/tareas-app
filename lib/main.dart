import 'package:flutter/material.dart';
import 'package:tareas_app/src/app.dart';
import 'package:tareas_app/src/config/app_config.dart';

void main() {
  runApp(TareasApp(config: AppConfig.desdeEntorno()));
}
