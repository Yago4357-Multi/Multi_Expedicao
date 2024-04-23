import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../../Views/lista_romaneio_conf_widget.dart' show ListaRomaneioConfWidget;
import '../../components/Widget/drawer_widget.dart';

///Modelo para a página de Bipagem do aplicativo
class ListaRomaneioConfModel extends FlutterFlowModel<ListaRomaneioConfWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  /// Modelo do drawer para a página
  late DrawerModel drawerModel;

  /// Campo para cotrolar o foco de um campo de texto
  FocusNode? textFieldFocusNode;

  /// Modelo para controlar um campo de texto
  TextEditingController? textController;

  /// Modelo para validar valores em um campo de texto
  String? Function(BuildContext, String?)? textControllerValidator;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    drawerModel = createModel(context, DrawerModel.new);
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    drawerModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }

/// Action blocks are added here.

/// Additional helper methods are added here.
}
