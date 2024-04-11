import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../../Views/escolha_romaneio_widget.dart';
import 'package:flutter/material.dart';

import 'drawer_model.dart';

class EscolhaRomaneioModel extends FlutterFlowModel<EscolhaRomaneioWidget> {
  ///  State fields for stateful widgets in this page.

  late DrawerModel drawerModel;
  final unfocusNode = FocusNode();
  TextEditingController? textController;
  FocusNode? textFieldFocusNode;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {
    drawerModel = createModel(context, () => DrawerModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
