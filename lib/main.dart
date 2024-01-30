import 'package:flutter/material.dart';
import 'package:romaneio_teste/Controls/Visualiza%C3%A7%C3%A3o.dart';
import 'Rotas.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade900),
        useMaterial3: true,
      ),
      routes: namedRoutes,
      initialRoute: Visualizacao(),
    );
  }
}