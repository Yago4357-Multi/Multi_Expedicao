import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'rotas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var prefs = await SharedPreferences.getInstance();
  var logado = prefs.getBool('logado');
  var ultPag = prefs.getString('ultPag') ?? '/';
  runApp(MyApp(logado: logado, ultPag: ultPag));
}

///Classe do meu aplicativo
class MyApp extends StatelessWidget {
  final String ultPag;

  ///Variável para mudar a visualização caso ele esteja logado
  final bool? logado;

  ///Construtor do meu aplicativo
  const MyApp({super.key, required this.logado, required this.ultPag});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade900),
        useMaterial3: true,
      ),
      routes: namedRoutes,
      initialRoute: ultPag,
    );
  }
}