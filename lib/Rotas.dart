import 'package:flutter/cupertino.dart';
import 'package:romaneio_teste/Views/Contagem.dart';
import 'package:romaneio_teste/Views/NConformidade.dart';
import 'Views/RomaneioTela.dart';

Map<String, Widget Function(BuildContext)> namedRoutes = {
  '/Contagem': (context) => const ContagemTela(),
  '/Conformidade': (context) => const NConformidade(),
  '/Romaneio': (context) => const RomaneioTela()
};