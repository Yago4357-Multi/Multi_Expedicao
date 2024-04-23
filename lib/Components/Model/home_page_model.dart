import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '/Views/home_page_widget.dart' show HomePageWidget;
import '/components/Widget/drawer_widget.dart';

///Modelo para a página inicial do app
class HomePageModel extends FlutterFlowModel<HomePageWidget> {
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
