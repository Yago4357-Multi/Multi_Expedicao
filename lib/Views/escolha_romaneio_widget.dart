import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../Components/Model/escolha_romaneio_model.dart';
import '../Components/Widget/drawer_widget.dart';
import '../Controls/banco.dart';
import '../Models/romaneio.dart';
import '../Models/usur.dart';
import 'lista_romaneios.dart';
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
            'Romaneio',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Outfit',
              color: FlutterFlowTheme.of(context).primaryBackground,
            ),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 2,
        ),
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                (['BI', 'Comercial'].contains(usur.acess)) ?
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => ListaRomaneiosWidget(usur, bd: bd),));
                  },
                  child: (Container(
                    alignment: Alignment.center,
                    width:
                    MediaQuery.of(context).size.height *
                        0.8,
                    height:
                    MediaQuery.of(context).size.height *
                        0.1,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(20)),
                    child: Text(
                      'Conferir Romaneios',
                      style: FlutterFlowTheme.of(context)
                          .titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  )),
                ) : Container(),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    return showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: FutureBuilder(
                            future: romaneios,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                romaneiosLista = snapshot.data as List<Romaneio>;
                                return Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16, 12, 16, 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          showCursor: true,
                                          initialValue:
                                          romaneio != '0' ? romaneio : '',
                                          controller: _model.textController,
                                          focusNode: _model.textFieldFocusNode,
                                          onChanged: (value) {
                                            romaneio = value;
                                          },
                                          onFieldSubmitted: (value) async {
                                            if (await bd.connected(context) ==
                                                1) {
                                              if (context.mounted) {
                                                if (romaneiosLista
                                                    .where((element) =>
                                                '${element.romaneio}' ==
                                                    romaneio)
                                                    .isEmpty) {
                                                  await showCupertinoModalPopup(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (context2) {
                                                      return CupertinoAlertDialog(
                                                        title: const Text(
                                                            'Romaneio não encontrado'),
                                                        actions: <CupertinoDialogAction>[
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
                                                  return;
                                                }
                                                if (romaneiosLista
                                                    .where((element) =>
                                                '${element.romaneio}' ==
                                                    romaneio &&
                                                    element.dtFechamento ==
                                                        null)
                                                    .isEmpty) {
                                                  await showCupertinoModalPopup(
                                                      barrierDismissible: false,
                                                      builder: (context2) {
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
                                                          actions: <CupertinoDialogAction>[
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
                                                      context: context);
                                                  return;
                                                }
                                                Navigator.pop(context);
                                                await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ListaRomaneioWidget(
                                                                int.parse(
                                                                    romaneio),
                                                                usur,
                                                                bd: bd)));
                                              }
                                            }
                                            setState(() {

                                            });
                                          },
                                          autofocus: true,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            labelText: 'Insira o Romaneio',
                                            labelStyle: FlutterFlowTheme.of(
                                                context)
                                                .labelMedium
                                                .override(
                                              fontFamily: 'Readex Pro',
                                              color:
                                              FlutterFlowTheme.of(context)
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
                                                color:
                                                FlutterFlowTheme.of(context)
                                                    .alternate,
                                                width: 2,
                                              ),
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.green.shade500,
                                                width: 2,
                                              ),
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.green.shade100,
                                                width: 2,
                                              ),
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                            focusedErrorBorder:
                                            OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.green.shade100,
                                                width: 2,
                                              ),
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(),
                                          validator: _model
                                              .textControllerValidator
                                              .asValidator(context),
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(33),
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                        ),
                                      ),
                                      Padding(
                                          padding:
                                          const EdgeInsets.only(left: 10),
                                          child: Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                  BorderRadius.circular(10)),
                                              child: IconButton(
                                                  icon: const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: () async {
                                                    if (await bd
                                                        .connected(context) ==
                                                        1) {
                                                      if (context.mounted) {
                                                        if (romaneiosLista
                                                            .where((element) =>
                                                        '${element.romaneio}' ==
                                                            romaneio)
                                                            .isEmpty) {
                                                          await showCupertinoModalPopup(
                                                            context: context,
                                                            barrierDismissible:
                                                            false,
                                                            builder: (context2) {
                                                              return CupertinoAlertDialog(
                                                                title: const Text(
                                                                    'Romaneio não encontrado'),
                                                                actions: <CupertinoDialogAction>[
                                                                  CupertinoDialogAction(
                                                                      isDefaultAction:
                                                                      true,
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
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
                                                            .where((element) =>
                                                        '${element.romaneio}' ==
                                                            romaneio &&
                                                            element.dtFechamento ==
                                                                null)
                                                            .isEmpty) {
                                                          await showCupertinoModalPopup(
                                                              barrierDismissible:
                                                              false,
                                                              builder:
                                                                  (context2) {
                                                                return CupertinoAlertDialog(
                                                                  title:
                                                                  const Text(
                                                                    'Romaneio finalizado\n',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                                  ),
                                                                  content: const Text(
                                                                      'Escolha outro Romaneio ou converse com os Desenvolvedores'),
                                                                  actions: <CupertinoDialogAction>[
                                                                    CupertinoDialogAction(
                                                                        isDefaultAction:
                                                                        true,
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
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
                                                        Navigator.pop(context);
                                                        await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    ListaRomaneioWidget(
                                                                        int.parse(
                                                                            romaneio),
                                                                        usur,
                                                                        bd: bd)));
                                                      }
                                                    }
                                                    setState(() {});
                                                  }))),
                                      Padding(
                                          padding:
                                          const EdgeInsets.only(left: 10),
                                          child: Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                  BorderRadius.circular(10)),
                                              child: IconButton(
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return StatefulBuilder(
                                                          builder:
                                                              (context, setter) {
                                                            internalSetter =
                                                                setter;
                                                            return Dialog(
                                                              backgroundColor:
                                                              Colors.white,
                                                              child: Stack(
                                                                children: [
                                                                  Column(
                                                                    mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                    children: [
                                                                      Container(
                                                                        height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                            0.1,
                                                                        width: MediaQuery.of(
                                                                            context)
                                                                            .size
                                                                            .width,
                                                                        decoration: const BoxDecoration(
                                                                            color: Colors
                                                                                .white,
                                                                            borderRadius:
                                                                            BorderRadiusDirectional.vertical(top: Radius.circular(20))),
                                                                        child:
                                                                        Align(
                                                                          alignment:
                                                                          Alignment.center,
                                                                          child:
                                                                          Text(
                                                                            'Romaneios Abertos',
                                                                            textAlign:
                                                                            TextAlign.center,
                                                                            style: FlutterFlowTheme.of(context)
                                                                                .headlineMedium
                                                                                .override(
                                                                              fontFamily: 'Outfit',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            10),
                                                                        width: double
                                                                            .infinity,
                                                                        decoration:
                                                                        BoxDecoration(
                                                                          color: FlutterFlowTheme.of(context)
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
                                                                          BorderRadius.circular(0),
                                                                          shape: BoxShape
                                                                              .rectangle,
                                                                        ),
                                                                        child:
                                                                        Container(
                                                                          width: double
                                                                              .infinity,
                                                                          height:
                                                                          40,
                                                                          decoration:
                                                                          BoxDecoration(
                                                                            color:
                                                                            FlutterFlowTheme.of(context).primaryBackground,
                                                                            borderRadius:
                                                                            BorderRadius.circular(12),
                                                                          ),
                                                                          alignment: const AlignmentDirectional(
                                                                              -1,
                                                                              0),
                                                                          child:
                                                                          Padding(
                                                                            padding: const EdgeInsetsDirectional
                                                                                .fromSTEB(
                                                                                16,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                            Row(
                                                                              mainAxisSize:
                                                                              MainAxisSize.max,
                                                                              mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                              crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                              children: [
                                                                                Expanded(
                                                                                  child: Text(
                                                                                    (responsiveVisibility(
                                                                                        context: context,
                                                                                        phone: false,
                                                                                        tablet: false,
                                                                                        desktop: true)) ? 'Romaneio' : 'Rom.',
                                                                                    style: FlutterFlowTheme.of(context).labelSmall.override(
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
                                                                                    desktop: true))(Expanded(
                                                                                  child: Text(
                                                                                    softWrap: true,
                                                                                    'Usuário de Abertura',
                                                                                    style: FlutterFlowTheme.of(context).labelSmall.override(
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
                                                                                    desktop: true))(
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        'Dt. de Abertura',
                                                                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                          fontFamily: 'Readex Pro',
                                                                                          letterSpacing: 0,
                                                                                          fontSize: 15,
                                                                                        ),
                                                                                      ),
                                                                                    )),
                                                                                Expanded(
                                                                                  child: Text(
                                                                                    'Paletes',
                                                                                    style: FlutterFlowTheme.of(context).labelSmall.override(
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
                                                                                        desktop: true)) ? 'Volumetria' : 'Vol.',
                                                                                    style: FlutterFlowTheme.of(context).labelSmall.override(
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
                                                                        width: MediaQuery.of(context).size.width,
                                                                        height: MediaQuery.of(context).size.height * 0.7,
                                                                        child: ListView
                                                                            .builder(
                                                                          shrinkWrap:
                                                                          true,
                                                                          physics: const AlwaysScrollableScrollPhysics(),
                                                                          scrollDirection:
                                                                          Axis.vertical,
                                                                          padding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                          itemCount:
                                                                          romaneiosLista
                                                                              .length,
                                                                          itemBuilder:
                                                                              (context,
                                                                              index) {
                                                                            if (romaneiosLista[index].dtFechamento ==
                                                                                null) {
                                                                              if (int.parse(romaneio) ==
                                                                                  romaneiosLista[index].romaneio) {
                                                                                return Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 1),
                                                                                  child: Container(
                                                                                    width: double.infinity,
                                                                                    decoration: BoxDecoration(
                                                                                      color: Colors.yellow.shade50,
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
                                                                                      splashColor: Colors.transparent,
                                                                                      focusColor: Colors.transparent,
                                                                                      hoverColor: Colors.transparent,
                                                                                      highlightColor: Colors.transparent,
                                                                                      onTap: () async {
                                                                                        if (await bd.connected(context) == 1) {
                                                                                          setter(
                                                                                                () {
                                                                                              romaneio = '${romaneiosLista[index].romaneio!}';
                                                                                              setState(() {
                                                                                                romaneio = '${romaneiosLista[index].romaneio!}';
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
                                                                                                color: Colors.green.shade400,
                                                                                                borderRadius: BorderRadius.circular(2),
                                                                                              ),
                                                                                            ),
                                                                                            Expanded(
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                                child: Text(
                                                                                                  '${romaneiosLista[index].romaneio}',
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
                                                                                                desktop: true))(
                                                                                                Expanded(
                                                                                                  child: Padding(
                                                                                                    padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                                    child: Text(
                                                                                                      '${romaneiosLista[index].usurCriacao}',
                                                                                                      style: FlutterFlowTheme.of(context).labelLarge.override(
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
                                                                                                desktop: true))(
                                                                                                Expanded(
                                                                                                  child: Padding(
                                                                                                    padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                                    child: Text(
                                                                                                      DateFormat('dd/MM/yyyy   kk:mm').format(romaneiosLista[index].dtRomaneio!),
                                                                                                      style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                                        fontFamily: 'Readex Pro',
                                                                                                        letterSpacing: 0,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                )),
                                                                                            Expanded(
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                                child: Text(
                                                                                                  '${romaneiosLista[index].palete}',
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
                                                                                                  '${romaneiosLista[index].vol}',
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
                                                                                              romaneio = '${romaneiosLista[index].romaneio!}';
                                                                                              setState(() {
                                                                                                romaneio = '${romaneiosLista[index].romaneio!}';
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
                                                                                                  '${romaneiosLista[index].romaneio}',
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
                                                                                                desktop: true))(
                                                                                                Expanded(
                                                                                                  child: Padding(
                                                                                                    padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                                    child: Text(
                                                                                                      '${romaneiosLista[index].usurCriacao}',
                                                                                                      style: FlutterFlowTheme.of(context).labelLarge.override(
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
                                                                                                desktop: true))(
                                                                                                Expanded(
                                                                                                  child: Padding(
                                                                                                    padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                                    child: Text(
                                                                                                      DateFormat('dd/MM/yyyy   kk:mm').format(romaneiosLista[index].dtRomaneio!),
                                                                                                      style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                                        fontFamily: 'Readex Pro',
                                                                                                        letterSpacing: 0,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                )),
                                                                                            Expanded(
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                                child: Text(
                                                                                                  '${romaneiosLista[index].palete}',
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
                                                                                                  '${romaneiosLista[index].vol}',
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
                                                                            } else {
                                                                              return Container();
                                                                            }
                                                                          },
                                                                        ),
                                                                      ),
                                                                      Expanded(child: Container(decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),))
                                                                    ],
                                                                  ),
                                                                  Positioned(
                                                                      bottom: 10,
                                                                      right: 10,
                                                                      child: Container(
                                                                          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
                                                                          width: 50,
                                                                          height: 50,
                                                                          child: IconButton(
                                                                            onPressed:
                                                                                () async {
                                                                              if (await bd.connected(context) ==
                                                                                  1) {
                                                                                if (context.mounted) {
                                                                                  if (romaneiosLista.where((element) => '${element.romaneio}' == romaneio).isEmpty) {
                                                                                    await showCupertinoModalPopup(
                                                                                      context: context,
                                                                                      barrierDismissible: false,
                                                                                      builder: (context2) {
                                                                                        return CupertinoAlertDialog(
                                                                                          title: const Text('Romaneio não encontrado'),
                                                                                          actions: <CupertinoDialogAction>[
                                                                                            CupertinoDialogAction(
                                                                                                isDefaultAction: true,
                                                                                                onPressed: () {
                                                                                                  Navigator.pop(context2);
                                                                                                },
                                                                                                child: const Text('Voltar'))
                                                                                          ],
                                                                                        );
                                                                                      },
                                                                                    );
                                                                                    return;
                                                                                  }
                                                                                  if (romaneiosLista.where((element) => '${element.romaneio}' == romaneio && element.dtFechamento == null).isEmpty) {
                                                                                    await showCupertinoModalPopup(
                                                                                        barrierDismissible: false,
                                                                                        builder: (context2) {
                                                                                          return CupertinoAlertDialog(
                                                                                            title: const Text(
                                                                                              'Romaneio finalizado\n',
                                                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            content: const Text('Escolha outro Romaneio ou converse com os Desenvolvedores'),
                                                                                            actions: <CupertinoDialogAction>[
                                                                                              CupertinoDialogAction(
                                                                                                  isDefaultAction: true,
                                                                                                  onPressed: () {
                                                                                                    Navigator.pop(context2);
                                                                                                  },
                                                                                                  child: const Text('Voltar'))
                                                                                            ],
                                                                                          );
                                                                                        },
                                                                                        context: context);
                                                                                    return;
                                                                                  }
                                                                                  Navigator.pop(context);
                                                                                  Navigator.pop(context);
                                                                                  Navigator.pop(context);
                                                                                  await Navigator.push(context, MaterialPageRoute(builder: (context) => ListaRomaneioWidget(int.parse(romaneio), usur, bd: bd)));
                                                                                }
                                                                              }
                                                                              setState(() {});
                                                                            },
                                                                            icon: const Icon(
                                                                                Icons.check,
                                                                                color: Colors.white),
                                                                          )))
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    );
                                                  },
                                                  icon: const Icon(
                                                      Icons.search_rounded,
                                                      color: Colors.white))))
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
                  },
                  child: (Container(
                    alignment: Alignment.center,
                    width:
                    MediaQuery.of(context).size.height *
                        0.8,
                    height:
                    MediaQuery.of(context).size.height *
                        0.1,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(20)),
                    child: Text(
                      'Continuar Romaneio',
                      style: FlutterFlowTheme.of(context)
                          .titleLarge,
                      textAlign: TextAlign.center,
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
                      bd.createRomaneio(usur);
                      var i = 0;
                      if (context.mounted) {
                        i = await bd.getRomaneio(context) ?? 0;
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ListaRomaneioWidget(i, usur, bd: bd),
                            ));
                      }
                    }
                    setState(() {});
                  },
                  child: (Container(
                    alignment: Alignment.center,
                    width:
                    MediaQuery.of(context).size.height *
                        0.8,
                    height:
                    MediaQuery.of(context).size.height *
                        0.1,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(20)),
                    child: Text(
                      'Criar Novo Romaneio',
                      style: FlutterFlowTheme.of(context)
                          .titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  )),
                ) : Container(),
              ]
            ),
          ),
        ),
      ),
    );
  }
}
