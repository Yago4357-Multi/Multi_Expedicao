import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:pdf/widgets.dart' as pw;

import '../Components/Model/lista_palete_model.dart';
import '../Components/Widget/drawer_widget.dart';
import '../Controls/banco.dart';
import '../Models/contagem.dart';
import '../Models/palete.dart';
import '../Models/usur.dart';

///Classe para manter a listagem dos paletes
class ListaPaleteWidget extends StatefulWidget {
  ///Classe para puxar o palete inicial da página
  final int cont;

  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///Variável para manter conexão com o Banco
  final Banco bd;

  ///Constutor para a página de listagem dos paletes
  const ListaPaleteWidget(this.usur,
      {super.key, required this.cont, required this.bd});

  @override
  State<ListaPaleteWidget> createState() =>
      _ListaPaleteWidgetState(cont, usur, bd);
}

class _ListaPaleteWidgetState extends State<ListaPaleteWidget> {
  ///Classe para puxar o palete inicial da página
  int cont;
  final Usuario usur;

  final pdf = pw.Document();

  final Banco bd;

  late Future<List<Paletes>> getPaletes;
  late List<Paletes> paletes;

  late StateSetter internalSetter;

  List<String> acessos = ['BI', 'Comercial', 'Logística'];
  List<String> acessosADM = ['BI'];
  List<String> acessosCol = ['Logística'];
  List<String> acessosPC = ['Comercial'];

  _ListaPaleteWidgetState(this.cont, this.usur, this.bd);

  ///Variáveis para mostrar erro no TextField
  Color corDica = Colors.green.shade400;
  Color corBorda = Colors.green.shade700;
  String dica = 'Procure um palete...';

