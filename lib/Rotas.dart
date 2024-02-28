import 'package:flutter/cupertino.dart';
import 'package:romaneio_teste/Views/home_page_widget.dart';
import 'package:romaneio_teste/Views/lista_pedido_widget.dart';
import 'package:romaneio_teste/Views/lista_romaneio_conf_widget.dart';

Map<String, Widget Function(BuildContext)> namedRoutes = {
  '/': (context) => const HomePageWidget(),
  '/ListaPedido': (context) => const ListaPedidoWidget(),
  '/ListaRomaneioConf': (context) => const ListaRomaneioConfWidget()
};