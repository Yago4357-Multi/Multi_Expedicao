import 'package:flutter/cupertino.dart';

import 'Controls/banco.dart';
import 'Models/usur.dart';
import 'Views/atualizar.dart';
import 'Views/conferencia_widget.dart';
import 'Views/criar_palete_widget.dart';
import 'Views/escolha_conferencia_widget.dart';
import 'Views/escolha_romaneio_widget.dart';
import 'Views/home_widget.dart';
import 'Views/lista_palete_widget.dart';
import 'Views/lista_pedido_widget.dart';
import 'Views/login_widget.dart';
import 'Views/romaneio_widget.dart';

///Lista para facilitar a navegação entre janelas
Map<String, Widget Function(BuildContext)> namedRoutes = {
  '/': (context) => const LoginWidget(),
  '/Home': (context) => HomeWidget(bd: Banco(context)),
  '/ListaRomaneio': (context)=> ListaRomaneioWidget(0, Usuario(0,'',''),bd: Banco(context)),
  '/ListaPalete': (context) =>  ListaPaleteWidget(cont: 0, Usuario(0,'',''),bd: Banco(context)),
  '/ListaPedido': (context) =>  ListaPedidoWidget(cont: 0, Usuario(0,'',''),bd: Banco(context)),
  '/ListaRomaneioConf': (context) =>  ListaRomaneioConfWidget(palete: 0, Usuario(0,'',''),bd: Banco(context)),
  '/EscolhaRomaneio': (context) =>  EscolhaBipagemWidget(Usuario(0,'',''),bd: Banco(context)),
  '/CriarPalete': (context) =>  CriarPaleteWidget(Usuario(0,'',''),0,bd: Banco(context)),
  '/CriarRomaneio': (context) =>
      EscolhaRomaneioWidget(Usuario(0, '', ''), bd: Banco(context)),
  '/Atualizar': (context) =>
      AtualizarWidget(usur: Usuario(0, '', ''), bd: Banco(context)),
};