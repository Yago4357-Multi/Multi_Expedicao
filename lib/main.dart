import 'package:flutter/material.dart';
import 'Controls/banco.dart';
import 'Controls/excel.dart';
import 'rotas.dart';

void main() {
  runApp(const MyApp());
}

///Classe do meu applicativo
class MyApp extends StatelessWidget {

  ///Construtor do meu aplicativo
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    var excel = ExcelClass();
    excel.pickFile();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade900),
        useMaterial3: true,
      ),
      routes: namedRoutes,
      initialRoute: '/',
    );
  }
}