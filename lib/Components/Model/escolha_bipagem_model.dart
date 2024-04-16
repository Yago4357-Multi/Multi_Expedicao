import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../../Views/escolha_bipagem_widget.dart';
import 'package:flutter/material.dart';

import 'drawer_model.dart';

class EscolhaBipagemModel extends FlutterFlowModel<EscolhaBipagemWidget> {
  ///  State fields for stateful widgets in this page.

  late DrawerModel drawerModel;
  final unfocusNode = FocusNode();
  TextEditingController? textController;
  FocusNode? textFieldFocusNode;
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
