import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../Components/Model/lista_romaneio.dart';
import '../Controls/Banco.dart';
import '../Models/Contagem.dart';
import '/Components/Widget/drawer_widget.dart';

class ListaRomaneioWidget extends StatefulWidget {
  const ListaRomaneioWidget({super.key});

  @override
  State<ListaRomaneioWidget> createState() => _ListaRomaneioWidgetState();
}

class _ListaRomaneioWidgetState extends State<ListaRomaneioWidget> {
  late StateSetter internalSetter;
  late ListaRomaneioModel _model;
  bool teste = false;
  late List<int> Palete = [];
  late List<int> PaleteSelecionado = [];
  List<Contagem> Pedidos = [];
  Color Cor = Colors.transparent;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final bd = Banco();
  late Future<List<int>> Paletes;
  late Future<List<Contagem>> PedidoResposta;

  @override
  void initState() {
    super.initState();
    Paletes = bd.paleteFinalizado();
    PedidoResposta = bd.selectPalletRomaneio(PaleteSelecionado);
    _model = createModel(context, ListaRomaneioModel.new);
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    _model.choiceChipsValue;
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
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16, 16, 0, 4),
                                child: Text(
                                  'Romaneio',
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .override(
                                    fontFamily: 'Outfit',
                                    fontSize: 30,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        16, 0, 0, 0),
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
                                    alignment: const AlignmentDirectional(0, 0),
                                    child: Text(
                                      PaleteSelecionado.join(' , '),
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
                                onPressed: () async {
                                  return showDialog(
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (context,
                                            void Function(void Function())
                                            setter) {
                                          internalSetter = setter;
                                          return Dialog(
                                            child: Container(
                                              color: Cor,
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                      width:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                      height:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                          0.1,
                                                      child: Row(
                                                        children: [
                                                          const Text(
                                                              'Paletes adicionados :',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize:
                                                                  20)),
                                                          Expanded(
                                                            child: Align(
                                                              alignment:
                                                              Alignment
                                                                  .center,
                                                              child: Text(
                                                                textAlign:
                                                                TextAlign
                                                                    .left,
                                                                PaleteSelecionado
                                                                    .join(
                                                                    ' , '),
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    40),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      )),
                                                  Expanded(
                                                    child: FutureBuilder(
                                                      future: Paletes,
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                            .connectionState ==
                                                            ConnectionState
                                                                .done) {
                                                          Palete =
                                                              snapshot.data ??
                                                                  [];
                                                          return ListView
                                                              .builder(
                                                            itemCount:
                                                            Palete.length,
                                                            itemBuilder:
                                                                (context,
                                                                index) {
                                                              return ListTile(
                                                                title: Text(
                                                                    '${Palete[index]}'),
                                                                onTap: () {
                                                                  setter(() {
                                                                    if (PaleteSelecionado
                                                                        .contains(
                                                                        Palete[index])) {
                                                                      PaleteSelecionado
                                                                          .remove(
                                                                          Palete[index]);
                                                                    } else {
                                                                      PaleteSelecionado.add(
                                                                          Palete[
                                                                          index]);
                                                                      PaleteSelecionado
                                                                          .sort(
                                                                            (a, b) =>
                                                                            a.compareTo(b),
                                                                      );
                                                                    }
                                                                    setState(() {
                                                                      PedidoResposta = bd.selectPalletRomaneio(PaleteSelecionado);
                                                                    });
                                                                  }
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          );
                                                        } else {
                                                          return const CircularProgressIndicator();
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                text: '+ Palete',
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
                                      ChipData('Errados'),
                                      ChipData('OK')
                                    ],
                                    onChanged: (val) => setState(() => _model
                                        .choiceChipsValue = val?.firstOrNull),
                                    selectedChipStyle: ChipStyle(
                                      backgroundColor: Colors.green.shade700,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: FlutterFlowTheme.of(context)
                                            .info,
                                        letterSpacing: 0,
                                      ),
                                      iconColor:
                                      FlutterFlowTheme.of(context).info,
                                      iconSize: 18,
                                      elevation: 2,
                                      borderColor:
                                      FlutterFlowTheme.of(context).accent1,
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
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0,
                                      ),
                                      iconColor: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      iconSize: 18,
                                      elevation: 0,
                                      borderColor: FlutterFlowTheme.of(context)
                                          .alternate,
                                      borderWidth: 1,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    chipSpacing: 8,
                                    rowSpacing: 12,
                                    multiselect: false,
                                    initialized:
                                    _model.choiceChipsValue != null,
                                    alignment: WrapAlignment.start,
                                    controller:
                                    _model.choiceChipsValueController =
                                        FormFieldController<List<String>>(
                                          ['Todos'],
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16, 0, 0, 0),
                                  child: Container(
                                    width: 300,
                                    child: TextFormField(
                                      controller: _model.textController,
                                      focusNode: _model.textFieldFocusNode,
                                      autofocus: false,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        labelText: 'Procurar por Pedido....',
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
                                            color: Colors.green.shade700,
                                            width: 2,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.green.shade400,
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
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 0, 16, 0),
                            child: Container(
                              width: double.infinity,
                              height: 40,
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Align(
                                        alignment:
                                        const AlignmentDirectional(-1, 0),
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
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment:
                                        const AlignmentDirectional(-1, 0),
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
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Align(
                                        alignment:
                                        const AlignmentDirectional(0.6, 0),
                                        child: Text(
                                          'Paletes',
                                          textAlign: TextAlign.end,
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            letterSpacing: 0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Align(
                                        alignment:
                                        const AlignmentDirectional(0.2, 0),
                                        child: Text(
                                          'Conferido',
                                          textAlign: TextAlign.end,
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            letterSpacing: 0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(4, 0, 16, 0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: [
                                            Align(
                                              alignment:
                                              const AlignmentDirectional(
                                                  1, 0),
                                              child: Text(
                                                'Status',
                                                style:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .override(
                                                  fontFamily:
                                                  'Readex Pro',
                                                  letterSpacing: 0,
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
                            ),
                          ),
                          FutureBuilder(
                            future: PedidoResposta,
                            builder: (context, snapshot) {
                              print(Pedidos);
                              if (snapshot.connectionState == ConnectionState.done) {
                                print(snapshot.data);
                                Pedidos = snapshot.data ?? [];
                                return ListView.builder(
                                  itemCount: Pedidos.length,
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    0,
                                    0,
                                    44,
                                  ),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          16, 0, 16, 0),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme
                                              .of(context)
                                              .secondaryBackground,
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 0,
                                              color: FlutterFlowTheme
                                                  .of(context)
                                                  .alternate,
                                              offset: const Offset(
                                                0,
                                                1,
                                              ),
                                            )
                                          ],
                                        ),
                                        child: Padding(
                                          padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              16, 12, 16, 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Align(
                                                  alignment:
                                                  const AlignmentDirectional(
                                                      -1, 0),
                                                  child: Text(
                                                    '${Pedidos[index].Ped}',
                                                    style:
                                                    FlutterFlowTheme
                                                        .of(context)
                                                        .bodyMedium
                                                        .override(
                                                      fontFamily:
                                                      'Readex Pro',
                                                      letterSpacing: 0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Align(
                                                  alignment:
                                                  const AlignmentDirectional(
                                                      -1, 0),
                                                  child: Text(
                                                    '    ?',
                                                    style:
                                                    FlutterFlowTheme
                                                        .of(context)
                                                        .bodyMedium
                                                        .override(
                                                      fontFamily:
                                                      'Readex Pro',
                                                      letterSpacing: 0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  '${Pedidos[index].Pallet}',
                                                  style: FlutterFlowTheme
                                                      .of(context)
                                                      .bodyMedium
                                                      .override(
                                                    fontFamily: 'Readex Pro',
                                                    letterSpacing: 0,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  '${Pedidos[index].Cx} / ${Pedidos[index].Vol}',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme
                                                      .of(context)
                                                      .bodyMedium
                                                      .override(
                                                    fontFamily: 'Readex Pro',
                                                    letterSpacing: 0,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Row(
                                                  mainAxisSize: MainAxisSize
                                                      .max,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                            .of(
                                                            context)
                                                            .accent2,
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                        border: Border.all(
                                                          color: FlutterFlowTheme
                                                              .of(
                                                              context)
                                                              .secondary,
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
                                                            'OK',
                                                            style: FlutterFlowTheme
                                                                .of(context)
                                                                .bodySmall
                                                                .override(
                                                              fontFamily:
                                                              'Readex Pro',
                                                              letterSpacing: 0,
                                                            ),
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
                                    );
                                  },
                                );
                              }
                              else {
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
