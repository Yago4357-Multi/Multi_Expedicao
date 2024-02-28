import 'package:flutter/cupertino.dart';
import '/Views/Contagem.dart';
import '/Views/NConformidade.dart';
import 'Views/RomaneioTela.dart';

Map<String, Widget Function(BuildContext)> namedRoutes = {
  '/Contagem': (context) => const ContagemTela(),
  '/Conformidade': (context) => const NConformidade(),
  '/Romaneio': (context) => const RomaneioTela()
};