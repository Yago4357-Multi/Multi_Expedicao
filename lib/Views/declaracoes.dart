import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../Components/Model/lista_romaneios.dart';
import '../Components/Widget/atualizacao.dart';
import '../Controls/banco.dart';
import '../Models/cliente.dart';
import '../Models/declaracao.dart';
import '../Models/pedido.dart';
import '../Models/usur.dart';
import '/Components/Widget/drawer_widget.dart';
import 'lista_cancelados.dart';
import 'lista_faturados.dart';

///Página da listagem de Romaneio
class DeclaracoesWidget extends StatefulWidget {
  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///Variável para manter conexão com o Banco
  final Banco bd;

  ///Construtor da página
  const DeclaracoesWidget(this.usur, {super.key, required this.bd});

  @override
  State<DeclaracoesWidget> createState() => _DeclaracoesWidget(usur, bd);
}

class _DeclaracoesWidget extends State<DeclaracoesWidget> {
  final Usuario usur;
  final Banco bd;

  late Declaracao dec = Declaracao(0, '', 0, 0, '', endereco: '', motivo: '');

  late StateSetter internalSetter;
  DateRangePickerController datas = DateRangePickerController();

  _DeclaracoesWidget(this.usur, this.bd);

  ///Variáveis para mostrar erro no TextField
  Color corDica = Colors.green.shade400;
  Color corBorda = Colors.green.shade700;
  String dica = 'Procure uma Declaração...';

  DateTime dtIni =
      (getCurrentTimestamp.subtract(const Duration(days: 7))).startOfDay;
  DateTime dtFim = (getCurrentTimestamp.endOfDay);
  late PickerDateRange datasRange;

  late ListaRomaneiosModel _model;

  late List<int> romaneiosSelecionadoint = [];

  late Future<Cliente> cliFut;
  late Cliente? cliente;

  late Future<int> qtdFatFut;
  late Future<int> qtdCancFut;
  int qtdFat = 0;
  int qtdCanc = 0;

  late Future<List<Pedido>> pedidosResposta;
  List<Pedido> pedidos = [];
  List<Pedido> pedidosSalvos = [];

