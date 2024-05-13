import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../Components/Model/lista_palete_model.dart';
import '../Components/Widget/drawer_widget.dart';
import '../Controls/banco.dart';
import '../Models/contagem.dart';
import '../Models/palete.dart';
import '../Models/usur.dart';
import 'criar_palete_widget.dart';

///Classe para manter a listagem dos paletes
class ListaPaleteWidget extends StatefulWidget {
  ///Classe para puxar o palete inicial da página
  final int cont;

  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///Constutor para a página de listagem dos paletes
  const ListaPaleteWidget(this.usur, {super.key, required this.cont});

  @override
  State<ListaPaleteWidget> createState() =>
      _ListaPaleteWidgetState(cont, this.usur);
}

class _ListaPaleteWidgetState extends State<ListaPaleteWidget> {
  ///Classe para puxar o palete inicial da página
  int cont;
  final Usuario usur;

  _ListaPaleteWidgetState(this.cont, this.usur);

  ///Variáveis para mostrar erro no TextField
  Color corDica = Colors.green.shade400;
  Color corBorda = Colors.green.shade700;
  String dica = 'Procure um palete...';

  bool inicial = true;
  late ListaPaleteModel _model;
  late final Banco bd;

  ///Variáveis para armazenar pedidos
  late Future<List<Contagem>> getPed;
  late List<Contagem> pedidos = [];
  late List<Contagem> pedidosExc = [];

