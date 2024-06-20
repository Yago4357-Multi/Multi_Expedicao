import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../Components/Model/criar_palete_model.dart';
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
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
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
            Padding(
              padding: const EdgeInsets.all(5),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  bd.atualizar(ultAtt, context);
                },
                child: Container(
                  width: 120,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Atualizar',
                        style: FlutterFlowTheme.of(context)
                            .headlineSmall
                            .override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                fontSize: 15),
                      ),
                      const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            )
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
        body: SafeArea(
            top: true,
            child: FutureBuilder(
              future: ultAttfut,
              builder: (context, snapshot) {
                ultAtt = snapshot.data;
                if (snapshot.connectionState == ConnectionState.done) {
                  return Center(
                      child: Text(
                          'Última Atualização \n ${ultAtt != null ? DateFormat('dd/MM/yyyy kk:mm:ss').format(ultAtt!.toLocal()) : 'Não atualizado'}',
                          style: FlutterFlowTheme.of(context)
                              .headlineLarge
                              .override(fontFamily: 'Readex Pro', fontSize: 16),
                          textAlign: TextAlign.center));
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            )),
      ),
    );
  }
}
