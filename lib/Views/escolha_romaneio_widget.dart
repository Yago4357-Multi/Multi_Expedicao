import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../Components/Model/escolha_romaneio_model.dart';
import '../Components/Widget/atualizacao.dart';
import '../Components/Widget/drawer_widget.dart';
import '../Controls/banco.dart';
import '../FlutterFlowTheme.dart';
import '../Models/romaneio.dart';
import '../Models/usur.dart';
import 'lista_cancelados.dart';
import 'lista_faturados.dart';
import 'lista_romaneios.dart';
import 'reimprimir_romaneio_widget.dart';
import 'romaneio_widget.dart';

export '../Components/Model/escolha_romaneio_model.dart';

///Página para definir a tarefa escolhida para o Romaneio
class EscolhaRomaneioWidget extends StatefulWidget {
  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///Variável para manter conexão com o Banco
  final Banco bd;

  ///Construtor da página de escolha do Romaneio
  const EscolhaRomaneioWidget(
      this.usur, {
        super.key,
        required this.bd,
      });

  @override
  State<EscolhaRomaneioWidget> createState() =>
      _EscolhaRomaneioWidgetState(usur, bd);
}

class _EscolhaRomaneioWidgetState extends State<EscolhaRomaneioWidget> {
  late EscolhaRomaneioModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final Banco bd;

  final Usuario usur;

  late String romaneio = '0';

  late StateSetter internalSetter;

  late Future<int> qtdFatFut;
  late Future<int> qtdCancFut;
  int qtdFat = 0;
  int qtdCanc = 0;

  _EscolhaRomaneioWidgetState(this.usur, this.bd);

  late Future<List<Romaneio>> romaneios;
  List<Romaneio> romaneiosLista = [];

