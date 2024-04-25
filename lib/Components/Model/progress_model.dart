import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '/Views/progress_widget.dart' show ProgressWidget;
import '/components/Widget/drawer_widget.dart';

///Modelo para a página inicial do app
class HomePageModel extends FlutterFlowModel<ProgressWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  ///Modelo para o Widget Drawer
  late DrawerModel drawerModel;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    drawerModel = createModel(context, DrawerModel.new);
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    drawerModel.dispose();
  }

/// Action blocks are added here.

/// Additional helper methods are added here.
}
