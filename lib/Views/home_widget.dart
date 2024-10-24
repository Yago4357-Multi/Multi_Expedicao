import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Components/Model/home_model.dart';
import '../Components/Widget/atualizacao.dart';
import '../Components/Widget/drawer_widget.dart';
import '../Controls/banco.dart';
import '../FlutterFlowTheme.dart';
import '../Models/contagem.dart';
import '../Models/usur.dart';
import 'carregamento_widget.dart';
import 'declaracoes.dart';
import 'deletar_pedido_widget.dart';
import 'escolha_conferencia_widget.dart';
import 'escolha_romaneio_widget.dart';
import 'lista_cancelados.dart';
import 'lista_faturados.dart';
import 'lista_palete_widget.dart';
import 'lista_pedido_widget.dart';
import 'reimprimir_palete_widget.dart';

///Página inicial do Aplicativo
class HomeWidget extends StatefulWidget {

  ///Variável para manter conexão com o Banco
  final Banco bd;

  ///Construtor da página inicial
  const HomeWidget({super.key, required this.bd});

  @override
  State<HomeWidget> createState() => _HomeWidgetState(bd);
}

class _HomeWidgetState extends State<HomeWidget> with TickerProviderStateMixin {
  Banco bd;

  late var prefs;

  late int hour = DateTime.now().toLocal().hour;
  late String hora = 'Bom dia';

  _HomeWidgetState(this.bd);

  late Future<int> qtdFatFut;
  late Future<int> qtdCancFut;
  int qtdFat = 0;
  int qtdCanc = 0;

