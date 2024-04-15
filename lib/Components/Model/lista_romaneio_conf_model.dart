import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../../Views/lista_romaneio_conf_widget.dart' show ListaRomaneioConfWidget;
import '../../components/Widget/drawer_widget.dart';

class ListaRomaneioConfModel extends FlutterFlowModel<ListaRomaneioConfWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for Drawer component.
  late DrawerModel drawerModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    drawerModel = createModel(context, DrawerModel.new);
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    drawerModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }

/// Action blocks are added here.

/// Additional helper methods are added here.
}
