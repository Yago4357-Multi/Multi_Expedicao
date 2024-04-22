import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../Components/Model/lista_romaneio.dart';
import '../Controls/banco.dart';
import '../Models/Palete.dart';
import '../Models/Pedido.dart';
import '/Components/Widget/drawer_widget.dart';
import 'lista_pedido_widget.dart';

class ListaRomaneioWidget extends StatefulWidget {
  ///Variável para puxar o número do romaneio
  int romaneio;

  ///Construtor da página
  ListaRomaneioWidget(this.romaneio, {super.key});

  @override
  State<ListaRomaneioWidget> createState() =>
      _ListaRomaneioWidgetState(romaneio);
}

class _ListaRomaneioWidgetState extends State<ListaRomaneioWidget> {
  int romaneio;

  _ListaRomaneioWidgetState(this.romaneio);

  ///Variáveis para mostrar erro no TextField
  Color corDica = Colors.green.shade400;
  Color corBorda = Colors.green.shade700;
  String Dica = 'Procure um pedido...';

  late StateSetter internalSetter;
  late ListaRomaneioModel _model;

  ///Variáveis para Salvar e Modelar Paletes
  late Future<List<palete>> PaletesFin;
  late Future<List<int>> getPaletes;

  late List<palete> Palete = [];
  late List<int> PaleteSelecionadoint = [];

  ///Variáveis para Salvar e Modelar pedidos
  late Future<List<pedido>> PedidoResposta;
  List<pedido> Pedidos = [];
  List<pedido> PedidosSalvos = [];

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final Banco bd;

  @override
  void initState() {
    super.initState();
    bd = Banco();
    _model = createModel(context, ListaRomaneioModel.new);
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    _model.choiceChipsValue;
    _model.choiceChipsValueController = FormFieldController<List<String>>(
      ['Todos'],
    );
    rodarBanco();
  }

