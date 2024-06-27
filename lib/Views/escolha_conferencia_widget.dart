import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../Components/Model/escolha_bipagem_model.dart';
import '../Components/Widget/atualizacao.dart';
import '../Components/Widget/drawer_widget.dart';
import '../Controls/banco.dart';
import '../Models/usur.dart';
import 'criar_palete_widget.dart';
import 'declaracoes.dart';
import 'lista_cancelados.dart';
import 'lista_faturados.dart';
import 'lista_palete_widget.dart';
import 'reimprimir_palete_widget.dart';

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

  late Future<int> qtdFatFut;
  late Future<int> qtdCancFut;
  int qtdFat = 0;
  int qtdCanc = 0;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final Usuario usur;

  _EscolhaBipagemWidgetState(this.usur, this.bd);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, EscolhaBipagemModel.new);
    rodarBanco();
  }

  void rodarBanco() async{
    qtdCancFut = bd.qtdCanc();
    qtdFatFut = bd.qtdFat();

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
          leadingWidth: 400,
          leading: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              FlutterFlowIconButton(
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
              if (responsiveVisibility(
                context: context,
                phone: false,
                tablet: false,
              ))
                FutureBuilder(
                  future: qtdFatFut,
                  builder: (context, snapshot) {
                    qtdFat = snapshot.data ?? 0;
                    if (qtdFat > 0 ) {
                      return Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: SizedBox(
                              width: 120,
                              height: 50,
                              child: Row(children: [
                                Text(
                                  'Fat.: $qtdFat',
                                  style: FlutterFlowTheme
                                      .of(context)
                                      .headlineSmall
                                      .override(
                                      fontFamily: 'Readex Pro',
                                      fontSize: 16,
                                      color: Colors.red),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ListaFaturadosWidget(usur, bd: bd),
                                        ));
                                  },
                                  icon: const Icon(
                                    Icons.assignment_late,
                                    color: Colors.red,
                                  ),
                                )
                              ])));
                    } else{
                      return Container();
                    }
                  },
                ),
              if (responsiveVisibility(
                context: context,
                phone: false,
                tablet: false,
              ))
                FutureBuilder(
                    future: qtdCancFut,
                    builder: (context, snapshot) {
                      qtdCanc = snapshot.data ?? 0;
                      if (qtdCanc > 0) {
                        return Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: SizedBox(
                                width: 120,
                                height: 50,
                                child: Row(children: [
                                  Text('Canc. : $qtdCanc',
                                      style: FlutterFlowTheme
                                          .of(context)
                                          .headlineSmall
                                          .override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 16,
                                          color: Colors.orange)),
                                  IconButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ListaCanceladosWidget(usur, bd: bd),
                                          ));
                                    },
                                    icon: const Icon(
                                      Icons.assignment_late,
                                      color: Colors.orange,
                                    ),
                                  )
                                ])));
                      } else{
                        return Container();
                      }
                    }),
            ],
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
          child: Stack(
            children: [
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: (responsiveVisibility(
                            context: context,
                            phone: false,
                            tablet: false,
                            desktop: true))
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(40, 20, 0, 10),
                              child: Text(
                                'Conferência',
                                style:
                                    FlutterFlowTheme.of(context).headlineMedium,
                              ))),
                      Divider(
                        height: 12,
                        thickness: 2,
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, left: 20),
                        child: ((responsiveVisibility(
                                context: context,
                                phone: false,
                                tablet: false,
                                desktop: true))
                            ? SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
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
                                                    CriarPaleteWidget(usur, 0,
                                                        bd: bd),
                                              ));
                                        }
                                        setState(() {});
                                      },
                                      child: (Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.3,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.create_new_folder_rounded,
                                              ),
                                              Container(
                                                height: 20,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                'Criar Novo Palete',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleLarge,
                                                textAlign: TextAlign.center,
                                              )
                                            ],
                                          ),
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
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          16, 12, 16, 12),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField(
                                                          showCursor: true,
                                                          controller: _model
                                                              .textController,
                                                          focusNode: _model
                                                              .textFieldFocusNode,
                                                          onFieldSubmitted:
                                                              (value) async {
                                                            if (await bd.connected(
                                                                    context) ==
                                                                1) {
                                                              bd.paleteExiste(
                                                                  int.parse(
                                                                      value),
                                                                  context,
                                                                  usur,
                                                                  bd);
                                                            }
                                                            setState(() {});
                                                          },
                                                          autofocus: true,
                                                          obscureText: false,
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                'Insira o Palete',
                                                            labelStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          'Readex Pro',
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryText,
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                            alignLabelWithHint:
                                                                false,
                                                            hintStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium,
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .alternate,
                                                                width: 2,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Colors
                                                                    .green
                                                                    .shade500,
                                                                width: 2,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            errorBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Colors
                                                                    .green
                                                                    .shade100,
                                                                width: 2,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            focusedErrorBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Colors
                                                                    .green
                                                                    .shade100,
                                                                width: 2,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                          ),
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium,
                                                          keyboardType:
                                                              const TextInputType
                                                                  .numberWithOptions(),
                                                          validator: _model
                                                              .textControllerValidator
                                                              .asValidator(
                                                                  context),
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
                                              );
                                            },
                                          );
                                        }
                                      },
                                      child: (Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.3,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.next_week,
                                              ),
                                              Container(
                                                height: 20,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                'Continuar Palete',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleLarge,
                                                textAlign: TextAlign.center,
                                              )
                                            ],
                                          ),
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
                                                    ListaPaleteWidget(
                                                        cont: 0, usur, bd: bd),
                                              ));
                                        }
                                      },
                                      child: (Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.3,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.manage_search,
                                              ),
                                              Container(
                                                height: 20,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                'Conferir Paletes',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleLarge,
                                                textAlign: TextAlign.center,
                                              )
                                            ],
                                          ),
                                        ),
                                      )),
                                    ),
                                    InkWell(
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
                                                    ReimprimirPaleteWidget(
                                                        usur, 0,
                                                        bd: bd)));
                                      },
                                      child: (Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.3,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.print_rounded,
                                              ),
                                              Container(
                                                height: 20,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                'Reimprimir Paletes',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleLarge,
                                                textAlign: TextAlign.center,
                                              )
                                            ],
                                          ),
                                        ),
                                      )),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
                                                  CriarPaleteWidget(usur, 0,
                                                      bd: bd),
                                            ));
                                      }
                                      setState(() {});
                                    },
                                    child: (Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 10, right: 20),
                                      child: Container(
                                        alignment: Alignment.center,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.1,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(width: 20),
                                            const Icon(
                                              Icons.create_new_folder_rounded,
                                            ),
                                            Expanded(
                                              child: Container(
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'Criar Novo Palete',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .titleLarge,
                                              textAlign: TextAlign.center,
                                            ),
                                            Expanded(
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topRight: Radius
                                                                .circular(20),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    20))),
                                              ),
                                            )
                                          ],
                                        ),
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
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        16, 12, 16, 12),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        showCursor: true,
                                                        controller: _model
                                                            .textController,
                                                        focusNode: _model
                                                            .textFieldFocusNode,
                                                        onFieldSubmitted:
                                                            (value) async {
                                                          if (await bd.connected(
                                                                  context) ==
                                                              1) {
                                                            bd.paleteExiste(
                                                                int.parse(
                                                                    value),
                                                                context,
                                                                usur,
                                                                bd);
                                                          }
                                                          setState(() {});
                                                        },
                                                        autofocus: true,
                                                        obscureText: false,
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              'Insira o Palete',
                                                          labelStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    color: FlutterFlowTheme.of(context)
                                                          .secondaryText,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                          alignLabelWithHint:
                                                              false,
                                                          hintStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium,
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .alternate,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green
                                                                  .shade500,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green
                                                                  .shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green
                                                                  .shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium,
                                                        keyboardType:
                                                            const TextInputType
                                                                .numberWithOptions(),
                                                        validator: _model
                                                            .textControllerValidator
                                                            .asValidator(
                                                                context),
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
                                            );
                                          },
                                        );
                                      }
                                    },
                                    child: (Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 10, right: 20),
                                      child: Container(
                                        alignment: Alignment.center,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.1,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(width: 20),
                                            const Icon(
                                              Icons.next_week,
                                            ),
                                            Expanded(
                                              child: Container(
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'Continuar Palete',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .titleLarge,
                                              textAlign: TextAlign.center,
                                            ),
                                            Expanded(
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topRight: Radius
                                                                .circular(20),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    20))),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )),
                                  ),
                                  InkWell(
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
                                                  ReimprimirPaleteWidget(
                                                      usur, 0,
                                                      bd: bd)));
                                    },
                                    child: (Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 10, right: 20),
                                      child: Container(
                                        alignment: Alignment.center,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.1,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(width: 20),
                                            const Icon(
                                              Icons.print_rounded,
                                            ),
                                            Expanded(
                                              child: Container(
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'Reimprimir Paletes',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .titleLarge,
                                              textAlign: TextAlign.center,
                                            ),
                                            Expanded(
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topRight: Radius
                                                                .circular(20),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    20))),
                                              ),
                                            )
                                          ],
                                        ),
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
                                                  ListaPaleteWidget(
                                                      cont: 0, usur, bd: bd),
                                            ));
                                      }
                                    },
                                    child: (Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 10, right: 20),
                                      child: Container(
                                        alignment: Alignment.center,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.1,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(width: 20),
                                            const Icon(
                                              Icons.manage_search,
                                            ),
                                            Expanded(
                                              child: Container(
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'Conferir Paletes',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .titleLarge,
                                              textAlign: TextAlign.center,
                                            ),
                                            Expanded(
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topRight: Radius
                                                                .circular(20),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    20))),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )),
                                  ),
                                ],
                              )),
                      ),
                      if (acessosPC.contains(usur.acess) ||
                          acessosADM.contains(usur.acess))
                        Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(40, 20, 0, 10),
                                child: Text(
                                  'Declarações',
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium,
                                ))),
                      if (acessosPC.contains(usur.acess) ||
                          acessosADM.contains(usur.acess))
                        Divider(
                          height: 12,
                          thickness: 2,
                          color: FlutterFlowTheme.of(context).alternate,
                        ),
                      if (acessosPC.contains(usur.acess) ||
                          acessosADM.contains(usur.acess))
                        Padding(
                          padding: const EdgeInsets.only(top: 20, left: 20),
                          child: ((responsiveVisibility(
                                  context: context,
                                  phone: false,
                                  tablet: false,
                                  desktop: true))
                              ? SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          if (await bd.connected(context) ==
                                              1) {
                                            Navigator.pop(context);
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DeclaracoesWidget(usur,
                                                          bd: bd),
                                                ));
                                          }
                                        },
                                        child: (Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Container(
                                            alignment: Alignment.center,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.3,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.2,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.list_alt_rounded,
                                                ),
                                                Container(
                                                  height: 20,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  'Reimprimir Paletes',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .titleLarge,
                                                  textAlign: TextAlign.center,
                                                )
                                              ],
                                            ),
                                          ),
                                        )),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
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
                                                    DeclaracoesWidget(usur,
                                                        bd: bd),
                                              ));
                                        }
                                      },
                                      child: (Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 10, right: 20),
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.8,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.1,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(width: 20),
                                              const Icon(
                                                Icons.list_alt_rounded,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                'Declarações',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleLarge,
                                                textAlign: TextAlign.center,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(20),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )),
                                    ),
                                  ],
                                )),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(right: 0,bottom: 0, child: AtualizacaoWidget(bd: bd,context: context, usur: usur,))
            ],
          ),
        ),
      ),
    );
  }
}