  late HomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = {
    'containerOnPageLoadAnimation4': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effectsBuilder: () => [
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 300.ms,
          begin: 0,
          end: 1,
        ),
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 300.ms,
          begin: const Offset(0, 20),
          end: const Offset(0, 0),
        ),
        TiltEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 300.ms,
          begin: const Offset(0.698, 0),
          end: const Offset(0, 0),
        ),
      ],
    ),
  };

  late Usuario usur;

  late String permissao;
  late String nome;
  late bool logado;

  List<String> acessos = ['BI', 'Comercial', 'Logística'];
  List<String> acessosADM = ['BI'];
  List<String> acessosCol = ['Logística'];
  List<String> acessosPC = ['Comercial'];

  bool carregado = false;

  late List<Contagem> pedidos;

  @override
  void initState() {
    super.initState();
    rodarBanco();
    _model = createModel(context, HomePageModel.new);
    setupAnimations(
      animationsMap.values.where((anim) =>
      anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );
  }

  Future<void> rodarBanco() async {
    prefs = await SharedPreferences.getInstance();
    logado = await prefs.getBool('logado') ?? false;
    if (logado) {
      qtdCanc = await bd.qtdCanc();
      qtdFat = await bd.qtdFat();
      await prefs.setString('ultPag', '/Home');
      permissao = await prefs.getString('Permissão');
      nome = await prefs.getString('Usuario');
      usur = Usuario(1, permissao, nome);
    } else {
      await Navigator.popAndPushNamed(context, '/');
    }
    print('aaaaaaaa');
    carregado = true;
    setState(() {});
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (carregado) {
      return GestureDetector(
        onTap: () => _model.unfocusNode.canRequestFocus
            ? FocusScope.of(context).requestFocus(_model.unfocusNode)
            : FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          drawer: Drawer(
            elevation: 16,
            child: wrapWithModel(
                model: _model.drawerModel,
                updateCallback: () => setState(() {}),
                child: DrawerWidget(
                  usur: usur,
                  context: context,
                  bd: bd,
                )),
          ),
          appBar: AppBar(
            backgroundColor: const Color(0xFF007000),
            automaticallyImplyLeading: false,
            leadingWidth: 400,
            leading: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                FlutterFlowIconButton(
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
                if (responsiveVisibility(
                  context: context,
                  phone: false,
                  tablet: false,
                ))
                  (qtdFat > 0)
                      ? Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: SizedBox(
                              width: 120,
                              height: 50,
                              child: Row(children: [
                                Text(
                                  'Fat.: $qtdFat',
                                  style: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 16,
                                          color: Colors.red),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ListaFaturadosWidget(usur,
                                                  bd: bd),
                                        ));
                                  },
                                  icon: const Icon(
                                    Icons.assignment_late,
                                    color: Colors.red,
                                  ),
                                )
                              ])))
                      : Container(),
                if (responsiveVisibility(
                  context: context,
                  phone: false,
                  tablet: false,
                ))
                  (qtdCanc > 0)
                      ? Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: SizedBox(
                              width: 120,
                              height: 50,
                              child: Row(children: [
                                Text('Canc. : $qtdCanc',
                                    style: FlutterFlowTheme.of(context)
                                        .headlineSmall
                                        .override(
                                            fontFamily: 'Readex Pro',
                                            fontSize: 16,
                                            color: Colors.orange)),
                                IconButton(
                                  onPressed: () async {
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ListaCanceladosWidget(usur,
                                                  bd: bd),
                                        ));
                                  },
                                  icon: const Icon(
                                    Icons.assignment_late,
                                    color: Colors.orange,
                                  ),
                                )
                              ])))
                      : Container(),
              ],
            ),
            title: Text(
              'Home Page',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: 'Outfit',
                    color: FlutterFlowTheme.of(context).primaryBackground,
                  ),
            ),
            actions: const [],
            centerTitle: true,
            elevation: 2,
          ),
          body: SafeArea(
            top: true,
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height *
                          ((responsiveVisibility(
                                  context: context,
                                  phone: false,
                                  tablet: false,
                                  desktop: true))
                              ? 0.2
                              : 0.23),
                      color: Colors.white,
                      alignment: AlignmentDirectional.centerStart,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 30, 0, 0),
                            child: RichText(
                              text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text:
                                            '$hora, \n  ${prefs.getString('Usuario')}',
                                        style: FlutterFlowTheme.of(context)
                                            .headlineLarge)
                                  ],
                                  style: FlutterFlowTheme.of(context)
                                      .headlineLarge),
                            ),
                          ),
                        ],
                      ),
                    ),
                      SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height *
                          ((responsiveVisibility(
                                  context: context,
                                  phone: false,
                                  tablet: false,
                                  desktop: true))
                              ? 0.7
                              : 0.62),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        physics: const PageScrollPhysics(),
                        primary: true,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: ((responsiveVisibility(
                                  context: context,
                                  phone: false,
                                  tablet: false,
                                  desktop: true))
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.center),
                          children: [
                            Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        40, 20, 0, 10),
                                    child: Text(
                                      'Tarefas',
                                      style: FlutterFlowTheme.of(context)
                                          .headlineMedium,
                                    ))),
                            Divider(
                              height: 12,
                              thickness: 2,
                              color: FlutterFlowTheme.of(context).alternate,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20, left: 20),
                              child: ((responsiveVisibility(
                                      context: context,
                                      phone: false,
                                      tablet: false,
                                      desktop: true))
                                  ? SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          if (acessosCol.contains(permissao) ||
                                              acessosADM.contains(permissao))
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EscolhaBipagemWidget(
                                                              usur,
                                                              bd: bd),
                                                    ));
                                              },
                                              child: (Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10),
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.3,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.2,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        Icons.space_dashboard,
                                                      ),
                                                      Container(
                                                        height: 20,
                                                        color: Colors.white,
                                                      ),
                                                      Text(
                                                        'Conferência',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleLarge,
                                                        textAlign:
                                                            TextAlign.center,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )),
                                            ),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EscolhaRomaneioWidget(
                                                            usur,
                                                            bd: bd),
                                                  ));
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Container(
                                                alignment: Alignment.center,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.2,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(Icons.list),
                                                    Container(
                                                      height: 20,
                                                      color: Colors.white,
                                                    ),
                                                    Text('Romaneio',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleLarge,
                                                        textAlign:
                                                            TextAlign.center)
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ListaCarregamentoWidget(
                                                            usur,
                                                            bd: bd),
                                                  ));
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Container(
                                                alignment: Alignment.center,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.2,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                        Icons.move_up_outlined),
                                                    Container(
                                                      height: 20,
                                                      color: Colors.white,
                                                    ),
                                                    Text('Carregamento',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleLarge,
                                                        textAlign:
                                                            TextAlign.center)
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (acessosCol.contains(permissao) ||
                                            acessosADM.contains(permissao))
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EscolhaBipagemWidget(
                                                            usur,
                                                            bd: bd),
                                                  ));
                                            },
                                            child: (Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10,
                                                  bottom: 10,
                                                  right: 20),
                                              child: Container(
                                                alignment: Alignment.center,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.8,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.1,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(width: 20),
                                                    const Icon(
                                                      Icons.space_dashboard,
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Conferência',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleLarge,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        decoration: const BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        20),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        20))),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )),
                                          ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EscolhaRomaneioWidget(
                                                          usur,
                                                          bd: bd),
                                                ));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, bottom: 10, right: 20),
                                            child: Container(
                                              alignment: Alignment.center,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.8,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.1,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(width: 20),
                                                  const Icon(Icons.list),
                                                  Expanded(
                                                    child: Container(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Romaneio',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .titleLarge,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      decoration: const BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          20),
                                                                  bottomRight:
                                                                      Radius.circular(
                                                                          20))),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ListaCarregamentoWidget(
                                                          usur,
                                                          bd: bd),
                                                ));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, bottom: 10, right: 20),
                                            child: Container(
                                              alignment: Alignment.center,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.8,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.1,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(width: 20),
                                                  const Icon(
                                                      Icons.move_up_outlined),
                                                  Expanded(
                                                    child: Container(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Carregamento',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .titleLarge,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      decoration: const BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          20),
                                                                  bottomRight:
                                                                      Radius.circular(
                                                                          20))),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                            ),
                            Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        40, 20, 0, 10),
                                    child: Text(
                                      'Listagem',
                                      style: FlutterFlowTheme.of(context)
                                          .headlineMedium,
                                    ))),
                            Divider(
                              height: 12,
                              thickness: 2,
                              color: FlutterFlowTheme.of(context).alternate,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20, left: 20),
                              child: (responsiveVisibility(
                                      context: context,
                                      phone: false,
                                      tablet: false,
                                      desktop: true))
                                  ? SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        child: Row(
                                          children: [
                                            if (acessosPC.contains(permissao) ||
                                                acessosADM.contains(permissao))
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ListaPedidoWidget(
                                                                cont: 0,
                                                                usur,
                                                                bd: bd),
                                                      ));
                                                },
                                                child: (Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10, right: 10),
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.3,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.2,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(Icons
                                                            .request_page_outlined),
                                                        Container(
                                                          height: 20,
                                                          color: Colors.white,
                                                        ),
                                                        Text(
                                                          'Pedidos',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .titleLarge,
                                                          textAlign:
                                                              TextAlign.center,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )),
                                              ),
                                            if (acessosPC.contains(permissao) ||
                                                acessosADM.contains(permissao))
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ListaPaleteWidget(
                                                                cont: 0,
                                                                usur,
                                                                bd: bd),
                                                      ));
                                                },
                                                child: (Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10, right: 10),
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.3,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.2,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        FaIcon(
                                                          FontAwesomeIcons
                                                              .pallet,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          size: 24,
                                                        ),
                                                        Container(
                                                          height: 20,
                                                          color: Colors.white,
                                                        ),
                                                        Text('Paletes',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleLarge,
                                                            textAlign: TextAlign
                                                                .center)
                                                      ],
                                                    ),
                                                  ),
                                                )),
                                              ),
                                            (acessosPC.contains(permissao) ||
                                                    acessosADM
                                                        .contains(permissao))
                                                ? InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    focusColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    onTap: () async {
                                                      await Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                ListaFaturadosWidget(
                                                                    usur,
                                                                    bd: bd),
                                                          ));
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10),
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.3,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.2,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const Icon(Icons
                                                                .fact_check_outlined),
                                                            Container(
                                                              height: 20,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            Text(
                                                                'Faturados não Bipados',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleLarge,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center)
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(
                                                    width: 0,
                                                    height: 0,
                                                  ),
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ListaCanceladosWidget(
                                                              usur,
                                                              bd: bd),
                                                    ));
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10),
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.3,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.2,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(Icons
                                                          .free_cancellation_outlined),
                                                      Container(
                                                        height: 20,
                                                        color: Colors.white,
                                                      ),
                                                      Text(
                                                          'Cancelados já Bipados',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .titleLarge,
                                                          textAlign:
                                                              TextAlign.center)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (acessosPC.contains(permissao) ||
                                            acessosADM.contains(permissao))
                                          InkWell(
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
                                                            cont: 0,
                                                            usur,
                                                            bd: bd),
                                                  ));
                                            },
                                            child: (Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10,
                                                  top: 10,
                                                  right: 20),
                                              child: Container(
                                                alignment: Alignment.center,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.8,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.1,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(width: 20),
                                                    const Icon(Icons
                                                        .request_page_outlined),
                                                    Expanded(
                                                      child: Container(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Pedidos',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleLarge,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        decoration: const BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        20),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        20))),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                          ),
                                        if (acessosPC.contains(permissao) ||
                                            acessosADM.contains(permissao))
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ListaPaleteWidget(
                                                            cont: 0,
                                                            usur,
                                                            bd: bd),
                                                  ));
                                            },
                                            child: (Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10,
                                                  top: 10,
                                                  right: 20),
                                              child: Container(
                                                alignment: Alignment.center,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.8,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.1,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(width: 20),
                                                    FaIcon(
                                                      FontAwesomeIcons.pallet,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      size: 24,
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Paletes',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleLarge,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        decoration: const BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        20),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        20))),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                          ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ListaFaturadosWidget(usur,
                                                          bd: bd),
                                                ));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10, top: 10, right: 20),
                                            child: Container(
                                              alignment: Alignment.center,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.8,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.1,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(width: 20),
                                                  const Icon(Icons
                                                      .fact_check_outlined),
                                                  Expanded(
                                                    child: Container(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Fat. não Bipados',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .titleLarge,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      decoration: const BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          20),
                                                                  bottomRight:
                                                                      Radius.circular(
                                                                          20))),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ListaCanceladosWidget(
                                                          usur,
                                                          bd: bd),
                                                ));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10, top: 10, right: 20),
                                            child: Container(
                                              alignment: Alignment.center,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.8,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.1,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(width: 20),
                                                  const Icon(Icons
                                                      .free_cancellation_outlined),
                                                  Expanded(
                                                    child: Container(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Canc. já Bipados',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .titleLarge,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      decoration: const BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          20),
                                                                  bottomRight:
                                                                      Radius.circular(
                                                                          20))),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        40, 20, 0, 10),
                                    child: Text(
                                      'Manutenção',
                                      style: FlutterFlowTheme.of(context)
                                          .headlineMedium,
                                    ))),
                            Divider(
                              height: 12,
                              thickness: 2,
                              color: FlutterFlowTheme.of(context).alternate,
                            ),
                            Padding(
                                padding:
                                    const EdgeInsets.only(top: 20, left: 20),
                                child: (responsiveVisibility(
                                        context: context,
                                        phone: false,
                                        tablet: false,
                                        desktop: true))
                                    ? Row(
                                        children: [
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ReimprimirPaleteWidget(
                                                              usur, 0,
                                                              bd: bd)));
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Container(
                                                alignment: Alignment.center,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.2,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                        Icons.print_rounded),
                                                    Container(
                                                      height: 20,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      'Reimpressão',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleLarge,
                                                      textAlign:
                                                          TextAlign.center,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          DeclaracoesWidget(
                                                              usur,
                                                              bd: bd)));
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Container(
                                                alignment: Alignment.center,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.2,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                        Icons.document_scanner),
                                                    Container(
                                                      height: 20,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      'Declarações',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleLarge,
                                                      textAlign:
                                                          TextAlign.center,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (acessosPC.contains(permissao) ||
                                              acessosADM.contains(permissao))
                                            (InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                prefs.setString(
                                                    'ultPag', '/Atualizar');
                                                await Navigator.popAndPushNamed(
                                                    context, '/Atualizar',
                                                    arguments: {
                                                      bd: bd,
                                                      usur: usur
                                                    });
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10),
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.3,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.2,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(Icons.refresh),
                                                      Container(
                                                        height: 20,
                                                        color: Colors.white,
                                                      ),
                                                      Text(
                                                        'Atualizar',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleLarge,
                                                        textAlign:
                                                            TextAlign.center,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )),
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          DeletarPedidoWidget(
                                                              usur,
                                                              bd: bd)));
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10,
                                                  top: 10,
                                                  right: 20),
                                              child: Container(
                                                alignment: Alignment.center,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.8,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.1,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(width: 20),
                                                    const Icon(Icons
                                                        .delete_sweep_outlined),
                                                    Expanded(
                                                      child: Container(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Deletar Caixa',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleLarge,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        decoration: const BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        20),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        20))),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ReimprimirPaleteWidget(
                                                              usur, 0,
                                                              bd: bd)));
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10,
                                                  top: 10,
                                                  right: 20),
                                              child: Container(
                                                alignment: Alignment.center,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.8,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.1,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(width: 20),
                                                    const Icon(
                                                        Icons.print_rounded),
                                                    Expanded(
                                                      child: Container(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Reimpressão',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleLarge,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        decoration: const BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        20),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        20))),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                          ],
                        ),
                      ),
                    ),
                  ],
                  ),
                Positioned(
                    right: 0,
                    bottom: 0,
                    child: AtualizacaoWidget(
                      bd: bd,
                      context: context,
                      usur: usur,
                    ))
              ],
            ),
          ),
        ),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }
}
