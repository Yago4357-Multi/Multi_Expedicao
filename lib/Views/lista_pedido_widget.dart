import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../Components/Model/lista_pedido_model.dart';
import '../Components/Widget/atualizacao.dart';
import '../Components/Widget/drawer_widget.dart';
import '../Controls/banco.dart';
import '../FlutterFlowTheme.dart';
import '../Models/contagem.dart';
import '../Models/usur.dart';
import 'lista_cancelados.dart';
import 'lista_faturados.dart';

///Classe para manter a listagem dos pedidos
class ListaPedidoWidget extends StatefulWidget {
  ///Classe para puxar o pedido inicial da página
  final int cont;

  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///Variável para manter conexão com o Banco
  final Banco bd;

  ///Constutor para a página de listagem dos pedidos
  const ListaPedidoWidget(this.usur,
      {super.key, required this.cont, required this.bd});

  @override
  State<ListaPedidoWidget> createState() =>
      _ListaPedidoWidgetState(cont, usur, bd);
}

class _ListaPedidoWidgetState extends State<ListaPedidoWidget> {
  int cont;
  final Usuario usur;

  final TextEditingController _model2 = TextEditingController();

  final Banco bd;

  _ListaPedidoWidgetState(this.cont, this.usur, this.bd);

  ///Variáveis para mostrar erro no TextField
  Color corDica = Colors.green.shade400;
  Color corBorda = Colors.green.shade700;
  String dica = 'Procure um pedido...';

  bool teste = false;

  bool inicial = true;
  late ListaPedidoModel _model;
  late Future<List<Contagem>> getPed;
  late List<Contagem> pedidos = [];
  late List<Contagem> pedidosAlt = [];
  late List<Contagem> pedidosExc = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<int> qtdFatFut;
  late Future<int> qtdCancFut;
  int qtdFat = 0;
  int qtdCanc = 0;

  @override
  void initState() {
    rodarBanco();
    super.initState();
    _model = createModel(context, ListaPedidoModel.new);
    _model.textController ??= TextEditingController();
  }