  @override
  void initState() {
    super.initState();
    rodarBanco();
    _model = createModel(context, EscolhaRomaneioModel.new);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void rodarBanco() async {
    romaneios = bd.romaneioExiste();
    qtdCancFut = bd.qtdCanc();
    qtdFatFut = bd.qtdFat();

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
            'Romaneio',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Outfit',
              color: FlutterFlowTheme.of(context).primaryBackground,
            ),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.lock_reset_outlined),onPressed: () {
                setState(rodarBanco);
              },
              color: Colors.white,
            ),
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
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(40, 20, 0, 10),
                                child: Text(
                                  'Romaneio',
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium,
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
                                (['BI', 'Comercial'].contains(usur.acess))
                                    ? InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    if (await bd.connected(context) == 1) {
                                                      bd.createRomaneio();
                                                      var i = 0;
                                                      if (context.mounted) {
                                                        i = await bd
                                                            .novoRomaneio(
                                                                context);
                                                      }
                                                      if (context.mounted) {
                                                        Navigator.pop(context);
                                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ListaRomaneioWidget(
                                                      i, usur, bd: bd),
                                            ));
                                      }
                                    }
                                    setState(() {});
                                  },
                                  child: (Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Container(
                                      alignment: Alignment.center,
                                      width:
                                      MediaQuery
                                          .of(context)
                                          .size
                                          .height *
                                          0.3,
                                      height:
                                      MediaQuery
                                          .of(context)
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
                                            'Criar Novo Romaneio',
                                            style:
                                            FlutterFlowTheme
                                                .of(context)
                                                .titleLarge,
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                                ) : Container(),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    if (await bd.connected(context) == 1) {
                                      return showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            child: FutureBuilder(
                                              future: romaneios,
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.done) {
                                                  romaneiosLista =
                                                                (snapshot
                                                                        .data ??
                                                                    []);
                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                        16, 12, 16, 12),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize
                                                          .max,
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: TextFormField(
                                                            showCursor: true,
                                                            initialValue:
                                                            romaneio != '0'
                                                                ? romaneio
                                                                : '',
                                                            controller: _model
                                                                .textController,
                                                            focusNode:
                                                            _model
                                                                .textFieldFocusNode,
                                                            onChanged: (value) {
                                                              romaneio = value;
                                                            },
                                                            onFieldSubmitted: (
                                                                value) async {
                                                              if (await bd
                                                                  .connected(
                                                                  context) ==
                                                                  1) {
                                                                if (context
                                                                    .mounted) {
                                                                  if (romaneiosLista
                                                                      .where((
                                                                      element) =>
                                                                  '${element
                                                                      .romaneio}' ==
                                                                      romaneio)
                                                                      .isEmpty) {
                                                                    await showCupertinoModalPopup(
                                                                      context: context,
                                                                      barrierDismissible: false,
                                                                      builder: (
                                                                          context2) {
                                                                        return CupertinoAlertDialog(
                                                                          title: const Text(
                                                                              'Romaneio não encontrado'),
                                                                          actions: <
                                                                              CupertinoDialogAction>[
                                                                            CupertinoDialogAction(
                                                                                isDefaultAction:
                                                                                true,
                                                                                onPressed: () {
                                                                                  Navigator
                                                                                      .pop(
                                                                                      context2);
                                                                                },
                                                                                child: const Text(
                                                                                    'Voltar'))
                                                                          ],
                                                                        );
                                                                      },
                                                                    );
                                                                    return;
                                                                  }
                                                                  if (romaneiosLista
                                                                      .where((
                                                                      element) =>
                                                                  '${element
                                                                      .romaneio}' ==
                                                                      romaneio &&
                                                                      element
                                                                          .dtFechamento ==
                                                                          null)
                                                                      .isEmpty) {
                                                                    await showCupertinoModalPopup(
                                                                        barrierDismissible:
                                                                        false,
                                                                        builder: (
                                                                            context2) {
                                                                          return CupertinoAlertDialog(
                                                                            title: const Text(
                                                                              'Romaneio finalizado\n',
                                                                              style: TextStyle(
                                                                                  fontWeight:
                                                                                  FontWeight
                                                                                      .bold),
                                                                            ),
                                                                            content: const Text(
                                                                                'Escolha outro Romaneio ou converse com os Desenvolvedores'),
                                                                            actions: <
                                                                                CupertinoDialogAction>[
                                                                              CupertinoDialogAction(
                                                                                  isDefaultAction:
                                                                                  true,
                                                                                  onPressed:
                                                                                      () {
                                                                                    Navigator
                                                                                        .pop(
                                                                                        context2);
                                                                                  },
                                                                                  child: const Text(
                                                                                      'Voltar'))
                                                                            ],
                                                                          );
                                                                        },
                                                                        context: context);
                                                                    return;
                                                                  }
                                                                  Navigator.pop(
                                                                      context);
                                                                  await Navigator
                                                                      .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (
                                                                              context) =>
                                                                              ListaRomaneioWidget(
                                                                                  int
                                                                                      .parse(
                                                                                      romaneio),
                                                                                  usur,
                                                                                  bd: bd)));
                                                                }
                                                              }
                                                              setState(() {});
                                                            },
                                                            autofocus: true,
                                                            obscureText: false,
                                                            decoration: InputDecoration(
                                                              labelText: 'Insira o Romaneio',
                                                              labelStyle: FlutterFlowTheme
                                                                  .of(
                                                                  context)
                                                                  .labelMedium
                                                                  .override(
                                                                fontFamily: 'Readex Pro',
                                                                color: FlutterFlowTheme
                                                                    .of(
                                                                    context)
                                                                    .secondaryText,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight
                                                                    .w500,
                                                              ),
                                                              alignLabelWithHint: false,
                                                              hintStyle:
                                                              FlutterFlowTheme
                                                                  .of(context)
                                                                  .labelMedium,
                                                              enabledBorder: OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                  color: FlutterFlowTheme
                                                                      .of(
                                                                      context)
                                                                      .alternate,
                                                                  width: 2,
                                                                ),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    8),
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderSide: BorderSide(
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
                                                              errorBorder: OutlineInputBorder(
                                                                borderSide: BorderSide(
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
                                                                borderSide: BorderSide(
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
                                                            keyboardType: const TextInputType
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
                                                        Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                            child: Container(
                                                                width: 50,
                                                                height: 50,
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .green,
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                        10)),
                                                                child: IconButton(
                                                                    icon: const Icon(
                                                                      Icons
                                                                          .check,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    onPressed: () async {
                                                                      if (await bd
                                                                          .connected(
                                                                          context) ==
                                                                          1) {
                                                                        if (context
                                                                            .mounted) {
                                                                          if (romaneiosLista
                                                                              .where((
                                                                              element) =>
                                                                          '${element
                                                                              .romaneio}' ==
                                                                              romaneio)
                                                                              .isEmpty) {
                                                                            await showCupertinoModalPopup(
                                                                              context: context,
                                                                              barrierDismissible:
                                                                              false,
                                                                              builder:
                                                                                  (
                                                                                  context2) {
                                                                                return CupertinoAlertDialog(
                                                                                  title: const Text(
                                                                                      'Romaneio não encontrado'),
                                                                                  actions: <
                                                                                      CupertinoDialogAction>[
                                                                                    CupertinoDialogAction(
                                                                                        isDefaultAction:
                                                                                        true,
                                                                                        onPressed:
                                                                                            () {
                                                                                          Navigator
                                                                                              .pop(
                                                                                              context2);
                                                                                        },
                                                                                        child: const Text(
                                                                                            'Voltar'))
                                                                                  ],
                                                                                );
                                                                              },
                                                                            );
                                                                            return;
                                                                          }
                                                                          if (romaneiosLista
                                                                              .where((
                                                                              element) =>
                                                                          '${element
                                                                              .romaneio}' ==
                                                                              romaneio &&
                                                                              element
                                                                                  .dtFechamento ==
                                                                                  null)
                                                                              .isEmpty) {
                                                                            await showCupertinoModalPopup(
                                                                                barrierDismissible:
                                                                                false,
                                                                                builder:
                                                                                    (
                                                                                    context2) {
                                                                                  return CupertinoAlertDialog(
                                                                                    title:
                                                                                    const Text(
                                                                                      'Romaneio finalizado\n',
                                                                                      style: TextStyle(
                                                                                          fontWeight:
                                                                                          FontWeight
                                                                                              .bold),
                                                                                    ),
                                                                                    content:
                                                                                    const Text(
                                                                                        'Escolha outro Romaneio ou converse com os Desenvolvedores'),
                                                                                    actions: <
                                                                                        CupertinoDialogAction>[
                                                                                      CupertinoDialogAction(
                                                                                          isDefaultAction:
                                                                                          true,
                                                                                          onPressed:
                                                                                              () {
                                                                                            Navigator
                                                                                                .pop(
                                                                                                context2);
                                                                                          },
                                                                                          child:
                                                                                          const Text(
                                                                                              'Voltar'))
                                                                                    ],
                                                                                  );
                                                                                },
                                                                                context:
                                                                                context);
                                                                            return;
                                                                          }
                                                                          Navigator
                                                                              .pop(
                                                                              context);
                                                                          await Navigator
                                                                              .push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (
                                                                                      context) =>
                                                                                      ListaRomaneioWidget(
                                                                                          int
                                                                                              .parse(
                                                                                              romaneio),
                                                                                          usur,
                                                                                          bd: bd)));
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    }))),
                                                        Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                            child: Container(
                                                                width: 50,
                                                                height: 50,
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .green,
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                        10)),
                                                                child: IconButton(
                                                                    onPressed: () async {
                                                                      if (await bd
                                                                          .connected(
                                                                          context) ==
                                                                          1) {
                                                                        await showDialog(
                                                                          context: context,
                                                                          builder: (
                                                                              context) {
                                                                            return StatefulBuilder(
                                                                              builder: (
                                                                                  context,
                                                                                  setter) {
                                                                                internalSetter =
                                                                                    setter;
                                                                                return Dialog(
                                                                                  backgroundColor:
                                                                                  Colors
                                                                                      .white,
                                                                                  child: Stack(
                                                                                    children: [
                                                                                      Column(
                                                                                        mainAxisSize:
                                                                                        MainAxisSize
                                                                                            .max,
                                                                                        children: [
                                                                                          Container(
                                                                                            height:
                                                                                            MediaQuery
                                                                                                .of(
                                                                                                context)
                                                                                                .size
                                                                                                .height *
                                                                                                0.1,
                                                                                            width:
                                                                                            MediaQuery
                                                                                                .of(
                                                                                                context)
                                                                                                .size
                                                                                                .width,
                                                                                            decoration:
                                                                                            const BoxDecoration(
                                                                                                color: Colors
                                                                                                    .white,
                                                                                                borderRadius: BorderRadiusDirectional
                                                                                                    .vertical(
                                                                                                    top: Radius
                                                                                                        .circular(
                                                                                                        20))),
                                                                                            child:
                                                                                            Align(
                                                                                              alignment: Alignment
                                                                                                  .center,
                                                                                              child: Text(
                                                                                                'Romaneios Abertos',
                                                                                                textAlign: TextAlign
                                                                                                    .center,
                                                                                                style: FlutterFlowTheme
                                                                                                    .of(
                                                                                                    context)
                                                                                                    .headlineMedium
                                                                                                    .override(
                                                                                                  fontFamily: 'Outfit',
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          Container(
                                                                                            padding:
                                                                                            const EdgeInsets
                                                                                                .all(
                                                                                                10),
                                                                                            width:
                                                                                            double
                                                                                                .infinity,
                                                                                            decoration:
                                                                                            BoxDecoration(
                                                                                              color: FlutterFlowTheme
                                                                                                  .of(
                                                                                                  context)
                                                                                                  .primaryBackground,
                                                                                              boxShadow: const [
                                                                                                BoxShadow(
                                                                                                  blurRadius: 0,
                                                                                                  color: Color(
                                                                                                      0xFFE0E3E7),
                                                                                                  offset: Offset(
                                                                                                    0.0,
                                                                                                    1,
                                                                                                  ),
                                                                                                )
                                                                                              ],
                                                                                              borderRadius: BorderRadius
                                                                                                  .circular(
                                                                                                  0),
                                                                                              shape: BoxShape
                                                                                                  .rectangle,
                                                                                            ),
                                                                                            child:
                                                                                            Container(
                                                                                              width: double
                                                                                                  .infinity,
                                                                                              height: 40,
                                                                                              decoration: BoxDecoration(
                                                                                                color: FlutterFlowTheme
                                                                                                    .of(
                                                                                                    context)
                                                                                                    .primaryBackground,
                                                                                                borderRadius: BorderRadius
                                                                                                    .circular(
                                                                                                    12),
                                                                                              ),
                                                                                              alignment: const AlignmentDirectional(
                                                                                                  -1,
                                                                                                  0),
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsetsDirectional
                                                                                                    .fromSTEB(
                                                                                                    16,
                                                                                                    0,
                                                                                                    0,
                                                                                                    0),
                                                                                                child: Row(
                                                                                                  mainAxisSize: MainAxisSize
                                                                                                      .max,
                                                                                                  mainAxisAlignment: MainAxisAlignment
                                                                                                      .spaceBetween,
                                                                                                  crossAxisAlignment: CrossAxisAlignment
                                                                                                      .center,
                                                                                                  children: [
                                                                                                    Expanded(
                                                                                                      child: Text(
                                                                                                        (responsiveVisibility(
                                                                                                            context: context,
                                                                                                            phone: false,
                                                                                                            tablet: false,
                                                                                                            desktop: true))
                                                                                                            ? 'Romaneio'
                                                                                                            : 'Rom.',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelSmall
                                                                                                            .override(
                                                                                                          fontFamily: 'Readex Pro',
                                                                                                          letterSpacing: 0,
                                                                                                          fontSize: 15,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    if (responsiveVisibility(
                                                                                                        context: context,
                                                                                                        phone: false,
                                                                                                        tablet: false,
                                                                                                        desktop: true))
                                                                                                      (Expanded(
                                                                                                        child: Text(
                                                                                                          softWrap: true,
                                                                                                          'Usuário de Abertura',
                                                                                                          style: FlutterFlowTheme
                                                                                                              .of(
                                                                                                              context)
                                                                                                              .labelSmall
                                                                                                              .override(
                                                                                                            fontFamily: 'Readex Pro',
                                                                                                            letterSpacing: 0,
                                                                                                            fontSize: 15,
                                                                                                          ),
                                                                                                        ),
                                                                                                      )),
                                                                                                    if (responsiveVisibility(
                                                                                                        context: context,
                                                                                                        phone: false,
                                                                                                        tablet: false,
                                                                                                        desktop: true))
                                                                                                      (Expanded(
                                                                                                        child: Text(
                                                                                                          'Dt. de Abertura',
                                                                                                          style: FlutterFlowTheme
                                                                                                              .of(
                                                                                                              context)
                                                                                                              .labelSmall
                                                                                                              .override(
                                                                                                            fontFamily: 'Readex Pro',
                                                                                                            letterSpacing: 0,
                                                                                                            fontSize: 15,
                                                                                                          ),
                                                                                                        ),
                                                                                                      )),
                                                                                                    Expanded(
                                                                                                      child: Text(
                                                                                                        'Paletes',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelSmall
                                                                                                            .override(
                                                                                                          fontFamily: 'Readex Pro',
                                                                                                          letterSpacing: 0,
                                                                                                          fontSize: 15,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Expanded(
                                                                                                      child: Text(
                                                                                                        (responsiveVisibility(
                                                                                                            context: context,
                                                                                                            phone: false,
                                                                                                            tablet: false,
                                                                                                            desktop: true))
                                                                                                            ? 'Volumetria'
                                                                                                            : 'Vol.',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelSmall
                                                                                                            .override(
                                                                                                          fontFamily: 'Readex Pro',
                                                                                                          letterSpacing: 0,
                                                                                                          fontSize: 15,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width:
                                                                                            MediaQuery
                                                                                                .of(
                                                                                                context)
                                                                                                .size
                                                                                                .width,
                                                                                            height:
                                                                                            MediaQuery
                                                                                                .of(
                                                                                                context)
                                                                                                .size
                                                                                                .height *
                                                                                                0.7,
                                                                                            child:
                                                                                            ListView
                                                                                                .builder(
                                                                                              shrinkWrap: true,
                                                                                              physics: const AlwaysScrollableScrollPhysics(),
                                                                                              scrollDirection: Axis
                                                                                                  .vertical,
                                                                                              padding: EdgeInsets
                                                                                                  .zero,
                                                                                              itemCount: romaneiosLista
                                                                                                  .length,
                                                                                              itemBuilder: (
                                                                                                  context,
                                                                                                  index) {
                                                                                                if (romaneiosLista[index]
                                                                                                    .dtFechamento ==
                                                                                                    null) {
                                                                                                  if (int
                                                                                                      .parse(
                                                                                                      romaneio) ==
                                                                                                      romaneiosLista[index]
                                                                                                          .romaneio) {
                                                                                                    return Padding(
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          0,
                                                                                                          0,
                                                                                                          0,
                                                                                                          1),
                                                                                                      child: Container(
                                                                                                        width: double
                                                                                                            .infinity,
                                                                                                        decoration: BoxDecoration(
                                                                                                          color: Colors
                                                                                                              .yellow
                                                                                                              .shade50,
                                                                                                          boxShadow: const [
                                                                                                            BoxShadow(
                                                                                                              blurRadius: 0,
                                                                                                              color: Color(
                                                                                                                  0xFFE0E3E7),
                                                                                                              offset: Offset(
                                                                                                                0.0,
                                                                                                                1,
                                                                                                              ),
                                                                                                            )
                                                                                                          ],
                                                                                                          borderRadius: BorderRadius
                                                                                                              .circular(
                                                                                                              0),
                                                                                                          shape: BoxShape
                                                                                                              .rectangle,
                                                                                                        ),
                                                                                                        child: InkWell(
                                                                                                          splashColor: Colors
                                                                                                              .transparent,
                                                                                                          focusColor: Colors
                                                                                                              .transparent,
                                                                                                          hoverColor: Colors
                                                                                                              .transparent,
                                                                                                          highlightColor: Colors
                                                                                                              .transparent,
                                                                                                          onTap: () async {
                                                                                                            if (await bd
                                                                                                                .connected(
                                                                                                                context) ==
                                                                                                                1) {
                                                                                                              setter(
                                                                                                                    () {
                                                                                                                  romaneio =
                                                                                                                  '${romaneiosLista[index]
                                                                                                                      .romaneio!}';
                                                                                                                  setState(() {
                                                                                                                    romaneio =
                                                                                                                    '${romaneiosLista[index]
                                                                                                                        .romaneio!}';
                                                                                                                  });
                                                                                                                },
                                                                                                              );
                                                                                                            }
                                                                                                            setState(() {});
                                                                                                          },
                                                                                                          child: Padding(
                                                                                                            padding: const EdgeInsets
                                                                                                                .all(
                                                                                                                8),
                                                                                                            child: Row(
                                                                                                              mainAxisSize: MainAxisSize
                                                                                                                  .max,
                                                                                                              children: [
                                                                                                                Container(
                                                                                                                  width: 4,
                                                                                                                  height: 50,
                                                                                                                  decoration: BoxDecoration(
                                                                                                                    color: Colors
                                                                                                                        .green
                                                                                                                        .shade400,
                                                                                                                    borderRadius: BorderRadius
                                                                                                                        .circular(
                                                                                                                        2),
                                                                                                                  ),
                                                                                                                ),
                                                                                                                Expanded(
                                                                                                                  child: Padding(
                                                                                                                    padding: const EdgeInsetsDirectional
                                                                                                                        .fromSTEB(
                                                                                                                        12,
                                                                                                                        0,
                                                                                                                        0,
                                                                                                                        0),
                                                                                                                    child: Text(
                                                                                                                      '${romaneiosLista[index]
                                                                                                                          .romaneio}',
                                                                                                                      style: FlutterFlowTheme
                                                                                                                          .of(
                                                                                                                          context)
                                                                                                                          .labelLarge
                                                                                                                          .override(
                                                                                                                        fontFamily: 'Readex Pro',
                                                                                                                        letterSpacing: 0,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                                if (responsiveVisibility(
                                                                                                                    context: context,
                                                                                                                    phone: false,
                                                                                                                    tablet: false,
                                                                                                                    desktop: true))
                                                                                                                  (Expanded(
                                                                                                                    child: Padding(
                                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                                          .fromSTEB(
                                                                                                                          12,
                                                                                                                          0,
                                                                                                                          0,
                                                                                                                          0),
                                                                                                                      child: Text(
                                                                                                                        '${romaneiosLista[index]
                                                                                                                            .usurCriacao}',
                                                                                                                        style: FlutterFlowTheme
                                                                                                                            .of(
                                                                                                                            context)
                                                                                                                            .labelLarge
                                                                                                                            .override(
                                                                                                                          fontFamily: 'Readex Pro',
                                                                                                                          letterSpacing: 0,
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  )),
                                                                                                                if (responsiveVisibility(
                                                                                                                    context: context,
                                                                                                                    phone: false,
                                                                                                                    tablet: false,
                                                                                                                    desktop: true))
                                                                                                                  (Expanded(
                                                                                                                    child: Padding(
                                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                                          .fromSTEB(
                                                                                                                          12,
                                                                                                                          0,
                                                                                                                          0,
                                                                                                                          0),
                                                                                                                      child: Text(
                                                                                                                        DateFormat(
                                                                                                                            'dd/MM/yyyy   kk:mm')
                                                                                                                            .format(
                                                                                                                            romaneiosLista[index]
                                                                                                                                .dtRomaneio!),
                                                                                                                        style: FlutterFlowTheme
                                                                                                                            .of(
                                                                                                                            context)
                                                                                                                            .labelLarge
                                                                                                                            .override(
                                                                                                                          fontFamily: 'Readex Pro',
                                                                                                                          letterSpacing: 0,
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  )),
                                                                                                                Expanded(
                                                                                                                  child: Padding(
                                                                                                                    padding: const EdgeInsetsDirectional
                                                                                                                        .fromSTEB(
                                                                                                                        12,
                                                                                                                        0,
                                                                                                                        0,
                                                                                                                        0),
                                                                                                                    child: Text(
                                                                                                                      '${romaneiosLista[index]
                                                                                                                          .palete}',
                                                                                                                      style: FlutterFlowTheme
                                                                                                                          .of(
                                                                                                                          context)
                                                                                                                          .labelLarge
                                                                                                                          .override(
                                                                                                                        fontFamily: 'Readex Pro',
                                                                                                                        letterSpacing: 0,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                                Expanded(
                                                                                                                  child: Padding(
                                                                                                                    padding: const EdgeInsetsDirectional
                                                                                                                        .fromSTEB(
                                                                                                                        12,
                                                                                                                        0,
                                                                                                                        0,
                                                                                                                        0),
                                                                                                                    child: Text(
                                                                                                                      '${romaneiosLista[index]
                                                                                                                          .vol}',
                                                                                                                      style: FlutterFlowTheme
                                                                                                                          .of(
                                                                                                                          context)
                                                                                                                          .labelLarge
                                                                                                                          .override(
                                                                                                                        fontFamily: 'Readex Pro',
                                                                                                                        letterSpacing: 0,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    );
                                                                                                  } else {
                                                                                                    return Padding(
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          0,
                                                                                                          0,
                                                                                                          0,
                                                                                                          1),
                                                                                                      child: Container(
                                                                                                        width: double
                                                                                                            .infinity,
                                                                                                        decoration: BoxDecoration(
                                                                                                          color: FlutterFlowTheme
                                                                                                              .of(
                                                                                                              context)
                                                                                                              .primaryBackground,
                                                                                                          boxShadow: const [
                                                                                                            BoxShadow(
                                                                                                              blurRadius: 0,
                                                                                                              color: Color(
                                                                                                                  0xFFE0E3E7),
                                                                                                              offset: Offset(
                                                                                                                0.0,
                                                                                                                1,
                                                                                                              ),
                                                                                                            )
                                                                                                          ],
                                                                                                          borderRadius: BorderRadius
                                                                                                              .circular(
                                                                                                              0),
                                                                                                          shape: BoxShape
                                                                                                              .rectangle,
                                                                                                        ),
                                                                                                        child: InkWell(
                                                                                                          onTap: () async {
                                                                                                            if (await bd
                                                                                                                .connected(
                                                                                                                context) ==
                                                                                                                1) {
                                                                                                              setter(
                                                                                                                    () {
                                                                                                                  romaneio =
                                                                                                                  '${romaneiosLista[index]
                                                                                                                      .romaneio!}';
                                                                                                                  setState(() {
                                                                                                                    romaneio =
                                                                                                                    '${romaneiosLista[index]
                                                                                                                        .romaneio!}';
                                                                                                                  });
                                                                                                                },
                                                                                                              );
                                                                                                            }
                                                                                                            setState(() {});
                                                                                                          },
                                                                                                          child: Padding(
                                                                                                            padding: const EdgeInsets
                                                                                                                .all(
                                                                                                                8),
                                                                                                            child: Row(
                                                                                                              mainAxisSize: MainAxisSize
                                                                                                                  .max,
                                                                                                              children: [
                                                                                                                Container(
                                                                                                                  width: 4,
                                                                                                                  height: 50,
                                                                                                                  decoration: BoxDecoration(
                                                                                                                    color: FlutterFlowTheme
                                                                                                                        .of(
                                                                                                                        context)
                                                                                                                        .alternate,
                                                                                                                    borderRadius: BorderRadius
                                                                                                                        .circular(
                                                                                                                        2),
                                                                                                                  ),
                                                                                                                ),
                                                                                                                Expanded(
                                                                                                                  child: Padding(
                                                                                                                    padding: const EdgeInsetsDirectional
                                                                                                                        .fromSTEB(
                                                                                                                        12,
                                                                                                                        0,
                                                                                                                        0,
                                                                                                                        0),
                                                                                                                    child: Text(
                                                                                                                      '${romaneiosLista[index]
                                                                                                                          .romaneio}',
                                                                                                                      style: FlutterFlowTheme
                                                                                                                          .of(
                                                                                                                          context)
                                                                                                                          .labelLarge
                                                                                                                          .override(
                                                                                                                        fontFamily: 'Readex Pro',
                                                                                                                        letterSpacing: 0,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                                if (responsiveVisibility(
                                                                                                                    context: context,
                                                                                                                    phone: false,
                                                                                                                    tablet: false,
                                                                                                                    desktop: true))
                                                                                                                  (Expanded(
                                                                                                                    child: Padding(
                                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                                          .fromSTEB(
                                                                                                                          12,
                                                                                                                          0,
                                                                                                                          0,
                                                                                                                          0),
                                                                                                                      child: Text(
                                                                                                                        '${romaneiosLista[index]
                                                                                                                            .usurCriacao}',
                                                                                                                        style: FlutterFlowTheme
                                                                                                                            .of(
                                                                                                                            context)
                                                                                                                            .labelLarge
                                                                                                                            .override(
                                                                                                                          fontFamily: 'Readex Pro',
                                                                                                                          letterSpacing: 0,
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  )),
                                                                                                                if (responsiveVisibility(
                                                                                                                    context: context,
                                                                                                                    phone: false,
                                                                                                                    tablet: false,
                                                                                                                    desktop: true))
                                                                                                                  (Expanded(
                                                                                                                    child: Padding(
                                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                                          .fromSTEB(
                                                                                                                          12,
                                                                                                                          0,
                                                                                                                          0,
                                                                                                                          0),
                                                                                                                      child: Text(
                                                                                                                        DateFormat(
                                                                                                                            'dd/MM/yyyy   kk:mm')
                                                                                                                            .format(
                                                                                                                            romaneiosLista[index]
                                                                                                                                .dtRomaneio!),
                                                                                                                        style: FlutterFlowTheme
                                                                                                                            .of(
                                                                                                                            context)
                                                                                                                            .labelLarge
                                                                                                                            .override(
                                                                                                                          fontFamily: 'Readex Pro',
                                                                                                                          letterSpacing: 0,
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  )),
                                                                                                                Expanded(
                                                                                                                  child: Padding(
                                                                                                                    padding: const EdgeInsetsDirectional
                                                                                                                        .fromSTEB(
                                                                                                                        12,
                                                                                                                        0,
                                                                                                                        0,
                                                                                                                        0),
                                                                                                                    child: Text(
                                                                                                                      '${romaneiosLista[index]
                                                                                                                          .palete}',
                                                                                                                      style: FlutterFlowTheme
                                                                                                                          .of(
                                                                                                                          context)
                                                                                                                          .labelLarge
                                                                                                                          .override(
                                                                                                                        fontFamily: 'Readex Pro',
                                                                                                                        letterSpacing: 0,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                                Expanded(
                                                                                                                  child: Padding(
                                                                                                                    padding: const EdgeInsetsDirectional
                                                                                                                        .fromSTEB(
                                                                                                                        12,
                                                                                                                        0,
                                                                                                                        0,
                                                                                                                        0),
                                                                                                                    child: Text(
                                                                                                                      '${romaneiosLista[index]
                                                                                                                          .vol}',
                                                                                                                      style: FlutterFlowTheme
                                                                                                                          .of(
                                                                                                                          context)
                                                                                                                          .labelLarge
                                                                                                                          .override(
                                                                                                                        fontFamily: 'Readex Pro',
                                                                                                                        letterSpacing: 0,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    );
                                                                                                  }
                                                                                                } else {
                                                                                                  return Container();
                                                                                                }
                                                                                              },
                                                                                            ),
                                                                                          ),
                                                                                          Expanded(
                                                                                              child: Container(
                                                                                                decoration:
                                                                                                const BoxDecoration(
                                                                                                    color: Colors
                                                                                                        .white,
                                                                                                    borderRadius: BorderRadius
                                                                                                        .only(
                                                                                                        bottomLeft: Radius
                                                                                                            .circular(
                                                                                                            20),
                                                                                                        bottomRight: Radius
                                                                                                            .circular(
                                                                                                            20))),
                                                                                              ))
                                                                                        ],
                                                                                      ),
                                                                                      Positioned(
                                                                                          bottom:
                                                                                          10,
                                                                                          right:
                                                                                          10,
                                                                                          child: Container(
                                                                                              decoration: BoxDecoration(
                                                                                                  color: Colors
                                                                                                      .green,
                                                                                                  borderRadius: BorderRadius
                                                                                                      .circular(
                                                                                                      10)),
                                                                                              width: 50,
                                                                                              height: 50,
                                                                                              child: IconButton(
                                                                                                onPressed: () async {
                                                                                                  if (await bd
                                                                                                      .connected(
                                                                                                      context) ==
                                                                                                      1) {
                                                                                                    if (context
                                                                                                        .mounted) {
                                                                                                      if (romaneiosLista
                                                                                                          .where((
                                                                                                          element) =>
                                                                                                      '${element
                                                                                                          .romaneio}' ==
                                                                                                          romaneio)
                                                                                                          .isEmpty) {
                                                                                                        await showCupertinoModalPopup(
                                                                                                          context: context,
                                                                                                          barrierDismissible: false,
                                                                                                          builder: (
                                                                                                              context2) {
                                                                                                            return CupertinoAlertDialog(
                                                                                                              title: const Text(
                                                                                                                  'Romaneio não encontrado'),
                                                                                                              actions: <
                                                                                                                  CupertinoDialogAction>[
                                                                                                                CupertinoDialogAction(
                                                                                                                    isDefaultAction: true,
                                                                                                                    onPressed: () {
                                                                                                                      Navigator
                                                                                                                          .pop(
                                                                                                                          context2);
                                                                                                                    },
                                                                                                                    child: const Text(
                                                                                                                        'Voltar'))
                                                                                                              ],
                                                                                                            );
                                                                                                          },
                                                                                                        );
                                                                                                        return;
                                                                                                      }
                                                                                                      if (romaneiosLista
                                                                                                          .where((
                                                                                                          element) =>
                                                                                                      '${element
                                                                                                          .romaneio}' ==
                                                                                                          romaneio &&
                                                                                                          element
                                                                                                              .dtFechamento ==
                                                                                                              null)
                                                                                                          .isEmpty) {
                                                                                                        await showCupertinoModalPopup(
                                                                                                            barrierDismissible: false,
                                                                                                            builder: (
                                                                                                                context2) {
                                                                                                              return CupertinoAlertDialog(
                                                                                                                title: const Text(
                                                                                                                  'Romaneio finalizado\n',
                                                                                                                  style: TextStyle(
                                                                                                                      fontWeight: FontWeight
                                                                                                                          .bold),
                                                                                                                ),
                                                                                                                content: const Text(
                                                                                                                    'Escolha outro Romaneio ou converse com os Desenvolvedores'),
                                                                                                                actions: <
                                                                                                                    CupertinoDialogAction>[
                                                                                                                  CupertinoDialogAction(
                                                                                                                      isDefaultAction: true,
                                                                                                                      onPressed: () {
                                                                                                                        Navigator
                                                                                                                            .pop(
                                                                                                                            context2);
                                                                                                                      },
                                                                                                                      child: const Text(
                                                                                                                          'Voltar'))
                                                                                                                ],
                                                                                                              );
                                                                                                            },
                                                                                                            context: context);
                                                                                                        return;
                                                                                                      }
                                                                                                      Navigator
                                                                                                          .pop(
                                                                                                          context);
                                                                                                      Navigator
                                                                                                          .pop(
                                                                                                          context);
                                                                                                      Navigator
                                                                                                          .pop(
                                                                                                          context);
                                                                                                      await Navigator
                                                                                                          .push(
                                                                                                          context,
                                                                                                          MaterialPageRoute(
                                                                                                              builder: (
                                                                                                                  context) =>
                                                                                                                  ListaRomaneioWidget(
                                                                                                                      int
                                                                                                                          .parse(
                                                                                                                          romaneio),
                                                                                                                      usur,
                                                                                                                      bd: bd)));
                                                                                                    }
                                                                                                  }
                                                                                                },
                                                                                                icon: const Icon(
                                                                                                    Icons
                                                                                                        .check,
                                                                                                    color: Colors
                                                                                                        .white),
                                                                                              )))
                                                                                    ],
                                                                                  ),
                                                                                );
                                                                              },
                                                                            );
                                                                          },
                                                                        );
                                                                      }
                                                                    },
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .search_rounded,
                                                                        color: Colors
                                                                            .white))))
                                                      ],
                                                    ),
                                                  );
                                                } else {
                                                  return const Center(
                                                    child: CircularProgressIndicator(),
                                                  );
                                                }
                                              },
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
                                      width:
                                      MediaQuery
                                          .of(context)
                                          .size
                                          .height *
                                          0.3,
                                      height:
                                      MediaQuery
                                          .of(context)
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
                                            Icons.next_week_rounded,
                                          ),
                                          Container(
                                            height: 20,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            'Continuar Romaneio',
                                            style:
                                            FlutterFlowTheme
                                                .of(context)
                                                .titleLarge,
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                                ),
                                (['BI', 'Comercial'].contains(usur.acess)) ?
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
                                                ReimpriprimirRomaneioWidget(
                                                    usur, 0, bd: bd),
                                          ));
                                    }
                                  },
                                  child: (Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Container(
                                      alignment: Alignment.center,
                                      width:
                                      MediaQuery
                                          .of(context)
                                          .size
                                          .height *
                                          0.3,
                                      height:
                                      MediaQuery
                                          .of(context)
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
                                            'Reimprimir Romaneios',
                                            style:
                                            FlutterFlowTheme
                                                .of(context)
                                                .titleLarge,
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                                ) : Container(),
                                (['BI', 'Comercial'].contains(usur.acess)) ?
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
                                                ListaRomaneiosWidget(
                                                    usur, bd: bd),
                                          ));
                                    }
                                  },
                                  child: (Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Container(
                                      alignment: Alignment.center,
                                      width:
                                      MediaQuery
                                          .of(context)
                                          .size
                                          .height *
                                          0.3,
                                      height:
                                      MediaQuery
                                          .of(context)
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
                                            'Conferir Romaneios',
                                            style:
                                            FlutterFlowTheme
                                                .of(context)
                                                .titleLarge,
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                                ) : Container(),
                              ],
                            ),
                          )
                              : Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              (['BI', 'Comercial'].contains(usur.acess))
                                  ? InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  if (await bd.connected(context) == 1) {
                                                    bd.createRomaneio();
                                                    var i = 0;
                                                    if (context.mounted) {
                                                      i = await bd.novoRomaneio(
                                                          context);
                                                    }
                                                    if (context.mounted) {
                                                      Navigator.pop(context);
                                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ListaRomaneioWidget(
                                                    i, usur, bd: bd),
                                          ));
                                    }
                                  }
                                  setState(() {});
                                },
                                child: (Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10, right: 20),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width:
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .height *
                                        0.8,
                                    height:
                                    MediaQuery
                                        .of(context)
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
                                          Icons.create_new_folder_rounded,
                                        ),
                                        Expanded(
                                          child: Container(
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Criar Novo Romaneio',
                                          style: FlutterFlowTheme
                                              .of(context)
                                              .titleLarge,
                                          textAlign: TextAlign.center,
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(
                                                        20),
                                                    bottomRight: Radius
                                                        .circular(20))),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                              ) : Container(),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  if (await bd.connected(context) == 1) {
                                    return showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          child: FutureBuilder(
                                            future: romaneios,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.done) {
                                                romaneiosLista =
                                                snapshot.data as List<Romaneio>;
                                                return Padding(
                                                  padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      16, 12, 16, 12),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize
                                                        .max,
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField(
                                                          showCursor: true,
                                                          initialValue:
                                                          romaneio != '0'
                                                              ? romaneio
                                                              : '',
                                                          controller: _model
                                                              .textController,
                                                          focusNode:
                                                          _model
                                                              .textFieldFocusNode,
                                                          onChanged: (value) {
                                                            romaneio = value;
                                                          },
                                                          onFieldSubmitted: (
                                                              value) async {
                                                            if (await bd
                                                                .connected(
                                                                context) ==
                                                                1) {
                                                              if (context
                                                                  .mounted) {
                                                                if (romaneiosLista
                                                                    .where((
                                                                    element) =>
                                                                '${element
                                                                    .romaneio}' ==
                                                                    romaneio)
                                                                    .isEmpty) {
                                                                  await showCupertinoModalPopup(
                                                                    context: context,
                                                                    barrierDismissible: false,
                                                                    builder: (
                                                                        context2) {
                                                                      return CupertinoAlertDialog(
                                                                        title: const Text(
                                                                            'Romaneio não encontrado'),
                                                                        actions: <
                                                                            CupertinoDialogAction>[
                                                                          CupertinoDialogAction(
                                                                              isDefaultAction:
                                                                              true,
                                                                              onPressed: () {
                                                                                Navigator
                                                                                    .pop(
                                                                                    context2);
                                                                              },
                                                                              child: const Text(
                                                                                  'Voltar'))
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                  return;
                                                                }
                                                                if (romaneiosLista
                                                                    .where((
                                                                    element) =>
                                                                '${element
                                                                    .romaneio}' ==
                                                                    romaneio &&
                                                                    element
                                                                        .dtFechamento ==
                                                                        null)
                                                                    .isEmpty) {
                                                                  await showCupertinoModalPopup(
                                                                      barrierDismissible:
                                                                      false,
                                                                      builder: (
                                                                          context2) {
                                                                        return CupertinoAlertDialog(
                                                                          title: const Text(
                                                                            'Romaneio finalizado\n',
                                                                            style: TextStyle(
                                                                                fontWeight:
                                                                                FontWeight
                                                                                    .bold),
                                                                          ),
                                                                          content: const Text(
                                                                              'Escolha outro Romaneio ou converse com os Desenvolvedores'),
                                                                          actions: <
                                                                              CupertinoDialogAction>[
                                                                            CupertinoDialogAction(
                                                                                isDefaultAction:
                                                                                true,
                                                                                onPressed:
                                                                                    () {
                                                                                  Navigator
                                                                                      .pop(
                                                                                      context2);
                                                                                },
                                                                                child: const Text(
                                                                                    'Voltar'))
                                                                          ],
                                                                        );
                                                                      },
                                                                      context: context);
                                                                  return;
                                                                }
                                                                Navigator.pop(
                                                                    context);
                                                                await Navigator
                                                                    .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (
                                                                            context) =>
                                                                            ListaRomaneioWidget(
                                                                                int
                                                                                    .parse(
                                                                                    romaneio),
                                                                                usur,
                                                                                bd: bd)));
                                                              }
                                                            }
                                                            setState(() {});
                                                          },
                                                          autofocus: true,
                                                          obscureText: false,
                                                          decoration: InputDecoration(
                                                            labelText: 'Insira o Romaneio',
                                                            labelStyle: FlutterFlowTheme
                                                                .of(
                                                                context)
                                                                .labelMedium
                                                                .override(
                                                              fontFamily: 'Readex Pro',
                                                              color: FlutterFlowTheme
                                                                  .of(
                                                                  context)
                                                                  .secondaryText,
                                                              fontSize: 14,
                                                              fontWeight: FontWeight
                                                                  .w500,
                                                            ),
                                                            alignLabelWithHint: false,
                                                            hintStyle:
                                                            FlutterFlowTheme
                                                                .of(context)
                                                                .labelMedium,
                                                            enabledBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                color: FlutterFlowTheme
                                                                    .of(
                                                                    context)
                                                                    .alternate,
                                                                width: 2,
                                                              ),
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                            ),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                color: Colors
                                                                    .green
                                                                    .shade500,
                                                                width: 2,
                                                              ),
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                            ),
                                                            errorBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                color: Colors
                                                                    .green
                                                                    .shade100,
                                                                width: 2,
                                                              ),
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                            ),
                                                            focusedErrorBorder:
                                                            OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                color: Colors
                                                                    .green
                                                                    .shade100,
                                                                width: 2,
                                                              ),
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                            ),
                                                          ),
                                                          style: FlutterFlowTheme
                                                              .of(context)
                                                              .bodyMedium,
                                                          keyboardType: const TextInputType
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
                                                      Padding(
                                                          padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                          child: Container(
                                                              width: 50,
                                                              height: 50,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .green,
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      10)),
                                                              child: IconButton(
                                                                  icon: const Icon(
                                                                    Icons.check,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  onPressed: () async {
                                                                    if (await bd
                                                                        .connected(
                                                                        context) ==
                                                                        1) {
                                                                      if (context
                                                                          .mounted) {
                                                                        if (romaneiosLista
                                                                            .where((
                                                                            element) =>
                                                                        '${element
                                                                            .romaneio}' ==
                                                                            romaneio)
                                                                            .isEmpty) {
                                                                          await showCupertinoModalPopup(
                                                                            context: context,
                                                                            barrierDismissible:
                                                                            false,
                                                                            builder:
                                                                                (
                                                                                context2) {
                                                                              return CupertinoAlertDialog(
                                                                                title: const Text(
                                                                                    'Romaneio não encontrado'),
                                                                                actions: <
                                                                                    CupertinoDialogAction>[
                                                                                  CupertinoDialogAction(
                                                                                      isDefaultAction:
                                                                                      true,
                                                                                      onPressed:
                                                                                          () {
                                                                                        Navigator
                                                                                            .pop(
                                                                                            context2);
                                                                                      },
                                                                                      child: const Text(
                                                                                          'Voltar'))
                                                                                ],
                                                                              );
                                                                            },
                                                                          );
                                                                          return;
                                                                        }
                                                                        if (romaneiosLista
                                                                            .where((
                                                                            element) =>
                                                                        '${element
                                                                            .romaneio}' ==
                                                                            romaneio &&
                                                                            element
                                                                                .dtFechamento ==
                                                                                null)
                                                                            .isEmpty) {
                                                                          await showCupertinoModalPopup(
                                                                              barrierDismissible:
                                                                              false,
                                                                              builder:
                                                                                  (
                                                                                  context2) {
                                                                                return CupertinoAlertDialog(
                                                                                  title:
                                                                                  const Text(
                                                                                    'Romaneio finalizado\n',
                                                                                    style: TextStyle(
                                                                                        fontWeight:
                                                                                        FontWeight
                                                                                            .bold),
                                                                                  ),
                                                                                  content:
                                                                                  const Text(
                                                                                      'Escolha outro Romaneio ou converse com os Desenvolvedores'),
                                                                                  actions: <
                                                                                      CupertinoDialogAction>[
                                                                                    CupertinoDialogAction(
                                                                                        isDefaultAction:
                                                                                        true,
                                                                                        onPressed:
                                                                                            () {
                                                                                          Navigator
                                                                                              .pop(
                                                                                              context2);
                                                                                        },
                                                                                        child:
                                                                                        const Text(
                                                                                            'Voltar'))
                                                                                  ],
                                                                                );
                                                                              },
                                                                              context:
                                                                              context);
                                                                          return;
                                                                        }
                                                                        Navigator
                                                                            .pop(
                                                                            context);
                                                                        await Navigator
                                                                            .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (
                                                                                    context) =>
                                                                                    ListaRomaneioWidget(
                                                                                        int
                                                                                            .parse(
                                                                                            romaneio),
                                                                                        usur,
                                                                                        bd: bd)));
                                                                      }
                                                                    }
                                                                    setState(() {});
                                                                  }))),
                                                      Padding(
                                                          padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                          child: Container(
                                                              width: 50,
                                                              height: 50,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .green,
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      10)),
                                                              child: IconButton(
                                                                  onPressed: () async {
                                                                    if (await bd
                                                                        .connected(
                                                                        context) ==
                                                                        1) {
                                                                      await showDialog(
                                                                        context: context,
                                                                        builder: (
                                                                            context) {
                                                                          return StatefulBuilder(
                                                                            builder: (
                                                                                context,
                                                                                setter) {
                                                                              internalSetter =
                                                                                  setter;
                                                                              return Dialog(
                                                                                backgroundColor:
                                                                                Colors
                                                                                    .white,
                                                                                child: Stack(
                                                                                  children: [
                                                                                    Column(
                                                                                      mainAxisSize:
                                                                                      MainAxisSize
                                                                                          .max,
                                                                                      children: [
                                                                                        Container(
                                                                                          height:
                                                                                          MediaQuery
                                                                                              .of(
                                                                                              context)
                                                                                              .size
                                                                                              .height *
                                                                                              0.1,
                                                                                          width:
                                                                                          MediaQuery
                                                                                              .of(
                                                                                              context)
                                                                                              .size
                                                                                              .width,
                                                                                          decoration:
                                                                                          const BoxDecoration(
                                                                                              color: Colors
                                                                                                  .white,
                                                                                              borderRadius: BorderRadiusDirectional
                                                                                                  .vertical(
                                                                                                  top: Radius
                                                                                                      .circular(
                                                                                                      20))),
                                                                                          child:
                                                                                          Align(
                                                                                            alignment: Alignment
                                                                                                .center,
                                                                                            child: Text(
                                                                                              'Romaneios Abertos',
                                                                                              textAlign: TextAlign
                                                                                                  .center,
                                                                                              style: FlutterFlowTheme
                                                                                                  .of(
                                                                                                  context)
                                                                                                  .headlineMedium
                                                                                                  .override(
                                                                                                fontFamily: 'Outfit',
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Container(
                                                                                          padding:
                                                                                          const EdgeInsets
                                                                                              .all(
                                                                                              10),
                                                                                          width:
                                                                                          double
                                                                                              .infinity,
                                                                                          decoration:
                                                                                          BoxDecoration(
                                                                                            color: FlutterFlowTheme
                                                                                                .of(
                                                                                                context)
                                                                                                .primaryBackground,
                                                                                            boxShadow: const [
                                                                                              BoxShadow(
                                                                                                blurRadius: 0,
                                                                                                color: Color(
                                                                                                    0xFFE0E3E7),
                                                                                                offset: Offset(
                                                                                                  0.0,
                                                                                                  1,
                                                                                                ),
                                                                                              )
                                                                                            ],
                                                                                            borderRadius: BorderRadius
                                                                                                .circular(
                                                                                                0),
                                                                                            shape: BoxShape
                                                                                                .rectangle,
                                                                                          ),
                                                                                          child:
                                                                                          Container(
                                                                                            width: double
                                                                                                .infinity,
                                                                                            height: 40,
                                                                                            decoration: BoxDecoration(
                                                                                              color: FlutterFlowTheme
                                                                                                  .of(
                                                                                                  context)
                                                                                                  .primaryBackground,
                                                                                              borderRadius: BorderRadius
                                                                                                  .circular(
                                                                                                  12),
                                                                                            ),
                                                                                            alignment: const AlignmentDirectional(
                                                                                                -1,
                                                                                                0),
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsetsDirectional
                                                                                                  .fromSTEB(
                                                                                                  16,
                                                                                                  0,
                                                                                                  0,
                                                                                                  0),
                                                                                              child: Row(
                                                                                                mainAxisSize: MainAxisSize
                                                                                                    .max,
                                                                                                mainAxisAlignment: MainAxisAlignment
                                                                                                    .spaceBetween,
                                                                                                crossAxisAlignment: CrossAxisAlignment
                                                                                                    .center,
                                                                                                children: [
                                                                                                  Expanded(
                                                                                                    child: Text(
                                                                                                      (responsiveVisibility(
                                                                                                          context: context,
                                                                                                          phone: false,
                                                                                                          tablet: false,
                                                                                                          desktop: true))
                                                                                                          ? 'Romaneio'
                                                                                                          : 'Rom.',
                                                                                                      style: FlutterFlowTheme
                                                                                                          .of(
                                                                                                          context)
                                                                                                          .labelSmall
                                                                                                          .override(
                                                                                                        fontFamily: 'Readex Pro',
                                                                                                        letterSpacing: 0,
                                                                                                        fontSize: 15,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  if (responsiveVisibility(
                                                                                                      context: context,
                                                                                                      phone: false,
                                                                                                      tablet: false,
                                                                                                      desktop: true))
                                                                                                    (Expanded(
                                                                                                      child: Text(
                                                                                                        softWrap: true,
                                                                                                        'Usuário de Abertura',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelSmall
                                                                                                            .override(
                                                                                                          fontFamily: 'Readex Pro',
                                                                                                          letterSpacing: 0,
                                                                                                          fontSize: 15,
                                                                                                        ),
                                                                                                      ),
                                                                                                    )),
                                                                                                  if (responsiveVisibility(
                                                                                                      context: context,
                                                                                                      phone: false,
                                                                                                      tablet: false,
                                                                                                      desktop: true))
                                                                                                    (Expanded(
                                                                                                      child: Text(
                                                                                                        'Dt. de Abertura',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelSmall
                                                                                                            .override(
                                                                                                          fontFamily: 'Readex Pro',
                                                                                                          letterSpacing: 0,
                                                                                                          fontSize: 15,
                                                                                                        ),
                                                                                                      ),
                                                                                                    )),
                                                                                                  Expanded(
                                                                                                    child: Text(
                                                                                                      'Paletes',
                                                                                                      style: FlutterFlowTheme
                                                                                                          .of(
                                                                                                          context)
                                                                                                          .labelSmall
                                                                                                          .override(
                                                                                                        fontFamily: 'Readex Pro',
                                                                                                        letterSpacing: 0,
                                                                                                        fontSize: 15,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Expanded(
                                                                                                    child: Text(
                                                                                                      (responsiveVisibility(
                                                                                                          context: context,
                                                                                                          phone: false,
                                                                                                          tablet: false,
                                                                                                          desktop: true))
                                                                                                          ? 'Volumetria'
                                                                                                          : 'Vol.',
                                                                                                      style: FlutterFlowTheme
                                                                                                          .of(
                                                                                                          context)
                                                                                                          .labelSmall
                                                                                                          .override(
                                                                                                        fontFamily: 'Readex Pro',
                                                                                                        letterSpacing: 0,
                                                                                                        fontSize: 15,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          width:
                                                                                          MediaQuery
                                                                                              .of(
                                                                                              context)
                                                                                              .size
                                                                                              .width,
                                                                                          height:
                                                                                          MediaQuery
                                                                                              .of(
                                                                                              context)
                                                                                              .size
                                                                                              .height *
                                                                                              0.7,
                                                                                          child:
                                                                                          ListView
                                                                                              .builder(
                                                                                            shrinkWrap: true,
                                                                                            physics: const AlwaysScrollableScrollPhysics(),
                                                                                            scrollDirection: Axis
                                                                                                .vertical,
                                                                                            padding: EdgeInsets
                                                                                                .zero,
                                                                                            itemCount: romaneiosLista
                                                                                                .length,
                                                                                            itemBuilder: (
                                                                                                context,
                                                                                                index) {
                                                                                              if (romaneiosLista[index]
                                                                                                  .dtFechamento ==
                                                                                                  null) {
                                                                                                if (int
                                                                                                    .parse(
                                                                                                    romaneio) ==
                                                                                                    romaneiosLista[index]
                                                                                                        .romaneio) {
                                                                                                  return Padding(
                                                                                                    padding: const EdgeInsetsDirectional
                                                                                                        .fromSTEB(
                                                                                                        0,
                                                                                                        0,
                                                                                                        0,
                                                                                                        1),
                                                                                                    child: Container(
                                                                                                      width: double
                                                                                                          .infinity,
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: Colors
                                                                                                            .yellow
                                                                                                            .shade50,
                                                                                                        boxShadow: const [
                                                                                                          BoxShadow(
                                                                                                            blurRadius: 0,
                                                                                                            color: Color(
                                                                                                                0xFFE0E3E7),
                                                                                                            offset: Offset(
                                                                                                              0.0,
                                                                                                              1,
                                                                                                            ),
                                                                                                          )
                                                                                                        ],
                                                                                                        borderRadius: BorderRadius
                                                                                                            .circular(
                                                                                                            0),
                                                                                                        shape: BoxShape
                                                                                                            .rectangle,
                                                                                                      ),
                                                                                                      child: InkWell(
                                                                                                        splashColor: Colors
                                                                                                            .transparent,
                                                                                                        focusColor: Colors
                                                                                                            .transparent,
                                                                                                        hoverColor: Colors
                                                                                                            .transparent,
                                                                                                        highlightColor: Colors
                                                                                                            .transparent,
                                                                                                        onTap: () async {
                                                                                                          if (await bd
                                                                                                              .connected(
                                                                                                              context) ==
                                                                                                              1) {
                                                                                                            setter(
                                                                                                                  () {
                                                                                                                romaneio =
                                                                                                                '${romaneiosLista[index]
                                                                                                                    .romaneio!}';
                                                                                                                setState(() {
                                                                                                                  romaneio =
                                                                                                                  '${romaneiosLista[index]
                                                                                                                      .romaneio!}';
                                                                                                                });
                                                                                                              },
                                                                                                            );
                                                                                                          }
                                                                                                          setState(() {});
                                                                                                        },
                                                                                                        child: Padding(
                                                                                                          padding: const EdgeInsets
                                                                                                              .all(
                                                                                                              8),
                                                                                                          child: Row(
                                                                                                            mainAxisSize: MainAxisSize
                                                                                                                .max,
                                                                                                            children: [
                                                                                                              Container(
                                                                                                                width: 4,
                                                                                                                height: 50,
                                                                                                                decoration: BoxDecoration(
                                                                                                                  color: Colors
                                                                                                                      .green
                                                                                                                      .shade400,
                                                                                                                  borderRadius: BorderRadius
                                                                                                                      .circular(
                                                                                                                      2),
                                                                                                                ),
                                                                                                              ),
                                                                                                              Expanded(
                                                                                                                child: Padding(
                                                                                                                  padding: const EdgeInsetsDirectional
                                                                                                                      .fromSTEB(
                                                                                                                      12,
                                                                                                                      0,
                                                                                                                      0,
                                                                                                                      0),
                                                                                                                  child: Text(
                                                                                                                    '${romaneiosLista[index]
                                                                                                                        .romaneio}',
                                                                                                                    style: FlutterFlowTheme
                                                                                                                        .of(
                                                                                                                        context)
                                                                                                                        .labelLarge
                                                                                                                        .override(
                                                                                                                      fontFamily: 'Readex Pro',
                                                                                                                      letterSpacing: 0,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ),
                                                                                                              if (responsiveVisibility(
                                                                                                                  context: context,
                                                                                                                  phone: false,
                                                                                                                  tablet: false,
                                                                                                                  desktop: true))
                                                                                                                (Expanded(
                                                                                                                  child: Padding(
                                                                                                                    padding: const EdgeInsetsDirectional
                                                                                                                        .fromSTEB(
                                                                                                                        12,
                                                                                                                        0,
                                                                                                                        0,
                                                                                                                        0),
                                                                                                                    child: Text(
                                                                                                                      '${romaneiosLista[index]
                                                                                                                          .usurCriacao}',
                                                                                                                      style: FlutterFlowTheme
                                                                                                                          .of(
                                                                                                                          context)
                                                                                                                          .labelLarge
                                                                                                                          .override(
                                                                                                                        fontFamily: 'Readex Pro',
                                                                                                                        letterSpacing: 0,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                )),
                                                                                                              if (responsiveVisibility(
                                                                                                                  context: context,
                                                                                                                  phone: false,
                                                                                                                  tablet: false,
                                                                                                                  desktop: true))
                                                                                                                (Expanded(
                                                                                                                  child: Padding(
                                                                                                                    padding: const EdgeInsetsDirectional
                                                                                                                        .fromSTEB(
                                                                                                                        12,
                                                                                                                        0,
                                                                                                                        0,
                                                                                                                        0),
                                                                                                                    child: Text(
                                                                                                                      DateFormat(
                                                                                                                          'dd/MM/yyyy   kk:mm')
                                                                                                                          .format(
                                                                                                                          romaneiosLista[index]
                                                                                                                              .dtRomaneio!),
                                                                                                                      style: FlutterFlowTheme
                                                                                                                          .of(
                                                                                                                          context)
                                                                                                                          .labelLarge
                                                                                                                          .override(
                                                                                                                        fontFamily: 'Readex Pro',
                                                                                                                        letterSpacing: 0,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                )),
                                                                                                              Expanded(
                                                                                                                child: Padding(
                                                                                                                  padding: const EdgeInsetsDirectional
                                                                                                                      .fromSTEB(
                                                                                                                      12,
                                                                                                                      0,
                                                                                                                      0,
                                                                                                                      0),
                                                                                                                  child: Text(
                                                                                                                    '${romaneiosLista[index]
                                                                                                                        .palete}',
                                                                                                                    style: FlutterFlowTheme
                                                                                                                        .of(
                                                                                                                        context)
                                                                                                                        .labelLarge
                                                                                                                        .override(
                                                                                                                      fontFamily: 'Readex Pro',
                                                                                                                      letterSpacing: 0,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ),
                                                                                                              Expanded(
                                                                                                                child: Padding(
                                                                                                                  padding: const EdgeInsetsDirectional
                                                                                                                      .fromSTEB(
                                                                                                                      12,
                                                                                                                      0,
                                                                                                                      0,
                                                                                                                      0),
                                                                                                                  child: Text(
                                                                                                                    '${romaneiosLista[index]
                                                                                                                        .vol}',
                                                                                                                    style: FlutterFlowTheme
                                                                                                                        .of(
                                                                                                                        context)
                                                                                                                        .labelLarge
                                                                                                                        .override(
                                                                                                                      fontFamily: 'Readex Pro',
                                                                                                                      letterSpacing: 0,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  );
                                                                                                } else {
                                                                                                  return Padding(
                                                                                                    padding: const EdgeInsetsDirectional
                                                                                                        .fromSTEB(
                                                                                                        0,
                                                                                                        0,
                                                                                                        0,
                                                                                                        1),
                                                                                                    child: Container(
                                                                                                      width: double
                                                                                                          .infinity,
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .primaryBackground,
                                                                                                        boxShadow: const [
                                                                                                          BoxShadow(
                                                                                                            blurRadius: 0,
                                                                                                            color: Color(
                                                                                                                0xFFE0E3E7),
                                                                                                            offset: Offset(
                                                                                                              0.0,
                                                                                                              1,
                                                                                                            ),
                                                                                                          )
                                                                                                        ],
                                                                                                        borderRadius: BorderRadius
                                                                                                            .circular(
                                                                                                            0),
                                                                                                        shape: BoxShape
                                                                                                            .rectangle,
                                                                                                      ),
                                                                                                      child: InkWell(
                                                                                                        onTap: () async {
                                                                                                          if (await bd
                                                                                                              .connected(
                                                                                                              context) ==
                                                                                                              1) {
                                                                                                            setter(
                                                                                                                  () {
                                                                                                                romaneio =
                                                                                                                '${romaneiosLista[index]
                                                                                                                    .romaneio!}';
                                                                                                                setState(() {
                                                                                                                  romaneio =
                                                                                                                  '${romaneiosLista[index]
                                                                                                                      .romaneio!}';
                                                                                                                });
                                                                                                              },
                                                                                                            );
                                                                                                          }
                                                                                                          setState(() {});
                                                                                                        },
                                                                                                        child: Padding(
                                                                                                          padding: const EdgeInsets
                                                                                                              .all(
                                                                                                              8),
                                                                                                          child: Row(
                                                                                                            mainAxisSize: MainAxisSize
                                                                                                                .max,
                                                                                                            children: [
                                                                                                              Container(
                                                                                                                width: 4,
                                                                                                                height: 50,
                                                                                                                decoration: BoxDecoration(
                                                                                                                  color: FlutterFlowTheme
                                                                                                                      .of(
                                                                                                                      context)
                                                                                                                      .alternate,
                                                                                                                  borderRadius: BorderRadius
                                                                                                                      .circular(
                                                                                                                      2),
                                                                                                                ),
                                                                                                              ),
                                                                                                              Expanded(
                                                                                                                child: Padding(
                                                                                                                  padding: const EdgeInsetsDirectional
                                                                                                                      .fromSTEB(
                                                                                                                      12,
                                                                                                                      0,
                                                                                                                      0,
                                                                                                                      0),
                                                                                                                  child: Text(
                                                                                                                    '${romaneiosLista[index]
                                                                                                                        .romaneio}',
                                                                                                                    style: FlutterFlowTheme
                                                                                                                        .of(
                                                                                                                        context)
                                                                                                                        .labelLarge
                                                                                                                        .override(
                                                                                                                      fontFamily: 'Readex Pro',
                                                                                                                      letterSpacing: 0,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ),
                                                                                                              if (responsiveVisibility(
                                                                                                                  context: context,
                                                                                                                  phone: false,
                                                                                                                  tablet: false,
                                                                                                                  desktop: true))
                                                                                                                (Expanded(
                                                                                                                  child: Padding(
                                                                                                                    padding: const EdgeInsetsDirectional
                                                                                                                        .fromSTEB(
                                                                                                                        12,
                                                                                                                        0,
                                                                                                                        0,
                                                                                                                        0),
                                                                                                                    child: Text(
                                                                                                                      '${romaneiosLista[index]
                                                                                                                          .usurCriacao}',
                                                                                                                      style: FlutterFlowTheme
                                                                                                                          .of(
                                                                                                                          context)
                                                                                                                          .labelLarge
                                                                                                                          .override(
                                                                                                                        fontFamily: 'Readex Pro',
                                                                                                                        letterSpacing: 0,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                )),
                                                                                                              if (responsiveVisibility(
                                                                                                                  context: context,
                                                                                                                  phone: false,
                                                                                                                  tablet: false,
                                                                                                                  desktop: true))
                                                                                                                (Expanded(
                                                                                                                  child: Padding(
                                                                                                                    padding: const EdgeInsetsDirectional
                                                                                                                        .fromSTEB(
                                                                                                                        12,
                                                                                                                        0,
                                                                                                                        0,
                                                                                                                        0),
                                                                                                                    child: Text(
                                                                                                                      DateFormat(
                                                                                                                          'dd/MM/yyyy   kk:mm')
                                                                                                                          .format(
                                                                                                                          romaneiosLista[index]
                                                                                                                              .dtRomaneio!),
                                                                                                                      style: FlutterFlowTheme
                                                                                                                          .of(
                                                                                                                          context)
                                                                                                                          .labelLarge
                                                                                                                          .override(
                                                                                                                        fontFamily: 'Readex Pro',
                                                                                                                        letterSpacing: 0,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                )),
                                                                                                              Expanded(
                                                                                                                child: Padding(
                                                                                                                  padding: const EdgeInsetsDirectional
                                                                                                                      .fromSTEB(
                                                                                                                      12,
                                                                                                                      0,
                                                                                                                      0,
                                                                                                                      0),
                                                                                                                  child: Text(
                                                                                                                    '${romaneiosLista[index]
                                                                                                                        .palete}',
                                                                                                                    style: FlutterFlowTheme
                                                                                                                        .of(
                                                                                                                        context)
                                                                                                                        .labelLarge
                                                                                                                        .override(
                                                                                                                      fontFamily: 'Readex Pro',
                                                                                                                      letterSpacing: 0,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ),
                                                                                                              Expanded(
                                                                                                                child: Padding(
                                                                                                                  padding: const EdgeInsetsDirectional
                                                                                                                      .fromSTEB(
                                                                                                                      12,
                                                                                                                      0,
                                                                                                                      0,
                                                                                                                      0),
                                                                                                                  child: Text(
                                                                                                                    '${romaneiosLista[index]
                                                                                                                        .vol}',
                                                                                                                    style: FlutterFlowTheme
                                                                                                                        .of(
                                                                                                                        context)
                                                                                                                        .labelLarge
                                                                                                                        .override(
                                                                                                                      fontFamily: 'Readex Pro',
                                                                                                                      letterSpacing: 0,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  );
                                                                                                }
                                                                                              } else {
                                                                                                return Container();
                                                                                              }
                                                                                            },
                                                                                          ),
                                                                                        ),
                                                                                        Expanded(
                                                                                            child: Container(
                                                                                              decoration:
                                                                                              const BoxDecoration(
                                                                                                  color: Colors
                                                                                                      .white,
                                                                                                  borderRadius: BorderRadius
                                                                                                      .only(
                                                                                                      bottomLeft: Radius
                                                                                                          .circular(
                                                                                                          20),
                                                                                                      bottomRight: Radius
                                                                                                          .circular(
                                                                                                          20))),
                                                                                            ))
                                                                                      ],
                                                                                    ),
                                                                                    Positioned(
                                                                                        bottom:
                                                                                        10,
                                                                                        right:
                                                                                        10,
                                                                                        child: Container(
                                                                                            decoration: BoxDecoration(
                                                                                                color: Colors
                                                                                                    .green,
                                                                                                borderRadius: BorderRadius
                                                                                                    .circular(
                                                                                                    10)),
                                                                                            width: 50,
                                                                                            height: 50,
                                                                                            child: IconButton(
                                                                                              onPressed: () async {
                                                                                                if (await bd
                                                                                                    .connected(
                                                                                                    context) ==
                                                                                                    1) {
                                                                                                  if (context
                                                                                                      .mounted) {
                                                                                                    if (romaneiosLista
                                                                                                        .where((
                                                                                                        element) =>
                                                                                                    '${element
                                                                                                        .romaneio}' ==
                                                                                                        romaneio)
                                                                                                        .isEmpty) {
                                                                                                      await showCupertinoModalPopup(
                                                                                                        context: context,
                                                                                                        barrierDismissible: false,
                                                                                                        builder: (
                                                                                                            context2) {
                                                                                                          return CupertinoAlertDialog(
                                                                                                            title: const Text(
                                                                                                                'Romaneio não encontrado'),
                                                                                                            actions: <
                                                                                                                CupertinoDialogAction>[
                                                                                                              CupertinoDialogAction(
                                                                                                                  isDefaultAction: true,
                                                                                                                  onPressed: () {
                                                                                                                    Navigator
                                                                                                                        .pop(
                                                                                                                        context2);
                                                                                                                  },
                                                                                                                  child: const Text(
                                                                                                                      'Voltar'))
                                                                                                            ],
                                                                                                          );
                                                                                                        },
                                                                                                      );
                                                                                                      return;
                                                                                                    }
                                                                                                    if (romaneiosLista
                                                                                                        .where((
                                                                                                        element) =>
                                                                                                    '${element
                                                                                                        .romaneio}' ==
                                                                                                        romaneio &&
                                                                                                        element
                                                                                                            .dtFechamento ==
                                                                                                            null)
                                                                                                        .isEmpty) {
                                                                                                      await showCupertinoModalPopup(
                                                                                                          barrierDismissible: false,
                                                                                                          builder: (
                                                                                                              context2) {
                                                                                                            return CupertinoAlertDialog(
                                                                                                              title: const Text(
                                                                                                                'Romaneio finalizado\n',
                                                                                                                style: TextStyle(
                                                                                                                    fontWeight: FontWeight
                                                                                                                        .bold),
                                                                                                              ),
                                                                                                              content: const Text(
                                                                                                                  'Escolha outro Romaneio ou converse com os Desenvolvedores'),
                                                                                                              actions: <
                                                                                                                  CupertinoDialogAction>[
                                                                                                                CupertinoDialogAction(
                                                                                                                    isDefaultAction: true,
                                                                                                                    onPressed: () {
                                                                                                                      Navigator
                                                                                                                          .pop(
                                                                                                                          context2);
                                                                                                                    },
                                                                                                                    child: const Text(
                                                                                                                        'Voltar'))
                                                                                                              ],
                                                                                                            );
                                                                                                          },
                                                                                                          context: context);
                                                                                                      return;
                                                                                                    }
                                                                                                    Navigator
                                                                                                        .pop(
                                                                                                        context);
                                                                                                    Navigator
                                                                                                        .pop(
                                                                                                        context);
                                                                                                    Navigator
                                                                                                        .pop(
                                                                                                        context);
                                                                                                    await Navigator
                                                                                                        .push(
                                                                                                        context,
                                                                                                        MaterialPageRoute(
                                                                                                            builder: (
                                                                                                                context) =>
                                                                                                                ListaRomaneioWidget(
                                                                                                                    int
                                                                                                                        .parse(
                                                                                                                        romaneio),
                                                                                                                    usur,
                                                                                                                    bd: bd)));
                                                                                                  }
                                                                                                }
                                                                                              },
                                                                                              icon: const Icon(
                                                                                                  Icons
                                                                                                      .check,
                                                                                                  color: Colors
                                                                                                      .white),
                                                                                            )))
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            },
                                                                          );
                                                                        },
                                                                      );
                                                                    }
                                                                  },
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .search_rounded,
                                                                      color: Colors
                                                                          .white))))
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                return const Center(
                                                  child: CircularProgressIndicator(),
                                                );
                                              }
                                            },
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
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .height *
                                        0.8,
                                    height:
                                    MediaQuery
                                        .of(context)
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
                                          Icons.next_week_rounded,
                                        ),
                                        Expanded(
                                          child: Container(
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Continuar Romaneio',
                                          style: FlutterFlowTheme
                                              .of(context)
                                              .titleLarge,
                                          textAlign: TextAlign.center,
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(
                                                        20),
                                                    bottomRight: Radius
                                                        .circular(20))),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                              ),
                              (['BI', 'Comercial'].contains(usur.acess))
                                  ? InkWell(
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
                                              ReimpriprimirRomaneioWidget(
                                                  usur, 0, bd: bd),
                                        ));
                                  }
                                },
                                child: (Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10, right: 20),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width:
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .height *
                                        0.8,
                                    height:
                                    MediaQuery
                                        .of(context)
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
                                          Icons.print_rounded,
                                        ),
                                        Expanded(
                                          child: Container(
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Reimprimir Romaneios',
                                          style: FlutterFlowTheme
                                              .of(context)
                                              .titleLarge,
                                          textAlign: TextAlign.center,
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(
                                                        20),
                                                    bottomRight: Radius
                                                        .circular(20))),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                              ) : Container(),
                              (['BI', 'Comercial'].contains(usur.acess))
                                  ? InkWell(
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
                                              ListaRomaneiosWidget(
                                                  usur, bd: bd),
                                        ));
                                  }
                                },
                                child: (Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10, right: 20),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width:
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .height *
                                        0.8,
                                    height:
                                    MediaQuery
                                        .of(context)
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
                                          Icons.manage_search,
                                        ),
                                        Expanded(
                                          child: Container(
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Conferir Romaneios',
                                          style: FlutterFlowTheme
                                              .of(context)
                                              .titleLarge,
                                          textAlign: TextAlign.center,
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(
                                                        20),
                                                    bottomRight: Radius
                                                        .circular(20))),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                              ) : Container(),
                            ],
                          )
                          ),
                        ),
                      ]),
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