  late Future<int> ultDecFut;
  int ultDec = 0;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    datasRange = PickerDateRange(dtIni, dtFim);
    super.initState();
    _model = createModel(context, ListaRomaneiosModel.new);
    _model.expansionTileController ??= ExpansionTileController();
    _model.textController ??= TextEditingController();
    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    _model.textFieldFocusNode2 ??= FocusNode();
    rodarBanco();
  }

  void rodarBanco() async {
    pedidosResposta = bd.allDeclaracoes(dtIni, dtFim);
    ultDecFut = bd.ultDec();
    cliFut = bd.selectCliente(0);
    qtdCancFut = bd.qtdCanc();
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
            if (responsiveVisibility(
              context: context,
              phone: false,
              tablet: false,
            ))
              FutureBuilder(
                  future: qtdCancFut,
                  builder: (context, snapshot) {
                    qtdCanc = snapshot.data ?? 0;
                    if (qtdCanc > 0) {
                      return Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: SizedBox(
                              width: 120,
                              height: 50,
                              child: Row(children: [
                                Text('Canc. : $qtdCanc',
                                    style: FlutterFlowTheme
                                        .of(context)
                                        .headlineSmall
                                        .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 16,
                                        color: Colors.orange)),
                                IconButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ListaCanceladosWidget(usur, bd: bd),
                                        ));
                                  },
                                  icon: const Icon(
                                    Icons.assignment_late,
                                    color: Colors.orange,
                                  ),
                                )
                              ])));
                    } else{
                      return Container();
                    }
                  }),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_reset_outlined),
            onPressed: () async {
              pedidosResposta = bd.allDeclaracoes(dtIni, dtFim);
              setState(() {});
            },
            color: Colors.white,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 5, bottom: 5),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: IconButton(
                  onPressed: () async {
                    ultDec = await ultDecFut;
                    return showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(builder:
                            (context, void Function(void Function()) set2) {
                          internalSetter = set2;
                          return FutureBuilder(
                              future: cliFut,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  cliente = snapshot.data;
                                  dec.ped = ultDec;
                                  dec.codCli = cliente?.cod_cli;
                                  dec.cliente = cliente?.cliente;
                                  dec.cnpj = cliente?.cnpj;
                                  dec.cidade = cliente?.cidade;
                                  dec.endereco = cliente?.endereco;
                                  dec.cep = cliente?.cep;
                                  dec.telefone = cliente?.telefone_celular;
                                  return Dialog(
                                    backgroundColor: Colors.white,
                                    child: SizedBox(
                                      width: 1000,
                                      height: 800,
                                      child: Stack(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 20, top: 20),
                                                  child: Text(
                                                    'Adicionar Declarações',
                                                    textAlign: TextAlign.start,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .headlineLarge
                                                        .override(
                                                            fontFamily:
                                                                'Readex Pro',
                                                            color: Colors
                                                                .green.shade700),
                                                  )),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20, top: 20, right: 20),
                                                child: TextFormField(
                                                  cursorWidth: 0,
                                                  autofocus: true,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        'Código da Declaração',
                                                    labelStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .labelMedium
                                                        .override(
                                                          fontFamily:
                                                              'Readex Pro',
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .secondaryText,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                    alignLabelWithHint: false,
                                                    hintStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .alternate,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Colors.green.shade500,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Colors.green.shade100,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Colors.green.shade100,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                  style:
                                                      FlutterFlowTheme.of(context)
                                                          .bodyMedium,
                                                  keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(),
                                                  inputFormatters: [
                                                    LengthLimitingTextInputFormatter(
                                                        33),
                                                    FilteringTextInputFormatter
                                                        .digitsOnly,
                                                  ],
                                                  readOnly: true,
                                                  initialValue: '$ultDec',
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20, top: 20, right: 20),
                                                child: TextFormField(
                                                  cursorWidth: 1,
                                                  autofocus: true,
                                                  obscureText: false,
                                                  onChanged: (value) {
                                                    dec.motivo = value;
                                                  },
                                                  initialValue: dec.motivo ?? '',
                                                  decoration: InputDecoration(
                                                    labelText: 'Motivo',
                                                    labelStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .labelMedium
                                                        .override(
                                                          fontFamily:
                                                              'Readex Pro',
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .secondaryText,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                    alignLabelWithHint: false,
                                                    hintStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .alternate,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Colors.green.shade500,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Colors.green.shade100,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Colors.green.shade100,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                  style:
                                                      FlutterFlowTheme.of(context)
                                                          .bodyMedium,
                                                  keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              top: 20,
                                                              right: 20),
                                                      child: TextFormField(
                                                        cursorWidth: 1,
                                                        onChanged: (value) async {
                                                          if (await bd.connected(
                                                                  context) ==
                                                              1) {
                                                            dec.valor = double.parse(value.replaceAll(',','.'));
                                                          }
                                                          setState(() {});
                                                        },
                                                        autofocus: true,
                                                        obscureText: false,
                                                        initialValue: '${dec.valor ?? ''}',
                                                        decoration:
                                                            InputDecoration(
                                                          labelText: 'Valor',
                                                          labelStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                    fontSize: 14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                          alignLabelWithHint:
                                                              false,
                                                          hintStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium,
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .alternate,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade500,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium,
                                                        keyboardType:
                                                            const TextInputType
                                                                .numberWithOptions(),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              top: 20,
                                                              right: 20),
                                                      child: TextFormField(
                                                        cursorWidth: 1,
                                                        onChanged: (value) async {
                                                          if (await bd.connected(
                                                                  context) ==
                                                              1) {
                                                            dec.vol = int.parse(value);
                                                          }
                                                          setState(() {});
                                                        },
                                                        autofocus: true,
                                                        obscureText: false,
                                                        initialValue: '${dec.vol}',
                                                        decoration:
                                                            InputDecoration(
                                                          labelText: 'Volumetria',
                                                          labelStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                    fontSize: 14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                          alignLabelWithHint:
                                                              false,
                                                          hintStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium,
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .alternate,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade500,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium,
                                                        keyboardType:
                                                            const TextInputType
                                                                .numberWithOptions(),
                                                        inputFormatters: [
                                                          LengthLimitingTextInputFormatter(
                                                              33),
                                                          FilteringTextInputFormatter
                                                              .digitsOnly,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              top: 20,
                                                              right: 20),
                                                      child: TextFormField(
                                                        cursorWidth: 1,
                                                        onFieldSubmitted:
                                                            (value) async {
                                                          if (await bd.connected(
                                                                  context) ==
                                                              1) {
                                                            if (value
                                                                .isNotEmpty || value != '') {
                                                              dec.codCli = int.parse(value);
                                                              cliFut = bd
                                                                  .selectCliente(
                                                                      int.parse(
                                                                          value));
                                                              set2(() {
                                                                setState(() {});
                                                              });
                                                            }else{
                                                              cliFut = bd.selectCliente(0);
                                                            }
                                                          }
                                                        },
                                                        autofocus: true,
                                                        obscureText: false,
                                                        initialValue:
                                                            '${cliente?.cod_cli ?? ''}',
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              'Código do Cliente',
                                                          labelStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                    fontSize: 14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                          alignLabelWithHint:
                                                              false,
                                                          hintStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium,
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .alternate,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade500,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium,
                                                        keyboardType:
                                                            const TextInputType
                                                                .numberWithOptions(),
                                                        inputFormatters: [
                                                          LengthLimitingTextInputFormatter(
                                                              33),
                                                          FilteringTextInputFormatter
                                                              .digitsOnly,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              top: 20,
                                                              right: 20),
                                                      child: TextFormField(
                                                        readOnly: true,
                                                        cursorWidth: 0,
                                                        onChanged: (value) async {
                                                          if (await bd.connected(
                                                                  context) ==
                                                              1) {}
                                                          setState(() {});
                                                        },
                                                        autofocus: true,
                                                        obscureText: false,
                                                        initialValue:
                                                            cliente?.cliente ??
                                                                '',
                                                        decoration:
                                                            InputDecoration(
                                                          labelText: 'Cliente',
                                                          labelStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                    fontSize: 14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                          alignLabelWithHint:
                                                              false,
                                                          hintStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium,
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .alternate,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade500,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium,
                                                        keyboardType:
                                                            const TextInputType
                                                                .numberWithOptions(),
                                                        inputFormatters: [
                                                          LengthLimitingTextInputFormatter(
                                                              33),
                                                          FilteringTextInputFormatter
                                                              .digitsOnly,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              top: 20,
                                                              right: 20),
                                                      child: TextFormField(
                                                        readOnly: true,
                                                        cursorWidth: 0,
                                                        onChanged: (value) async {
                                                          if (await bd.connected(
                                                                  context) ==
                                                              1) {}
                                                          setState(() {});
                                                        },
                                                        autofocus: true,
                                                        obscureText: false,
                                                        initialValue:
                                                            cliente?.cnpj ?? '',
                                                        decoration:
                                                            InputDecoration(
                                                          labelText: 'CNPJ',
                                                          labelStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                    fontSize: 14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                          alignLabelWithHint:
                                                              false,
                                                          hintStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium,
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .alternate,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade500,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium,
                                                        keyboardType:
                                                            const TextInputType
                                                                .numberWithOptions(),
                                                        inputFormatters: [
                                                          LengthLimitingTextInputFormatter(
                                                              33),
                                                          FilteringTextInputFormatter
                                                              .digitsOnly,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              top: 20,
                                                              right: 20),
                                                      child: TextFormField(
                                                        readOnly: true,
                                                        cursorWidth: 0,
                                                        onChanged: (value) async {
                                                          if (await bd.connected(
                                                                  context) ==
                                                              1) {}
                                                          setState(() {});
                                                        },
                                                        autofocus: true,
                                                        obscureText: false,
                                                        initialValue:
                                                            cliente?.cidade ?? '',
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              'Cidade / Estado',
                                                          labelStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                    fontSize: 14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                          alignLabelWithHint:
                                                              false,
                                                          hintStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium,
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .alternate,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade500,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium,
                                                        keyboardType:
                                                            const TextInputType
                                                                .numberWithOptions(),
                                                        inputFormatters: [
                                                          LengthLimitingTextInputFormatter(
                                                              33),
                                                          FilteringTextInputFormatter
                                                              .digitsOnly,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              top: 20,
                                                              right: 20),
                                                      child: TextFormField(
                                                        cursorWidth: 1,
                                                        readOnly: true,
                                                        autofocus: true,
                                                        obscureText: false,
                                                        initialValue: dec.endereco ?? '',
                                                        decoration:
                                                            InputDecoration(
                                                          labelText: 'Endereço',
                                                          labelStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                    fontSize: 14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                          alignLabelWithHint:
                                                              false,
                                                          hintStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium,
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .alternate,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade500,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium,
                                                        keyboardType:
                                                            const TextInputType
                                                                .numberWithOptions(),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              top: 20,
                                                              right: 20),
                                                      child: TextFormField(
                                                        cursorWidth: 1,
                                                        readOnly: true,
                                                        autofocus: true,
                                                        obscureText: false,
                                                        initialValue: dec.cep ?? '',
                                                        decoration:
                                                            InputDecoration(
                                                          labelText: 'CEP',
                                                          labelStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                    fontSize: 14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                          alignLabelWithHint:
                                                              false,
                                                          hintStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium,
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .alternate,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade500,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium,
                                                        keyboardType:
                                                            const TextInputType
                                                                .numberWithOptions(),
                                                        inputFormatters: [
                                                          LengthLimitingTextInputFormatter(
                                                              33),
                                                          FilteringTextInputFormatter
                                                              .digitsOnly,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              top: 20,
                                                              right: 20),
                                                      child: TextFormField(
                                                        cursorWidth: 1,
                                                        initialValue: dec.telefone ?? '',
                                                        readOnly: true,
                                                        autofocus: true,
                                                        obscureText: false,
                                                        decoration:
                                                            InputDecoration(
                                                          labelText: 'Telefone',
                                                          labelStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                    fontSize: 14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                          alignLabelWithHint:
                                                              false,
                                                          hintStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium,
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .alternate,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade500,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .green.shade100,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium,
                                                        keyboardType:
                                                            const TextInputType
                                                                .numberWithOptions(),
                                                        inputFormatters: [
                                                          LengthLimitingTextInputFormatter(
                                                              33),
                                                          FilteringTextInputFormatter
                                                              .digitsOnly,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const Expanded(
                                                    flex: 4,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 20,
                                                          top: 20,
                                                          right: 20),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Positioned(
                                              bottom: 10,
                                              right: 10,
                                              child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: IconButton(
                                                    onPressed: () async {
                                                      if (dec.valor == 0 || dec.vol == 0 || dec.motivo == '' || dec.codCli == 0) {
                                                        await showCupertinoModalPopup(
                                                          context: context,
                                                          barrierDismissible: false,
                                                          builder: (context) {
                                                            return CupertinoAlertDialog(
                                                              title: const Text('Nenhum campo pode ficar em branco'),
                                                              actions: <CupertinoDialogAction>[
                                                                CupertinoDialogAction(
                                                                    isDefaultAction: true,
                                                                    onPressed: () {
                                                                      Navigator.pop(context);
                                                                    },
                                                                    child: const Text('Voltar'))
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      }else{
                                                        pedidosResposta =
                                                            bd.createDeclaracao(
                                                                dec, dtIni,
                                                                dtFim);
                                                        dec = Declaracao(
                                                            0, '', 0, 0, '',
                                                            endereco: '',
                                                            motivo: '');
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                    icon: const Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                    ),
                                                  ))),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              });
                        });
                      },
                    );
                  },
                  icon: const Icon(Icons.add)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 5, bottom: 5),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: IconButton(
                  onPressed: () async {
                    
                  },
                  icon: const Icon(Icons.edit)),
            ),
          ),
        ],
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        top: true,
        child: Stack(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: const AlignmentDirectional(0, -1),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        maxWidth: 1200,
                      ),
                      decoration: const BoxDecoration(),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                desktop: true))
                              if (responsiveVisibility(
                                context: context,
                                phone: true,
                                tablet: true,
                                desktop: false,
                              ))
                                Container(
                                  width: double.infinity,
                                  height: 24,
                                  decoration: const BoxDecoration(),
                                ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (responsiveVisibility(
                                  context: context,
                                  phone: false,
                                  tablet: false,
                                ))
                                  Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsetsDirectional.fromSTEB(
                                                16, 40, 0, 40),
                                        child: SizedBox(
                                          width: 500,
                                          child: TextFormField(
                                            canRequestFocus: true,
                                            onChanged: (value) {
                                              _model.textController2?.value =
                                                  TextEditingValue.empty;
                                              if (pedidos.length <
                                                  pedidosSalvos.length) {
                                                pedidosSalvos = pedidos;
                                              }
                                              if (value.isNotEmpty) {
                                                var x =
                                                    pedidosSalvos.where((element) {
                                                  var texto =
                                                      element.ped.toString();
                                                  texto.startsWith(value);
                                                  return texto.startsWith(value);
                                                });
                                                if (x.isNotEmpty) {
                                                } else {
                                                  dica =
                                                      'Declaração não encontrada';
                                                  corDica = Colors.red.shade400;
                                                  corBorda = Colors.red.shade700;
                                                }
                                              } else {
                                                dica = 'Procure uma Declaração...';
                                                corDica = Colors.green.shade400;
                                                corBorda = Colors.green.shade700;
                                              }
                                              setState(() {});
                                            },
                                            controller: _model.textController,
                                            focusNode: _model.textFieldFocusNode,
                                            autofocus: false,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              labelText: dica,
                                              labelStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .override(
                                                        fontFamily: 'Readex Pro',
                                                        letterSpacing: 0,
                                                      ),
                                              hintStyle:
                                                  FlutterFlowTheme.of(context)
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
                                                  color:
                                                      FlutterFlowTheme.of(context)
                                                          .error,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color:
                                                      FlutterFlowTheme.of(context)
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
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                            validator: _model
                                                .textControllerValidator
                                                .asValidator(context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                SizedBox(
                                  width: 300,
                                  height: 300,
                                  child: SfDateRangePicker(
                                    view: DateRangePickerView.month,
                                    navigationDirection:
                                        DateRangePickerNavigationDirection.vertical,
                                    maxDate: getCurrentTimestamp,
                                    startRangeSelectionColor: Colors.green.shade700,
                                    initialDisplayDate: dtFim,
                                    onSelectionChanged:
                                        (dateRangePickerSelectionChangedArgs) async {
                                      if (await bd.connected(context) == 1) {
                                        datasRange =
                                            dateRangePickerSelectionChangedArgs
                                                .value;
                                        dtIni = (datasRange.startDate ??
                                                DateTime.parse('01/01/2000'))
                                            .startOfDay;
                                        try {
                                          if (datasRange.endDate != null) {
                                            if (datasRange.endDate! >=
                                                (dtIni.add(
                                                    const Duration(days: 7)))) {
                                              dtFim = dtIni
                                                  .add(const Duration(days: 7))
                                                  .endOfDay;
                                            } else {
                                              dtFim =
                                                  (datasRange.endDate!).endOfDay;
                                            }
                                          } else {
                                            dtFim = (datasRange.endDate ?? dtIni)
                                                .endOfDay;
                                          }
                                        } catch (e) {
                                          print(e);
                                        }
                                        datasRange = PickerDateRange(dtIni, dtFim);
                                        datas.selectedRange = datasRange;
                                        pedidosResposta =
                                            bd.allDeclaracoes(dtIni, dtFim);

                                        setState(() {
                                          _model.textController?.value =
                                              TextEditingValue.empty;
                                          _model.textController2?.value =
                                              TextEditingValue.empty;
                                          dica = 'Procure por uma Declaração...';
                                          corDica = Colors.green.shade400;
                                          corBorda = Colors.green.shade700;
                                        });
                                      }
                                      setState(() {});
                                    },
                                    monthViewSettings:
                                        const DateRangePickerMonthViewSettings(
                                      weekendDays: [6, 7],
                                      weekNumberStyle:
                                          DateRangePickerWeekNumberStyle(
                                              backgroundColor: Colors.grey,
                                              textStyle: TextStyle(
                                                  fontWeight: FontWeight.w200)),
                                    ),
                                    initialSelectedRange:
                                        PickerDateRange(dtIni, dtFim),
                                    headerStyle: const DateRangePickerHeaderStyle(
                                        backgroundColor: Colors.white,
                                        textStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        )),
                                    allowViewNavigation: false,
                                    showNavigationArrow: true,
                                    monthFormat: 'MM',
                                    rangeSelectionColor: Colors.green.shade100,
                                    backgroundColor: Colors.white,
                                    endRangeSelectionColor: Colors.green.shade700,
                                    selectionColor: Colors.green.shade200,
                                    todayHighlightColor: Colors.green.shade600,
                                    selectionMode:
                                        DateRangePickerSelectionMode.range,
                                    controller: datas,
                                  ),
                                )
                              ],
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
                            ),
                            FutureBuilder(
                                future: pedidosResposta,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (pedidosSalvos != snapshot.data) {
                                      pedidos = snapshot.data ?? [];
                                      pedidosSalvos = pedidos;
                                    }
                                    return ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: pedidosSalvos.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0, 0, 0, 10),
                                            child: Container(
                                              padding:
                                                  const EdgeInsetsDirectional.all(
                                                      10),
                                              height: 130,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Column(
                                                    mainAxisSize: MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      RichText(
                                                        textAlign: TextAlign.start,
                                                        text: TextSpan(
                                                          children: [
                                                            const TextSpan(
                                                              text: 'Declaração \n',
                                                              style: TextStyle(
                                                                  fontSize: 12),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  '${pedidosSalvos[index].ped}',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmall
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    letterSpacing:
                                                                        0,
                                                                    fontSize: 20,
                                                                  ),
                                                            )
                                                          ],
                                                          style:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyLarge
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                  ),
                                                        ),
                                                      ),
                                                      RichText(
                                                        textAlign: TextAlign.start,
                                                        overflow: TextOverflow.fade,
                                                        softWrap: true,
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: 'Nota : ',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmall
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    letterSpacing:
                                                                        0,
                                                                    fontSize: 10,
                                                                  ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  '${pedidosSalvos[index].nota}',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmall
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    letterSpacing:
                                                                        0,
                                                                    fontSize: 12,
                                                                  ),
                                                            )
                                                          ],
                                                          style:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyLarge
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                  ),
                                                        ),
                                                      ),
                                                      RichText(
                                                        textAlign: TextAlign.end,
                                                        text: TextSpan(
                                                          children: [
                                                            const TextSpan(
                                                              text: 'Volumetria : ',
                                                              style: TextStyle(
                                                                  fontSize: 10),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  '${pedidosSalvos[index].vol}',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmall
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    letterSpacing:
                                                                        0,
                                                                    fontSize: 14,
                                                                  ),
                                                            )
                                                          ],
                                                          style:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyLarge
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                  ),
                                                        ),
                                                      ),
                                                      RichText(
                                                        textAlign: TextAlign.end,
                                                        text: TextSpan(
                                                          children: [
                                                            const TextSpan(
                                                              text: 'Palete : ',
                                                              style: TextStyle(
                                                                  fontSize: 10),
                                                            ),
                                                            TextSpan(
                                                              text: pedidosSalvos[
                                                                      index]
                                                                  .palete,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmall
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    letterSpacing:
                                                                        0,
                                                                    fontSize: 14,
                                                                  ),
                                                            )
                                                          ],
                                                          style:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyLarge
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                  ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Flexible(
                                                    flex: 2,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20),
                                                      child: SizedBox(
                                                        width: 400,
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            RichText(
                                                              textAlign:
                                                                  TextAlign.start,
                                                              overflow:
                                                                  TextOverflow.fade,
                                                              softWrap: true,
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        'Cliente \n ',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Readex Pro',
                                                                          letterSpacing:
                                                                              0,
                                                                          fontSize:
                                                                              10,
                                                                        ),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        '${pedidosSalvos[index].codCli} - ${pedidosSalvos[index].cliente}',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Readex Pro',
                                                                          letterSpacing:
                                                                              0,
                                                                          fontSize:
                                                                              12,
                                                                        ),
                                                                  )
                                                                ],
                                                                style: FlutterFlowTheme
                                                                        .of(context)
                                                                    .bodyLarge
                                                                    .override(
                                                                      fontFamily:
                                                                          'Readex Pro',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                    ),
                                                              ),
                                                            ),
                                                            RichText(
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        'Cidade \n ',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Readex Pro',
                                                                          letterSpacing:
                                                                              0,
                                                                          fontSize:
                                                                              10,
                                                                        ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: pedidosSalvos[
                                                                            index]
                                                                        .cidade,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Readex Pro',
                                                                          letterSpacing:
                                                                              0,
                                                                          fontSize:
                                                                              12,
                                                                        ),
                                                                  )
                                                                ],
                                                                style: FlutterFlowTheme
                                                                        .of(context)
                                                                    .bodyLarge
                                                                    .override(
                                                                      fontFamily:
                                                                          'Readex Pro',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 150,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.center,
                                                      children: [
                                                        RichText(
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: 'R\$ ',
                                                                style: FlutterFlowTheme
                                                                        .of(context)
                                                                    .labelSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          'Readex Pro',
                                                                      letterSpacing:
                                                                          0,
                                                                      fontSize: 16,
                                                                    ),
                                                              ),
                                                              TextSpan(
                                                                text: (((NumberFormat('#,##0.0',
                                                                                    'pt_BR')
                                                                                .format(pedidosSalvos[index]
                                                                                    .valor))
                                                                            .replaceAll(
                                                                                '.',
                                                                                ':'))
                                                                        .replaceAll(
                                                                            '.',
                                                                            ','))
                                                                    .replaceAll(
                                                                        ':', '.'),
                                                                style: FlutterFlowTheme
                                                                        .of(context)
                                                                    .labelSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          'Readex Pro',
                                                                      letterSpacing:
                                                                          0,
                                                                      fontSize: 20,
                                                                    ),
                                                              )
                                                            ],
                                                            style:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyLarge
                                                                    .override(
                                                                      fontFamily:
                                                                          'Readex Pro',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                    ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ));
                                      },
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(right: 0,bottom: 0, child: AtualizacaoWidget(bd: bd,context: context, usur: usur,))
          ],
        ),
      ),
    );
  }
}
