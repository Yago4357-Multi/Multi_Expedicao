import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../../Views/lista_romaneios.dart';
import 'drawer_model.dart';

///Modelo para a página de listagem do Romaneio
class ListaRomaneiosModel extends FlutterFlowModel<ListaRomaneiosWidget> {
  ///  State fields for stateful widgets in this page.
  late DrawerModel drawerModel;
  ///
  final unfocusNode = FocusNode();
  /// Campo de estado para o Widget de escolha
  FormFieldController<List<String>>? choiceChipsValueController;
  /// Getter e Setter do campo de escolha de estado
  String? get choiceChipsValue =>
      choiceChipsValueController?.value?.firstOrNull;
  set choiceChipsValue(String? val) =>
      choiceChipsValueController?.value = val != null ? [val] : [];
  /// Controlador de Foco do campo de texto
  FocusNode? textFieldFocusNode;
  FocusNode? textFieldFocusNode2;
  /// Controlar de um campo de text da página
  TextEditingController? textController;
  TextEditingController? textController2;
  /// Modelo para validar texto de um campo de texto
  String? Function(BuildContext, String?)? textControllerValidator;
  String? Function(BuildContext, String?)? textControllerValidator2;
  ExpansionTileController? expansionTileController;

  @override
  void initState(BuildContext context) {
    drawerModel = createModel(context, DrawerModel.new);
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    textFieldFocusNode?.dispose();
    textFieldFocusNode2?.dispose();
    textController?.dispose();
  }
}