  void rodarBanco() async {
    PaletesFin = bd.paleteFinalizado();
    getPaletes = bd.selectRomaneio(romaneio);
    PedidoResposta = bd.selectPalletRomaneio(getPaletes);
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
        drawer: Drawer(
          elevation: 16,
          child: wrapWithModel(
            model: _model.drawerModel,
            updateCallback: () => setState(() {}),
            child: const DrawerWidget(),
          ),
        ),
        floatingActionButton: SizedBox(
          width: 300,
          height: 60,
          child: FloatingActionButton(
            onPressed: () async {
              await showCupertinoModalPopup(
                  barrierDismissible: false,
                  builder: (context2) {
                    if (PaleteSelecionadoint.isNotEmpty) {
                      if (PedidosSalvos.where(
                          (element) => element.Status == 'Errado').isEmpty) {
                        return CupertinoAlertDialog(
                          title: Text(
                              'Você deseja finalizar o Romaneio $romaneio ?'),
                          content: const Text(
                              'Essa ação bloqueará o Romaneio de alterações Futuras'),
                          actions: <CupertinoDialogAction>[
                            CupertinoDialogAction(
                                isDefaultAction: true,
                                isDestructiveAction: true,
                                onPressed: () {
                                  bd.endRomaneio(romaneio);
                                  Navigator.popAndPushNamed(context, '/');
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
                      } else {
                        return CupertinoAlertDialog(
                          title: const Text('O Romaneio possui problemas'),
                          content: const Text(
                              'Corrija os erros no Romaneio antes de tentar finaliza-lo'),
                          actions: <CupertinoDialogAction>[
                            CupertinoDialogAction(
                                isDefaultAction: true,
                                onPressed: () {
                                  // bd.endRomaneio(romaneio);
                                  Navigator.pop(context2);
                                },
                                child: const Text(
                                  'Voltar',
                                )),
                          ],
                        );
                      }
                    } else {
                      return CupertinoAlertDialog(
                        title: const Text('Romaneio sem Paletes'),
                        content: const Text(
                            'Você deve selecionar pelo menos 1 palete para finalizar o Romaneio'),
                        actions: <CupertinoDialogAction>[
                          CupertinoDialogAction(
                              isDefaultAction: true,
                              onPressed: () {
                                Navigator.pop(context2, '/');
                              },
                              child: const Text(
                                'Voltar',
                              )),
                        ],
                      );
                    }
                  },
                  context: context);
            },
            backgroundColor: Colors.orange.shade400,
            elevation: 8,
            child: const Text(
              'Finalizar Romaneio',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
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
                      maxWidth: 970,
                    ),
                    decoration: const BoxDecoration(),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 24,
                            decoration: const BoxDecoration(),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16, 16, 0, 4),
                                child: Text(
                                  'Romaneio : $romaneio',
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .override(
                                        fontFamily: 'Outfit',
                                        fontSize: 30,
                                        letterSpacing: 0,
                                      ),
                                ),
                              ),
                              FutureBuilder(
                                future: getPaletes,
                                builder: (context, snapshot) {
                                  PaleteSelecionadoint = snapshot.data ?? [];
                                  PaleteSelecionadoint.sort(
                                    (a, b) => a.compareTo(b),
                                  );
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(16, 0, 0, 0),
                                          child: Text(
                                            'Paletes Nesse Romaneio',
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  fontSize: 18,
                                                  letterSpacing: 0,
                                                ),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              const AlignmentDirectional(0, 0),
                                          child: Text(
                                            PaleteSelecionadoint.join(','),
                                            textAlign: TextAlign.end,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  fontSize: 40,
                                                  letterSpacing: 0,
                                                ),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                },
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 0, 0, 0),
                            child: Text(
                              'Listagem de Pedidos do Romaneio',
                              style: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 24,
                            decoration: const BoxDecoration(),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              FFButtonWidget(
                                text: '+ Palete',
                                onPressed: () async {
                                  _model.choiceChipsValue = 'Todos';
                                  return showDialog(
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (context,
                                            void Function(void Function())
                                                setter) {
                                          internalSetter = setter;
                                          return FutureBuilder(
                                            future: PaletesFin,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.done) {
                                                Palete = snapshot.data ?? [];
                                                return Dialog(
                                                  backgroundColor: Colors.white,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Container(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.1,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        decoration: const BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadiusDirectional.vertical(
                                                                    top: Radius
                                                                        .circular(
                                                                            20))),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            'Paletes Finalizados',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .headlineMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Outfit',
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        width: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
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
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(0),
                                                          shape: BoxShape
                                                              .rectangle,
                                                        ),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          height: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          alignment:
                                                              const AlignmentDirectional(
                                                                  -1, 0),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                    16,
                                                                    0,
                                                                    0,
                                                                    0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    'Palete',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Readex Pro',
                                                                          letterSpacing:
                                                                              0,
                                                                          fontSize:
                                                                              20,
                                                                        ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    'Usuário de Bipagem',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Readex Pro',
                                                                          letterSpacing:
                                                                              0,
                                                                          fontSize:
                                                                              20,
                                                                        ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    'Data da Bipagem',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Readex Pro',
                                                                          letterSpacing:
                                                                              0,
                                                                          fontSize:
                                                                              20,
                                                                        ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    'Usuário de Fechamento',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Readex Pro',
                                                                          letterSpacing:
                                                                              0,
                                                                          fontSize:
                                                                              20,
                                                                        ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    'Data de Fechamento',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Readex Pro',
                                                                          letterSpacing:
                                                                              0,
                                                                          fontSize:
                                                                              20,
                                                                        ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    'Volumetria',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Readex Pro',
                                                                          letterSpacing:
                                                                              0,
                                                                          fontSize:
                                                                              20,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      ListView.builder(
                                                        shrinkWrap: true,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        itemCount:
                                                            Palete.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          if (PaleteSelecionadoint
                                                              .contains(Palete[
                                                                      index]
                                                                  .pallet)) {
                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      1),
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .yellow
                                                                      .shade50,
                                                                  boxShadow: const [
                                                                    BoxShadow(
                                                                      blurRadius:
                                                                          0,
                                                                      color: Color(
                                                                          0xFFE0E3E7),
                                                                      offset:
                                                                          Offset(
                                                                        0.0,
                                                                        1,
                                                                      ),
                                                                    )
                                                                  ],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              0),
                                                                  shape: BoxShape
                                                                      .rectangle,
                                                                ),
                                                                child: InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  focusColor: Colors
                                                                      .transparent,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap:
                                                                      () async {
                                                                    setter(() {
                                                                      PaleteSelecionadoint.remove(
                                                                          Palete[index]
                                                                              .pallet);
                                                                      bd.removePalete(
                                                                          romaneio,
                                                                          PaleteSelecionadoint);
                                                                      getPaletes =
                                                                          bd.selectRomaneio(
                                                                              romaneio);
                                                                      setState(
                                                                          () {
                                                                        PedidoResposta =
                                                                            bd.selectPalletRomaneio(getPaletes);
                                                                      });
                                                                    });
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              4,
                                                                          height:
                                                                              50,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.green.shade400,
                                                                            borderRadius:
                                                                                BorderRadius.circular(2),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                12,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                                Text(
                                                                              '${Palete[index].pallet}',
                                                                              style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                12,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                                Text(
                                                                              '${Palete[index].id_usur_inclusao}',
                                                                              style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                12,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                                Text(
                                                                              '${Palete[index].dt_inclusao}',
                                                                              style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                12,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                                Text(
                                                                              '${Palete[index].id_usur_fechamento}',
                                                                              style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                12,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                                Text(
                                                                              '${Palete[index].dt_fechamento}',
                                                                              style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                12,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                                Text(
                                                                              '${Palete[index].volumetria}',
                                                                              style: FlutterFlowTheme.of(context).labelLarge.override(
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
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      1),
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  boxShadow: const [
                                                                    BoxShadow(
                                                                      blurRadius:
                                                                          0,
                                                                      color: Color(
                                                                          0xFFE0E3E7),
                                                                      offset:
                                                                          Offset(
                                                                        0.0,
                                                                        1,
                                                                      ),
                                                                    )
                                                                  ],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              0),
                                                                  shape: BoxShape
                                                                      .rectangle,
                                                                ),
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    setter(() {
                                                                      PaleteSelecionadoint.add(
                                                                          Palete[index].pallet ??
                                                                              0);
                                                                      PaleteSelecionadoint
                                                                          .sort(
                                                                        (a, b) =>
                                                                            a.compareTo(b),
                                                                      );
                                                                      bd.updatePalete(
                                                                          romaneio,
                                                                          PaleteSelecionadoint);
                                                                      getPaletes =
                                                                          bd.selectRomaneio(
                                                                              romaneio);
                                                                      setState(
                                                                          () {
                                                                        PedidoResposta =
                                                                            bd.selectPalletRomaneio(getPaletes);
                                                                      });
                                                                    });
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              4,
                                                                          height:
                                                                              50,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).alternate,
                                                                            borderRadius:
                                                                                BorderRadius.circular(2),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                12,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                                Text(
                                                                              '${Palete[index].pallet}',
                                                                              style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                12,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                                Text(
                                                                              '${Palete[index].id_usur_inclusao}',
                                                                              style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                12,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                                Text(
                                                                              '${Palete[index].dt_inclusao}',
                                                                              style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                12,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                                Text(
                                                                              '${Palete[index].id_usur_fechamento}',
                                                                              style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                12,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                                Text(
                                                                              '${Palete[index].dt_fechamento}',
                                                                              style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                12,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                                Text(
                                                                              '${Palete[index].volumetria}',
                                                                              style: FlutterFlowTheme.of(context).labelLarge.override(
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
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                return const CircularProgressIndicator();
                                              }
                                            },
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                options: FFButtonOptions(
                                  height: 40,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      24, 0, 24, 0),
                                  iconPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          0, 0, 0, 0),
                                  color: Colors.green.shade700,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Readex Pro',
                                        color: Colors.white,
                                        letterSpacing: 0,
                                      ),
                                  elevation: 3,
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ]
                                .divide(const SizedBox(width: 40))
                                .addToStart(const SizedBox(width: 10)),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 12, 16, 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 8, 0, 8),
                                  child: FlutterFlowChoiceChips(
                                      options: const [
                                        ChipData('Todos'),
                                        ChipData('Errado'),
                                        ChipData('OK')
                                      ],
                                      onChanged: (val) {
                                        setState(() {
                                          if (_model.choiceChipsValue ==
                                              'Todos') {
                                            Pedidos = PedidosSalvos;
                                          } else {
                                            Pedidos = PedidosSalvos.where(
                                                    (element) =>
                                                        element.Status ==
                                                        _model.choiceChipsValue)
                                                .toList();
                                          }
                                        });
                                      },
                                      selectedChipStyle: ChipStyle(
                                        backgroundColor: Colors.green.shade700,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Readex Pro',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                              letterSpacing: 0,
                                            ),
                                        iconColor:
                                            FlutterFlowTheme.of(context).info,
                                        iconSize: 18,
                                        elevation: 2,
                                        borderColor:
                                            FlutterFlowTheme.of(context)
                                                .accent1,
                                        borderWidth: 1,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      unselectedChipStyle: ChipStyle(
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Readex Pro',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0,
                                            ),
                                        iconColor: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        iconSize: 18,
                                        elevation: 0,
                                        borderColor:
                                            FlutterFlowTheme.of(context)
                                                .alternate,
                                        borderWidth: 1,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      chipSpacing: 8,
                                      rowSpacing: 12,
                                      multiselect: false,
                                      alignment: WrapAlignment.start,
                                      controller:
                                          _model.choiceChipsValueController!),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16, 0, 0, 0),
                                  child: SizedBox(
                                    width: 300,
                                    child: TextFormField(
                                      canRequestFocus: true,
                                      onChanged: (value) {
                                        _model.choiceChipsValue = 'Todos';
                                        setState(() {
                                          if (PedidosSalvos.length <
                                              Pedidos.length) {
                                            PedidosSalvos = Pedidos;
                                          }
                                          if (value.isNotEmpty) {
                                            var x =
                                                PedidosSalvos.where((element) {
                                              var texto =
                                                  element.Ped.toString();
                                              texto.startsWith(value);
                                              return texto.startsWith(value);
                                            });
                                            if (x.isNotEmpty) {
                                              Pedidos = x.toList();
                                            } else {
                                              Pedidos = [];
                                              Dica = 'Pedido não encontrado';
                                              corDica = Colors.red.shade400;
                                              corBorda = Colors.red.shade700;
                                            }
                                          } else {
                                            Pedidos = PedidosSalvos;
                                            Dica = 'Procure por um pedido...';
                                            corDica = Colors.green.shade400;
                                            corBorda = Colors.green.shade700;
                                          }
                                        });
                                      },
                                      controller: _model.textController,
                                      focusNode: _model.textFieldFocusNode,
                                      autofocus: false,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        labelText: Dica,
                                        labelStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              fontFamily: 'Readex Pro',
                                              letterSpacing: 0,
                                            ),
                                        hintStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              fontFamily: 'Readex Pro',
                                              letterSpacing: 0,
                                            ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: corBorda,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: corDica,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        contentPadding:
                                            const EdgeInsetsDirectional
                                                .fromSTEB(20, 0, 0, 0),
                                        suffixIcon: Icon(
                                          Icons.search_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                        ),
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            letterSpacing: 0,
                                          ),
                                      cursorColor:
                                          FlutterFlowTheme.of(context).primary,
                                      validator: _model.textControllerValidator
                                          .asValidator(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: const AlignmentDirectional(-1, 0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16, 0, 0, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Pedido',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            letterSpacing: 0,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Carregamento',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            letterSpacing: 0,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Paletes',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            letterSpacing: 0,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Conferido',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            letterSpacing: 0,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 4, 40, 4),
                                      child: Text(
                                        'Status',
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
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
                          FutureBuilder(
                            future: PedidoResposta,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (PedidosSalvos != snapshot.data) {
                                  Pedidos = snapshot.data ?? [];
                                  PedidosSalvos = Pedidos;
                                }
                                return ListView.builder(
                                  itemCount: Pedidos.length,
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    0,
                                    0,
                                    44,
                                  ),
                                  reverse: true,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    var corStatus = FlutterFlowTheme.of(context)
                                        .primaryBackground;
                                    var corBordaStatus =
                                        FlutterFlowTheme.of(context).secondary;
                                    var corFundoStatus =
                                        FlutterFlowTheme.of(context).accent2;
                                    var corTextoStatus = Colors.black;
                                    if (Pedidos[index].Status == 'Errado') {
                                      corStatus = Colors.red.shade100;
                                      corBordaStatus = Colors.red;
                                      corFundoStatus = Colors.red.shade100;
                                      corTextoStatus = Colors.red;
                                    }
                                    return InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ListaPedidoWidget(
                                                      cont: Pedidos[index].Ped),
                                            ));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 10, 0, 0),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: corStatus,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(20)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(16, 12, 16, 12),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${Pedidos[index].Ped}',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          color: corTextoStatus,
                                                          fontFamily:
                                                              'Readex Pro',
                                                          letterSpacing: 0,
                                                        ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    '?',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          color: corTextoStatus,
                                                          fontFamily:
                                                              'Readex Pro',
                                                          letterSpacing: 0,
                                                        ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    Pedidos[index].Pallet,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          color: corTextoStatus,
                                                          fontFamily:
                                                              'Readex Pro',
                                                          letterSpacing: 0,
                                                        ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    '${Pedidos[index].Cxs} / ${Pedidos[index].Vol}',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          color: corTextoStatus,
                                                          fontFamily:
                                                              'Readex Pro',
                                                          letterSpacing: 0,
                                                        ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: corFundoStatus,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                        color: corBordaStatus,
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
                                                                8, 4, 8, 4),
                                                        child: Text(
                                                          Pedidos[index].Status,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodySmall
                                                              .override(
                                                                color:
                                                                    corTextoStatus,
                                                                fontFamily:
                                                                    'Readex Pro',
                                                                letterSpacing:
                                                                    0,
                                                              ),
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
                                    );
                                  },
                                );
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                          ),
                        ],
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
  }
}
