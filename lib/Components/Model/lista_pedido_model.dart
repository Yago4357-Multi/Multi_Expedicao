import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '/Views/lista_pedido_widget.dart' show ListaPedidoWidget;
import 'drawer_model.dart';

///Modelo para a página de Lista de caixas por Pedido
class ListaPedidoModel extends FlutterFlowModel<ListaPedidoWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  ///Modelo para o Widget Drawer
  late DrawerModel drawerModel;
  ///Modelo para controlar um campo de texto
  TextEditingController? textController;
  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    drawerModel = createModel(context, DrawerModel.new);
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    drawerModel.dispose();
  }

/// Action blocks are added here.

/// Additional helper methods are added here.
}
