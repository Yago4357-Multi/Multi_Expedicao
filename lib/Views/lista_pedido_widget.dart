import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../Components/Model/lista_pedido_model.dart';
import '../Components/Widget/drawer_widget.dart';
import '../Controls/banco.dart';
import '../Models/contagem.dart';
import '../Models/usur.dart';

///Classe para manter a listagem dos pedidos
class ListaPedidoWidget extends StatefulWidget {
  ///Classe para puxar o pedido inicial da página
  final int cont;

  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///Constutor para a página de listagem dos pedidos
  const ListaPedidoWidget(this.usur, {super.key, required this.cont});

  @override
  State<ListaPedidoWidget> createState() =>
      _ListaPedidoWidgetState(cont, usur);
}

class _ListaPedidoWidgetState extends State<ListaPedidoWidget> {
  int cont;
  final Usuario usur;

  _ListaPedidoWidgetState(this.cont, this.usur);

  ///Variáveis para mostrar erro no TextField
  Color corDica = Colors.green.shade400;
  Color corBorda = Colors.green.shade700;
  String dica = 'Procure um pedido...';

  bool inicial = true;
  late ListaPedidoModel _model;
  late final Banco bd;
  late Future<List<Contagem>> getPed;
  late List<Contagem> pedidos = [];
  late List<Contagem> pedidosAlt = [];
  late List<Contagem> pedidosExc = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    rodarBanco();
    super.initState();
    _model = createModel(context, ListaPedidoModel.new);
    _model.textController ??= TextEditingController();
  }

  void rodarBanco() async {
    bd = Banco();
    getPed = bd.selectPedido(cont);
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
          child: DrawerWidget(usur: usur,context: context,),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: inicial
            ? IconButton(
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    inicial = false;
                  });
                },
                icon: const Icon(Icons.edit_outlined))
            : IconButton(
                color: Colors.white,
                onPressed: () async {
                  if (pedidosExc.isNotEmpty || pedidosAlt.isNotEmpty) {
                    await showCupertinoModalPopup(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: const Text('Salvar Alterações?'),
                          content: const Text(
                              'Após alteração deve ser alinhado com Logística a parte manual das alterações '),
                          actions: <CupertinoDialogAction>[
                            CupertinoDialogAction(
                                isDefaultAction: true,
                                isDestructiveAction: true,
                                onPressed: () {
                                  if (pedidosAlt.isNotEmpty) {
                                    bd.updatePedidoBip(pedidosAlt);
                                    pedidosAlt = [];
                                    getPed = bd.selectPedido(cont);
                                  }
                                  if (pedidosExc.isNotEmpty) {
                                    bd.excluiPedido(pedidosExc, usur);
                                    if (pedidosExc.length == pedidos.length){
                                      pedidos = [];
                                    }
                                    pedidosExc = [];
                                    getPed = bd.selectPedido(cont);
                                  }
                                  inicial = true;
                                  setState(() {
                                    Navigator.pop(context);
                                  });
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
                },
                icon: const Icon(Icons.done)),
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
      body: SafeArea(
        top: true,
        child: Row(
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
                        print(snapshot.hasData);
                        print(snapshot.data);
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
                                        flex: 2,
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
                                                    getPed =
                                                        bd.selectPedido(cont);
                                                    setState(() {
                                                      cont = int.parse(value);
                                                      _model.textController
                                                          .text = '';
                                                    });
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
                                      flex: 3,
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
                                                      ?
                                                  'Nº Volumes :' : 'Progresso do Pedido',
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
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    24, 4, 0, 0),
                                child: Text(
                                  'Status : Pendente',
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
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                const TextSpan(
                                                                    text:
                                                                        'Palete Localizado\n',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Readex Pro',
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      fontSize:
                                                                          18,
                                                                    )),
                                                                TextSpan(
                                                                  text:
                                                                      '${pedidos[index].palete}',
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w900,
                                                                    fontSize:
                                                                        24,
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
                                                        Colors.yellow.shade500,
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
                                                            SizedBox(
                                                              width: 50,
                                                              child: TextField(
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                decoration: InputDecoration
                                                                    .collapsed(
                                                                        hintStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontFamily: 'Readex Pro',
                                                                              color: const Color(0xFF005200),
                                                                              fontSize: 26,
                                                                              fontWeight: FontWeight.w400,
                                                                            ),
                                                                        hintText:
                                                                            '${pedidos[index].palete}'),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          'Readex Pro',
                                                                      color: Colors
                                                                          .yellow
                                                                          .shade500,
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
                                                            SizedBox(
                                                              width: 50,
                                                              child: TextField(
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                decoration: InputDecoration
                                                                    .collapsed(
                                                                        hintStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontFamily: 'Readex Pro',
                                                                              color: const Color(0xFF005200),
                                                                              fontSize: 26,
                                                                              fontWeight: FontWeight.w400,
                                                                            ),
                                                                        hintText:
                                                                            '${pedidos[index].palete}'),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
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
      ),
    );
  }
}
