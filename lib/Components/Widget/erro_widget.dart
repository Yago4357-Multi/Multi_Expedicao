import 'package:flutter/foundation.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../Model/erro_model.dart';
export '../Model/erro_model.dart';

class ErroWidget extends StatefulWidget {
  const ErroWidget({super.key});

  @override
  State<ErroWidget> createState() => _ErroWidgetState();
}

class _ErroWidgetState extends State<ErroWidget> {
  late ErroModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ErroModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 6,
          sigmaY: 8,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).accent4,
          ),
          alignment: const AlignmentDirectional(0, 1),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 7,
                      color: Color(0x33000000),
                      offset: Offset(0, -2),
                    )
                  ],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 3,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).alternate,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 0, 0),
                        child: Text(
                          'Erro na Bipagem',
                          style: FlutterFlowTheme.of(context).headlineSmall,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 0, 0),
                        child: Text(
                          'Pedido e Volume já bipados anteriormente',
                          style: FlutterFlowTheme.of(context).labelMedium,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding:
                            const EdgeInsetsDirectional.fromSTEB(16, 16, 0, 40),
                            child: FFButtonWidget(
                              onPressed: () {
                                if (kDebugMode) {
                                  print('Button pressed ...');
                                }
                              },
                              text: 'Tentar Novamente',
                              options: FFButtonOptions(
                                width: MediaQuery.sizeOf(context).width * 0.48,
                                height: 60,
                                padding:
                                const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                iconPadding:
                                const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                color: const Color(0xFF54C354),
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  fontWeight: FontWeight.bold,
                                ),
                                elevation: 2,
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(0),
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(0),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 16, 16, 40),
                            child: FFButtonWidget(
                              onPressed: () {
                                if (kDebugMode) {
                                  print('Button pressed ...');
                                }
                              },
                              text: 'Verificar',
                              options: FFButtonOptions(
                                width: MediaQuery.sizeOf(context).width * 0.46,
                                height: 60,
                                padding:
                                const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                iconPadding:
                                const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                color: FlutterFlowTheme.of(context).error,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  fontWeight: FontWeight.bold,
                                ),
                                elevation: 2,
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(0),
                                  bottomRight: Radius.circular(12),
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
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
