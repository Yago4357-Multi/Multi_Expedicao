import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../Components/Model/lista_cancelados.dart';
import '../Components/Widget/atualizacao.dart';
import '../Controls/banco.dart';
import '../Models/palete.dart';
import '../Models/pedido.dart';
import '../Models/usur.dart';
import '/Components/Widget/drawer_widget.dart';
import 'lista_faturados.dart';
import 'lista_pedido_widget.dart';

///Página da listagem de Romaneio
class ListaCanceladosWidget extends StatefulWidget {
  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///Variável para manter conexão com o Banco
  final Banco bd;

  ///Construtor da página
  const ListaCanceladosWidget(this.usur, {super.key, required this.bd});

  @override
  State<ListaCanceladosWidget> createState() => _ListaCanceladosWidget(usur, bd);
}

class _ListaCanceladosWidget extends State<ListaCanceladosWidget> {
  final Usuario usur;
  final Banco bd;

  DateRangePickerController datas = DateRangePickerController();

  _ListaCanceladosWidget(this.usur, this.bd);

  ///Variáveis para mostrar erro no TextField
  Color corDica = Colors.green.shade400;
  Color corBorda = Colors.green.shade700;
  String dica = 'Procure um pedido...';

  late Future<int> qtdFatFut;
  int qtdFat = 0;

  late PickerDateRange datasRange;

  late StateSetter internalSetter;
  late ListaCanceladosModel _model;

  late List<Paletes> palete = [];
  late List<int> paleteSelecionadoint = [];

