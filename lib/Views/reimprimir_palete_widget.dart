import 'dart:ui';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../Components/Model/criar_palete_model.dart';
import '../Components/Widget/drawer_widget.dart';
import '../Controls/banco.dart';
import '../Models/palete.dart';
import '../Models/usur.dart';
import 'home_widget.dart';

export '../Components/Model/criar_palete_model.dart';

///Página para a criação de novos Paletes
class ReimprimirPaleteWidget extends StatefulWidget {
  ///Variável para definir permissões do Usur.
  final Usuario usur;

  ///Variável para guardar número do palete
  final int palete;

  ///Variável para manter conexão com o Banco
  final Banco bd;

  ///Construtor da página de criação de novos Paletes
  const ReimprimirPaleteWidget(
      this.usur,
      this.palete, {
        super.key,
        required this.bd,
      });

  @override
  State<ReimprimirPaleteWidget> createState() =>
      _ReimprimirPaleteWidgetState(usur, palete, bd);
}

class _ReimprimirPaleteWidgetState extends State<ReimprimirPaleteWidget> {
  late Banco bd;

  final Usuario usur;
  int palete = 0;
  String paleteText = '';

  late StateSetter internalSetter;

  late Future<List<Paletes>> getPaletes;
  late List<Paletes> paletes;
  final pdf = pw.Document();
  late CriarPaleteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  _ReimprimirPaleteWidgetState(this.usur, this.palete, this.bd);

  @override
  void initState() {
    super.initState();
    rodarBanco();
    _model = createModel(context, CriarPaleteModel.new);
  }