  ///Variáveis para armazenar dados do Palete
  late Future<List<Paletes>> getPalete;
  late List<Paletes> palete;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    bd = Banco();
    rodarBanco();
    _model = createModel(context, ListaPaleteModel.new);
    _model.textController ??= TextEditingController();
  }

  void rodarBanco() async {
    getPed = bd.selectPallet(cont);
    getPalete = bd.paleteAll(cont, context);
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
          ),
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
                onPressed: () async {
                  if (palete.isNotEmpty) {
                    setState(() {
                      inicial = false;
                    });
                  } else {
                    await showCupertinoModalPopup(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: const Text('Selecione um Palete'),
                          actions: <CupertinoDialogAction>[
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
                  }
                },
                icon: const Icon(Icons.edit_outlined))
            : IconButton(
                color: Colors.white,
                onPressed: () async {
                  if (pedidosExc.isNotEmpty) {
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
                                onPressed: () async {
                                  if (pedidosExc.isNotEmpty) {
                                    bd.excluiPedido(pedidosExc, usur);
                                    pedidosExc = [];
                                    getPed = bd.selectPedido(cont);
                                  }
                                  setState(() {
                                    inicial = true;
                                    getPed = bd.selectPedido(cont);
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
                  child: FutureBuilder(
                    future: getPalete,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        palete = snapshot.data ?? [];
                        return SingleChildScrollView(
                          child: FutureBuilder(
                            future: getPed,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                pedidos = snapshot.data ?? [];
                                return Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Stack(
                                              children: [
                                                Align(
                                                  alignment:
                                                      const AlignmentDirectional(
                                                          -1, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                            'Nº Palete :',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .headlineMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Outfit',
                                                                  fontSize: 20,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                25, 8, 0, 0),
                                                        child: TextField(
                                                          textAlignVertical:
                                                              TextAlignVertical
                                                                  .center,
                                                          decoration:
                                                              InputDecoration(
                                                            hintStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          'Readex Pro',
                                                                      color: const Color(
                                                                          0xFF005200),
                                                                      fontSize:
                                                                          30,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                    ),
                                                            hintText: palete
                                                                    .isNotEmpty
                                                                ? '${palete[0].pallet}'
                                                                : 'Palete desconhecido',
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                color: corBorda,
                                                                width: 2,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                color: corDica,
                                                                width: 2,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                            errorBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .error,
                                                                width: 2,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                            focusedErrorBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .error,
                                                                width: 2,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                          ),
                                                          onSubmitted:
                                                              (value) async {
                                                            setState(() {
                                                              cont = int.parse(
                                                                  value);
                                                              getPed = bd
                                                                  .selectPallet(
                                                                      cont);
                                                              getPalete =
                                                                  bd.paleteAll(
                                                                      cont,
                                                                      context);
                                                            });
                                                          },
                                                          controller: _model
                                                              .textController,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .headlineMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Outfit',
                                                                fontSize: 24,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                inicial == false
                                                    ? palete.isNotEmpty
                                                        ? Positioned(
                                                            right: 5,
                                                            top: 20,
                                                            child: SizedBox(
                                                              width: 180,
                                                              height: 35,
                                                              child:
                                                                  FloatingActionButton(
                                                                onPressed:
                                                                    () async {
                                                                  await showCupertinoModalPopup(
                                                                    context:
                                                                        context,
                                                                    barrierDismissible:
                                                                        false,
                                                                    builder:
                                                                        (context) {
                                                                      return CupertinoAlertDialog(
                                                                        title: const Text(
                                                                            'Reimprimir etiqueta?'),
                                                                        actions: <CupertinoDialogAction>[
                                                                          CupertinoDialogAction(
                                                                              isDefaultAction: true,
                                                                              isDestructiveAction: true,
                                                                              onPressed: () async {
                                                                                Navigator.pop(context);
                                                                                print(_model.textController?.text ?? '0');
                                                                                await Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                      builder: (context) => CriarPaleteWidget(usur, int.parse(_model.textController?.text ?? '0')),
                                                                                    ));
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
                                                                backgroundColor:
                                                                    Colors
                                                                        .orange
                                                                        .shade400,
                                                                elevation: 8,
                                                                child:
                                                                    const Text(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  'Reimprimir',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w900,
                                                                    fontSize:
                                                                        20,
                                                                  ),
                                                                ),
                                                              ),
                                                            ))
                                                        : Container()
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment:
                                                  const AlignmentDirectional(
                                                      0, 0),
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
                                                              .fromSTEB(
                                                              10, 20, 0, 0),
                                                      child: Text(
                                                        'Nº Volumes :',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .headlineMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Outfit',
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
                                                            const EdgeInsets
                                                                .all(10),
                                                        child: Text(
                                                          palete.isNotEmpty
                                                              ? '${palete[0].volumetria}'
                                                              : '0',
                                                          style: TextStyle(
                                                            fontSize: 40,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .green.shade700,
                                                          ),
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment:
                                                  const AlignmentDirectional(
                                                      0, 0),
                                              child: Stack(
                                                children: [
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  10, 20, 0, 0),
                                                          child: Text(
                                                            'Dt. Fechamento :',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .headlineMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Outfit',
                                                                  fontSize: 20,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  10, 20, 0, 0),
                                                          child: Text(
                                                            palete.isNotEmpty
                                                                ? palete[0].dtFechamento !=
                                                                        null
                                                                    ? DateFormat(
                                                                            'kk:mm   dd/MM/yyyy')
                                                                        .format(
                                                                            palete[0].dtFechamento!)
                                                                    : 'Palete aberto'
                                                                : 'Palete Aberto',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .headlineMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Outfit',
                                                                  fontSize: 20,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  inicial == false
                                                      ? palete.isNotEmpty
                                                          ? palete[0].dtFechamento !=
                                                                  null
                                                              ? Positioned(
                                                                  right: 5,
                                                                  top: 20,
                                                                  child:
                                                                      SizedBox(
                                                                    width: 100,
                                                                    height: 35,
                                                                    child:
                                                                        FloatingActionButton(
                                                                      onPressed:
                                                                          () async {
                                                                        await showCupertinoModalPopup(
                                                                          context:
                                                                              context,
                                                                          barrierDismissible:
                                                                              false,
                                                                          builder:
                                                                              (context) {
                                                                            return CupertinoAlertDialog(
                                                                              title: const Text('Reabrir Palete?'),
                                                                              content: const Text('Reabrir o palete fará com que os pedidos dentro dele possam ser alterados'),
                                                                              actions: <CupertinoDialogAction>[
                                                                                CupertinoDialogAction(
                                                                                    isDefaultAction: true,
                                                                                    isDestructiveAction: true,
                                                                                    onPressed: () async {
                                                                                      setState(() {
                                                                                        bd.reabrirPalete(cont);
                                                                                        getPalete = bd.paleteAll(cont, context);
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
                                                                      },
                                                                      backgroundColor: Colors
                                                                          .orange
                                                                          .shade400,
                                                                      elevation:
                                                                          8,
                                                                      child:
                                                                          const Text(
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        'Reabrir',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.w900,
                                                                          fontSize:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ))
                                                              : Container()
                                                          : Container()
                                                      : Container(),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment:
                                                  const AlignmentDirectional(
                                                      0, 0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                              10, 20, 0, 0),
                                                      child: Text(
                                                        'Dt. Carregamento :',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .headlineMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Outfit',
                                                                  fontSize: 20,
                                                                ),
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                              10, 20, 0, 0),
                                                      child: Text(
                                                        palete.isNotEmpty
                                                            ? palete[0].dtCarregamento !=
                                                                    null
                                                                ? DateFormat(
                                                                        'kk:mm   dd/MM/yyyy')
                                                                    .format(palete[
                                                                            0]
                                                                        .dtCarregamento!)
                                                                : 'Palete não carregado'
                                                            : 'Palete não carregado',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .headlineMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Outfit',
                                                                  fontSize: 20,
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
                                    ListView.builder(
                                      itemCount: (pedidos.length),
                                      primary: false,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemBuilder: (context, index) {
                                        if (inicial) {
                                          return Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(14, 10, 14, 10),
                                            child: Container(
                                              constraints: const BoxConstraints(
                                                maxWidth: 570,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
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
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                const TextSpan(
                                                                    text:
                                                                        'Nº Pedido\n',
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
                                                                      '${pedidos[index].ped}',
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Color(
                                                                        0xFF007000),
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
                                          );
                                        } else {
                                          if (pedidosExc
                                              .contains(pedidos[index])) {
                                            return Stack(
                                              fit: StackFit.passthrough,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          14, 10, 14, 10),
                                                  child: Container(
                                                    width: double.infinity,
                                                    constraints:
                                                        const BoxConstraints(
                                                      maxWidth: 570,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
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
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                RichText(
                                                                  text:
                                                                      TextSpan(
                                                                    children: [
                                                                      const TextSpan(
                                                                          text:
                                                                              'Nº Pedido\n',
                                                                          style:
                                                                              TextStyle(
                                                                            fontFamily:
                                                                                'Readex Pro',
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                            fontSize:
                                                                                18,
                                                                          )),
                                                                      TextSpan(
                                                                        text:
                                                                            '${pedidos[index].ped}',
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              Colors.red,
                                                                          fontWeight:
                                                                              FontWeight.w900,
                                                                          fontSize:
                                                                              24,
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
                                                  ),
                                                ),
                                                Positioned(
                                                  right: 20,
                                                  top: 15,
                                                  child: FloatingActionButton(
                                                    backgroundColor:
                                                        Colors.green,
                                                    onPressed: () {
                                                      setState(() {
                                                        pedidosExc.remove(
                                                            pedidos[index]);
                                                      });
                                                    },
                                                    child: const Icon(
                                                      Icons
                                                          .settings_backup_restore,
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
                                                          .fromSTEB(
                                                          14, 10, 14, 10),
                                                  child: Container(
                                                    width: double.infinity,
                                                    constraints:
                                                        const BoxConstraints(
                                                      maxWidth: 570,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey.shade300,
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
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                RichText(
                                                                  text:
                                                                      TextSpan(
                                                                    children: [
                                                                      const TextSpan(
                                                                          text:
                                                                              'Nº Pedido\n',
                                                                          style:
                                                                              TextStyle(
                                                                            fontFamily:
                                                                                'Readex Pro',
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                            fontSize:
                                                                                18,
                                                                          )),
                                                                      TextSpan(
                                                                        text:
                                                                            '${pedidos[index].ped}',
                                                                        style:
                                                                            TextStyle(
                                                                          color: Colors
                                                                              .green
                                                                              .shade700,
                                                                          fontWeight:
                                                                              FontWeight.w900,
                                                                          fontSize:
                                                                              24,
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
                                                  ),
                                                ),
                                                Positioned(
                                                  right: 20,
                                                  top: 15,
                                                  child: FloatingActionButton(
                                                    backgroundColor: Colors.red,
                                                    onPressed: () {
                                                      setState(() {
                                                        pedidosExc.add(
                                                            pedidos[index]);
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
          ],
        ),
      ),
    );
  }
}
