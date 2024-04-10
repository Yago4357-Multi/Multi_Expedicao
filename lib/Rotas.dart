import 'package:flutter/cupertino.dart';

import 'Views/home_page_widget.dart';
import 'Views/lista_pedido_widget.dart';
import 'Views/lista_romaneio_conf_widget.dart';

Map<String, Widget Function(BuildContext)> namedRoutes = {
  '/': (context) => const HomePageWidget(),
  '/ListaPedido': (context) => ListaPedidoWidget(cont: '0'),
  '/ListaRomaneioConf': (context) => ListaRomaneioConfWidget()
};