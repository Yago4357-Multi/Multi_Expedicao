import 'package:flutterflow_ui/flutterflow_ui.dart';
import '../../Views/criar_palete_widget.dart';
import 'package:flutter/material.dart';

import 'drawer_model.dart';

class CriarPaleteModel extends FlutterFlowModel<CriarPaleteWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  late DrawerModel drawerModel;

  @override
  void initState(BuildContext context) {
    drawerModel = createModel(context, () => DrawerModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
