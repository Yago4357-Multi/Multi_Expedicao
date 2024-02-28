import 'package:flutterflow_ui/flutterflow_ui.dart';
import '/Views/lista_pedido_widget.dart' show ListaPedidoWidget;
import 'package:flutter/material.dart';

import 'drawer_model.dart';

class ListaPedidoModel extends FlutterFlowModel<ListaPedidoWidget> {
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