  ///Variáveis para Salvar e Modelar pedidos
  late Future<List<Pedido>> pedidoResposta;
  List<Pedido> pedidos = [];
  List<Pedido> pedidosSalvos = [];

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ListaCanceladosModel.new);
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    rodarBanco();
  }

  void rodarBanco() async {
      pedidoResposta = bd.canceladosBipados();
      qtdFatFut = bd.qtdFat();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        leadingWidth: 400,
        leading: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            FlutterFlowIconButton(
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
            if (responsiveVisibility(
              context: context,
              phone: false,
              tablet: false,
            ))
              FutureBuilder(
                future: qtdFatFut,
                builder: (context, snapshot) {
                  qtdFat = snapshot.data ?? 0;
                  if (qtdFat > 0 ) {
                    return Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: SizedBox(
                            width: 120,
                            height: 50,
                            child: Row(children: [
                              Text(
                                'Fat.: $qtdFat',
                                style: FlutterFlowTheme
                                    .of(context)
                                    .headlineSmall
                                    .override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 16,
                                    color: Colors.red),
                              ),
                              IconButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ListaFaturadosWidget(usur, bd: bd),
                                      ));
                                },
                                icon: const Icon(
                                  Icons.assignment_late,
                                  color: Colors.red,
                                ),
                              )
                            ])));
                  } else{
                    return Container();
                  }
                },
              ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.lock_reset_outlined),onPressed: () async {
            pedidoResposta = bd.canceladosBipados();
            setState(() {
            });
          }, color: Colors.white,),
        ],
        centerTitle: true,
        elevation: 2,
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 24,
                    decoration: const BoxDecoration(),
                  ),
                  if (responsiveVisibility(
                    context: context,
                    phone: false,
                    tablet: false,
                  ))Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          16, 40, 0, 40),
                      child: SizedBox(
                        width: 500,
                        child: TextFormField(
                          canRequestFocus: true,
                          onChanged: (value) {
                            _model.choiceChipsValue = 'Todos';
                            setState(() {
                              if (pedidosSalvos.length <
                                  pedidos.length) {
                                pedidosSalvos = pedidos;
                              }
                              if (value.isNotEmpty) {
                                var x =
                                    pedidosSalvos.where((element) {
                                  var texto = element.ped.toString();
                                  texto.startsWith(value);
                                  return texto.startsWith(value);
                                });
                                if (x.isNotEmpty) {
                                  pedidos = x.toList();
                                } else {
                                  pedidos = [];
                                  dica = 'Pedido não encontrado';
                                  corDica = Colors.red.shade400;
                                  corBorda = Colors.red.shade700;
                                }
                              } else {
                                pedidos = pedidosSalvos;
                                dica = 'Procure por um pedido...';
                                corDica = Colors.green.shade400;
                                corBorda = Colors.green.shade700;
                              }
                            });
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: corDica,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context)
                                    .error,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context)
                                    .error,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding:
                                const EdgeInsetsDirectional.fromSTEB(
                                    20, 0, 0, 0),
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
                          validator: _model.textControllerValidator
                              .asValidator(context),
                        ),
                      ),
                    ),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          FlutterFlowTheme.of(context).primaryBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: const AlignmentDirectional(-1, 0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          16, 0, 0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Pedido',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                          if (responsiveVisibility(
                            context: context,
                            phone: false,
                            tablet: false,
                          ))
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Nota',
                                style: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .override(
                                      fontFamily: 'Readex Pro',
                                      letterSpacing: 0,
                                    ),
                              ),
                            ),
                          if (responsiveVisibility(
                            context: context,
                            phone: false,
                            tablet: false,
                          ))
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Cód. Cli.',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                          if (responsiveVisibility(
                            context: context,
                            phone: false,
                            tablet: false,
                          ))
                          Expanded(
                            flex: 4,
                            child: Text(
                              'Cliente',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                          if (responsiveVisibility(
                            context: context,
                            phone: false,
                            tablet: false,
                          ))
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Cidade',
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
                              child: Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0, 4, 40, 4),
                                child: Text(
                                  'Volumes Bip.',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: 'Readex Pro',
                                        letterSpacing: 0,
                                      ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder(
                    future: pedidoResposta,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.done) {
                        if (pedidosSalvos != snapshot.data) {
                          pedidos = snapshot.data ?? [];
                          pedidosSalvos = pedidos;
                        }
                        return ListView.builder(
                          itemCount: pedidos.length,
                          padding: const EdgeInsets.fromLTRB(
                            0,
                            0,
                            0,
                            44,
                          ),
                          reverse: true,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            var corStatus = FlutterFlowTheme.of(context)
                                .primaryBackground;
                            var corBordaStatus =
                                FlutterFlowTheme.of(context).secondary;
                            var corFundoStatus =
                                FlutterFlowTheme.of(context).accent2;
                            var corTextoStatus = Colors.black;
                            if (pedidos[index].status == 'Incorreto') {
                              corStatus = Colors.red.shade100;
                              corBordaStatus = Colors.red;
                              corFundoStatus = Colors.red.shade100;
                              corTextoStatus = Colors.red;
                            }
                            return InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ListaPedidoWidget(
                                              cont: pedidos[index].ped,
                                              usur,
                                              bd: bd),
                                    ));
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: corStatus,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional
                                        .fromSTEB(16, 12, 16, 12),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${pedidos[index].ped}',
                                            style:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      color: corTextoStatus,
                                                      fontFamily:
                                                          'Readex Pro',
                                                      letterSpacing: 0,
                                                    ),
                                          ),
                                        ),
                                        if (responsiveVisibility(
                                          context: context,
                                          phone: false,
                                          tablet: false,
                                        ))
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${pedidos[index].nota}',
                                            style:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      color: corTextoStatus,
                                                      fontFamily:
                                                          'Readex Pro',
                                                      letterSpacing: 0,
                                                    ),
                                          ),
                                        ),
                                        if (responsiveVisibility(
                                          context: context,
                                          phone: false,
                                          tablet: false,
                                        ))
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${pedidos[index].codCli ?? ''}',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    color: corTextoStatus,
                                                    fontFamily:
                                                        'Readex Pro',
                                                    letterSpacing: 0,
                                                  ),
                                            ),
                                          ),
                                        if (responsiveVisibility(
                                          context: context,
                                          phone: false,
                                          tablet: false,
                                        ))
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            pedidos[index].cliente ?? '',
                                            style:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      color: corTextoStatus,
                                                      fontFamily:
                                                          'Readex Pro',
                                                      letterSpacing: 0,
                                                    ),
                                          ),
                                        ),
                                        if (responsiveVisibility(
                                          context: context,
                                          phone: false,
                                          tablet: false,
                                        ))
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '${pedidos[index].cidade}',
                                            style:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      color: corTextoStatus,
                                                      fontFamily:
                                                          'Readex Pro',
                                                      letterSpacing: 0,
                                                    ),
                                          ),
                                        ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: corFundoStatus,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8),
                                                border: Border.all(
                                                  color: corBordaStatus,
                                                ),
                                              ),
                                              child: Align(
                                                alignment:
                                                    const AlignmentDirectional(
                                                        0, 0),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          8, 4, 8, 4),
                                                  child: Text(
                                                    '${pedidos[index].caixas}',
                                                    style: FlutterFlowTheme
                                                            .of(context)
                                                        .bodySmall
                                                        .override(
                                                          color:
                                                              corTextoStatus,
                                                          fontFamily:
                                                              'Readex Pro',
                                                          letterSpacing: 0,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                ],
              ),
            ),
            Positioned(right: 0,bottom: 0, child: AtualizacaoWidget(bd: bd,context: context, usur: usur,))
          ],
        ),
      ),
    );
  }
}
