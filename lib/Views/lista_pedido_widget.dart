import '/Components/Widget/drawer_widget.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../Components/Model/lista_pedido_model.dart';
export '../Components/Model/lista_pedido_model.dart';

class ListaPedidoWidget extends StatefulWidget {
  const ListaPedidoWidget({super.key});

  @override
  State<ListaPedidoWidget> createState() => _ListaPedidoWidgetState();
}

class _ListaPedidoWidgetState extends State<ListaPedidoWidget> {
  late ListaPedidoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ListaPedidoModel());
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
                      maxWidth: 1170,
                    ),
                    decoration: const BoxDecoration(),
                    child: SingleChildScrollView(
                      child: Column(
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
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: const AlignmentDirectional(-1, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment:
                                          const AlignmentDirectional(-1, -1),
                                          child: Padding(
                                            padding:
                                            const EdgeInsetsDirectional.fromSTEB(
                                                10, 20, 0, 0),
                                            child: Text(
                                              'Nº Pedido :',
                                              textAlign: TextAlign.start,
                                              style:
                                              FlutterFlowTheme.of(context)
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
                                          const EdgeInsetsDirectional.fromSTEB(
                                              25, 8, 0, 0),
                                          child: Text(
                                            '429242424',
                                            textAlign: TextAlign.center,
                                            style: FlutterFlowTheme.of(context)
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
                                    alignment: const AlignmentDirectional(0, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        Align(
                                          alignment:
                                          const AlignmentDirectional(-1, -1),
                                          child: Padding(
                                            padding:
                                            const EdgeInsetsDirectional.fromSTEB(
                                                10, 20, 0, 0),
                                            child: Text(
                                              'Nº Volumes :',
                                              textAlign: TextAlign.start,
                                              style:
                                              FlutterFlowTheme.of(context)
                                                  .headlineMedium
                                                  .override(
                                                fontFamily: 'Outfit',
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: const AlignmentDirectional(0, 0),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: CircularPercentIndicator(
                                              percent: 0.4,
                                              radius: MediaQuery.sizeOf(context)
                                                  .width *
                                                  0.125,
                                              lineWidth: 15,
                                              animation: true,
                                              animateFromLastPercent: true,
                                              progressColor: const Color(0xFFEAB491),
                                              backgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .accent4,
                                              center: Text(
                                                '1 / 5',
                                                textAlign: TextAlign.center,
                                                style:
                                                FlutterFlowTheme.of(context)
                                                    .headlineSmall
                                                    .override(
                                                  fontFamily: 'Outfit',
                                                  color:
                                                  const Color(0xFFEA5E24),
                                                  fontSize: 24,
                                                ),
                                              ),
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
                            padding:
                            const EdgeInsetsDirectional.fromSTEB(24, 4, 0, 0),
                            child: Text(
                              'Status : Pendente',
                              textAlign: TextAlign.start,
                              style: FlutterFlowTheme.of(context).labelMedium,
                            ),
                          ),
                          ListView(
                            padding: const EdgeInsets.fromLTRB(
                              0,
                              12,
                              0,
                              44,
                            ),
                            primary: false,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    14, 0, 14, 0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onLongPress: () async {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    constraints: const BoxConstraints(
                                      maxWidth: 570,
                                    ),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        width: 2,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          10, 12, 12, 12),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  textScaleFactor:
                                                  MediaQuery.of(context)
                                                      .textScaleFactor,
                                                  text: TextSpan(
                                                    children: const [
                                                      TextSpan(
                                                        text:
                                                        'Pallet Localizado\n',
                                                        style: TextStyle(),
                                                      ),
                                                      TextSpan(
                                                        text: '2',
                                                        style: TextStyle(
                                                          color:
                                                          Color(0xFF007000),
                                                          fontWeight:
                                                          FontWeight.w900,
                                                          fontSize: 24,
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
                                                      FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(0, 4, 0, 0),
                                                  child: Text(
                                                    'Cliente : 169',
                                                    style: FlutterFlowTheme.of(
                                                        context)
                                                        .labelMedium,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(0, 4, 0, 0),
                                                  child: Text(
                                                    'Cidade : Tubarão',
                                                    style: FlutterFlowTheme.of(
                                                        context)
                                                        .labelMedium,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (responsiveVisibility(
                                            context: context,
                                            phone: false,
                                            tablet: false,
                                            tabletLandscape: false,
                                          ))
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  if (responsiveVisibility(
                                                    context: context,
                                                    desktop: false,
                                                  ))
                                                    Padding(
                                                      padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0, 4, 0, 0),
                                                      child: Container(
                                                        height: 32,
                                                        decoration:
                                                        BoxDecoration(
                                                          color:
                                                          const Color(0xFFEAB491),
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(12),
                                                          border: Border.all(
                                                            color: const Color(
                                                                0xFFEA5E24),
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
                                                                8,
                                                                0,
                                                                8,
                                                                0),
                                                            child: Text(
                                                              'Vol : 1 / 5',
                                                              textAlign:
                                                              TextAlign
                                                                  .center,
                                                              style: FlutterFlowTheme
                                                                  .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                fontFamily:
                                                                'Readex Pro',
                                                                color: const Color(
                                                                    0xFFEA5E24),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if (responsiveVisibility(
                                                    context: context,
                                                    desktop: false,
                                                  ))
                                                    Padding(
                                                      padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0, 4, 0, 0),
                                                      child: Container(
                                                        height: 32,
                                                        decoration:
                                                        BoxDecoration(
                                                          color:
                                                          const Color(0xFFEAB491),
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(12),
                                                          border: Border.all(
                                                            color: const Color(
                                                                0xFFEA5E24),
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
                                                                8,
                                                                0,
                                                                8,
                                                                0),
                                                            child: Text(
                                                              'Vol : 1 / 5',
                                                              textAlign:
                                                              TextAlign
                                                                  .center,
                                                              style: FlutterFlowTheme
                                                                  .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                fontFamily:
                                                                'Readex Pro',
                                                                color: const Color(
                                                                    0xFFEA5E24),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if (responsiveVisibility(
                                                    context: context,
                                                    desktop: false,
                                                  ))
                                                    Padding(
                                                      padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0, 4, 0, 0),
                                                      child: Container(
                                                        height: 32,
                                                        decoration:
                                                        BoxDecoration(
                                                          color:
                                                          const Color(0xFFEAB491),
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(12),
                                                          border: Border.all(
                                                            color: const Color(
                                                                0xFFEA5E24),
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
                                                                8,
                                                                0,
                                                                8,
                                                                0),
                                                            child: Text(
                                                              'Vol : 1 / 5',
                                                              textAlign:
                                                              TextAlign
                                                                  .center,
                                                              style: FlutterFlowTheme
                                                                  .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                fontFamily:
                                                                'Readex Pro',
                                                                color: const Color(
                                                                    0xFFEA5E24),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if (responsiveVisibility(
                                                    context: context,
                                                    desktop: false,
                                                  ))
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
                                                          color:
                                                          const Color(0xFF6ABD6A),
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
                                                                1,
                                                                0,
                                                                1,
                                                                0),
                                                            child: RichText(
                                                              textScaleFactor:
                                                              MediaQuery.of(
                                                                  context)
                                                                  .textScaleFactor,
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
                                                                  const TextSpan(
                                                                    text:
                                                                    '1 / 5',
                                                                    style:
                                                                    TextStyle(
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
                                          Padding(
                                            padding:
                                            const EdgeInsetsDirectional.fromSTEB(
                                                0, 4, 0, 0),
                                            child: Container(
                                              height: 80,
                                              constraints: BoxConstraints(
                                                minWidth:
                                                MediaQuery.sizeOf(context)
                                                    .width *
                                                    0.2,
                                                maxWidth:
                                                MediaQuery.sizeOf(context)
                                                    .width *
                                                    0.3,
                                                maxHeight:
                                                MediaQuery.sizeOf(context)
                                                    .height *
                                                    0.8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF6ABD6A),
                                                borderRadius:
                                                BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: const Color(0xFF005200),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Align(
                                                alignment:
                                                const AlignmentDirectional(0, 0),
                                                child: Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(1, 0, 1, 0),
                                                  child: RichText(
                                                    textScaleFactor:
                                                    MediaQuery.of(context)
                                                        .textScaleFactor,
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
                                                            fontSize: 18,
                                                            fontWeight:
                                                            FontWeight
                                                                .w800,
                                                          ),
                                                        ),
                                                        const TextSpan(
                                                          text: '1 / 5',
                                                          style: TextStyle(
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
                                                        FontWeight.w800,
                                                      ),
                                                    ),
                                                    textAlign: TextAlign.center,
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
                              ),
                            ].divide(const SizedBox(height: 12)),
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
