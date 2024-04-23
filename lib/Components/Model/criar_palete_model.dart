import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../../Views/criar_palete_widget.dart';
import 'drawer_model.dart';

///Modelo para a página de Criação de Palete
class CriarPaleteModel extends FlutterFlowModel<CriarPaleteWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  ///Criando modelo local para o Drawer
  late DrawerModel drawerModel;

  @override
  void initState(BuildContext context) {
    drawerModel = createModel(context, DrawerModel.new);
  }

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
