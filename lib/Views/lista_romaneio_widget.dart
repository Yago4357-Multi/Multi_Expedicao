import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../Components/Model/lista_romaneio.dart';
import '../Controls/banco.dart';
import '../Models/palete.dart';
import '../Models/pedido.dart';
import '../Models/usur.dart';
import '/Components/Widget/drawer_widget.dart';
import 'lista_pedido_widget.dart';

///Página da listagem de Romaneio
class ListaRomaneioWidget extends StatefulWidget {
  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///Variável para puxar o número do romaneio
  final int romaneio;

  ///Construtor da página
  const ListaRomaneioWidget(this.romaneio, this.usur, {super.key});

  @override
  State<ListaRomaneioWidget> createState() =>
      _ListaRomaneioWidgetState(romaneio, usur);
}

class _ListaRomaneioWidgetState extends State<ListaRomaneioWidget> {
  int romaneio;
  final Usuario usur;

  _ListaRomaneioWidgetState(this.romaneio, this.usur);

  ///Variáveis para mostrar erro no TextField
  Color corDica = Colors.green.shade400;
  Color corBorda = Colors.green.shade700;
  String dica = 'Procure um pedido...';

  late StateSetter internalSetter;
  late ListaRomaneioModel _model;

  ///Variáveis para Salvar e Modelar Paletes
  late Future<List<Paletes>> paletesFin;
  late Future<List<int>> getPaletes;

  late List<Paletes> palete = [];
  late List<int> paleteSelecionadoint = [];

