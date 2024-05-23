import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../Components/Model/lista_romaneio.dart';
import '../Controls/banco.dart';
import '../Models/contagem.dart';
import '../Models/usur.dart';
import '/Components/Widget/drawer_widget.dart';

///Página da listagem de Romaneio
class DeletarPedidoWidget extends StatefulWidget {
  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///Variável para manter a conexão com o Banco
  final Banco bd;

  ///Construtor da página
  const DeletarPedidoWidget(this.usur, {super.key, required this.bd});

  @override
  State<DeletarPedidoWidget> createState() =>
      _DeletarPedidoWidgetState(usur, bd);
}

class _DeletarPedidoWidgetState extends State<DeletarPedidoWidget> {
  final Usuario usur;
  final Banco bd;

  _DeletarPedidoWidgetState(this.usur, this.bd);

  ///Variáveis para mostrar erro no TextField
  Color corDica = Colors.green.shade400;
  Color corBorda = Colors.green.shade700;
  String dica = 'Insira a caixa...';

  late StateSetter internalSetter;
  late ListaRomaneioModel _model;

  ///Variáveis para Salvar e Modelar Pedidos
  late Future<List<Contagem>> pedidosFut;
  late List<Contagem> pedidos = [];
  late List<Contagem> pedidosExc = [];

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ListaRomaneioModel.new);
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    rodarBanco();
  }

  void rodarBanco() async {
    pedidosFut = bd.selectAll();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _model.textFieldFocusNode?.requestFocus();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
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
        actions: const [],
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        top: true,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      maxWidth: 970,
                    ),
                    decoration: const BoxDecoration(),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: (responsiveVisibility(
                          context: context,
                          phone: false,
                          tablet: false,
                        ))
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 24,
                            decoration: const BoxDecoration(),
                          ),
                          Container(
                            width: double.infinity,
                            height: 24,
                            decoration: const BoxDecoration(),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (responsiveVisibility(
                                context: context,
                                phone: true,
                                tablet: true,
                                desktop: false,
                              ))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: SizedBox(
                                    width: 300,
                                    child: TextFormField(
                                      onFieldSubmitted: (value) async {
                                        var codArrumado =
                                            value.substring(14, 33);
                                        var ped = codArrumado.substring(0, 10);
                                        var cx = codArrumado.substring(14, 16);
                                        if (pedidosExc.contains(Contagem(int.parse(ped), 0, int.parse(cx), 0)) ==
                                            false) {
                                          pedidosExc.add(Contagem(int.parse(ped), 0, int.parse(cx), 0));
                                        }
                                        _model.textController.text = '';
                                        setState(() {});
                                      },
                                      controller: _model.textController,
                                      focusNode: _model.textFieldFocusNode,
                                      autofocus: false,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        labelText: dica,
                                        labelStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              fontFamily: 'Readex Pro',
                                              letterSpacing: 0,
                                            ),
                                        hintStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              fontFamily: 'Readex Pro',
                                              letterSpacing: 0,
                                            ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: corBorda,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: corDica,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        contentPadding:
                                            const EdgeInsetsDirectional
                                                .fromSTEB(20, 0, 0, 0),
                                        suffixIcon: Icon(
                                          Icons.search_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                        ),
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            letterSpacing: 0,
                                          ),
                                      cursorColor:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: const AlignmentDirectional(-1, 0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16, 0, 0, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Pedido',
                                      textAlign: TextAlign.center,
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            letterSpacing: 0,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Caixa',
                                      textAlign: TextAlign.start,
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            letterSpacing: 0,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: pedidosExc.isNotEmpty
                                    ? pedidosExc.length
                                    : 0,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            14, 10, 14, 10),
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: 570,
                                      ),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context)
                                              .alternate,
                                          width: 2,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(10, 12, 12, 12),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                  textAlign: TextAlign.start,
                                                  '${pedidosExc.isNotEmpty ? pedidosExc[index].ped : 0}',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .headlineLarge
                                                      .override(
                                                          fontFamily:
                                                              'Readex Pro',
                                                          color: Colors.red,
                                                          fontSize: 26)),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                textAlign: TextAlign.center,
                                                '${pedidosExc.isNotEmpty ? pedidosExc[index].caixa : 0}',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20)),
                          child: IconButton(
                            icon: const Icon(Icons.check_outlined,
                                color: Colors.white),
                            onPressed: () async {
                              await showCupertinoModalPopup(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return CupertinoAlertDialog(
                                    title: const Text(
                                      'Verifique todos os pedidos antes de exclui-los',
                                    ),
                                    actions: <CupertinoDialogAction>[
                                      CupertinoDialogAction(
                                          isDefaultAction: true,
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Voltar')),
                                      CupertinoDialogAction(
                                          isDestructiveAction: true,
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await showCupertinoModalPopup(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (context) {
                                                return CupertinoAlertDialog(
                                                  title: const Text(
                                                    'Após exclusão todos os pedidos excluídos terão que ser bipados novamente. Deseja continuar??',
                                                  ),
                                                  actions: <CupertinoDialogAction>[
                                                    CupertinoDialogAction(
                                                        isDefaultAction: true,
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            'Voltar')),
                                                    CupertinoDialogAction(
                                                        isDestructiveAction:
                                                            true,
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          bd.excluiPedido(
                                                              pedidosExc,
                                                              usur,
                                                              0);
                                                          pedidosExc = [];
                                                          setState(() {});
                                                        },
                                                        child: const Text(
                                                            'Continuar'))
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: const Text('Continuar'))
                                    ],
                                  );
                                },
                              );
                            },
                          )))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
