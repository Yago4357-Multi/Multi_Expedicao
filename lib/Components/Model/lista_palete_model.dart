import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '/Views/lista_palete_widget.dart' show ListaPaleteWidget;
import 'drawer_model.dart';

///Modelo para a tela com Listagem de Pedidos no Palete
class ListaPaleteModel extends FlutterFlowModel<ListaPaleteWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  ///Modelo para o Widget Drawer
  late DrawerModel drawerModel;
  ///Modelo para controlar um campo de texto
  TextEditingController? textController;

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
