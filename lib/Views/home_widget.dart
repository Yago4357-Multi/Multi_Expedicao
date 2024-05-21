import 'package:Multi_Romaneio/Views/reimprimir_palete_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Components/Model/home_model.dart';
import '../Components/Widget/drawer_widget.dart';
import '../Controls/banco.dart';
import '../Controls/excel.dart';
import '../Models/contagem.dart';
import '../Models/usur.dart';
import 'carregamento_widget.dart';
import 'escolha_conferencia_widget.dart';
import 'escolha_romaneio_widget.dart';
import 'lista_faturados.dart';
import 'lista_palete_widget.dart';
import 'lista_pedido_widget.dart';
import 'lista_romaneios.dart';

///Página inicial do Aplicativo
class HomeWidget extends StatefulWidget {
  ///Variável para definir permissões do usuário
  final Usuario usur;

  final Banco bd;

  ///Construtor da página inicial
  const HomeWidget(this.usur, {super.key, required this.bd});

  @override
  State<HomeWidget> createState() => _HomeWidgetState(this.usur, this.bd);
}

class _HomeWidgetState extends State<HomeWidget> with TickerProviderStateMixin {
  final ExcelClass excel = ExcelClass();

  final Usuario acess;

  final Banco bd;

  late int hour = DateTime.now().toLocal().hour;
  late String hora;

  _HomeWidgetState(this.acess, this.bd);

  late HomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = {
    'containerOnPageLoadAnimation4': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
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

  List<String> acessos = ['BI', 'Comercial', 'Logística'];
  List<String> acessosADM = ['BI'];
  List<String> acessosCol = ['Logística'];
  List<String> acessosPC = ['Comercial'];

  late Future<List<Contagem>> getPed;
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

  void rodarBanco() async {
    getPed = bd.selectAll();
    if (hour < 12) {
      hora = 'Bom dia ';
    } else {
      hora = 'Boa tarde ';
    }
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        drawer: Drawer(
          elevation: 16,
          child: wrapWithModel(
              model: _model.drawerModel,
              updateCallback: () => setState(() {}),
              child: DrawerWidget(
                usur: acess,
                context: context,
                bd: bd,
              )),
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
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.2,
                color: Colors.white,
                alignment: AlignmentDirectional.centerStart,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 30, 0, 0),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: '$hora, ${acess.nome}',
                              style: FlutterFlowTheme.of(context).headlineLarge)
                        ], style: FlutterFlowTheme.of(context).headlineLarge),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.745,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(40, 20, 0, 10),
                              child: Text(
                                'Tarefas',
                                style:
                                    FlutterFlowTheme.of(context).headlineMedium,
                              ))),
                      Divider(
                        height: 12,
                        thickness: 2,
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, left: 20),
                        child: Row(
                          children: [
                            if (acessosCol.contains(acess.acess) ||
                                acessosADM.contains(acess.acess))
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  Navigator.pop(context);
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EscolhaBipagemWidget(acess, bd: bd),
                                      ));
                                },
                                child: (Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          style: FlutterFlowTheme.of(context)
                                              .titleLarge,
                                          textAlign: TextAlign.center,
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
                                Navigator.pop(context);
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EscolhaRomaneioWidget(acess, bd: bd),
                                    ));
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.list),
                                      Container(
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                      Text('Romaneio',
                                          style: FlutterFlowTheme.of(context)
                                              .titleLarge,
                                          textAlign: TextAlign.center)
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
                                Navigator.pop(context);
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ListaCarregamentoWidget(acess,
                                              bd: bd),
                                    ));
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.move_up_outlined),
                                      Container(
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                      Text('Carregamento',
                                          style: FlutterFlowTheme.of(context)
                                              .titleLarge,
                                          textAlign: TextAlign.center)
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
                              padding: const EdgeInsets.fromLTRB(40, 20, 0, 10),
                              child: Text(
                                'Listagem',
                                style:
                                    FlutterFlowTheme.of(context).headlineMedium,
                              ))),
                      Divider(
                        height: 12,
                        thickness: 2,
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, left: 20),
                        child: Row(
                          children: [
                            if (acessosPC.contains(acess.acess) ||
                                acessosADM.contains(acess.acess))
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  Navigator.pop(context);
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ListaPedidoWidget(
                                            cont: 0, acess, bd: bd),
                                      ));
                                },
                                child: (Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.request_page_outlined),
                                        Container(
                                          height: 20,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          'Pedidos',
                                          style: FlutterFlowTheme.of(context)
                                              .titleLarge,
                                          textAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                              ),
                            if (acessosPC.contains(acess.acess) ||
                                acessosADM.contains(acess.acess))
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  Navigator.pop(context);
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ListaPaleteWidget(
                                            cont: 0, acess, bd: bd),
                                      ));
                                },
                                child: (Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.pallet,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 24,
                                        ),
                                        Container(
                                          height: 20,
                                          color: Colors.white,
                                        ),
                                        Text('Paletes',
                                            style: FlutterFlowTheme.of(context)
                                                .titleLarge,
                                            textAlign: TextAlign.center)
                                      ],
                                    ),
                                  ),
                                )),
                              ),
                            if (acessosPC.contains(acess.acess) ||
                                acessosADM.contains(acess.acess))
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  Navigator.pop(context);
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ListaRomaneiosWidget(acess, bd: bd),
                                      ));
                                },
                                child: (Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.history_edu),
                                        Container(
                                          height: 20,
                                          color: Colors.white,
                                        ),
                                        Text('Romaneios',
                                            style: FlutterFlowTheme.of(context)
                                                .titleLarge,
                                            textAlign: TextAlign.center)
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
                                Navigator.pop(context);
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ListaFaturadosWidget(acess, bd: bd),
                                    ));
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.fact_check_outlined),
                                      Container(
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                      Text('Faturados não Bipados',
                                          style: FlutterFlowTheme.of(context)
                                              .titleLarge,
                                          textAlign: TextAlign.center)
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
                              padding: const EdgeInsets.fromLTRB(40, 20, 0, 10),
                              child: Text(
                                'Manutenção',
                                style:
                                    FlutterFlowTheme.of(context).headlineMedium,
                              ))),
                      Divider(
                        height: 12,
                        thickness: 2,
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, left: 20),
                        child: Row(
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                Navigator.pop(context);
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ReimprimirPaleteWidget(acess, 0,
                                                bd: bd)));
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.print_rounded),
                                      Container(
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'Reimpressão',
                                        style: FlutterFlowTheme.of(context)
                                            .titleLarge,
                                        textAlign: TextAlign.center,
                                      )
                                    ],
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
            ],
          ),
        ),
      ),
    );
  }
}