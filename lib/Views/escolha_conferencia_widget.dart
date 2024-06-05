import 'package:MultiExpedicao/Views/reimprimir_palete_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../Components/Model/escolha_bipagem_model.dart';
import '../Components/Widget/drawer_widget.dart';
import '../Controls/banco.dart';
import '../Models/usur.dart';
import 'criar_palete_widget.dart';
import 'lista_palete_widget.dart';

export '../Components/Model/escolha_bipagem_model.dart';

///Página da escolha de bipagem
class EscolhaBipagemWidget extends StatefulWidget {
  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///Variável para manter conexão com o Banco
  final Banco bd;

  ///Construtor da página de escolha de bipagem
  const EscolhaBipagemWidget(this.usur, {super.key, required this.bd});

  @override
  State<EscolhaBipagemWidget> createState() =>
      _EscolhaBipagemWidgetState(usur, bd);
}

class _EscolhaBipagemWidgetState extends State<EscolhaBipagemWidget> {
  late EscolhaBipagemModel _model;
  final Banco bd;

  List<String> acessos = ['BI','Comercial','Logística'];
  List<String> acessosADM = ['BI'];
  List<String> acessosCol = ['Logística'];
  List<String> acessosPC = ['Comercial'];

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final Usuario usur;

  _EscolhaBipagemWidgetState(this.usur, this.bd);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, EscolhaBipagemModel.new);
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        drawer: Drawer(
          elevation: 16,
          child: wrapWithModel(
            model: _model.drawerModel,
            updateCallback: () => setState(() {}),
            child: DrawerWidget(
              usur: usur,
              context: context,
              bd: bd,
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: const Color(0xFF007000),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30,
            borderWidth: 1,
            buttonSize: 60,
            icon: const Icon(
              Icons.dehaze_rounded,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () async {
              scaffoldKey.currentState!.openDrawer();
            },
          ),
          title: Text(
            'Conferência',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Outfit',
                  color: FlutterFlowTheme.of(context).primaryBackground,
                ),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.lock_reset_outlined),onPressed: () {
              setState(() {
              });
            }, color: Colors.white,),
          ],
          centerTitle: true,
          elevation: 2,
        ),
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                (acessosPC.contains(usur.acess) || acessosADM.contains(usur.acess)) ?
                (InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.push(context, MaterialPageRoute(
                        builder: (context) =>
                            ReimprimirPaleteWidget(usur, 0, bd: bd)));
                  },
                  child: (Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.height * 0.8,
                    height: MediaQuery.of(context).size.height * 0.1,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      'Reimprimir Paletes',
                      style: FlutterFlowTheme.of(context).titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  )),
                )) : Container(),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    if (await bd.connected(context) == 1) {
                      Navigator.pop(context);
                      await Navigator.push(context, MaterialPageRoute(
                        builder: (context) =>
                            ListaPaleteWidget(cont: 0, usur, bd: bd),));
                    }
                  },
                  child: (Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.height * 0.8,
                    height: MediaQuery.of(context).size.height * 0.1,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      'Conferir Paletes',
                      style: FlutterFlowTheme.of(context).titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  )),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    if (await bd.connected(context) == 1) {
                      await showDialog(
                        useSafeArea: true,
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16, 12, 16, 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      showCursor: true,
                                      controller: _model.textController,
                                      focusNode: _model.textFieldFocusNode,
                                      onFieldSubmitted: (value) async {
                                        if (await bd.connected(context) == 1) {
                                          bd.paleteExiste(int.parse(value),
                                              context, usur, bd);
                                        }
                                        setState(() {});
                                      },
                                      autofocus: true,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        labelText: 'Insira o Palete',
                                        labelStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              fontFamily: 'Readex Pro',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                        alignLabelWithHint: false,
                                        hintStyle: FlutterFlowTheme.of(context)
                                            .labelMedium,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.green.shade500,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.green.shade100,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.green.shade100,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium,
                                      keyboardType: const TextInputType
                                          .numberWithOptions(),
                                      validator: _model.textControllerValidator
                                          .asValidator(context),
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(33),
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                  child: (Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.height * 0.8,
                    height: MediaQuery.of(context).size.height * 0.1,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      'Continuar Palete',
                      style: FlutterFlowTheme.of(context).titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  )),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    if (await bd.connected(context) == 1) {
                      Navigator.pop(context);
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CriarPaleteWidget(usur, 0, bd: bd),
                          ));
                    }
                    setState(() {});
                  },
                  child: (Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.height * 0.8,
                    height: MediaQuery.of(context).size.height * 0.1,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      'Criar Novo Palete',
                      style: FlutterFlowTheme.of(context).titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
