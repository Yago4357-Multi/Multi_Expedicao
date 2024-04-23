import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../../Views/escolha_romaneio_widget.dart';
import 'drawer_model.dart';

///Modelo para a página de escolha do Romaneio
class EscolhaRomaneioModel extends FlutterFlowModel<EscolhaRomaneioWidget> {
  ///  State fields for stateful widgets in this page.

  late DrawerModel drawerModel;
  ///Modelo para manter o controlador de Foco
  final unfocusNode = FocusNode();
  ///Modelo para controlar o texto da página
  TextEditingController? textController;
  ///Modelo para manter o controlador de de um campo de texto
  FocusNode? textFieldFocusNode;
  ///Modelo para validar valores inseridos no comapo de texto
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {
    drawerModel = createModel(context, DrawerModel.new);
  }

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
