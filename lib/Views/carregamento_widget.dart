import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../Components/Model/lista_romaneio.dart';
import '../Controls/banco.dart';
import '../Models/carregamento.dart';
import '../Models/romaneio.dart';
import '../Models/usur.dart';
import '/Components/Widget/drawer_widget.dart';
import 'home_widget.dart';

///Página da listagem de Romaneio
class ListaCarregamentoWidget extends StatefulWidget {
  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///
  final Banco bd;

  ///Construtor da página
  const ListaCarregamentoWidget(this.usur, {super.key, required this.bd});

  @override
  State<ListaCarregamentoWidget> createState() =>
      _ListaCarregamentoWidgetState(usur, bd);
}

class _ListaCarregamentoWidgetState extends State<ListaCarregamentoWidget> {
  final Usuario usur;

  final Banco bd;

  _ListaCarregamentoWidgetState(this.usur, this.bd);

  ///Variáveis para mostrar erro no TextField
  Color corDica = Colors.green.shade400;
  Color corBorda = Colors.green.shade700;
  String dica = 'Insira o palete...';

  late StateSetter internalSetter;
  late ListaRomaneioModel _model;

  ///Variáveis para Salvar e Modelar Paletes
  late Future<List<Romaneio>> romaneioFin;
  late Future<List<Carregamento>> carregamentoFin;
  late Future<List<int>> getRomaneio;

  late List<Romaneio> paleteSec = [];
  late List<Romaneio> palete = [];
  late int romaneioSelecionadoint = 0;

