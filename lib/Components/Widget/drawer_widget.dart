import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../Controls/banco.dart';
import '../../Models/usur.dart';
import '../../Views/carregamento_widget.dart';
import '../../Views/deletar_pedido_widget.dart';
import '../../Views/escolha_conferencia_widget.dart';
import '../../Views/escolha_romaneio_widget.dart';
import '../../Views/home_widget.dart';
import '../../Views/lista_cancelados.dart';
import '../../Views/lista_faturados.dart';
import '../../Views/lista_palete_widget.dart';
import '../../Views/lista_pedido_widget.dart';
import '../../Views/lista_romaneios.dart';
import '../../Views/reimprimir_palete_widget.dart';
import '../Model/drawer_model.dart';

export '../Model/drawer_model.dart';

///Widget para puxar o mesmo Drawer em todas as telas
class DrawerWidget extends StatefulWidget {

  ///Variável para definir permissões do usuário
  final Usuario usur;

  final BuildContext context;

  final Banco bd;

  ///Construtor do Drawer
  const DrawerWidget({required this.usur, required this.context, required this.bd, super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState(usur, context, bd);
}

class _DrawerWidgetState extends State<DrawerWidget> {
  late DrawerModel _model;
  late final bd;

  final Usuario usur;

  final BuildContext context2;

  List<String> acessos = ['BI','Comercial','Logística'];
  List<String> acessosADM = ['BI'];
  List<String> acessosCol = ['Logística'];
  List<String> acessosPC = ['Comercial'];

  _DrawerWidgetState(this.usur, this.context2, this.bd);

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, DrawerModel.new);
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      height: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.flag,
                      color: Color(0xFF007000),
                      size: 32,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                      child: Text(
                        'Romaneio',
                        style: FlutterFlowTheme.of(context).headlineMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 12,
                thickness: 2,
                color: FlutterFlowTheme.of(context).alternate,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.72,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 0, 0),
                        child: Text(
                          'Telas',
                          style: FlutterFlowTheme.of(context).labelMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            16, 0, 16, 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          height: 44,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme
                                .of(context)
                                .primaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            shape: BoxShape.rectangle,
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsetsDirectional.fromSTEB(8, 0, 6, 0),
                            child: MaterialButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                Navigator.pop(context2);
                                await Navigator.push(context, MaterialPageRoute(builder: (context) => HomeWidget(usur,bd: bd),));
                              },
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.home_rounded,
                                      color:
                                      FlutterFlowTheme
                                          .of(context)
                                          .primaryText,
                                      size: 24,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          12, 0, 0, 0),
                                      child: Text(
                                        'Home',
                                        style:
                                        FlutterFlowTheme
                                            .of(context)
                                            .bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            16, 0, 16, 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          height: 44,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme
                                .of(context)
                                .primaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            shape: BoxShape.rectangle,
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsetsDirectional.fromSTEB(8, 0, 6, 0),
                            child: MaterialButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                Navigator.pop(context2);
                                await Navigator.push(context, MaterialPageRoute(builder: (context) => ListaCarregamentoWidget(usur,bd: bd),));
                              },
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.move_up_outlined,
                                      color:
                                      FlutterFlowTheme
                                          .of(context)
                                          .primaryText,
                                      size: 24,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          12, 0, 0, 0),
                                      child: Text(
                                        'Carregamento',
                                        style:
                                        FlutterFlowTheme
                                            .of(context)
                                            .bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            16, 0, 16, 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          height: 44,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme
                                .of(context)
                                .primaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            shape: BoxShape.rectangle,
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsetsDirectional.fromSTEB(8, 0, 6, 0),
                            child: MaterialButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                Navigator.pop(context2);
                                await Navigator.push(context, MaterialPageRoute(builder: (context) => DeletarPedidoWidget(usur,bd: bd),));
                              },
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.delete_sweep_outlined,
                                      color:
                                      FlutterFlowTheme
                                          .of(context)
                                          .primaryText,
                                      size: 24,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          12, 0, 0, 0),
                                      child: Text(
                                        'Deletar Palete',
                                        style:
                                        FlutterFlowTheme
                                            .of(context)
                                            .bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (acessosCol.contains(usur.acess) || acessosADM.contains(usur.acess)) (Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            16, 0, 16, 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          height: 44,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme
                                .of(context)
                                .primaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            shape: BoxShape.rectangle,
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsetsDirectional.fromSTEB(8, 0, 6, 0),
                            child: MaterialButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                Navigator.pop(context2);
                                await Navigator.push(context, MaterialPageRoute(builder: (context) => EscolhaBipagemWidget(usur,bd: bd),));
                              },
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.space_dashboard,
                                      color:
                                      FlutterFlowTheme
                                          .of(context)
                                          .primaryText,
                                      size: 24,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          12, 0, 0, 0),
                                      child: Text(
                                        'Confêrencia',
                                        style:
                                        FlutterFlowTheme
                                            .of(context)
                                            .bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          height: 44,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            shape: BoxShape.rectangle,
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsetsDirectional.fromSTEB(8, 0, 6, 0),
                            child: MaterialButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                Navigator.pop(context2);
                                await Navigator.push(context, MaterialPageRoute(
                                  builder: (context) =>
                                      EscolhaRomaneioWidget(usur,bd: bd),));
                              },
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.list,
                                      color:
                                      FlutterFlowTheme.of(context).primaryText,
                                      size: 24,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          12, 0, 0, 0),
                                      child: Text(
                                        'Romaneio',
                                        style:
                                        FlutterFlowTheme.of(context).bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          height: 44,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            shape: BoxShape.rectangle,
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsetsDirectional.fromSTEB(8, 0, 6, 0),
                            child: MaterialButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                Navigator.pop(context2);
                                await Navigator.push(context, MaterialPageRoute(
                                    builder: (context) =>
                                        ReimprimirPaleteWidget(usur, 0, bd: bd)));
                              },

                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.print_rounded,
                                      color:
                                      FlutterFlowTheme.of(context).primaryText,
                                      size: 24,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          12, 0, 0, 0),
                                      child: Text(
                                        'Reimprimir',
                                        style:
                                        FlutterFlowTheme.of(context).bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          height: 44,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            shape: BoxShape.rectangle,
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsetsDirectional.fromSTEB(8, 0, 6, 0),
                            child: MaterialButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                Navigator.pop(context2);
                                await Navigator.push(context, MaterialPageRoute(
                                  builder: (context) =>
                                      ListaFaturadosWidget(usur, bd: bd),));
                              },
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.fact_check_outlined,
                                      color:
                                      FlutterFlowTheme.of(context).primaryText,
                                      size: 24,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          12, 0, 0, 0),
                                      child: Text(
                                        'Faturados',
                                        style:
                                        FlutterFlowTheme.of(context).bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          height: 44,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            shape: BoxShape.rectangle,
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsetsDirectional.fromSTEB(8, 0, 6, 0),
                            child: MaterialButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                Navigator.pop(context2);
                                await Navigator.push(context, MaterialPageRoute(
                                  builder: (context) =>
                                      ListaCanceladosWidget(usur, bd: bd),));
                              },
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.free_cancellation_outlined,
                                      color:
                                      FlutterFlowTheme.of(context).primaryText,
                                      size: 24,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          12, 0, 0, 0),
                                      child: Text(
                                        'Cancelados',
                                        style:
                                        FlutterFlowTheme.of(context).bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (acessosPC.contains(usur.acess) || acessosADM.contains(usur.acess)) (Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          height: 44,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            shape: BoxShape.rectangle,
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsetsDirectional.fromSTEB(8, 0, 6, 0),
                            child: MaterialButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                Navigator.pop(context2);
                                await Navigator.push(context, MaterialPageRoute(builder: (context) => ListaPedidoWidget(cont: 0 , usur,bd: bd),));
                              },
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    FaIcon(
                                      Icons.request_page_outlined,
                                      color:
                                      FlutterFlowTheme.of(context).primaryText,
                                      size: 24,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          12, 0, 0, 0),
                                      child: Text(
                                        'Pedidos',
                                        style:
                                        FlutterFlowTheme.of(context).bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                      if (acessosPC.contains(usur.acess) || acessosADM.contains(usur.acess)) (Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          height: 44,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            shape: BoxShape.rectangle,
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsetsDirectional.fromSTEB(8, 0, 6, 0),
                            child: MaterialButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                Navigator.pop(context2);
                                await Navigator.push(context, MaterialPageRoute(builder: (context) => ListaPaleteWidget(cont: 0, usur, bd: bd),));
                              },
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.pallet,
                                      color:
                                      FlutterFlowTheme.of(context).primaryText,
                                      size: 24,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          12, 0, 0, 0),
                                      child: Text(
                                        'Paletes',
                                        style:
                                        FlutterFlowTheme.of(context).bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                      if (acessosPC.contains(usur.acess) || acessosADM.contains(usur.acess)) (Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          height: 44,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            shape: BoxShape.rectangle,
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsetsDirectional.fromSTEB(8, 0, 6, 0),
                            child: MaterialButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                Navigator.pop(context2);
                                await Navigator.push(context, MaterialPageRoute(builder: (context) => ListaRomaneiosWidget(usur, bd: bd),));
                              },
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.history_edu,
                                      color:
                                      FlutterFlowTheme.of(context).primaryText,
                                      size: 24,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          12, 0, 0, 0),
                                      child: Text(
                                        'Romaneios',
                                        style:
                                        FlutterFlowTheme.of(context).bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                    ].divide(const SizedBox(height: 12)),
                  ),
                ),
              ),
              Expanded(child: Container()),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 20, 4),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        await Navigator.popAndPushNamed(context2, '/');
                      },
                      child: const Icon(
                        Icons.logout,
                        size: 30,
                        color: Colors.red,
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
