import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

                    return showModalBottomSheet(
                      elevation: MediaQuery.of(context).viewInsets.bottom,
                      useSafeArea: true,
                      context: context, builder: (context) {
                      return Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            16, 12, 16, 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextFormField(
                                showCursor: true,
                                controller: _model.textController,
                                focusNode: _model.textFieldFocusNode,
                                onFieldSubmitted: (value) async {
                                  bd.romaneioExiste(int.parse(value), context, usur);
                                },
                                autofocus: true,
                                obscureText: false,
                                decoration: InputDecoration(
                                  labelText: 'Insira o Romaneio',
                                  labelStyle: FlutterFlowTheme.of(
                                      context)
                                      .labelMedium
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    color: FlutterFlowTheme.of(
                                        context)
                                        .secondaryText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  alignLabelWithHint: false,
                                  hintStyle:
                                  FlutterFlowTheme.of(context)
                                      .labelMedium,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                      FlutterFlowTheme.of(context)
                                          .alternate,
                                      width: 2,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green.shade500,
                                      width: 2,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green.shade100,
                                      width: 2,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  focusedErrorBorder:
                                  OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green.shade100,
                                      width: 2,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium,
                                keyboardType: const TextInputType
                                    .numberWithOptions(),
                                validator: _model
                                    .textControllerValidator
                                    .asValidator(context),
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(
                                      33),
                                  FilteringTextInputFormatter
                                      .digitsOnly,
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },);

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
