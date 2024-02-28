import '/components/Widget/drawer_widget.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import '/Views/home_page_widget.dart' show HomePageWidget;
import 'package:flutter/material.dart';

class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for Drawer component.
  late DrawerModel drawerModel;

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
