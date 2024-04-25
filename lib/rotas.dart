import 'package:flutter/cupertino.dart';

import 'Views/criar_palete_widget.dart';
import 'Views/escolha_bipagem_widget.dart';
import 'Views/escolha_romaneio_widget.dart';
import 'Views/lista_palete_widget.dart';
import 'Views/lista_pedido_widget.dart';
import 'Views/lista_romaneio_conf_widget.dart';
import 'Views/lista_romaneio_widget.dart';
import 'Views/login_widget.dart';
import 'Views/progress_widget.dart';

///Lista para facilitar a navegação entre janelas
Map<String, Widget Function(BuildContext)> namedRoutes = {
  '/': (context) => const LoginWidget(),
  '/Progresso': (context) => const ProgressWidget(''),
  '/ListaRomaneio': (context)=> const ListaRomaneioWidget(0, ''),
  '/ListaPalete': (context) => const ListaPaleteWidget(cont: 0, ''),
  '/ListaPedido': (context) => const ListaPedidoWidget(cont: 0, ''),
  '/ListaRomaneioConf': (context) => const ListaRomaneioConfWidget(palete: 0, ''),
  '/EscolhaRomaneio': (context) => const EscolhaBipagemWidget(''),
  '/CriarPalete': (context) => const CriarPaleteWidget(''),
  '/CriarRomaneio': (context) => const EscolhaRomaneioWidget('')
};