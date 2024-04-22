import 'package:flutterflow_ui/flutterflow_ui.dart';
import '/Views/lista_palete_widget.dart' show ListaPaleteWidget;
import 'package:flutter/material.dart';

import 'drawer_model.dart';

class ListaPaleteModel extends FlutterFlowModel<ListaPaleteWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for Drawer component.
  late DrawerModel drawerModel;
  TextEditingController? textController;
  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    drawerModel = createModel(context, () => DrawerModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    drawerModel.dispose();
  }

/// Action blocks are added here.

/// Additional helper methods are added here.
}
