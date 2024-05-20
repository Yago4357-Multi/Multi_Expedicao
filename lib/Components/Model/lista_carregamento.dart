import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../../Views/carregamento_widget.dart';
import 'drawer_model.dart';

///Modelo para a página de listagem do Romaneio
class ListaCarregamentoModel extends FlutterFlowModel<ListaCarregamentoWidget> {
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
  /// Controlar de um campo de text da página
  TextEditingController? textController;
  /// Modelo para validar texto de um campo de texto
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {
    drawerModel = createModel(context, DrawerModel.new);
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
