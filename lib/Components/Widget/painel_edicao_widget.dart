import 'package:flutter/foundation.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';

import '../Model/painel_edicao_model.dart';
export '../Model/painel_edicao_model.dart';

class PainelEdicaoWidget extends StatefulWidget {
  const PainelEdicaoWidget({super.key});

  @override
  State<PainelEdicaoWidget> createState() => _PainelEdicaoWidgetState();
}

class _PainelEdicaoWidgetState extends State<PainelEdicaoWidget> {
  late PainelEdicaoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PainelEdicaoModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 270,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 5,
            color: Color(0x3B1D2429),
            offset: Offset(0, -3),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            FFButtonWidget(
              onPressed: () {
                if (kDebugMode) {
                  print('Button pressed ...');
                }
              },
              text: 'Editar',
              options: FFButtonOptions(
                width: double.infinity,
                height: 60,
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                color: FlutterFlowTheme.of(context).primaryBackground,
                textStyle: FlutterFlowTheme.of(context).bodyLarge,
                elevation: 2,
                borderSide: const BorderSide(
                  color: Colors.transparent,
                  width: 1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
              child: FFButtonWidget(
                onPressed: () {
                  if (kDebugMode) {
                    print('Button pressed ...');
                  }
                },
                text: 'Apagar',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 60,
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  color: FlutterFlowTheme.of(context).error,
                  textStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: 'Readex Pro',
                    color: const Color(0xFF7C0000),
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 2,
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                    width: 1,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
              child: FFButtonWidget(
                onPressed: () async {
                  Navigator.pop;
                },
                text: 'Cancel',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 60,
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: 'Lexend Deca',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  elevation: 0,
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                    width: 0,
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