  late List<Carregamento> carregamento = [];
  late List<Carregamento> carregamentoSalvo = [];

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
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
      romaneioFin = bd.romaneioFinalizado();
      carregamentoFin = bd.getCarregamento(romaneioSelecionadoint);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _model.textFieldFocusNode?.requestFocus();
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
                      crossAxisAlignment: (responsiveVisibility(
                        context: context,
                        phone: false,
                        tablet: false,
                      ))
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 24,
                          decoration: const BoxDecoration(),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: (responsiveVisibility(
                            context: context,
                            phone: false,
                            tablet: false,
                            desktop: true,
                          ))
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Romaneio : $romaneioSelecionadoint',
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .override(
                                        fontFamily: 'Outfit',
                                        fontSize: 30,
                                        letterSpacing: 0,
                                      ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: FFButtonWidget(
                                    text: 'Escolher Romaneio',
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
                                                future: romaneioFin,
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.done) {
                                                    palete =
                                                        snapshot.data ?? [];
                                                    return Dialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.12,
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            decoration: const BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadiusDirectional
                                                                        .vertical(
                                                                            top:
                                                                                Radius.circular(20))),
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Text(
                                                                'Romaneios Finalizados',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
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
                                                            width:
                                                                double.infinity,
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
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              height: 60,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
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
                                                                      child:
                                                                          Text(
                                                                        'Romaneio',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .labelSmall
                                                                            .override(
                                                                              fontFamily: 'Readex Pro',
                                                                              letterSpacing: 0,
                                                                              fontSize: (responsiveVisibility(
                                                                                context: context,
                                                                                phone: false,
                                                                                tablet: false,
                                                                              ))
                                                                                  ? 20
                                                                                  : 15,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                    if (responsiveVisibility(
                                                                      context:
                                                                          context,
                                                                      phone:
                                                                          false,
                                                                      tablet:
                                                                          false,
                                                                    ))
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          'Data de Fechamento',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .override(
                                                                                fontFamily: 'Readex Pro',
                                                                                letterSpacing: 0,
                                                                                fontSize: 20,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        'Volumetria',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .labelSmall
                                                                            .override(
                                                                              fontFamily: 'Readex Pro',
                                                                              letterSpacing: 0,
                                                                              fontSize: (responsiveVisibility(
                                                                                context: context,
                                                                                phone: false,
                                                                                tablet: false,
                                                                              ))
                                                                                  ? 20
                                                                                  : 15,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          ListView.builder(
                                                            physics:
                                                                const AlwaysScrollableScrollPhysics(),
                                                            shrinkWrap: true,
                                                            padding:
                                                                EdgeInsets.zero,
                                                            scrollDirection:
                                                                Axis.vertical,
                                                            itemCount:
                                                                palete.length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              if (romaneioSelecionadoint ==
                                                                  palete[index]
                                                                      .romaneio) {
                                                                return Padding(
                                                                  padding:
                                                                      const EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          1),
                                                                  child:
                                                                      Container(
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
                                                                          color:
                                                                              Color(0xFFE0E3E7),
                                                                          offset:
                                                                              Offset(
                                                                            0.0,
                                                                            1,
                                                                          ),
                                                                        )
                                                                      ],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              0),
                                                                      shape: BoxShape
                                                                          .rectangle,
                                                                    ),
                                                                    child:
                                                                        InkWell(
                                                                      splashColor:
                                                                          Colors
                                                                              .transparent,
                                                                      focusColor:
                                                                          Colors
                                                                              .transparent,
                                                                      hoverColor:
                                                                          Colors
                                                                              .transparent,
                                                                      highlightColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onTap:
                                                                          () async {
                                                                        if (await bd.connected(context) == 1) {
                                                                          romaneioSelecionadoint =
                                                                              0;
                                                                          carregamentoFin =
                                                                              bd.getCarregamento(romaneioSelecionadoint);
                                                                          setter(
                                                                              () {
                                                                            setState(() {});
                                                                          });
                                                                        }
                                                                      },
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8),
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children: [
                                                                            Container(
                                                                              width: 4,
                                                                              height: 50,
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.green.shade400,
                                                                                borderRadius: BorderRadius.circular(2),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              child: Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                child: Text(
                                                                                  '${palete[index].romaneio}',
                                                                                  style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                        fontFamily: 'Readex Pro',
                                                                                        letterSpacing: 0,
                                                                                        fontSize: (responsiveVisibility(
                                                                                          context: context,
                                                                                          phone: false,
                                                                                          tablet: false,
                                                                                        ))
                                                                                            ? 20
                                                                                            : 15,
                                                                                      ),
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
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                  child: Text(
                                                                                    palete[index].dtFechamento != null ? DateFormat('kk:mm   dd/MM/yyyy').format(palete[index].dtFechamento!) : '',
                                                                                    style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                          fontFamily: 'Readex Pro',
                                                                                          letterSpacing: 0,
                                                                                        ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            Expanded(
                                                                              child: Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                child: Text(
                                                                                  '${palete[index].vol}',
                                                                                  style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                        fontFamily: 'Readex Pro',
                                                                                        letterSpacing: 0,
                                                                                        fontSize: (responsiveVisibility(
                                                                                          context: context,
                                                                                          phone: false,
                                                                                          tablet: false,
                                                                                        ))
                                                                                            ? 20
                                                                                            : 15,
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
                                                                  child:
                                                                      Container(
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
                                                                          color:
                                                                              Color(0xFFE0E3E7),
                                                                          offset:
                                                                              Offset(
                                                                            0.0,
                                                                            1,
                                                                          ),
                                                                        )
                                                                      ],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              0),
                                                                      shape: BoxShape
                                                                          .rectangle,
                                                                    ),
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        if (await bd.connected(context) == 1) {
                                                                          romaneioSelecionadoint =
                                                                              palete[index].romaneio ?? 0;
                                                                          carregamentoFin =
                                                                              bd.getCarregamento(romaneioSelecionadoint);
                                                                          setter(
                                                                              () {
                                                                            setState(() {});
                                                                          });
                                                                        }
                                                                      },
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8),
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children: [
                                                                            Container(
                                                                              width: 4,
                                                                              height: 50,
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).alternate,
                                                                                borderRadius: BorderRadius.circular(2),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              child: Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                child: Text(
                                                                                  '${palete[index].romaneio}',
                                                                                  style: FlutterFlowTheme.of(context).labelLarge.override(
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
                                                                            ))
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                  child: Text(
                                                                                    '${palete[index].dtFechamento}',
                                                                                    style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                          fontFamily: 'Readex Pro',
                                                                                          letterSpacing: 0,
                                                                                        ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            Expanded(
                                                                              child: Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                child: Text(
                                                                                  '${palete[index].vol}',
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
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
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
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          height: 24,
                          decoration: const BoxDecoration(),
                        ),
                        (responsiveVisibility(
                          context: context,
                          phone: false,
                          tablet: false,
                        ))
                            ? Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: (responsiveVisibility(
                                  context: context,
                                  phone: false,
                                  tablet: false,
                                ))
                                    ? MainAxisAlignment.spaceBetween
                                    : MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0, 8, 0, 40),
                                    child: FlutterFlowChoiceChips(
                                        options: const [
                                          ChipData('Todos'),
                                          ChipData('Não Carregado'),
                                          ChipData('Carregado')
                                        ],
                                        onChanged: (val) {
                                          setState(() {});
                                          if (val?.first == 'Todos') {
                                            carregamento = carregamentoSalvo;
                                          } else {
                                            carregamento = carregamentoSalvo
                                                .where((element) =>
                                                    element.status ==
                                                    val?.first)
                                                .toList();
                                          }
                                        },
                                        selectedChipStyle: ChipStyle(
                                          backgroundColor:
                                              Colors.green.shade700,
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        unselectedChipStyle: ChipStyle(
                                          backgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0,
                                              ),
                                          iconColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryText,
                                          iconSize: 18,
                                          elevation: 0,
                                          borderColor:
                                              FlutterFlowTheme.of(context)
                                                  .alternate,
                                          borderWidth: 1,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        chipSpacing: 8,
                                        rowSpacing: 12,
                                        multiselect: false,
                                        alignment: WrapAlignment.start,
                                        controller:
                                            _model.choiceChipsValueController!),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0, 8, 0, 40),
                                    child: FlutterFlowChoiceChips(
                                        options: const [
                                          ChipData('Todos'),
                                          ChipData('Não Carregado'),
                                          ChipData('Carregado')
                                        ],
                                        onChanged: (val) {
                                          setState(() {});
                                          if (val?.first == 'Todos') {
                                            carregamento = carregamentoSalvo;
                                          } else {
                                            carregamento = carregamentoSalvo
                                                .where((element) =>
                                                    element.status ==
                                                    val?.first)
                                                .toList();
                                          }
                                        },
                                        selectedChipStyle: ChipStyle(
                                          backgroundColor:
                                              Colors.green.shade700,
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        unselectedChipStyle: ChipStyle(
                                          backgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0,
                                              ),
                                          iconColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryText,
                                          iconSize: 18,
                                          elevation: 0,
                                          borderColor:
                                              FlutterFlowTheme.of(context)
                                                  .alternate,
                                          borderWidth: 1,
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                    phone: true,
                                    tablet: true,
                                    desktop: false,
                                  ))
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              16, 0, 0, 40),
                                      child: SizedBox(
                                        width: 300,
                                        child: TextFormField(
                                          onFieldSubmitted: (value) async {
                                            if (await bd.connected(context) == 1) {
                                              _model.textController.text = '';
                                              List<Carregamento>
                                                  carregamentoAlter;
                                              carregamentoAlter =
                                                  carregamentoSalvo
                                                      .where((element) =>
                                                          element.romaneio ==
                                                          int.parse(value))
                                                      .toList();
                                              if (carregamentoAlter.isEmpty) {
                                                if (context.mounted) {
                                                  await showCupertinoModalPopup(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (context2) {
                                                      return CupertinoAlertDialog(
                                                        title: const Text(
                                                            'Palete não encontrado no Romaneio'),
                                                        actions: <
                                                            CupertinoDialogAction>[
                                                          CupertinoDialogAction(
                                                              isDefaultAction:
                                                              true,
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context2);
                                                              },
                                                              child: const Text(
                                                                  'Voltar'))
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              } else {
                                                carregamentoAlter[0].status =
                                                    'Carregado';
                                                carregamentoSalvo.removeWhere(
                                                    (element) =>
                                                        element.romaneio ==
                                                        int.parse(value));
                                                carregamentoSalvo
                                                    .add(carregamentoAlter[0]);
                                                if (carregamentoSalvo
                                                    .where((element) =>
                                                        element.status ==
                                                        'Não Carregado')
                                                    .isEmpty) {
                                                  if (context.mounted) {
                                                    await showCupertinoModalPopup(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (context2) {
                                                        return CupertinoAlertDialog(
                                                          title: const Text(
                                                              'Romaneio carregado totalmente'),
                                                          actions: <
                                                              CupertinoDialogAction>[
                                                            CupertinoDialogAction(
                                                                isDefaultAction:
                                                                true,
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context2);
                                                                  Navigator.pop(
                                                                      context2);
                                                                  Navigator
                                                                      .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder: (
                                                                            context) =>
                                                                            HomeWidget(
                                                                                usur,
                                                                                bd: bd),
                                                                      ));
                                                                },
                                                                child: const Text(
                                                                    'Continuar'))
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                }
                                                bd.updateCarregamento(
                                                    int.parse(value), usur);
                                              }
                                              setState(() {});
                                            }
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
                                              color:
                                                  FlutterFlowTheme.of(context)
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
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: const AlignmentDirectional(-1, 0),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 0, 0, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Palete',
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
                                    'Volumetria',
                                    style: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          letterSpacing: 0,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
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
                          future: carregamentoFin,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (carregamentoSalvo != snapshot.data) {
                                carregamento = snapshot.data ?? [];
                                carregamentoSalvo = carregamento;
                              }
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: carregamento.isNotEmpty
                                        ? carregamento.length
                                        : 0,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(14, 10, 14, 10),
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
                                              color:
                                                  FlutterFlowTheme.of(context)
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
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(
                                                            0, 4, 0, 0),
                                                    child: Text(
                                                        textAlign:
                                                            TextAlign.start,
                                                        '${carregamento.isNotEmpty ? carregamento[index].romaneio : 0}',
                                                        style: TextStyle(
                                                            fontSize: 32,
                                                            color: Colors.grey
                                                                .shade700)),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(
                                                            0, 4, 0, 0),
                                                    child: Text(
                                                      textAlign:
                                                          TextAlign.center,
                                                      '${carregamento.isNotEmpty ? carregamento[index].vol : 0}',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(
                                                            0, 4, 0, 0),
                                                    child: Container(
                                                      height: 80,
                                                      width:
                                                          (responsiveVisibility(
                                                        context: context,
                                                        phone: false,
                                                        tablet: false,
                                                      ))
                                                              ? 160
                                                              : 100,
                                                      decoration: BoxDecoration(
                                                        color: carregamento[
                                                                        index]
                                                                    .status ==
                                                                'Carregado'
                                                            ? const Color(
                                                                0xFF6ABD6A)
                                                            : Colors
                                                                .red.shade100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                          color: carregamento[
                                                                          index]
                                                                      .status ==
                                                                  'Carregado'
                                                              ? const Color(
                                                                  0xFF005200)
                                                              : Colors.red,
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
                                                                      '${carregamento.isNotEmpty ? carregamento[index].status : ''}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        (responsiveVisibility(
                                                                      context:
                                                                          context,
                                                                      phone:
                                                                          false,
                                                                      tablet:
                                                                          false,
                                                                    ))
                                                                            ? 20
                                                                            : 15,
                                                                  ),
                                                                )
                                                              ],
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    color: carregamento[index].status ==
                                                                            'Carregado'
                                                                        ? const Color(
                                                                            0xFF005200)
                                                                        : Colors
                                                                            .red,
                                                                    fontSize:
                                                                        24,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800,
                                                                  ),
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
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
                                      );
                                    }),
                              );
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        )
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
