import 'package:flutter/foundation.dart';

import '../Models/Contagem.dart';
import '/components/Widget/drawer_widget.dart';
import '/components/Widget/painel_edicao_widget.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:romaneio_teste/Components/Model/lista_romaneio_conf_model.dart';
export 'package:romaneio_teste/Components/Model/lista_romaneio_conf_model.dart';

class ListaRomaneioConfWidget extends StatefulWidget {
  const ListaRomaneioConfWidget({super.key});

  @override
  State<ListaRomaneioConfWidget> createState() =>
      _ListaRomaneioConfWidgetState();
}

class _ListaRomaneioConfWidgetState extends State<ListaRomaneioConfWidget> {


  late List<List<Contagem>> Pedidos = [];

  late ListaRomaneioConfModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ListaRomaneioConfModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    _model.textFieldFocusNode!.addListener(() => setState(() {}));
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (kDebugMode) {
              print('FloatingActionButton pressed ...');
            }
          },
          backgroundColor: const Color(0xFF007000),
          elevation: 8,
          label: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'Pallet',
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                          fontFamily: 'Outfit',
                          color: FlutterFlowTheme.of(context).primaryBackground,
                        ),
                  ),
                  Container(
                    width: 160,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0x00FFFFFF),
                      borderRadius: BorderRadius.circular(8),
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: const Color(0x00E0E3E7),
                        width: 2,
                      ),
                    ),
                    child: FlutterFlowCountController(
                      decrementIconBuilder: (enabled) => FaIcon(
                        FontAwesomeIcons.minus,
                        color: enabled
                            ? FlutterFlowTheme.of(context).alternate
                            : FlutterFlowTheme.of(context).primaryBackground,
                        size: 20,
                      ),
                      incrementIconBuilder: (enabled) => FaIcon(
                        FontAwesomeIcons.plus,
                        color: enabled
                            ? FlutterFlowTheme.of(context).primaryBackground
                            : FlutterFlowTheme.of(context).primaryBackground,
                        size: 20,
                      ),
                      countBuilder: (count) => Text(
                        count.toString(),
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                              fontFamily: 'Outfit',
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                            ),
                      ),
                      count: _model.countControllerValue ??= 1,
                      updateCount: (count) =>
                          setState(() => {
                            if (count>=1){
                            _model.countControllerValue = count
                            }
                            else{
                              _model.countControllerValue = 1
                          }
                          }
                          ),
                      stepSize: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
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
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: const AlignmentDirectional(-1, -1),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(24, 20, 0, 0),
                                        child: Text(
                                          'Pallet :',
                                          textAlign: TextAlign.start,
                                          style: FlutterFlowTheme.of(context)
                                              .headlineMedium,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 20, 24, 0),
                                        child: Text(
                                          '${_model.countControllerValue}',
                                          textAlign: TextAlign.end,
                                          style: FlutterFlowTheme.of(context)
                                              .headlineMedium
                                              .override(
                                                fontFamily: 'Outfit',
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold,
                                              ),
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
                                  'Pedidos nesse Pallet',
                                  textAlign: TextAlign.start,
                                  style:
                                      FlutterFlowTheme.of(context).labelMedium,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16, 12, 16, 0),
                                child: Container(
                                  width: double.infinity,
                                  constraints: const BoxConstraints(
                                    maxWidth: double.infinity,
                                  ),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            16, 12, 16, 12),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: TextFormField(
                                            controller: _model.textController,
                                            focusNode:
                                                _model.textFieldFocusNode,
                                            onChanged: (_) =>
                                                EasyDebounce.debounce(
                                              '_model.textController',
                                              const Duration(
                                                  milliseconds: 1000),
                                              () => setState(() {
                                                if (Pedidos.length <= _model.countControllerValue){
                                                  Pedidos.add([Contagem(_model.textController.text, _model.countControllerValue)]);
                                                }
                                                else {
                                                  Pedidos[_model.countControllerValue-1].add(Contagem(_model.textController.text, _model.countControllerValue));
                                                }
                                                _model.textController.text = "";
                                              }),
                                            ),
                                            autofocus: true,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              labelText: 'Pedido',
                                              labelStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .labelMedium
                                                  .override(
                                                    fontFamily: 'Readex Pro',
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                              alignLabelWithHint: false,
                                              hintStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium,
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .alternate,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium,
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                                decimal: true),
                                            validator: _model
                                                .textControllerValidator
                                                .asValidator(context),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp('[0-9]'))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    12,
                                    0,
                                    44,
                                  ),
                                  primary: false,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: (Pedidos.isEmpty) ? 0 : (Pedidos.length >= _model.countControllerValue) ? (Pedidos[_model.countControllerValue-1].isEmpty) ? 0 : Pedidos[_model.countControllerValue-1].length : 0,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              14, 10, 14, 10),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onLongPress: () async {
                                          await showModalBottomSheet(
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (context) {
                                              return GestureDetector(
                                                onTap: () => _model.unfocusNode
                                                        .canRequestFocus
                                                    ? FocusScope.of(context)
                                                        .requestFocus(
                                                            _model.unfocusNode)
                                                    : FocusScope.of(context)
                                                        .unfocus(),
                                                child: Padding(
                                                  padding:
                                                      MediaQuery.viewInsetsOf(
                                                          context),
                                                  child:
                                                      const PainelEdicaoWidget(),
                                                ),
                                              );
                                            },
                                          ).then(
                                              (value) => safeSetState(() {}));
                                        },
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
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
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
                                                      InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          Navigator
                                                              .popAndPushNamed(
                                                                  context,
                                                                  '/ListaPedido');
                                                        },
                                                        child: RichText(
                                                          text: TextSpan(
                                                            children: [
                                                              const TextSpan(
                                                                text: 'Ped. : ',
                                                                style:
                                                                    TextStyle(),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    Pedidos[_model.countControllerValue-1][index].Cod_Arrumado,
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
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                0, 4, 0, 0),
                                                        child: Text(
                                                          'Palete : ${ Pedidos[_model.countControllerValue-1][index].Palete}',
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
                                                          'Cidade : ${ Pedidos[_model.countControllerValue-1][index].Cx}',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
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
                                                      mainAxisSize:
                                                          MainAxisSize.max,
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
                                                                color: const Color(
                                                                    0xFFEAB491),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                border:
                                                                    Border.all(
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
                                                                    'Vol : ${ Pedidos[_model.countControllerValue-1][index].Cx} / ${ Pedidos[_model.countControllerValue-1][index].Vol}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              'Readex Pro',
                                                                          color:
                                                                              const Color(0xFFEA5E24),
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
                                                                color: const Color(
                                                                    0xFFEAB491),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                border:
                                                                    Border.all(
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
                                                                    'Vol : ${ Pedidos[_model.countControllerValue-1][index].Cx} / ${ Pedidos[_model.countControllerValue-1][index].Vol}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              'Readex Pro',
                                                                          color:
                                                                              const Color(0xFFEA5E24),
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
                                                                color: const Color(
                                                                    0xFFEAB491),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                border:
                                                                    Border.all(
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
                                                                    'Vol : ${ Pedidos[_model.countControllerValue-1][index].Cx} / ${ Pedidos[_model.countControllerValue-1][index].Vol}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              'Readex Pro',
                                                                          color:
                                                                              const Color(0xFFEA5E24),
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
                                                                minWidth: MediaQuery.sizeOf(
                                                                            context)
                                                                        .width *
                                                                    0.2,
                                                                maxWidth: MediaQuery.sizeOf(
                                                                            context)
                                                                        .width *
                                                                    0.3,
                                                                maxHeight: MediaQuery.sizeOf(
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
                                                                border:
                                                                    Border.all(
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
                                                                  child:
                                                                      RichText(
                                                                    text:
                                                                        TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              'Vol. :\n',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: 'Readex Pro',
                                                                                color: const Color(0xFF005200),
                                                                                fontSize: 18,
                                                                                fontWeight: FontWeight.w800,
                                                                              ),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              '${ Pedidos[_model.countControllerValue-1][index].Cx} / ${ Pedidos[_model.countControllerValue-1][index].Vol}',
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
                                                                            color:
                                                                                const Color(0xFF005200),
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
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(0, 4, 0, 0),
                                                  child: Container(
                                                    height: 80,
                                                    constraints: BoxConstraints(
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
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFF6ABD6A),
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
                                                                text:
                                                                    'Vol. :\n',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
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
                                                                text: '${ Pedidos[_model.countControllerValue-1][index].Cx} / ${ Pedidos[_model.countControllerValue-1][index].Vol}',
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
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