  void rodarBanco() async {
    getPaletes = bd.paletesFull();
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
          title: Text(
            'Reimprimir Palete',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Outfit',
              color: FlutterFlowTheme.of(context).primaryBackground,
            ),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.lock_reset_outlined),onPressed: () async {
              getPaletes = bd.paletesFull();
              setState(() {
              });
            }, color: Colors.white,),
          ],
          centerTitle: true,
          elevation: 2,
        ),
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
        body: SafeArea(
          top: true,
          child: FutureBuilder(
            future: getPaletes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                paletes = (snapshot.data ?? []);
                return Center(
                  widthFactor: double.infinity,
                  heightFactor: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Container()),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                canRequestFocus: true,
                                onChanged: (value) {
                                  paleteText = value;
                                },
                                onFieldSubmitted: (value) async {
                                  if (await bd.connected(context) == 1) {
                                    if (paletes
                                        .where((element) =>
                                    element.pallet == int.parse(paleteText))
                                        .isNotEmpty) {
                                      palete = int.parse(value);
                                    } else {
                                      if (context.mounted) {
                                        await showCupertinoModalPopup(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return CupertinoAlertDialog(
                                              title: const Text(
                                                  'Palete não encontrado'),
                                              actions: <CupertinoDialogAction>[
                                                CupertinoDialogAction(
                                                    isDefaultAction: true,
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Voltar'))
                                              ],
                                            );
                                          },
                                        );
                                        return;
                                      }
                                    }
                                  }
                                  setState(() {});
                                },
                                autofocus: false,
                                obscureText: false,
                                decoration: InputDecoration(
                                  labelText: 'Insira um Palete',
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
                                    borderSide: const BorderSide(
                                      color: Colors.green,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.green,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding:
                                  const EdgeInsetsDirectional.fromSTEB(
                                      20, 0, 0, 0),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  letterSpacing: 0,
                                ),
                                cursorColor:
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                            Container(
                              width: 10,
                            ),
                            Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10)),
                                child: IconButton(
                                  onPressed: () async {
                                    if (await bd.connected(context) == 1) {
                                      if (paletes
                                          .where((element) =>
                                      element.pallet == int.parse(paleteText)).isNotEmpty) {
                                        palete = int.parse(paleteText);
                                      } else {
                                        if (context.mounted) {
                                          await showCupertinoModalPopup(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) {
                                              return CupertinoAlertDialog(
                                                title: const Text(
                                                    'Palete não encontrado'),
                                                actions: <
                                                    CupertinoDialogAction>[
                                                  CupertinoDialogAction(
                                                      isDefaultAction: true,
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                          'Voltar'))
                                                ],
                                              );
                                            },
                                          );
                                          return;
                                        }
                                      }
                                    }
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.check_rounded),
                                  color: Colors.white,
                                )),
                            Container(
                              width: 10,
                            ),
                            Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10)),
                                child: IconButton(
                                  onPressed: () async {
                                    if (await bd.connected(context) == 1){
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(
                                            builder: (context, setter) {
                                              internalSetter = setter;
                                              return Dialog(
                                                backgroundColor: Colors.white,
                                                child: Stack(
                                                  children: [
                                                    Column(
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
                                                              'Lista de Paletes',
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
                                                                  if (responsiveVisibility(
                                                                      context: context,
                                                                      phone: false,
                                                                      tablet: false,
                                                                      desktop: true)) Expanded(
                                                                    child: Text(
                                                                      'Romaneio',
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
                                                                  if (responsiveVisibility(
                                                                      context: context,
                                                                      phone: false,
                                                                      tablet: false,
                                                                      desktop: true)) Expanded(
                                                                    child: Text(
                                                                      softWrap:
                                                                      true,
                                                                      'Usur. de Abert.',
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
                                                                  if (responsiveVisibility(
                                                                      context: context,
                                                                      phone: false,
                                                                      tablet: false,
                                                                      desktop: true)) Expanded(
                                                                    child: Text(
                                                                      'Dt. de Abert.',
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
                                                                  if (responsiveVisibility(
                                                                      context: context,
                                                                      phone: false,
                                                                      tablet: false,
                                                                      desktop: true)) Expanded(
                                                                    child: Text(
                                                                      softWrap:
                                                                      true,
                                                                      'Usur. de Fecha.',
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
                                                                  if (responsiveVisibility(
                                                                      context: context,
                                                                      phone: false,
                                                                      tablet: false,
                                                                      desktop: true)) Expanded(
                                                                    child: Text(
                                                                      'Dt. de Fecha.',
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
                                                                  if (responsiveVisibility(
                                                                      context: context,
                                                                      phone: false,
                                                                      tablet: false,
                                                                      desktop: true)) Expanded(
                                                                    child: Text(
                                                                      softWrap:
                                                                      true,
                                                                      'Usur. de Carreg.',
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
                                                                  if (responsiveVisibility(
                                                                      context: context,
                                                                      phone: false,
                                                                      tablet: false,
                                                                      desktop: true)) Expanded(
                                                                    child: Text(
                                                                      'Dt. de Carreg.',
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
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                              context)
                                                              .size
                                                              .width,
                                                          height: MediaQuery.of(
                                                              context)
                                                              .size
                                                              .height *
                                                              0.7,
                                                          child: ListView.builder(
                                                            shrinkWrap: true,
                                                            physics:
                                                            const AlwaysScrollableScrollPhysics(),
                                                            scrollDirection:
                                                            Axis.vertical,
                                                            padding:
                                                            EdgeInsets.zero,
                                                            itemCount:
                                                            paletes.length,
                                                            itemBuilder:
                                                                (context, index) {
                                                              if (palete ==
                                                                  paletes[index].pallet) {
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
                                                                        if (await bd
                                                                            .connected(context) ==
                                                                            1) {
                                                                          setter(
                                                                                () {
                                                                              palete =
                                                                              paletes[index].pallet!;
                                                                              setState(
                                                                                      () {
                                                                                    palete =
                                                                                    paletes[index].pallet!;
                                                                                  });
                                                                            },
                                                                          );
                                                                        }
                                                                        setState(() {});
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
                                                                                  '${paletes[index].pallet}',
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
                                                                                  '${paletes[index].volumetria}',
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
                                                                                desktop: true)) Expanded(
                                                                              child:
                                                                              Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                    12,
                                                                                    0,
                                                                                    0,
                                                                                    0),
                                                                                child:
                                                                                Text(
                                                                                  '${paletes[index].romaneio ?? ''}',
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
                                                                                desktop: true)) Expanded(
                                                                              child:
                                                                              Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                    12,
                                                                                    0,
                                                                                    0,
                                                                                    0),
                                                                                child:
                                                                                Text(
                                                                                  '${paletes[index].UsurInclusao}',
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
                                                                                desktop: true))Expanded(
                                                                              child:
                                                                              Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                    12,
                                                                                    0,
                                                                                    0,
                                                                                    0),
                                                                                child:
                                                                                Text(
                                                                                  DateFormat('dd/MM/yyyy   kk:mm').format(paletes[index].dtInclusao!),
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
                                                                                desktop: true)) Expanded(
                                                                              child:
                                                                              Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                    12,
                                                                                    0,
                                                                                    0,
                                                                                    0),
                                                                                child:
                                                                                Text(
                                                                                  paletes[index].UsurFechamento ?? '',
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
                                                                                desktop: true)) Expanded(
                                                                              child:
                                                                              Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                    12,
                                                                                    0,
                                                                                    0,
                                                                                    0),
                                                                                child:
                                                                                Text(
                                                                                  paletes[index].dtFechamento != null ? DateFormat('dd/MM/yyyy   kk:mm').format(paletes[index].dtFechamento!) : '',
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
                                                                                desktop: true)) Expanded(
                                                                              child:
                                                                              Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                    12,
                                                                                    0,
                                                                                    0,
                                                                                    0),
                                                                                child:
                                                                                Text(
                                                                                  paletes[index].UsurCarregamento ?? '',
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
                                                                                desktop: true)) Expanded(
                                                                              child:
                                                                              Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                    12,
                                                                                    0,
                                                                                    0,
                                                                                    0),
                                                                                child:
                                                                                Text(
                                                                                  paletes[index].dtCarregamento != null ? DateFormat('dd/MM/yyyy   kk:mm').format(paletes[index].dtCarregamento!) : '',
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
                                                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 1),
                                                                  child: Container(
                                                                    width: double.infinity,
                                                                    decoration: BoxDecoration(
                                                                      color: FlutterFlowTheme.of(context).primaryBackground,
                                                                      boxShadow: const [
                                                                        BoxShadow(
                                                                          blurRadius: 0,
                                                                          color: Color(0xFFE0E3E7),
                                                                          offset: Offset(
                                                                            0.0,
                                                                            1,
                                                                          ),
                                                                        )
                                                                      ],
                                                                      borderRadius: BorderRadius.circular(0),
                                                                      shape: BoxShape.rectangle,
                                                                    ),
                                                                    child: InkWell(
                                                                      onTap: () async {
                                                                        if (await bd.connected(context) == 1) {
                                                                          setter(
                                                                                () {
                                                                              palete = paletes[index].pallet!;
                                                                              setState(() {
                                                                                palete = paletes[index].pallet!;
                                                                              });
                                                                            },
                                                                          );
                                                                        }
                                                                        setState(() {});
                                                                      },
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8),
                                                                        child: Row(
                                                                          mainAxisSize: MainAxisSize.max,
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
                                                                                  '${paletes[index].pallet}',
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
                                                                                  '${paletes[index].volumetria}',
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
                                                                                  '${paletes[index].romaneio ?? ''}',
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
                                                                                desktop: true))Expanded(
                                                                              child: Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                child: Text(
                                                                                  '${paletes[index].UsurInclusao}',
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
                                                                                desktop: true))Expanded(
                                                                              child: Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                child: Text(
                                                                                  DateFormat('dd/MM/yyyy   kk:mm').format(paletes[index].dtInclusao!),
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
                                                                                desktop: true))Expanded(
                                                                              child: Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                child: Text(
                                                                                  paletes[index].UsurFechamento ?? '',
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
                                                                                desktop: true))Expanded(
                                                                              child: Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                child: Text(
                                                                                  paletes[index].dtFechamento != null ? DateFormat('dd/MM/yyyy   kk:mm').format(paletes[index].dtFechamento!) : '',
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
                                                                                desktop: true))Expanded(
                                                                              child: Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                child: Text(
                                                                                  paletes[index].UsurCarregamento ?? '',
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
                                                                                desktop: true))Expanded(
                                                                              child: Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                child: Text(
                                                                                  paletes[index].dtCarregamento != null ? DateFormat('dd/MM/yyyy   kk:mm').format(paletes[index].dtCarregamento!) : '',
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
                                                        ),
                                                        Expanded(
                                                            child: Container(
                                                              decoration: const BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius: BorderRadius.only(
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
                                                        bottom: 10,
                                                        right: 10,
                                                        child: Container(
                                                            decoration: BoxDecoration(
                                                                color:
                                                                Colors.green,
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    10)),
                                                            width: 50,
                                                            height: 50,
                                                            child: IconButton(
                                                              onPressed:
                                                                  () async {
                                                                if (await bd.connected(context) == 1) {
                                                                  pdf.addPage(pw.Page(
                                                                    pageFormat: PdfPageFormat.a4,
                                                                    build: (context2) {
                                                                      return pw.Container(
                                                                        width: 200,
                                                                        height: 100,
                                                                        child: pw.BarcodeWidget(
                                                                            data: '$palete',
                                                                            barcode: Barcode.code128(),
                                                                            width: 160,
                                                                            height: 60,
                                                                            color: PdfColors.black,
                                                                            drawText: true,
                                                                            textStyle: pw.TextStyle(
                                                                              fontSize: 40,
                                                                              letterSpacing: 0,
                                                                              fontWeight: pw.FontWeight.bold
                                                                            )),
                                                                      );
                                                                    },
                                                                  ));
                                                                  await Printing.layoutPdf(
                                                                      onLayout: (format) => pdf.save());
                                                                  if (context.mounted) {
                                                                    Navigator.pop(context);
                                                                    await Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              HomeWidget(usur, bd: bd),
                                                                        ));
                                                                  }
                                                                }
                                                                setState(() {});
                                                              },
                                                              icon: const Icon(
                                                                  Icons.receipt_long,
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
                                  icon: const Icon(Icons.search_rounded),
                                  color: Colors.white,
                                ))
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          BarcodeWidget(
                            data: '$palete',
                            barcode: Barcode.code128(),
                            width: 300,
                            height: 90,
                            drawText: true,
                            color: FlutterFlowTheme.of(context).primaryText,
                            style: const TextStyle(
                              fontSize: 20,
                              letterSpacing: 0,
                                fontWeight: FontWeight.bold
                            ),
                            backgroundColor: Colors.transparent,
                            errorBuilder: (context, error) => const SizedBox(
                              width: 300,
                              height: 90,
                            ),
                          ),
                        ],
                      ),
                      Expanded(child: Container()),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20, 24, 20, 12),
                        child: FFButtonWidget(
                          onPressed: () async {
                            if (await bd.connected(context) == 1) {
                              bd.createPalete(usur);
                              pdf.addPage(pw.Page(
                                pageFormat: PdfPageFormat.a4,
                                build: (context2) {
                                  return pw.Container(
                                    width: 200,
                                    height: 100,
                                    child: pw.BarcodeWidget(
                                        data: '$palete',
                                        barcode: Barcode.code128(),
                                        width: 160,
                                        height: 60,
                                        color: PdfColors.black,
                                        drawText: true,
                                        textStyle: pw.TextStyle(
                                          fontSize: 40,
                                          letterSpacing: 0,
                                            fontWeight: pw.FontWeight.bold
                                        )),
                                  );
                                },
                              ));
                              await Printing.layoutPdf(
                                  onLayout: (format) => pdf.save());
                              if (context.mounted) {
                                Navigator.pop(context);
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          HomeWidget(usur, bd: bd),
                                    ));
                              }
                            }
                            setState(() {});
                          },
                          text: 'Criar Palete e Imprimir Cód.',
                          icon: const Icon(
                            Icons.receipt_long,
                            size: 15,
                          ),
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 54,
                            padding: const EdgeInsets.all(0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 0, 0),
                            color: Colors.green.shade700,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white,
                              letterSpacing: 0,
                            ),
                            elevation: 4,
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
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
        ),
      ),
    );
  }
}
