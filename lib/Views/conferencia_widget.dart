import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import '../Components/Model/lista_romaneio_conf_model.dart';

import '../Components/Widget/drawer_widget.dart';
import '../Controls/banco.dart';
import '../Models/contagem.dart';
import '../Models/usur.dart';
import 'home_widget.dart';
import 'lista_pedido_widget.dart';

///Página para mostrar a listagem da Bipagem
class ListaRomaneioConfWidget extends StatefulWidget {
  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///Variável para definir o palete que está sendo bipado
  final int palete;

  ///Variável para manter conexão com o Banco
  final Banco bd;

  ///Construtor da página
  const ListaRomaneioConfWidget(
    this.usur, {
    super.key,
    required this.palete,
    required this.bd,
  });

  @override
  State<ListaRomaneioConfWidget> createState() =>
      _ListaRomaneioConfWidgetState(palete, usur, bd);
}

class _ListaRomaneioConfWidgetState extends State<ListaRomaneioConfWidget> {
  int palete;
  int volumes = 0;
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
    rodarBanco();
    _model = createModel(context, ListaRomaneioConfModel.new);
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    _model.textFieldFocusNode!.addListener(() => setState(() {}));
  }

  void rodarBanco() async {
    teste = bd.selectPallet(palete, context);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_reset_outlined),
            onPressed: () {
              setState(() {});
            },
            color: Colors.white,
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: SizedBox(
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
                            title:
                                Text('Você deseja finalizar o Palete $palete?'),
                            content: const Text(
                                'Essa ação bloqueará o Palete de alterações Futuras'),
                            actions: <CupertinoDialogAction>[
                              CupertinoDialogAction(
                                  isDefaultAction: true,
                                  isDestructiveAction: true,
                                  onPressed: () async {
                                    if (await bd.connected(context) == 1) {
                                      bd.endPalete(palete, usur);
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeWidget(usur, bd: bd)));
                                      }
                                    }
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
          ),
        ],
        centerTitle: true,
        elevation: 2,
      ),
      body: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: const AlignmentDirectional(0, -1),
            child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  maxWidth: 1170,
                ),
                decoration: const BoxDecoration(),
                child: FutureBuilder(
                    future: teste,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        pedidos = snapshot.data ?? [];
                        var pedNum = <int>[];
                        volumes = 0;
                        for (var i in pedidos) {
                          if (pedNum.contains(i.ped) == false) {
                            pedNum.add(i.ped!);
                            volumes += i.volBip!;
                          }
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: (responsiveVisibility(
                                      context: context,
                                      phone: false,
                                      tablet: false,
                                      desktop: true))
                                  ? MediaQuery.of(context).size.height * 2
                                  : MediaQuery.of(context).size.height * 0.6,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
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
                                  Padding(
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
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: (responsiveVisibility(
                                      context: context,
                                      phone: false,
                                      tablet: false,
                                      desktop: true))
                                  ? MediaQuery.of(context).size.height * 2
                                  : MediaQuery.of(context).size.height * 0.6,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            24, 5, 0, 0),
                                    child: Text(
                                      'Vol. Tot. do Palete:',
                                      textAlign: TextAlign.start,
                                      style: FlutterFlowTheme.of(context)
                                          .labelLarge,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0, 5, 24, 0),
                                    child: Text(
                                      '$volumes',
                                      textAlign: TextAlign.end,
                                      style: FlutterFlowTheme.of(context)
                                          .labelLarge
                                          .override(
                                            fontFamily: 'Outfit',
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16, 12, 16, 0),
                              child: Container(
                                width: (responsiveVisibility(
                                        context: context,
                                        phone: false,
                                        tablet: false,
                                        desktop: true))
                                    ? MediaQuery.of(context).size.height * 2
                                    : MediaQuery.of(context).size.height * 0.55,
                                height: 60,
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
                                  child: TextFormField(
                                    cursorWidth: 0,
                                    controller: _model.textController,
                                    focusNode: _model.textFieldFocusNode,
                                    onFieldSubmitted: (value) async {
                                      if (await bd.connected(context) == 1) {
                                        var codArrumado =
                                            value.substring(14, 33);
                                        var ped = int.parse(
                                            codArrumado.substring(0, 10));
                                        int? teste2 =
                                            await bd.selectAllPedidos(ped);
                                        print(teste2);
                                        if (teste2 ==
                                            0) {
                                          if (context.mounted) {
                                            teste = bd.insert(
                                                _model.textController!.text,
                                                palete,
                                                context,
                                                usur);
                                          }
                                        } else {
                                          if (teste2 == 1) {
                                            await showCupertinoModalPopup(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (context) {
                                                return CupertinoAlertDialog(
                                                  title: const Text(
                                                      'O Pedido está cancelado no Sistema'),
                                                  actions: <CupertinoDialogAction>[
                                                    CupertinoDialogAction(
                                                        isDefaultAction: true,
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            'Voltar'))
                                                  ],
                                                );
                                              },
                                            );
                                          } else {
                                            await showCupertinoModalPopup(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (context) {
                                                return CupertinoAlertDialog(
                                                  title: const Text(
                                                      'Pedido não encontrado no Sistema'),
                                                  actions: <CupertinoDialogAction>[
                                                    CupertinoDialogAction(
                                                        isDefaultAction: true,
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            'Voltar'))
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        }
                                      }
                                      _model.textController.text = '';
                                      _model.textFieldFocusNode?.requestFocus();

                                      setState(() {});
                                    },
                                    autofocus: true,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: 'Pedido',
                                      labelStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            color: FlutterFlowTheme.of(context)
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
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.green.shade500,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.green.shade100,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.green.shade100,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    style:
                                        FlutterFlowTheme.of(context).bodyMedium,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(),
                                    validator: _model.textControllerValidator
                                        .asValidator(context),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(33),
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, bottom: 2, left: 20, right: 20),
                              child: Text(
                                'Últ. Caixa Bip.',
                                textAlign: TextAlign.start,
                                style: FlutterFlowTheme.of(context).labelLarge,
                              ),
                            ),
                            Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: SizedBox(
                                    width: (responsiveVisibility(
                                            context: context,
                                            phone: false,
                                            tablet: false,
                                            desktop: true))
                                        ? MediaQuery.of(context).size.height * 2
                                        : MediaQuery.of(context).size.height *
                                            0.4,
                                    child: const Divider())),
                            SizedBox(
                              width: (responsiveVisibility(
                                      context: context,
                                      phone: false,
                                      tablet: false,
                                      desktop: true))
                                  ? MediaQuery.of(context).size.height * 2
                                  : MediaQuery.of(context).size.height * 0.6,
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    12,
                                    0,
                                    44,
                                  ),
                                  reverse: false,
                                  scrollDirection: Axis.vertical,
                                  physics: const BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: pedidos.isEmpty ? 0 : 1,
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
                                                      cont:
                                                          pedidos[index].ped ??
                                                              0,
                                                      usur,
                                                      bd: bd),
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
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              width: 2,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(10, 12, 12, 12),
                                            child:
                                                (responsiveVisibility(
                                                        context: context,
                                                        phone: false,
                                                        tablet: false,
                                                        desktop: true))
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: RichText(
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              text: TextSpan(
                                                                children: [
                                                                  const TextSpan(
                                                                    text:
                                                                        'Ped. : \n ',
                                                                    style:
                                                                        TextStyle(),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        '${pedidos[index].ped ?? ''}',
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Color(
                                                                          0xFF007000),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900,
                                                                      fontSize:
                                                                          26,
                                                                    ),
                                                                  )
                                                                ],
                                                                style: FlutterFlowTheme.of(
                                                                        context)
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
                                                          Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                    0, 4, 0, 0),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  width: 95,
                                                                  height: 80,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: const Color(
                                                                        0xFF6ABD6A),
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              12),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              12),
                                                                    ),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: const Color(
                                                                          0xFF005200),
                                                                      width: 2,
                                                                    ),
                                                                  ),
                                                                  child: Align(
                                                                    alignment:
                                                                        const AlignmentDirectional(
                                                                            0,
                                                                            0),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                          1,
                                                                          0,
                                                                          1,
                                                                          0),
                                                                      child:
                                                                          RichText(
                                                                        text:
                                                                            TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                              text: 'Caixa :\n',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    color: const Color(0xFF005200),
                                                                                    fontSize: 18,
                                                                                    fontWeight: FontWeight.w800,
                                                                                  ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: '${pedidos[index].caixa}',
                                                                              style: const TextStyle(
                                                                                fontSize: 26,
                                                                              ),
                                                                            )
                                                                          ],
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: 'Readex Pro',
                                                                                color: const Color(0xFF005200),
                                                                                fontSize: 24,
                                                                                fontWeight: FontWeight.w800,
                                                                              ),
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: 150,
                                                                  height: 80,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .indigoAccent
                                                                        .shade100,
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .only(
                                                                      topRight:
                                                                          Radius.circular(
                                                                              12),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              12),
                                                                    ),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Colors
                                                                          .indigo,
                                                                      width: 2,
                                                                    ),
                                                                  ),
                                                                  child: Align(
                                                                    alignment:
                                                                        const AlignmentDirectional(
                                                                            0,
                                                                            0),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                          1,
                                                                          0,
                                                                          1,
                                                                          0),
                                                                      child:
                                                                          RichText(
                                                                        text:
                                                                            TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                              text: 'Cxs Conf. :\n',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    color: Colors.indigo,
                                                                                    fontSize: 18,
                                                                                    fontWeight: FontWeight.w800,
                                                                                  ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: '${pedidos[index].volBip} / ${pedidos[index].vol}',
                                                                              style: const TextStyle(
                                                                                fontSize: 26,
                                                                              ),
                                                                            )
                                                                          ],
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: 'Readex Pro',
                                                                                color: Colors.indigo,
                                                                                fontSize: 24,
                                                                                fontWeight: FontWeight.w800,
                                                                              ),
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional
                                                                    .centerStart,
                                                            child: RichText(
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              text: TextSpan(
                                                                children: [
                                                                  const TextSpan(
                                                                    text:
                                                                        'Ped. : ',
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        '${pedidos[index].ped ?? ''}',
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Color(
                                                                          0xFF007000),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900,
                                                                      fontSize:
                                                                          26,
                                                                    ),
                                                                  )
                                                                ],
                                                                style: FlutterFlowTheme.of(
                                                                        context)
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
                                                          Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                    0, 8, 0, 0),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  width: 95,
                                                                  height: 60,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: const Color(
                                                                        0xFF6ABD6A),
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              12),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              12),
                                                                    ),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: const Color(
                                                                          0xFF005200),
                                                                      width: 2,
                                                                    ),
                                                                  ),
                                                                  child: Align(
                                                                    alignment:
                                                                        const AlignmentDirectional(
                                                                            0,
                                                                            0),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                          1,
                                                                          0,
                                                                          1,
                                                                          0),
                                                                      child:
                                                                          RichText(
                                                                        text:
                                                                            TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                              text: 'Caixa. :\n',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    color: const Color(0xFF005200),
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.w800,
                                                                                  ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: '${pedidos[index].caixa}',
                                                                              style: const TextStyle(
                                                                                fontSize: 22,
                                                                              ),
                                                                            )
                                                                          ],
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: 'Readex Pro',
                                                                                color: const Color(0xFF005200),
                                                                                fontSize: 22,
                                                                                fontWeight: FontWeight.w800,
                                                                              ),
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: 150,
                                                                  height: 60,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .indigoAccent
                                                                        .shade100,
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .only(
                                                                      topRight:
                                                                          Radius.circular(
                                                                              12),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              12),
                                                                    ),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Colors
                                                                          .indigo,
                                                                      width: 2,
                                                                    ),
                                                                  ),
                                                                  child: Align(
                                                                    alignment:
                                                                        const AlignmentDirectional(
                                                                            0,
                                                                            0),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                          1,
                                                                          0,
                                                                          1,
                                                                          0),
                                                                      child:
                                                                          RichText(
                                                                        text:
                                                                            TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                              text: 'Cxs Conf. :\n',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    color: Colors.indigo,
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.w800,
                                                                                  ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: '${pedidos[index].volBip} / ${pedidos[index].vol}',
                                                                              style: const TextStyle(
                                                                                fontSize: 22,
                                                                              ),
                                                                            )
                                                                          ],
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: 'Readex Pro',
                                                                                color: Colors.indigo,
                                                                                fontSize: 22,
                                                                                fontWeight: FontWeight.w800,
                                                                              ),
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        );
                      } else {
                        return const Center(
                            heightFactor: double.infinity,
                            widthFactor: double.infinity,
                            child: CircularProgressIndicator());
                      }
                    })),
          ),
        ],
      ),
    );
  }
}
