import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../Components/Model/progress_model.dart';
import '../Components/Widget/atualizacao.dart';
import '../Components/Widget/drawer_widget.dart';
import '../Controls/banco.dart';
import '../FlutterFlowTheme.dart';
import '../Models/contagem.dart';
import '../Models/usur.dart';
import 'conferencia_widget.dart';
import 'lista_cancelados.dart';
import 'lista_faturados.dart';

///Página inicial do Aplicativo
class ProgressWidget extends StatefulWidget {

  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///Variável para manter conexão com o Banco
  final Banco bd;

  ///Construtor da página inicial
  const ProgressWidget(this.usur, {super.key, required this.bd});

  @override
  State<ProgressWidget> createState() => _ProgressWidgetState(usur, bd);
}

class _ProgressWidgetState extends State<ProgressWidget>
    with TickerProviderStateMixin {

  final Usuario acess;

  final Banco bd;

  _ProgressWidgetState(this.acess, this.bd);

  late HomePageModel _model;

  late Future<int> qtdFatFut;
  late Future<int> qtdCancFut;
  int qtdFat = 0;
  int qtdCanc = 0;

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

  void rodarBanco() async{
      qtdCancFut = bd.qtdCanc();
      qtdFatFut = bd.qtdFat();
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
            child: DrawerWidget(usur: acess, context: context,bd: bd,)
          ),
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
                FutureBuilder(
                  future: qtdFatFut,
                  builder: (context, snapshot) {
                    qtdFat = snapshot.data ?? 0;
                    if (qtdFat > 0 ) {
                      return Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: SizedBox(
                              width: 120,
                              height: 50,
                              child: Row(children: [
                                Text(
                                  'Fat.: $qtdFat',
                                  style: FlutterFlowTheme
                                      .of(context)
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
                                              ListaFaturadosWidget(acess, bd: bd),
                                        ));
                                  },
                                  icon: const Icon(
                                    Icons.assignment_late,
                                    color: Colors.red,
                                  ),
                                )
                              ])));
                    } else{
                      return Container();
                    }
                  },
                ),
              if (responsiveVisibility(
                context: context,
                phone: false,
                tablet: false,
              ))
                FutureBuilder(
                    future: qtdCancFut,
                    builder: (context, snapshot) {
                      qtdCanc = snapshot.data ?? 0;
                      if (qtdCanc > 0) {
                        return Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: SizedBox(
                                width: 120,
                                height: 50,
                                child: Row(children: [
                                  Text('Canc. : $qtdCanc',
                                      style: FlutterFlowTheme
                                          .of(context)
                                          .headlineSmall
                                          .override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 16,
                                          color: Colors.orange)),
                                  IconButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ListaCanceladosWidget(acess, bd: bd),
                                          ));
                                    },
                                    icon: const Icon(
                                      Icons.assignment_late,
                                      color: Colors.orange,
                                    ),
                                  )
                                ])));
                      } else{
                        return Container();
                      }
                    }),
            ],
          ),
          title: Text(
            'Progresso',
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
              FutureBuilder(
                future: getPed,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    pedidos = snapshot.data ?? [];
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: const AlignmentDirectional(-1, 0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color:
                                  FlutterFlowTheme.of(context).secondaryBackground,
                            ),
                            child: Align(
                              alignment: const AlignmentDirectional(-1, -1),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    5, 0, 0, 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: const AlignmentDirectional(-1, -1),
                                      child: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.fromSTEB(
                                                0, 10, 0, 0),
                                        child: Text(
                                          'Bom dia,',
                                          style: FlutterFlowTheme.of(context)
                                              .displaySmall
                                              .override(
                                                fontFamily: 'Outfit',
                                                fontWeight: FontWeight.normal,
                                              ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: const AlignmentDirectional(-1, -1),
                                      child: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.fromSTEB(
                                                10, 0, 0, 0),
                                        child: Text(
                                          'Progresso do romaneio atual',
                                          style: FlutterFlowTheme.of(context)
                                              .labelMedium,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            constraints: const BoxConstraints(
                              maxHeight: 140,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  FlutterFlowTheme.of(context).secondaryBackground,
                              shape: BoxShape.rectangle,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0, 8, 0, 0),
                                      child: ListView(
                                        padding: EdgeInsets.zero,
                                        primary: false,
                                        scrollDirection: Axis.horizontal,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(16, 0, 8, 8),
                                            child: Container(
                                              width: 130,
                                              height: 200,
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(context)
                                                    .secondaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: const Color(0xFFE0E3E7),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(12),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${pedidos.length}',
                                                      style: FlutterFlowTheme.of(
                                                              context)
                                                          .displaySmall,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(0, 4, 0, 0),
                                                      child: Text(
                                                        'Total',
                                                        style: FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0, 0, 8, 8),
                                            child: Container(
                                              width: 130,
                                              height: 200,
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(context)
                                                    .secondaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: const Color(0xFFE0E3E7),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(12),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '5',
                                                      style: FlutterFlowTheme.of(
                                                              context)
                                                          .displaySmall
                                                          .override(
                                                            fontFamily: 'Outfit',
                                                            color:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .tertiary,
                                                          ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(0, 4, 0, 0),
                                                      child: Text(
                                                        'Faltam Conf.',
                                                        style: FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0, 0, 16, 8),
                                            child: Container(
                                              width: 150,
                                              height: 200,
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(context)
                                                    .secondaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: const Color(0xFFE0E3E7),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(12),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '14',
                                                      style: FlutterFlowTheme.of(
                                                              context)
                                                          .displaySmall
                                                          .override(
                                                            fontFamily: 'Outfit',
                                                            color:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondary,
                                                          ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(0, 4, 0, 0),
                                                      child: Text(
                                                        'OK',
                                                        style: FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium,
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              if (Navigator.of(context).canPop()) {
                                Navigator.pop;
                              }
                              await Navigator.push(context, MaterialPageRoute(builder: (context) => ListaRomaneioConfWidget(palete: 0, acess, bd: bd),));
                            },
                            child: Container(
                              width: double.infinity,
                              height: 110,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 4,
                                    color: Color(0x34090F13),
                                    offset: Offset(0, 2),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    12, 8, 12, 8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Continuar Conferência',
                                      style:
                                          FlutterFlowTheme.of(context).titleLarge,
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0, 4, 0, 0),
                                            child: Text(
                                              'Progress',
                                              style: FlutterFlowTheme.of(context)
                                                  .labelMedium,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0, 4, 0, 0),
                                            child: Text(
                                              '4/10',
                                              style: FlutterFlowTheme.of(context)
                                                  .headlineLarge,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color:
                                  FlutterFlowTheme.of(context).secondaryBackground,
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 3,
                                  color: Color(0x33000000),
                                  offset: Offset(0, 1),
                                )
                              ],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 12, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  16, 12, 12, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Ped. Não Encontrados',
                                                style: FlutterFlowTheme.of(context)
                                                    .headlineSmall,
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 4, 0, 0),
                                                child: Text(
                                                  'Lista de Erros da Conferência',
                                                  style:
                                                      FlutterFlowTheme.of(context)
                                                          .labelMedium,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_right_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  16, 12, 0, 12),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${pedidos.length}',
                                                style: FlutterFlowTheme.of(context)
                                                    .displaySmall,
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 4, 0, 0),
                                                child: Text(
                                                  'Nº Bipagens',
                                                  style:
                                                      FlutterFlowTheme.of(context)
                                                          .labelMedium,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  0, 0, 16, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '1',
                                                style: FlutterFlowTheme.of(context)
                                                    .displaySmall,
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 4, 0, 0),
                                                child: Text(
                                                  'Ped. Não Encontrados',
                                                  style:
                                                      FlutterFlowTheme.of(context)
                                                          .labelMedium,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ).animateOnPageLoad(
                              animationsMap['containerOnPageLoadAnimation4']!),
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
              Positioned(right: 0,bottom: 0, child: AtualizacaoWidget(bd: bd,context: context, usur: acess,))
            ],
          ),
        ),
      ),
    );
  }
}
