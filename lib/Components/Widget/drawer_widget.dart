import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Model/drawer_model.dart';
export '../Model/drawer_model.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  late DrawerModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DrawerModel());
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
                        padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 6, 0),
                        child: MaterialButton(
                          onPressed: () async {
                            Navigator.popAndPushNamed(context,'/ListaRomaneioConf');
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
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  size: 24,
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                  child: Text(
                                    'Listagem',
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
                        padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 6, 0),
                        child: MaterialButton(
                          onPressed: () async {
                            if (Navigator.of(context).canPop()) {
                              Navigator.pop;
                            }
                            Navigator.popAndPushNamed(context,'/');
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
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  size: 24,
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
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
                    ),
                  ),
                ].divide(const SizedBox(height: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
