import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../Components/Model/criar_palete_model.dart';
import '../Components/Widget/atualizacao.dart';
import '../Components/Widget/drawer_widget.dart';
import '../Controls/banco.dart';
import '../Models/usur.dart';

///Página para a criação de novos Paletes
class AtualizarWidget extends StatefulWidget {
  ///Variável para definir permissões do Usur.
  final Usuario usur;

  ///Variável para manter conexão com o Banco
  final Banco bd;

  ///Construtor da página de criação de novos Paletes
  const AtualizarWidget(
      this.usur, {
        super.key,
        required this.bd,
      });

  @override
  State<AtualizarWidget> createState() => _AtualizarWidget(usur, bd);
}

class _AtualizarWidget extends State<AtualizarWidget> {
  late Banco bd;

  final Usuario usur;

  late var teste;

  late Future<DateTime?> ultAttfut;
  late DateTime? ultAtt;

  late CriarPaleteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  _AtualizarWidget(this.usur, this.bd);

  @override
  void initState() {
    super.initState();
    rodarBanco();
    _model = createModel(context, CriarPaleteModel.new);
  }

  void rodarBanco() async {
    ultAttfut = bd.ultAttget();
    teste = AtualizacaoWidget(usur: usur, context: context, bd: bd,);
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
            'Atualizar Banco',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Outfit',
              color: FlutterFlowTheme.of(context).primaryBackground,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.lock_reset_outlined),
              onPressed: () async {
                rodarBanco();
                setState(() {});
              },
              color: Colors.white,
            ),
          ],
          centerTitle: true,
          elevation: 2,
        ),
        drawer: Drawer(
          elevation: 16,
          child: wrapWithModel(
            model: _model.drawerModel,
            updateCallback: () => setState(() {}),
            child: DrawerWidget(
              usur: usur,
              context: context,
              bd: bd,
            ),
          ),
        ),
        body: Stack(
          children: [
            SafeArea(
                top: true,
                child: FutureBuilder(
                  future: ultAttfut,
                  builder: (context, snapshot) {
                    ultAtt = snapshot.data;
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  if (await bd.connected(context) == 1){
                                    if (context.mounted) {
                                      bd.atualizar(ultAtt, context);
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width:
                                    MediaQuery.of(context).size.height *
                                        0.3,
                                    height:
                                    MediaQuery.of(context).size.height *
                                        0.2,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(20)),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.refresh),
                                        Container(
                                          height: 20,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          'Atualização Rápida',
                                          style: FlutterFlowTheme.of(context)
                                              .titleLarge,
                                          textAlign: TextAlign.center,
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
                                  if (await bd.connected(context) == 1){
                                    if (context.mounted) {
                                      bd.atualizarFull(ultAtt, context);
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width:
                                    MediaQuery.of(context).size.height *
                                        0.3,
                                    height:
                                    MediaQuery.of(context).size.height *
                                        0.2,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(20)),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.restart_alt),
                                        Container(
                                          height: 20,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          'Atualização Full',
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
                          ));
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                )),
            Positioned(bottom: 0,right:0, child: teste)
          ],
        ),
      ),
    );
  }
}
