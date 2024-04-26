import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../Components/Model/escolha_romaneio_model.dart';
import '../Components/Widget/drawer_widget.dart';
import '../Controls/banco.dart';
import '../Models/usur.dart';
import 'lista_romaneio_widget.dart';

export '../Components/Model/escolha_romaneio_model.dart';

///Página para definir a tarefa escolhida para o Romaneio
class EscolhaRomaneioWidget extends StatefulWidget {

  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///Construtor da página de escolha do Romaneio
  const EscolhaRomaneioWidget(this.usur,{super.key});

  @override
  State<EscolhaRomaneioWidget> createState() => _EscolhaRomaneioWidgetState(this.usur);
}

class _EscolhaRomaneioWidgetState extends State<EscolhaRomaneioWidget> {
  late EscolhaRomaneioModel _model;
  final bd = Banco();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final Usuario usur;

  _EscolhaRomaneioWidgetState(this.usur);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, EscolhaRomaneioModel.new);
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
        drawer: Drawer(
          elevation: 16,
          child: wrapWithModel(
            model: _model.drawerModel,
            updateCallback: () => setState(() {}),
            child: DrawerWidget(usur: usur,context: context,),
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
          title: Text(
            'Criar Romaneio',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Outfit',
                  color: FlutterFlowTheme.of(context).primaryBackground,
                ),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 2,
        ),
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: const AlignmentDirectional(0, 0),
                child: FFButtonWidget(
                  text: 'Continuar Romaneio',
                  onPressed: () async {
                    var i = await bd.getRomaneio(context) ?? 0;
                    if (i != 0) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => ListaRomaneioWidget(i, usur)));
                      }
                    }
                  },
                  options: FFButtonOptions(
                    width: 260,
                    height: 60,
                    padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                    iconPadding:
                        const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: Colors.green.shade700,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Readex Pro',
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 0,
                        ),
                    elevation: 3,
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, 0),
                child: FFButtonWidget(
                  onPressed: () async {
                    bd.createRomaneio(usur);
                    var i = await bd.getRomaneio(context) ?? 0;
                    if (context.mounted) {
                      Navigator.pop(context);
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => ListaRomaneioWidget(i, usur),));
                    }
                  },
                  text: 'Criar Novo Romaneio',
                  options: FFButtonOptions(
                    width: 300,
                    height: 60,
                    padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                    iconPadding:
                        const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: Colors.orange.shade700,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Readex Pro',
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 0,
                        ),
                    elevation: 3,
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ].divide(const SizedBox(height: 50)),
          ),
        ),
      ),
    );
  }
}