  void rodarBanco() async {
    getPed = bd.selectPedido(cont);
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
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
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

        actions: [
          IconButton(icon: const Icon(Icons.lock_reset_outlined),onPressed: () async {
            getPed = bd.selectPedido(cont);
            setState(() {
            });
          }, color: Colors.white,),
          Padding(
            padding: const EdgeInsets.all(5),
            child: InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                if (inicial) {
                  setState(() {
                    inicial = false;
                  });
                } else {
                  if (pedidosExc.isNotEmpty || pedidosAlt.isNotEmpty) {
                    await showCupertinoModalPopup(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: const Text('Deseja Continuar?'),
                          content: const Text(
                              'Para alterações das caixas o ideal é fazer via coletor pela Logística'),
                          actions: <CupertinoDialogAction>[
                            CupertinoDialogAction(
                                isDefaultAction: true,
                                isDestructiveAction: true,
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await showCupertinoModalPopup(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return CupertinoAlertDialog(
                                          title: const Text('Salvar Alterações?'),
                                        content: const Text(
                                            'Após alteração deve ser alinhado com Logística a parte manual das alterações'),
                                        actions: <CupertinoDialogAction>[
                                          CupertinoDialogAction(
                                              isDefaultAction: true,
                                              isDestructiveAction: true,
                                              onPressed: () async {
                                                if (await bd.connected(context) == 1) {
                                                  if (pedidosAlt.isNotEmpty) {
                                                    getPed = bd.updatePedidoBip(pedidosAlt, cont);
                                                    pedidosAlt = [];
                                                  }
                                                  if (pedidosExc.isNotEmpty) {
                                                    var pedidosSet = pedidos.toSet();
                                                    var pedidosSetExc = pedidosExc.toSet();
                                                    pedidos = pedidosSet
                                                        .difference(pedidosSetExc)
                                                        .toList();
                                                    if (pedidos.isEmpty) {
                                                      cont = 0;
                                                    }
                                                    getPed = bd.excluiPedido(
                                                        pedidosExc, usur, cont);
                                                    pedidosExc = [];
                                                  }
                                                  inicial = true;
                                                }
                                                Navigator.pop(context);
                                                setState(() {});
                                              },
                                              child: const Text('Continuar')),
                                          CupertinoDialogAction(
                                              isDefaultAction: true,
                                              onPressed: () {
                                                setState(() {
                                                  Navigator.pop(context);
                                                });
                                              },
                                              child: const Text('Voltar'))
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text('Continuar')),
                            CupertinoDialogAction(
                                isDefaultAction: true,
                                onPressed: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: const Text('Voltar'))
                          ],
                        );
                      },
                    );
                  } else {
                    setState(() {
                      inicial = true;
                    });
                  }
                }
              },
              child: Container(
                width: 120,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    inicial
                        ? Text(
                      'Editar',
                      style: FlutterFlowTheme.of(context)
                          .headlineSmall
                          .override(
                          fontFamily: 'Readex Pro',
                          color: Colors.white,
                          fontSize: 15),
                    )
                        : Text(
                      'Salvar',
                      style: FlutterFlowTheme.of(context)
                          .headlineSmall
                          .override(
                          fontFamily: 'Readex Pro',
                          color: Colors.white,
                          fontSize: 15),
                    ),
                    inicial
                        ? const Icon(Icons.edit_outlined, color: Colors.white)
                        : const Icon(
                      Icons.done,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!inicial)
            Padding(
              padding:
              const EdgeInsets.only(left: 15, top: 5, bottom: 5, right: 5),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  pedidosAlt = [];
                  pedidosExc = [];
                  inicial = true;
                  setState(() {});
                },
                child: Container(
                  width: 120,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius:
                      const BorderRadius.all(Radius.circular(20))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Cancelar',
                        style: FlutterFlowTheme.of(context)
                            .headlineSmall
                            .override(
                            fontFamily: 'Readex Pro',
                            color: Colors.white,
                            fontSize: 15),
                      ),
                      const Icon(
                        Icons.cancel_outlined,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Container(),
        ],
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        top: true,
        child: Stack(
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
                      child: SingleChildScrollView(
                        child: FutureBuilder(
                          future: getPed,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              pedidos = snapshot.data ?? [];
                              return Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: const AlignmentDirectional(0, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (responsiveVisibility(
                                          context: context,
                                          phone: false,
                                          tablet: false,
                                        ))
                                          Expanded(
                                            flex: 4,
                                            child: Align(
                                              alignment:
                                              const AlignmentDirectional(-1, 0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Align(
                                                    alignment:
                                                    const AlignmentDirectional(
                                                        -1, -1),
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          10, 20, 0, 0),
                                                      child: Text(
                                                        'Nº Pedido :',
                                                        textAlign: TextAlign.start,
                                                        style: FlutterFlowTheme.of(
                                                            context)
                                                            .headlineMedium
                                                            .override(
                                                          fontFamily: 'Outfit',
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(25, 8, 0, 0),
                                                    child: TextField(
                                                      textAlignVertical:
                                                      TextAlignVertical.center,
                                                      decoration: InputDecoration(
                                                        hintStyle: FlutterFlowTheme
                                                            .of(context)
                                                            .bodyMedium
                                                            .override(
                                                          fontFamily:
                                                          'Readex Pro',
                                                          color: const Color(
                                                              0xFF005200),
                                                          fontSize: 26,
                                                          fontWeight:
                                                          FontWeight.w400,
                                                        ),
                                                        hintText: pedidos.isNotEmpty
                                                            ? '${pedidos[0].ped}'
                                                            : 'Pedido não encontrado...',
                                                        enabledBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color: corBorda,
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                        ),
                                                        focusedBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color: corDica,
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                        ),
                                                        errorBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color:
                                                            FlutterFlowTheme.of(
                                                                context)
                                                                .error,
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                        ),
                                                        focusedErrorBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color:
                                                            FlutterFlowTheme.of(
                                                                context)
                                                                .error,
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                        ),
                                                        contentPadding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(
                                                            20, 0, 0, 0),
                                                      ),
                                                      onSubmitted: (value) async {
                                                        if (await bd.connected(
                                                            context) ==
                                                            1) {
                                                          setState(() {
                                                            cont = int.parse(
                                                                value == ''
                                                                    ? '0'
                                                                    : value);
                                                            _model.textController
                                                                .text = '';
                                                            getPed = bd
                                                                .selectPedido(cont);
                                                          });
                                                        }
                                                        setState(() {});
                                                      },
                                                      controller:
                                                      _model.textController,
                                                      textAlign: TextAlign.center,
                                                      style: FlutterFlowTheme.of(
                                                          context)
                                                          .headlineMedium
                                                          .override(
                                                        fontFamily: 'Outfit',
                                                        fontSize: 24,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        Expanded(
                                          flex: 6,
                                          child: Align(
                                            alignment:
                                            const AlignmentDirectional(0, 0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: [
                                                Align(
                                                  alignment:
                                                  const AlignmentDirectional(
                                                      -1, -1),
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(10, 20, 0, 0),
                                                    child: Text(
                                                      (responsiveVisibility(
                                                          context: context,
                                                          phone: false,
                                                          tablet: false,
                                                          desktop: true))
                                                          ? 'Nº Volumes :'
                                                          : 'Progresso do Pedido',
                                                      textAlign: TextAlign.start,
                                                      style: FlutterFlowTheme.of(
                                                          context)
                                                          .headlineMedium
                                                          .override(
                                                        fontFamily: 'Outfit',
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                  const AlignmentDirectional(
                                                      0, 0),
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.all(10),
                                                    child: (responsiveVisibility(
                                                        context: context,
                                                        phone: false,
                                                        tablet: false,
                                                        desktop: true))
                                                        ? CircularPercentIndicator(
                                                      circularStrokeCap:
                                                      CircularStrokeCap
                                                          .round,
                                                      percent: pedidos
                                                          .isNotEmpty
                                                          ? ((pedidos.length -
                                                          pedidosExc
                                                              .length) /
                                                          (pedidos[0].vol ??
                                                              0)) <=
                                                          1
                                                          ? ((pedidos.length -
                                                          pedidosExc
                                                              .length) /
                                                          (pedidos[0]
                                                              .vol ??
                                                              0))
                                                          : 1
                                                          : 0,
                                                      radius:
                                                      MediaQuery.sizeOf(
                                                          context)
                                                          .width *
                                                          0.04,
                                                      lineWidth: 15,
                                                      animation: true,
                                                      animateFromLastPercent:
                                                      true,
                                                      progressColor: pedidos
                                                          .isNotEmpty
                                                          ? (((pedidos.length) /
                                                          (pedidos[0].vol ??
                                                              0)) ==
                                                          1)
                                                          ? Colors.green
                                                          : Colors
                                                          .deepOrange
                                                          : Colors.deepOrange,
                                                      backgroundColor: pedidos
                                                          .isNotEmpty
                                                          ? (pedidosExc
                                                          .isNotEmpty &&
                                                          (pedidos.length /
                                                              (pedidos[0].vol ??
                                                                  0)) >=
                                                              1)
                                                          ? Colors.red
                                                          : Colors.grey
                                                          : Colors.grey,
                                                      center: Text(
                                                        '${pedidos.length - pedidosExc.length} / ${pedidos.isNotEmpty ? pedidos[0].vol : 0}',
                                                        textAlign:
                                                        TextAlign.center,
                                                        style: FlutterFlowTheme
                                                            .of(context)
                                                            .headlineSmall
                                                            .override(
                                                          fontFamily:
                                                          'Outfit',
                                                          color: pedidos
                                                              .isNotEmpty
                                                              ? (((pedidos.length - pedidosExc.length) / (pedidos[0].vol ?? 0)) ==
                                                              1)
                                                              ? Colors
                                                              .green
                                                              : Colors
                                                              .deepOrange
                                                              : Colors
                                                              .deepOrange,
                                                          fontSize: 24,
                                                        ),
                                                      ),
                                                    )
                                                        : LinearProgressIndicator(
                                                      borderRadius:
                                                      const BorderRadius
                                                          .all(
                                                          Radius.circular(
                                                              20)),
                                                      minHeight: 10,
                                                      color: pedidos
                                                          .isNotEmpty
                                                          ? (((pedidos.length) /
                                                          (pedidos[0].vol ??
                                                              0)) ==
                                                          1)
                                                          ? Colors.green
                                                          : Colors
                                                          .deepOrange
                                                          : Colors.deepOrange,
                                                      backgroundColor: pedidos
                                                          .isNotEmpty
                                                          ? (pedidosExc
                                                          .isNotEmpty &&
                                                          (pedidos.length /
                                                              (pedidos[0].vol ??
                                                                  0)) >=
                                                              1)
                                                          ? Colors.red
                                                          : Colors.grey
                                                          : Colors.grey,
                                                      value: pedidos
                                                          .isNotEmpty
                                                          ? ((pedidos.length -
                                                          pedidosExc
                                                              .length) /
                                                          (pedidos[0].vol ??
                                                              0)) <=
                                                          1
                                                          ? ((pedidos.length -
                                                          pedidosExc
                                                              .length) /
                                                          (pedidos[0]
                                                              .vol ??
                                                              0))
                                                          : 1
                                                          : 0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(0, 20, 0, 0),
                                                child: Text(
                                                  'Expositor ?',
                                                  textAlign: TextAlign.start,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .headlineMedium
                                                      .override(
                                                        fontFamily: 'Outfit',
                                                        fontSize: 20,
                                                      ),
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    const AlignmentDirectional(
                                                        0, 0),
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () {
                                                        teste = !teste;
                                                        setState(() {});
                                                      },
                                                      child: Container(
                                                          width: 50,
                                                          height: 50,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius
                                                                          .circular(
                                                                              20)),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .green
                                                                      .shade700,
                                                                  width: 4)),
                                                          child: teste
                                                              ? Icon(
                                                                  Icons
                                                                      .check_rounded,
                                                                  color: Colors
                                                                      .green
                                                                      .shade700,
                                                                  size: 40,
                                                                )
                                                              : Container()),
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        24, 4, 0, 0),
                                    child: Text(
                                      'Status : ${pedidos.isNotEmpty ? pedidos[0].status ?? 'Desconhecido' : ''}',
                                      textAlign: TextAlign.start,
                                      style:
                                      FlutterFlowTheme.of(context).labelMedium,
                                    ),
                                  ),
                                  ListView.builder(
                                    itemCount: (pedidos.length),
                                    primary: false,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemBuilder: (context, index) {
                                      if (inicial) {
                                        return Padding(
                                          padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              14, 10, 14, 10),
                                          child: Container(
                                            constraints: const BoxConstraints(
                                              maxWidth: 570,
                                            ),
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                              borderRadius:
                                              BorderRadius.circular(8),
                                              border: Border.all(
                                                color: FlutterFlowTheme.of(context)
                                                    .alternate,
                                                width: 2,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(10, 12, 12, 12),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Column(
                                                      mainAxisSize:
                                                      MainAxisSize.min,
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: [
                                                        RichText(
                                                          text: TextSpan(
                                                            children: [
                                                              const TextSpan(
                                                                  text:
                                                                  'Palete Localizado\n',
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                    'Readex Pro',
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                    fontSize: 18,
                                                                  )),
                                                              TextSpan(
                                                                text:
                                                                '${pedidos[index].palete}',
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
                                                            style:
                                                            FlutterFlowTheme.of(
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
                                                        Padding(
                                                          padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                              0, 4, 0, 0),
                                                          child: Text(
                                                            'Cliente : ${pedidos[index].cliente}',
                                                            style:
                                                            FlutterFlowTheme.of(
                                                                context)
                                                                .labelMedium,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                              0, 4, 0, 0),
                                                          child: Text(
                                                            'Cidade : ${pedidos[index].cidade}',
                                                            style:
                                                            FlutterFlowTheme.of(
                                                                context)
                                                                .labelMedium,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(0, 4, 0, 0),
                                                    child: Container(
                                                      height: 80,
                                                      constraints: BoxConstraints(
                                                        minWidth: MediaQuery.sizeOf(
                                                            context)
                                                            .width *
                                                            0.2,
                                                        maxWidth: MediaQuery.sizeOf(
                                                            context)
                                                            .width *
                                                            0.3,
                                                        maxHeight:
                                                        MediaQuery.sizeOf(
                                                            context)
                                                            .height *
                                                            0.8,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                        const Color(0xFF6ABD6A),
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                        border: Border.all(
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
                                                              1, 0, 1, 0),
                                                          child: RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text: 'Vol. :\n',
                                                                  style: FlutterFlowTheme
                                                                      .of(context)
                                                                      .bodyMedium
                                                                      .override(
                                                                    fontFamily:
                                                                    'Readex Pro',
                                                                    color: const Color(
                                                                        0xFF005200),
                                                                    fontSize:
                                                                    18,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                  '${pedidos[index].caixa} / ${pedidos[index].vol}',
                                                                  style:
                                                                  const TextStyle(
                                                                    fontSize: 26,
                                                                  ),
                                                                )
                                                              ],
                                                              style: FlutterFlowTheme
                                                                  .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                fontFamily:
                                                                'Readex Pro',
                                                                color: const Color(
                                                                    0xFF005200),
                                                                fontSize: 24,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w800,
                                                              ),
                                                            ),
                                                            textAlign:
                                                            TextAlign.center,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        if (pedidosExc.contains(pedidos[index])) {
                                          return Stack(
                                            fit: StackFit.passthrough,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(14, 10, 14, 10),
                                                child: Container(
                                                  width: double.infinity,
                                                  constraints: const BoxConstraints(
                                                    maxWidth: 570,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                    BorderRadius.circular(8),
                                                    border: Border.all(
                                                      color: Colors.red,
                                                      width: 4,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        10, 12, 12, 12),
                                                    child: Row(
                                                      mainAxisSize:
                                                      MainAxisSize.max,
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          flex: 4,
                                                          child: Column(
                                                            mainAxisSize:
                                                            MainAxisSize.min,
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              const Text(
                                                                  'Palete Localizado',
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                    'Readex Pro',
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                    fontSize: 18,
                                                                    wordSpacing: 0,
                                                                  )),
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .red
                                                                        .shade100,
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                        4)),
                                                                width: 120,
                                                                child: Padding(
                                                                  padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 5),
                                                                  child: Text(
                                                                    '${pedidos[index].palete}',
                                                                    textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                    style: FlutterFlowTheme.of(
                                                                        context)
                                                                        .bodyMedium
                                                                        .override(
                                                                      fontFamily:
                                                                      'Readex Pro',
                                                                      color: Colors
                                                                          .red
                                                                          .shade500,
                                                                      fontSize:
                                                                      26,
                                                                      fontWeight:
                                                                      FontWeight.w800,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                    0, 4, 0, 0),
                                                                child: Text(
                                                                  'Cliente : ${pedidos[index].cliente}',
                                                                  style: FlutterFlowTheme
                                                                      .of(context)
                                                                      .labelMedium,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                    0, 4, 0, 0),
                                                                child: Text(
                                                                  'Cidade : ${pedidos[index].cidade}',
                                                                  style: FlutterFlowTheme
                                                                      .of(context)
                                                                      .labelMedium,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                            child: Text(
                                                              'Caixa será \nexclúida !!',
                                                              style: FlutterFlowTheme
                                                                  .of(context)
                                                                  .titleLarge
                                                                  .override(
                                                                  fontFamily:
                                                                  'Readex Pro',
                                                                  color: Colors
                                                                      .red),
                                                            )),
                                                        Padding(
                                                          padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                              0, 4, 0, 0),
                                                          child: Container(
                                                            height: 80,
                                                            constraints:
                                                            BoxConstraints(
                                                              minWidth:
                                                              MediaQuery.sizeOf(
                                                                  context)
                                                                  .width *
                                                                  0.2,
                                                              maxWidth:
                                                              MediaQuery.sizeOf(
                                                                  context)
                                                                  .width *
                                                                  0.3,
                                                              maxHeight:
                                                              MediaQuery.sizeOf(
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
                                                                  .circular(12),
                                                              border: Border.all(
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
                                                                    1, 0, 1, 0),
                                                                child: RichText(
                                                                  text: TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                        'Vol. :\n',
                                                                        style: FlutterFlowTheme.of(
                                                                            context)
                                                                            .bodyMedium
                                                                            .override(
                                                                          fontFamily:
                                                                          'Readex Pro',
                                                                          color:
                                                                          const Color(0xFF005200),
                                                                          fontSize:
                                                                          18,
                                                                          fontWeight:
                                                                          FontWeight.w800,
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
                                                                      color: const Color(
                                                                          0xFF005200),
                                                                      fontSize:
                                                                      24,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w800,
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
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                right: 20,
                                                top: 15,
                                                child: FloatingActionButton(
                                                  backgroundColor: Colors.green,
                                                  onPressed: () {
                                                    setState(() {
                                                      pedidosExc
                                                          .remove(pedidos[index]);
                                                    });
                                                  },
                                                  child: const Icon(
                                                    Icons.settings_backup_restore,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                        } else {
                                          if (pedidosAlt
                                              .where((element) =>
                                          element.caixa ==
                                              pedidos[index].caixa)
                                              .isNotEmpty) {
                                            return Stack(
                                              fit: StackFit.passthrough,
                                              children: [
                                                Padding(
                                                  padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(14, 10, 14, 10),
                                                  child: Container(
                                                    width: double.infinity,
                                                    constraints:
                                                    const BoxConstraints(
                                                      maxWidth: 570,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme.of(
                                                          context)
                                                          .secondaryBackground,
                                                      borderRadius:
                                                      BorderRadius.circular(8),
                                                      border: Border.all(
                                                        color:
                                                        Colors.orange.shade500,
                                                        width: 4,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          10, 12, 12, 12),
                                                      child: Row(
                                                        mainAxisSize:
                                                        MainAxisSize.max,
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            flex: 4,
                                                            child: Column(
                                                              mainAxisSize:
                                                              MainAxisSize.min,
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                const Text(
                                                                    'Palete Localizado',
                                                                    style:
                                                                    TextStyle(
                                                                      fontFamily:
                                                                      'Readex Pro',
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                      fontSize: 18,
                                                                      wordSpacing:
                                                                      0,
                                                                    )),
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .orange
                                                                          .shade100,
                                                                      borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                          4)),
                                                                  width: 120,
                                                                  child: Center(
                                                                    child: Row(
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                          Padding(
                                                                            padding: const EdgeInsets
                                                                                .only(
                                                                                top:
                                                                                5),
                                                                            child:
                                                                            Text(
                                                                              '${pedidos[index].palete}',
                                                                              textAlign:
                                                                              TextAlign.center,
                                                                              style: FlutterFlowTheme.of(context)
                                                                                  .bodyMedium
                                                                                  .override(
                                                                                fontFamily: 'Readex Pro',
                                                                                color: Colors.orange.shade500,
                                                                                fontSize: 26,
                                                                                fontWeight: FontWeight.w800,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const Expanded(
                                                                            child: Padding(
                                                                                padding: EdgeInsets.only(left: 5, top: 5),
                                                                                child: Icon(
                                                                                  Icons.arrow_right_alt,
                                                                                  color: Colors.orange,
                                                                                ))),
                                                                        Expanded(
                                                                          child:
                                                                          TextField(
                                                                            textAlign:
                                                                            TextAlign.center,
                                                                            keyboardType:
                                                                            TextInputType.number,
                                                                            decoration: InputDecoration.collapsed(
                                                                                hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  fontFamily: 'Readex Pro',
                                                                                  color: Colors.orange.shade500,
                                                                                  fontSize: 26,
                                                                                  fontWeight: FontWeight.w800,
                                                                                ),
                                                                                hintText: '${pedidosAlt.where((element) => element.ped == pedidos[index].ped && element.caixa == pedidos[index].caixa).toList()[0].palete}'),
                                                                            style: FlutterFlowTheme.of(context)
                                                                                .bodyMedium
                                                                                .override(
                                                                              fontFamily: 'Readex Pro',
                                                                              color: Colors.orange.shade500,
                                                                              fontSize: 26,
                                                                              fontWeight: FontWeight.w800,
                                                                            ),
                                                                            onTapAlwaysCalled:
                                                                            true,
                                                                            controller:
                                                                            _model2,
                                                                            onSubmitted:
                                                                                (value) {
                                                                              setState(
                                                                                      () {
                                                                                    pedidosAlt.removeWhere(
                                                                                          (element) => element.ped == pedidos[index].ped && element.caixa == pedidos[index].caixa,
                                                                                    );
                                                                                    pedidosAlt.add(Contagem(
                                                                                        pedidos[index].ped,
                                                                                        int.parse(value),
                                                                                        pedidos[index].caixa,
                                                                                        pedidos[index].vol));
                                                                                    _model2.text =
                                                                                    '';
                                                                                  });
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
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
                                                                    'Cliente : ${pedidos[index].cliente}',
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
                                                          ),
                                                          Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .all(20),
                                                              child: Text(
                                                                'Caixa será \nalterada !!',
                                                                style: FlutterFlowTheme
                                                                    .of(context)
                                                                    .titleLarge
                                                                    .override(
                                                                    fontFamily:
                                                                    'Readex Pro',
                                                                    color: Colors
                                                                        .orange),
                                                              )),
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
                                                                border: Border.all(
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
                                                                    text: TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                          'Vol. :\n',
                                                                          style: FlutterFlowTheme.of(
                                                                              context)
                                                                              .bodyMedium
                                                                              .override(
                                                                            fontFamily:
                                                                            'Readex Pro',
                                                                            color:
                                                                            const Color(0xFF005200),
                                                                            fontSize:
                                                                            18,
                                                                            fontWeight:
                                                                            FontWeight.w800,
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
                                                                        color: const Color(
                                                                            0xFF005200),
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
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  right: 20,
                                                  top: 15,
                                                  child: FloatingActionButton(
                                                    backgroundColor: Colors.red,
                                                    onPressed: () {
                                                      setState(() {
                                                        pedidosAlt.removeWhere(
                                                                (element) =>
                                                            element.caixa ==
                                                                pedidos[index]
                                                                    .caixa);
                                                        pedidosExc
                                                            .add(pedidos[index]);
                                                      });
                                                    },
                                                    child: const Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            );
                                          } else {
                                            return Stack(
                                              fit: StackFit.passthrough,
                                              children: [
                                                Padding(
                                                  padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(14, 10, 14, 10),
                                                  child: Container(
                                                    width: double.infinity,
                                                    constraints:
                                                    const BoxConstraints(
                                                      maxWidth: 570,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme.of(
                                                          context)
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
                                                      child: Row(
                                                        mainAxisSize:
                                                        MainAxisSize.max,
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            flex: 4,
                                                            child: Column(
                                                              mainAxisSize:
                                                              MainAxisSize.min,
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                const Text(
                                                                    'Palete Localizado',
                                                                    style:
                                                                    TextStyle(
                                                                      fontFamily:
                                                                      'Readex Pro',
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                      fontSize: 18,
                                                                      wordSpacing:
                                                                      0,
                                                                    )),
                                                                TextField(
                                                                  keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                                  decoration: InputDecoration
                                                                      .collapsed(
                                                                      hintStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                          .bodyMedium
                                                                          .override(
                                                                        fontFamily:
                                                                        'Readex Pro',
                                                                        color:
                                                                        const Color(0xFF005200),
                                                                        fontSize:
                                                                        26,
                                                                        fontWeight:
                                                                        FontWeight.w400,
                                                                      ),
                                                                      hintText:
                                                                      '${pedidos[index].palete}'),
                                                                  style: FlutterFlowTheme
                                                                      .of(context)
                                                                      .bodyMedium
                                                                      .override(
                                                                    fontFamily:
                                                                    'Readex Pro',
                                                                    color: const Color(
                                                                        0xFF005200),
                                                                    fontSize:
                                                                    26,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                  ),
                                                                  onTapAlwaysCalled:
                                                                  true,
                                                                  onSubmitted:
                                                                      (value) {
                                                                    setState(() {
                                                                      pedidosAlt.add(Contagem(
                                                                          pedidos[index]
                                                                              .ped,
                                                                          int.parse(
                                                                              value),
                                                                          pedidos[index]
                                                                              .caixa,
                                                                          pedidos[index]
                                                                              .vol));
                                                                    });
                                                                  },
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
                                                                    'Cliente : ${pedidos[index].cliente}',
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
                                                                border: Border.all(
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
                                                                    text: TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                          'Vol. :\n',
                                                                          style: FlutterFlowTheme.of(
                                                                              context)
                                                                              .bodyMedium
                                                                              .override(
                                                                            fontFamily:
                                                                            'Readex Pro',
                                                                            color:
                                                                            const Color(0xFF005200),
                                                                            fontSize:
                                                                            18,
                                                                            fontWeight:
                                                                            FontWeight.w800,
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
                                                                        color: const Color(
                                                                            0xFF005200),
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
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  right: 20,
                                                  top: 15,
                                                  child: FloatingActionButton(
                                                    backgroundColor: Colors.red,
                                                    onPressed: () {
                                                      setState(() {
                                                        pedidosExc
                                                            .add(pedidos[index]);
                                                      });
                                                    },
                                                    child: const Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            );
                                          }
                                        }
                                      }
                                    },
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      12,
                                      0,
                                      44,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(right: 0,bottom: 0, child: AtualizacaoWidget(bd: bd,context: context, usur: usur,))
          ],
        ),
      ),
    );
  }
}
