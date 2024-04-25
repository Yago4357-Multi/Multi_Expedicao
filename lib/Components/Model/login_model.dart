
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart' show FlutterFlowModel;

import '../../Views/login_widget.dart';

///Modelo para a página de Login
class LoginModel extends FlutterFlowModel<LoginWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  // State field(s) for emailAddress widget.
  ///Controlador de foco para o campo de Usuário
  FocusNode? emailAddressFocusNode;
  ///Controlador de texto para o campo de Usuário
  TextEditingController? emailAddressTextController;
  ///Controlador para validar o texto do campo de Usuário
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;

  // State field(s) for password widget.
  ///Controlador de foco para o campo de Senha
  FocusNode? passwordFocusNode;
  ///Controlador de texto para o campo de Senha
  TextEditingController? passwordTextController;
  ///Controlador de visibilidade para o campo de Senha
  late bool passwordVisibility;
  ///Controlador para validar o texto do campo de Senha
  String? Function(BuildContext, String?)? passwordTextControllerValidator;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    passwordFocusNode?.dispose();
    passwordTextController?.dispose();
  }
}
