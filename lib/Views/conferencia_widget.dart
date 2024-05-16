import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import '../Components/Model/lista_romaneio_conf_model.dart';

import '../Components/Widget/drawer_widget.dart';
import '../Controls/banco.dart';
import '../Models/contagem.dart';
import '../Models/usur.dart';
import 'lista_pedido_widget.dart';
import 'progress_widget.dart';


///Página para mostrar a listagem da Bipagem
class ListaRomaneioConfWidget extends StatefulWidget {
  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///Variável para definir o palete que está sendo bipado
  final int palete;

  final Banco bd;

  ///Construtor da página
  const ListaRomaneioConfWidget(this.usur, this.bd, {super.key, required this.palete});

  @override
  State<ListaRomaneioConfWidget> createState() =>
      _ListaRomaneioConfWidgetState(palete, usur, bd);
}

class _ListaRomaneioConfWidgetState extends State<ListaRomaneioConfWidget> {
  int palete;
  final Usuario usur;

  _ListaRomaneioConfWidgetState(this.palete, this.usur, this.bd);

  List<Contagem> pedidos = [];
  late ListaRomaneioConfModel _model;
  late final Banco bd;
  late Future<List<Contagem>> teste;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ListaRomaneioConfModel.new);
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    _model.textFieldFocusNode!.addListener(() => setState(() {}));
    rodarBanco();
  }

  void rodarBanco() async {
    teste = bd.selectPallet(palete);
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
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: SizedBox(
          width: 200,
          height: 50,
          child: FloatingActionButton(
            onPressed: () async {
              if (pedidos.isEmpty) {
                await showCupertinoModalPopup(
                    barrierDismissible: false,
                    builder: (context2) {
                      return CupertinoAlertDialog(
                        title: const Text('Sem pedidos no Palete'),
                        actions: <CupertinoDialogAction>[
                          CupertinoDialogAction(
                              isDefaultAction: true,
                              onPressed: () {
                                Navigator.pop(context2);
                              },
                              child: const Text('Voltar'))
                        ],
                      );
                    },
                    context: context);
              } else {
                await showCupertinoModalPopup(
                    barrierDismissible: false,
                    builder: (context2) {
                      return CupertinoAlertDialog(
                        title: Text('Você deseja finalizar o Palete $palete?'),
                        content: const Text(
                            'Essa ação bloqueará o Palete de alterações Futuras'),
                        actions: <CupertinoDialogAction>[
                          CupertinoDialogAction(
                              isDefaultAction: true,
                              isDestructiveAction: true,
                              onPressed: () async {
                                bd.endPalete(palete, usur);
                                Navigator.pop(context);
                                await Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => ProgressWidget(usur,bd)));
                              },
                              child: const Text(
                                'Continuar',
                              )),
                          CupertinoDialogAction(
                              isDefaultAction: true,
                              onPressed: () {
                                Navigator.pop(context2);
                              },
                              child: const Text('Voltar'))
                        ],
                      );
                    },
                    context: context);
              }
            },
            backgroundColor: Colors.orange.shade400,
            elevation: 8,
            child: const Text(
              'Finalizar Palete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ),
        ),
        drawer: Drawer(
          elevation: 16,
          child: wrapWithModel(
            model: _model.drawerModel,
            updateCallback: () => setState(() {}),
            child: DrawerWidget(
              usur: usur,context: context,
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
          actions: const [],
          centerTitle: true,
          elevation: 2,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Align(
                      alignment: const AlignmentDirectional(0, -1),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          maxWidth: 1170,
                        ),
                        decoration: const BoxDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: const AlignmentDirectional(-1, -1),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: const AlignmentDirectional(0, 0),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              24, 20, 0, 0),
                                      child: Text(
                                        'Pallet :',
                                        textAlign: TextAlign.start,
                                        style: FlutterFlowTheme.of(context)
                                            .headlineMedium,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 20, 24, 0),
                                      child: Text(
                                        '$palete',
                                        textAlign: TextAlign.end,
                                        style: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .override(
                                              fontFamily: 'Outfit',
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  24, 4, 0, 0),
                              child: Text(
                                'Pedidos nesse Pallet',
                                textAlign: TextAlign.start,
                                style: FlutterFlowTheme.of(context).labelMedium,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16, 12, 16, 0),
                              child: Container(
                                width: double.infinity,
                                constraints: const BoxConstraints(
                                  maxWidth: double.infinity,
                                ),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16, 12, 16, 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: TextFormField(
                                          controller: _model.textController,
                                          focusNode: _model.textFieldFocusNode,
                                          onFieldSubmitted: (value) async {
                                            setState(() {
                                              bd.insert(
                                                  _model.textController!.text,
                                                  palete,
                                                  context,
                                                  usur);
                                              teste = bd.selectPallet(palete);
                                              _model.textController.text = '';
                                              _model.textFieldFocusNode?.requestFocus();
                                            });
                                          },
                                          autofocus: true,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            labelText: 'Pedido',
                                            labelStyle: FlutterFlowTheme.of(
                                                    context)
                                                .labelMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                            alignLabelWithHint: false,
                                            hintStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium,
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
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
                                            focusedErrorBorder:
                                                OutlineInputBorder(
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
                                          validator: _model
                                              .textControllerValidator
                                              .asValidator(context),
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                                33),
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            FutureBuilder(
                              future: teste,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  pedidos = snapshot.data ?? [];
                                  return ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(
                                        0,
                                        12,
                                        0,
                                        44,
                                      ),
                                      reverse: true,
                                      scrollDirection: Axis.vertical,
                                      physics: const BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: (pedidos.length),
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ListaPedidoWidget(
                                                          cont: pedidos[index]
                                                                  .ped ??
                                                              0,
                                                          usur,bd),
                                                ));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(14, 10, 14, 10),
                                            child: Container(
                                              width: double.infinity,
                                              constraints: const BoxConstraints(
                                                maxWidth: 570,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .alternate,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        10, 12, 12, 12),
                                                child: Column(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: RichText(
                                                        textAlign:
                                                            TextAlign.start,
                                                        text: TextSpan(
                                                          children: [
                                                            const TextSpan(
                                                              text: 'Ped. : ',
                                                              style:
                                                                  TextStyle(),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  '${pedidos[index].ped}',
                                                              style:
                                                                  const TextStyle(
                                                                color: Color(
                                                                    0xFF007000),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                fontSize: 24,
                                                              ),
                                                            )
                                                          ],
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyLarge
                                                              .override(
                                                                fontFamily:
                                                                    'Readex Pro',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                      0,
                                                                      4,
                                                                      0,
                                                                      0),
                                                              child: Text(
                                                                'Palete : ${pedidos[index].palete}',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                      0,
                                                                      4,
                                                                      0,
                                                                      0),
                                                              child: Text(
                                                                'Cidade : ${pedidos[index].cidade}',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  0, 4, 0, 0),
                                                          child: Container(
                                                            height: 80,
                                                            constraints:
                                                                BoxConstraints(
                                                              minWidth: MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width *
                                                                  0.2,
                                                              maxWidth: MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width *
                                                                  0.3,
                                                              maxHeight: MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .height *
                                                                  0.8,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xFF6ABD6A),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              border:
                                                                  Border.all(
                                                                color: const Color(
                                                                    0xFF005200),
                                                                width: 2,
                                                              ),
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  const AlignmentDirectional(
                                                                      0, 0),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                        1,
                                                                        0,
                                                                        1,
                                                                        0),
                                                                child: RichText(
                                                                  text:
                                                                      TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            'Vol. :\n',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontFamily: 'Readex Pro',
                                                                              color: const Color(0xFF005200),
                                                                              fontSize: 18,
                                                                              fontWeight: FontWeight.w800,
                                                                            ),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            '${pedidos[index].caixa} / ${pedidos[index].vol}',
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              26,
                                                                        ),
                                                                      )
                                                                    ],
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              'Readex Pro',
                                                                          color:
                                                                              const Color(0xFF005200),
                                                                          fontSize:
                                                                              24,
                                                                          fontWeight:
                                                                              FontWeight.w800,
                                                                        ),
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                } else {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