  ///Variáveis para Salvar e Modelar pedidos
  late Future<List<Pedido>> pedidoResposta;
  List<Pedido> pedidos = [];
  List<Pedido> pedidosSalvos = [];

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
    paletesFin = bd.paleteFinalizado();
    getPaletes = bd.selectRomaneio(romaneio);
    pedidoResposta = bd.selectPalletRomaneio(getPaletes);
  }

  @override
  void dispose() {
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
          ),
        ),
      ),
      floatingActionButton: (['BI', 'Comercial'].contains(usur))
          ? SizedBox(
              width: 300,
              height: 60,
              child: FloatingActionButton(
                onPressed: () async {
                  await showCupertinoModalPopup(
                      barrierDismissible: false,
                      builder: (context2) {
                        if (paleteSelecionadoint.isNotEmpty) {
                          if (pedidosSalvos
                              .where((element) => element.status == 'Errado')
                              .isEmpty) {
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
                              title:
                                  const Text('O Romaneio possui problemas'),
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
            )
          : Container(),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 24,
                          decoration: const BoxDecoration(),
                        ),
                        if (responsiveVisibility(
                          context: context,
                          phone: false,
                          tablet: false,
                        ))
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding:
                                const EdgeInsetsDirectional.fromSTEB(
                                    36, 36, 20, 24),
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
                                  paleteSelecionadoint =
                                      snapshot.data ?? [];
                                  paleteSelecionadoint.sort(
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
                                          padding:
                                          const EdgeInsetsDirectional
                                              .fromSTEB(16, 0, 0, 0),
                                          child: Text(
                                            'Paletes Nesse Romaneio',
                                            style:
                                            FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                              fontFamily:
                                              'Readex Pro',
                                              fontSize: 18,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                          const AlignmentDirectional(
                                              0, 0),
                                          child: Text(
                                            paleteSelecionadoint.join(','),
                                            textAlign: TextAlign.end,
                                            style:
                                            FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                              fontFamily:
                                              'Readex Pro',
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
                        if (responsiveVisibility(
                          context: context,
                          phone: true,
                          tablet: true,
                        ))
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                'Romaneio : $romaneio',
                                textAlign: TextAlign.start,
                                style: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .override(
                                  fontFamily: 'Outfit',
                                  fontSize: 30,
                                  letterSpacing: 0,
                                ),
                              ),
                              FutureBuilder(
                                future: getPaletes,
                                builder: (context, snapshot) {
                                  paleteSelecionadoint =
                                      snapshot.data ?? [];
                                  paleteSelecionadoint.sort(
                                        (a, b) => a.compareTo(b),
                                  );
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                          const EdgeInsetsDirectional
                                              .fromSTEB(0, 10, 0, 0),
                                          child: Text(
                                            'Paletes Nesse Romaneio',
                                            style:
                                            FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                              fontFamily:
                                              'Readex Pro',
                                              fontSize: 18,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                          const AlignmentDirectional(
                                              0, 0),
                                          child: Text(
                                            paleteSelecionadoint.join(','),
                                            textAlign: TextAlign.end,
                                            style:
                                            FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                              fontFamily:
                                              'Readex Pro',
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
                        Container(
                          width: double.infinity,
                          height: 24,
                          decoration: const BoxDecoration(),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                        pedidos = pedidosSalvos;
                                      } else {
                                        pedidos = pedidosSalvos
                                            .where((element) =>
                                                element.status ==
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
                            if (responsiveVisibility(
                              context: context,
                              phone: false,
                              tablet: false,
                            ))
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        16, 0, 0, 0),
                                child: SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    canRequestFocus: true,
                                    onChanged: (value) {
                                      _model.choiceChipsValue = 'Todos';
                                      setState(() {
                                        if (pedidosSalvos.length <
                                            pedidos.length) {
                                          pedidosSalvos = pedidos;
                                        }
                                        if (value.isNotEmpty) {
                                          var x = pedidosSalvos
                                              .where((element) {
                                            var texto =
                                                element.ped.toString();
                                            texto.startsWith(value);
                                            return texto.startsWith(value);
                                          });
                                          if (x.isNotEmpty) {
                                            pedidos = x.toList();
                                          } else {
                                            pedidos = [];
                                            dica = 'Pedido não encontrado';
                                            corDica = Colors.red.shade400;
                                            corBorda = Colors.red.shade700;
                                          }
                                        } else {
                                          pedidos = pedidosSalvos;
                                          dica = 'Procure por um pedido...';
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
                                      labelText: dica,
                                      labelStyle:
                                          FlutterFlowTheme.of(context)
                                              .labelMedium
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                letterSpacing: 0,
                                              ),
                                      hintStyle:
                                          FlutterFlowTheme.of(context)
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
                                          color:
                                              FlutterFlowTheme.of(context)
                                                  .error,
                                          width: 2,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      focusedErrorBorder:
                                          OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              FlutterFlowTheme.of(context)
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
                                        FlutterFlowTheme.of(context)
                                            .primary,
                                    validator: _model
                                        .textControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                              ),
                          ],
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
                                if (responsiveVisibility(
                                  context: context,
                                  phone: false,
                                  tablet: false,
                                ))
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
                                if (responsiveVisibility(
                                  context: context,
                                  phone: false,
                                  tablet: false,
                                ))
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(0, 4, 40, 4),
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
                          future: pedidoResposta,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (pedidosSalvos != snapshot.data) {
                                pedidos = snapshot.data ?? [];
                                pedidosSalvos = pedidos;
                              }
                              return ListView.builder(
                                itemCount: pedidos.length,
                                padding: const EdgeInsets.fromLTRB(
                                  0,
                                  0,
                                  0,
                                  44,
                                ),
                                reverse: true,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  var corStatus = FlutterFlowTheme.of(context)
                                      .primaryBackground;
                                  var corBordaStatus =
                                      FlutterFlowTheme.of(context).secondary;
                                  var corFundoStatus =
                                      FlutterFlowTheme.of(context).accent2;
                                  var corTextoStatus = Colors.black;
                                  if (pedidos[index].status == 'Errado') {
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
                                                    cont: pedidos[index].ped,
                                                    usur),
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
                                                  '${pedidos[index].ped}',
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
                                              if (responsiveVisibility(
                                                context: context,
                                                phone: false,
                                                tablet: false,
                                              ))
                                                Expanded(
                                                  child: Text(
                                                    pedidos[index].palete,
                                                    style: FlutterFlowTheme
                                                            .of(context)
                                                        .bodyMedium
                                                        .override(
                                                          color:
                                                              corTextoStatus,
                                                          fontFamily:
                                                              'Readex Pro',
                                                          letterSpacing: 0,
                                                        ),
                                                  ),
                                                ),
                                              Expanded(
                                                child: Text(
                                                  '${pedidos[index].caixas} / ${pedidos[index].vol}',
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
                                              if (responsiveVisibility(
                                                context: context,
                                                phone: false,
                                                tablet: false,
                                              ))
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: corFundoStatus,
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(8),
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
                                                          pedidos[index]
                                                              .status,
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
    );
  }
}
