import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../Views/escolha_bipagem_widget.dart';
import '../../Views/escolha_romaneio_widget.dart';
import '../../Views/lista_palete_widget.dart';
import '../../Views/lista_pedido_widget.dart';
import '../../Views/progress_widget.dart';
import '../Model/drawer_model.dart';

export '../Model/drawer_model.dart';

///Widget para puxar o mesmo Drawer em todas as telas
class DrawerWidget extends StatefulWidget {

  ///Variável para definir permissões do usuário
  final String acess;

  ///Construtor do Drawer
  const DrawerWidget({required this.acess, super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState(acess);
}

class _DrawerWidgetState extends State<DrawerWidget> {
  late DrawerModel _model;

  String acess;

  List<String> acessos = ['BI','Comercial','Logística'];
  List<String> acessosADM = ['BI'];
  List<String> acessosCol = ['Logística'];
  List<String> acessosPC = ['Comercial'];

  _DrawerWidgetState(this.acess);

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
    print(acessosADM.contains(acess));
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
            Expanded(
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
                  if (acessosCol.contains(acess) || acessosADM.contains(acess)) (Padding(
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
                              await Navigator.push(context, MaterialPageRoute(builder: (context) => EscolhaBipagemWidget(acess),));
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
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => EscolhaRomaneioWidget(acess),));
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
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => ListaPedidoWidget(cont: 0 , acess),));
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
                  ),
                  if (acessosPC.contains(acess) || acessosADM.contains(acess)) (Padding(
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
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => ListaPaleteWidget(cont: 0, acess),));
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
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => ProgressWidget(acess),));
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
                                  FontAwesomeIcons.percent,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 24,
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      12, 0, 0, 0),
                                  child: Text(
                                    'Progresso',
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
                  Expanded(child: Container()),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 10),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () async {
                            await Navigator.popAndPushNamed(context, '/');
                          },
                          child: const Icon(
                            Icons.logout,
                            size: 30,
                            color: Colors.red,
                          ),
                        ),
                      )),
                ].divide(const SizedBox(height: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
