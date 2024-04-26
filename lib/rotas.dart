import 'package:flutter/cupertino.dart';

import 'Models/usur.dart';
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
  '/Progress': (context) => ProgressWidget(Usuario(0,'')),
  '/ListaRomaneio': (context)=> ListaRomaneioWidget(0, Usuario(0,'')),
  '/ListaPalete': (context) =>  ListaPaleteWidget(cont: 0, Usuario(0,'')),
  '/ListaPedido': (context) =>  ListaPedidoWidget(cont: 0, Usuario(0,'')),
  '/ListaRomaneioConf': (context) =>  ListaRomaneioConfWidget(palete: 0, Usuario(0,'')),
  '/EscolhaRomaneio': (context) =>  EscolhaBipagemWidget(Usuario(0,'')),
  '/CriarPalete': (context) =>  CriarPaleteWidget(Usuario(0,'')),
  '/CriarRomaneio': (context) =>  EscolhaRomaneioWidget(Usuario(0,''))
};