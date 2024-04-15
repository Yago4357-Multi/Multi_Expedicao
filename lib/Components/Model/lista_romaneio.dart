import 'package:audioplayers/audioplayers.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import '../../Views/lista_romaneio_widget.dart';
import 'package:flutter/material.dart';

import 'drawer_model.dart';

class ListaRomaneioModel extends FlutterFlowModel<ListaRomaneioWidget> {
  ///  State fields for stateful widgets in this page.
  late DrawerModel drawerModel;
  final unfocusNode = FocusNode();
  AudioPlayer? soundPlayer;
  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController;
  String? get choiceChipsValue =>
      choiceChipsValueController?.value?.firstOrNull;
  set choiceChipsValue(String? val) =>
      choiceChipsValueController?.value = val != null ? [val] : [];
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
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