  bool inicial = true;
  late ListaPaleteModel _model;

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
    rodarBanco();
    _model = createModel(context, ListaPaleteModel.new);
    _model.textController ??= TextEditingController();
  }

  void rodarBanco() async {
    getPaletes = bd.paletesFull();
    getPed = bd.selectPallet(cont, context);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_reset_outlined),
            onPressed: () async {
              getPed = bd.selectPallet(cont, context);
              getPalete = bd.paleteAll(cont, context);
              getPaletes = bd.paletesFull();
              setState(() {});
            },
            color: Colors.white,
          ),
          (acessosPC.contains(
              usur.acess) ||
              acessosADM.contains(
                  usur.acess))
              ?
          Padding(
            padding: const EdgeInsets.all(5),
            child: InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                if (inicial) {
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
                } else {
                  if (pedidosExc.isNotEmpty) {
                    await showCupertinoModalPopup(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: const Text('Deseja Continuar?'),
                          content: const Text(
                              'Para alterações dos paletes o ideal é fazer via coletor pela Logística'),
                          actions: <CupertinoDialogAction>[
                            CupertinoDialogAction(
                                isDefaultAction: true,
                                isDestructiveAction: true,
                                onPressed: () async {
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
                                                if (await bd
                                                        .connected(context) ==
                                                    1) {
                                                  if (pedidosExc.isNotEmpty) {
                                                    getPed = bd.excluiPedido(
                                                        pedidosExc, usur, cont);
                                                    pedidosExc = [];
                                                  }
                                                  setState(() {
                                                    inicial = true;
                                                    Navigator.pop(context);
                                                  });
                                                }
                                                setState(() {});
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
                }
              },
              child: Container(
                width: 100,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    inicial
                        ? Text(
                            'Editar',
                            style: FlutterFlowTheme.of(context)
                                .headlineSmall
                                .override(
                                    fontFamily: 'Readex Pro',
                                    color: Colors.white,
                                    fontSize: 15),
                          )
                        : Text(
                            'Salvar',
                            style: FlutterFlowTheme.of(context)
                                .headlineSmall
                                .override(
                                    fontFamily: 'Readex Pro',
                                    color: Colors.white,
                                    fontSize: 15),
                          ),
                    inicial
                        ? const Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                          )
                        : const Icon(
                            Icons.done,
                            color: Colors.white,
                          ),
                  ],
                ),
              ),
            ),
          ) : Container(),
          if (!inicial)
            Padding(
              padding:
                  const EdgeInsets.only(left: 15, top: 5, right: 5, bottom: 5),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  pedidosExc = [];
                  inicial = true;
                  setState(() {});
                },
                child: Container(
                  width: 100,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Cancelar',
                        style: FlutterFlowTheme.of(context)
                            .headlineSmall
                            .override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                fontSize: 15),
                      ),
                      const Icon(
                        Icons.cancel_outlined,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Container(),
        ],
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
                                            flex: 3,
                                            child: Align(
                                              alignment:
                                                  const AlignmentDirectional(
                                                      -1, 0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
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
                                                        'Nº Palete :',
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
                                                                  fontSize: 30,
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
                                                                  .circular(12),
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
                                                                  .circular(12),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .error,
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .error,
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                      ),
                                                      onSubmitted:
                                                          (value) async {
                                                        if (await bd.connected(
                                                                context) ==
                                                            1) {
                                                          if (await bd
                                                                  .selectPallet(
                                                                      int.parse(
                                                                          value),
                                                                      context) !=
                                                              []) {
                                                            cont = int.parse(
                                                                value);
                                                            if (context
                                                                .mounted) {
                                                              getPed = bd
                                                                  .selectPallet(
                                                                      cont,
                                                                      context);
                                                              if (context
                                                                  .mounted) {
                                                                getPalete = bd
                                                                    .paleteAll(
                                                                        cont,
                                                                        context);
                                                              }
                                                              setState(() {});
                                                            }
                                                          }
                                                        } else {
                                                          _model.textController!
                                                              .text = '';
                                                          setState(() {});
                                                        }
                                                        setState(() {});
                                                      },
                                                      controller:
                                                          _model.textController,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
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
                                          ),
                                          Expanded(flex: 3,
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
                                          Expanded(flex: 3,
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
                                                                            'dd/MM/yyyy   kk:mm')
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
                                                  (acessosPC.contains(
                                                              usur.acess) ||
                                                          acessosADM.contains(
                                                              usur.acess))
                                                      ? inicial == false
                                                          ? palete.isNotEmpty
                                                              ? palete[0].dtFechamento !=
                                                                          null &&
                                                                      palete[0]
                                                                              .dtCarregamento ==
                                                                          null
                                                                  ? Positioned(
                                                                      right: 5,
                                                                      top: 20,
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            100,
                                                                        height:
                                                                            35,
                                                                        child:
                                                                            FloatingActionButton(
                                                                          onPressed:
                                                                              () async {
                                                                            await showCupertinoModalPopup(
                                                                              context: context,
                                                                              barrierDismissible: false,
                                                                              builder: (context) {
                                                                                return CupertinoAlertDialog(
                                                                                  title: const Text('Reabrir Palete?'),
                                                                                  content: const Text('Reabrir o palete fará com que os pedidos dentro dele possam ser alterados'),
                                                                                  actions: <CupertinoDialogAction>[
                                                                                    CupertinoDialogAction(
                                                                                        isDefaultAction: true,
                                                                                        isDestructiveAction: true,
                                                                                        onPressed: () async {
                                                                                          if (await bd.connected(context) == 1) {
                                                                                            setState(() {
                                                                                              bd.reabrirPalete(cont);
                                                                                              getPalete = bd.paleteAll(cont, context);
                                                                                              Navigator.pop(context);
                                                                                            });
                                                                                          }
                                                                                          setState(() {});
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
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.w900,
                                                                              fontSize: 20,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ))
                                                                  : Container()
                                                              : Container()
                                                          : Container()
                                                      : Container(),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(flex: 3,
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
                                                                        'dd/MM/yyyy   kk:mm')
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
                                          Expanded(flex: 1, child: Padding(
                                            padding: const EdgeInsets.only(top: 50),
                                            child: Container(
                                              alignment: Alignment.center,
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
                                                          return FutureBuilder(
                                                            future: getPaletes,
                                                            builder: (context, snapshot) {
                                                              if (snapshot.connectionState == ConnectionState.done) {
                                                                paletes = snapshot.data!;
                                                                paletes.sort((a, b) => a.pallet!.compareTo(b.pallet!));
                                                                return StatefulBuilder(
                                                                  builder: (
                                                                      context,
                                                                      setter) {
                                                                    internalSetter =
                                                                        setter;
                                                                    return Dialog(
                                                                      backgroundColor: Colors
                                                                          .white,
                                                                      child: Stack(
                                                                        children: [
                                                                          Column(
                                                                            mainAxisSize:
                                                                            MainAxisSize
                                                                                .max,
                                                                            children: [
                                                                              Container(
                                                                                height: MediaQuery
                                                                                    .of(
                                                                                    context)
                                                                                    .size
                                                                                    .height *
                                                                                    0.1,
                                                                                width: MediaQuery
                                                                                    .of(
                                                                                    context)
                                                                                    .size
                                                                                    .width,
                                                                                decoration: const BoxDecoration(
                                                                                    color: Colors
                                                                                        .white,
                                                                                    borderRadius:
                                                                                    BorderRadiusDirectional
                                                                                        .vertical(
                                                                                        top: Radius
                                                                                            .circular(
                                                                                            20))),
                                                                                child: Align(
                                                                                  alignment:
                                                                                  Alignment
                                                                                      .center,
                                                                                  child: Text(
                                                                                    'Lista de Paletes',
                                                                                    textAlign: TextAlign
                                                                                        .center,
                                                                                    style: FlutterFlowTheme
                                                                                        .of(
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
                                                                                    .all(
                                                                                    10),
                                                                                width: double
                                                                                    .infinity,
                                                                                decoration:
                                                                                BoxDecoration(
                                                                                  color: FlutterFlowTheme
                                                                                      .of(
                                                                                      context)
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
                                                                                      .circular(
                                                                                      0),
                                                                                  shape: BoxShape
                                                                                      .rectangle,
                                                                                ),
                                                                                child: Container(
                                                                                  width:
                                                                                  double
                                                                                      .infinity,
                                                                                  height: 40,
                                                                                  decoration:
                                                                                  BoxDecoration(
                                                                                    color: FlutterFlowTheme
                                                                                        .of(
                                                                                        context)
                                                                                        .primaryBackground,
                                                                                    borderRadius:
                                                                                    BorderRadius
                                                                                        .circular(
                                                                                        12),
                                                                                  ),
                                                                                  alignment:
                                                                                  const AlignmentDirectional(
                                                                                      -1,
                                                                                      0),
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
                                                                                            style: FlutterFlowTheme
                                                                                                .of(
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
                                                                                            style: FlutterFlowTheme
                                                                                                .of(
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
                                                                                            style: FlutterFlowTheme
                                                                                                .of(
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
                                                                                            style: FlutterFlowTheme
                                                                                                .of(
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
                                                                                            style: FlutterFlowTheme
                                                                                                .of(
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
                                                                                            style: FlutterFlowTheme
                                                                                                .of(
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
                                                                                            style: FlutterFlowTheme
                                                                                                .of(
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
                                                                                            style: FlutterFlowTheme
                                                                                                .of(
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
                                                                                            style: FlutterFlowTheme
                                                                                                .of(
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
                                                                                width: MediaQuery
                                                                                    .of(
                                                                                    context)
                                                                                    .size
                                                                                    .width,
                                                                                height: MediaQuery
                                                                                    .of(
                                                                                    context)
                                                                                    .size
                                                                                    .height *
                                                                                    0.7,
                                                                                child: ListView
                                                                                    .builder(
                                                                                  shrinkWrap: true,
                                                                                  physics:
                                                                                  const AlwaysScrollableScrollPhysics(),
                                                                                  scrollDirection:
                                                                                  Axis
                                                                                      .vertical,
                                                                                  padding:
                                                                                  EdgeInsets
                                                                                      .zero,
                                                                                  itemCount:
                                                                                  paletes
                                                                                      .length,
                                                                                  itemBuilder:
                                                                                      (
                                                                                      context,
                                                                                      index) {
                                                                                    if (cont ==
                                                                                        paletes[index]
                                                                                            .pallet) {
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
                                                                                                  .connected(
                                                                                                  context) ==
                                                                                                  1) {
                                                                                                setter(
                                                                                                      () {
                                                                                                    cont =
                                                                                                    paletes[index]
                                                                                                        .pallet!;
                                                                                                    setState(
                                                                                                            () {
                                                                                                          cont =
                                                                                                          paletes[index]
                                                                                                              .pallet!;
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
                                                                                                      Colors
                                                                                                          .green
                                                                                                          .shade400,
                                                                                                      borderRadius:
                                                                                                      BorderRadius
                                                                                                          .circular(
                                                                                                          2),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Expanded(
                                                                                                    child:
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          12,
                                                                                                          0,
                                                                                                          0,
                                                                                                          0),
                                                                                                      child:
                                                                                                      Text(
                                                                                                        '${paletes[index]
                                                                                                            .pallet}',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelLarge
                                                                                                            .override(
                                                                                                          fontFamily: 'Readex Pro',
                                                                                                          letterSpacing: 0,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Expanded(
                                                                                                    child:
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          12,
                                                                                                          0,
                                                                                                          0,
                                                                                                          0),
                                                                                                      child:
                                                                                                      Text(
                                                                                                        '${paletes[index]
                                                                                                            .volumetria}',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelLarge
                                                                                                            .override(
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
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          12,
                                                                                                          0,
                                                                                                          0,
                                                                                                          0),
                                                                                                      child:
                                                                                                      Text(
                                                                                                        '${paletes[index]
                                                                                                            .romaneio ??
                                                                                                            ''}',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelLarge
                                                                                                            .override(
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
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          12,
                                                                                                          0,
                                                                                                          0,
                                                                                                          0),
                                                                                                      child:
                                                                                                      Text(
                                                                                                        '${paletes[index]
                                                                                                            .UsurInclusao}',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelLarge
                                                                                                            .override(
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
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          12,
                                                                                                          0,
                                                                                                          0,
                                                                                                          0),
                                                                                                      child:
                                                                                                      Text(
                                                                                                        DateFormat(
                                                                                                            'dd/MM/yyyy   kk:mm')
                                                                                                            .format(
                                                                                                            paletes[index]
                                                                                                                .dtInclusao!),
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelLarge
                                                                                                            .override(
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
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          12,
                                                                                                          0,
                                                                                                          0,
                                                                                                          0),
                                                                                                      child:
                                                                                                      Text(
                                                                                                        paletes[index]
                                                                                                            .UsurFechamento ??
                                                                                                            '',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelLarge
                                                                                                            .override(
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
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          12,
                                                                                                          0,
                                                                                                          0,
                                                                                                          0),
                                                                                                      child:
                                                                                                      Text(
                                                                                                        paletes[index]
                                                                                                            .dtFechamento !=
                                                                                                            null
                                                                                                            ? DateFormat(
                                                                                                            'dd/MM/yyyy   kk:mm')
                                                                                                            .format(
                                                                                                            paletes[index]
                                                                                                                .dtFechamento!)
                                                                                                            : '',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelLarge
                                                                                                            .override(
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
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          12,
                                                                                                          0,
                                                                                                          0,
                                                                                                          0),
                                                                                                      child:
                                                                                                      Text(
                                                                                                        paletes[index]
                                                                                                            .UsurCarregamento ??
                                                                                                            '',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelLarge
                                                                                                            .override(
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
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          12,
                                                                                                          0,
                                                                                                          0,
                                                                                                          0),
                                                                                                      child:
                                                                                                      Text(
                                                                                                        paletes[index]
                                                                                                            .dtCarregamento !=
                                                                                                            null
                                                                                                            ? DateFormat(
                                                                                                            'dd/MM/yyyy   kk:mm')
                                                                                                            .format(
                                                                                                            paletes[index]
                                                                                                                .dtCarregamento!)
                                                                                                            : '',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelLarge
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
                                                                                        ),
                                                                                      );
                                                                                    } else {
                                                                                      return Padding(
                                                                                        padding: const EdgeInsetsDirectional
                                                                                            .fromSTEB(
                                                                                            0,
                                                                                            0,
                                                                                            0,
                                                                                            1),
                                                                                        child: Container(
                                                                                          width: double
                                                                                              .infinity,
                                                                                          decoration: BoxDecoration(
                                                                                            color: FlutterFlowTheme
                                                                                                .of(
                                                                                                context)
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
                                                                                            borderRadius: BorderRadius
                                                                                                .circular(
                                                                                                0),
                                                                                            shape: BoxShape
                                                                                                .rectangle,
                                                                                          ),
                                                                                          child: InkWell(
                                                                                            onTap: () async {
                                                                                              if (await bd
                                                                                                  .connected(
                                                                                                  context) ==
                                                                                                  1) {
                                                                                                setter(
                                                                                                      () {
                                                                                                    cont =
                                                                                                    paletes[index]
                                                                                                        .pallet!;
                                                                                                    setState(() {
                                                                                                      cont =
                                                                                                      paletes[index]
                                                                                                          .pallet!;
                                                                                                    });
                                                                                                  },
                                                                                                );
                                                                                              }
                                                                                              setState(() {});
                                                                                            },
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsets
                                                                                                  .all(
                                                                                                  8),
                                                                                              child: Row(
                                                                                                mainAxisSize: MainAxisSize
                                                                                                    .max,
                                                                                                children: [
                                                                                                  Container(
                                                                                                    width: 4,
                                                                                                    height: 50,
                                                                                                    decoration: BoxDecoration(
                                                                                                      color: FlutterFlowTheme
                                                                                                          .of(
                                                                                                          context)
                                                                                                          .alternate,
                                                                                                      borderRadius: BorderRadius
                                                                                                          .circular(
                                                                                                          2),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Expanded(
                                                                                                    child: Padding(
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          12,
                                                                                                          0,
                                                                                                          0,
                                                                                                          0),
                                                                                                      child: Text(
                                                                                                        '${paletes[index]
                                                                                                            .pallet}',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelLarge
                                                                                                            .override(
                                                                                                          fontFamily: 'Readex Pro',
                                                                                                          letterSpacing: 0,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Expanded(
                                                                                                    child: Padding(
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          12,
                                                                                                          0,
                                                                                                          0,
                                                                                                          0),
                                                                                                      child: Text(
                                                                                                        '${paletes[index]
                                                                                                            .volumetria}',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelLarge
                                                                                                            .override(
                                                                                                          fontFamily: 'Readex Pro',
                                                                                                          letterSpacing: 0,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Expanded(
                                                                                                    child: Padding(
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          12,
                                                                                                          0,
                                                                                                          0,
                                                                                                          0),
                                                                                                      child: Text(
                                                                                                        '${paletes[index]
                                                                                                            .romaneio ??
                                                                                                            ''}',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelLarge
                                                                                                            .override(
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
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          12,
                                                                                                          0,
                                                                                                          0,
                                                                                                          0),
                                                                                                      child: Text(
                                                                                                        '${paletes[index]
                                                                                                            .UsurInclusao}',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelLarge
                                                                                                            .override(
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
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          12,
                                                                                                          0,
                                                                                                          0,
                                                                                                          0),
                                                                                                      child: Text(
                                                                                                        DateFormat(
                                                                                                            'dd/MM/yyyy   kk:mm')
                                                                                                            .format(
                                                                                                            paletes[index]
                                                                                                                .dtInclusao!),
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelLarge
                                                                                                            .override(
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
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          12,
                                                                                                          0,
                                                                                                          0,
                                                                                                          0),
                                                                                                      child: Text(
                                                                                                        paletes[index]
                                                                                                            .UsurFechamento ??
                                                                                                            '',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelLarge
                                                                                                            .override(
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
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          12,
                                                                                                          0,
                                                                                                          0,
                                                                                                          0),
                                                                                                      child: Text(
                                                                                                        paletes[index]
                                                                                                            .dtFechamento !=
                                                                                                            null
                                                                                                            ? DateFormat(
                                                                                                            'dd/MM/yyyy   kk:mm')
                                                                                                            .format(
                                                                                                            paletes[index]
                                                                                                                .dtFechamento!)
                                                                                                            : '',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelLarge
                                                                                                            .override(
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
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          12,
                                                                                                          0,
                                                                                                          0,
                                                                                                          0),
                                                                                                      child: Text(
                                                                                                        paletes[index]
                                                                                                            .UsurCarregamento ??
                                                                                                            '',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelLarge
                                                                                                            .override(
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
                                                                                                      padding: const EdgeInsetsDirectional
                                                                                                          .fromSTEB(
                                                                                                          12,
                                                                                                          0,
                                                                                                          0,
                                                                                                          0),
                                                                                                      child: Text(
                                                                                                        paletes[index]
                                                                                                            .dtCarregamento !=
                                                                                                            null
                                                                                                            ? DateFormat(
                                                                                                            'dd/MM/yyyy   kk:mm')
                                                                                                            .format(
                                                                                                            paletes[index]
                                                                                                                .dtCarregamento!)
                                                                                                            : '',
                                                                                                        style: FlutterFlowTheme
                                                                                                            .of(
                                                                                                            context)
                                                                                                            .labelLarge
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
                                                                                        ),
                                                                                      );
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                  child: Container(
                                                                                    decoration: const BoxDecoration(
                                                                                        color: Colors
                                                                                            .white,
                                                                                        borderRadius: BorderRadius
                                                                                            .only(
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
                                                                                      Colors
                                                                                          .green,
                                                                                      borderRadius:
                                                                                      BorderRadius
                                                                                          .circular(
                                                                                          10)),
                                                                                  width: 50,
                                                                                  height: 50,
                                                                                  child: IconButton(
                                                                                    onPressed:
                                                                                        () async {

                                                                                          if (await bd.connected(
                                                                                              context) ==
                                                                                              1) {
                                                                                            print(cont);
                                                                                            if (await bd
                                                                                                .selectPallet(
                                                                                                cont,
                                                                                                context) !=
                                                                                                []) {
                                                                                              if (context
                                                                                                  .mounted) {
                                                                                                getPed = bd
                                                                                                    .selectPallet(
                                                                                                    cont,
                                                                                                    context);
                                                                                                if (context
                                                                                                    .mounted) {
                                                                                                  getPalete = bd
                                                                                                      .paleteAll(
                                                                                                      cont,
                                                                                                      context);
                                                                                                }
                                                                                                Navigator.pop(context);
                                                                                                setState(() {});
                                                                                              }
                                                                                            }
                                                                                          } else {
                                                                                            _model.textController!
                                                                                                .text = '';
                                                                                            setState(() {});
                                                                                          }
                                                                                          setState(() {});
                                                                                      setState(() {

                                                                                      });
                                                                                    },
                                                                                    icon: const Icon(
                                                                                        Icons
                                                                                            .youtube_searched_for,
                                                                                        color: Colors
                                                                                            .white),
                                                                                  )))
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              } else {
                                                                return const CircularProgressIndicator();
                                                              }
                                                            },
                                                          );
                                                        },
                                                      );
                                                    }
                                                  },
                                                  icon: const Icon(Icons.search_rounded),
                                                  color: Colors.white,
                                                )),
                                          ))
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
                                                        width: 4,
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
                                                                const Text(
                                                                    'Nº Pedido',
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
                                                                      wordSpacing:
                                                                          0,
                                                                    )),
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .red
                                                                          .shade100,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              4)),
                                                                  width: 140,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top: 5),
                                                                    child: Text(
                                                                      '${pedidos[index].ped}',
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
                                                                                Colors.red.shade500,
                                                                            fontSize:
                                                                                24,
                                                                            fontWeight:
                                                                                FontWeight.w800,
                                                                          ),
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
                                                                  const EdgeInsets
                                                                      .all(20),
                                                              child: Text(
                                                                'Caixa será \nexclúida !!',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleLarge
                                                                    .override(
                                                                        fontFamily:
                                                                            'Readex Pro',
                                                                        color: Colors
                                                                            .red),
                                                              )),
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
