import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '/Components/Widget/drawer_widget.dart';
import '../Components/Model/lista_romaneios.dart';
import '../Components/Widget/atualizacao.dart';
import '../Controls/banco.dart';
import '../Models/pedido.dart';
import '../Models/romaneio.dart';
import '../Models/usur.dart';
import 'lista_cancelados.dart';
import 'lista_faturados.dart';

///Página da listagem de Romaneio
class ListaRomaneiosWidget extends StatefulWidget {
  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///Variável para manter conexão com o Banco
  final Banco bd;

  ///Construtor da página
  const ListaRomaneiosWidget(this.usur, {super.key, required this.bd});

  @override
  State<ListaRomaneiosWidget> createState() => _ListaRomaneiosWidget(usur, bd);
}

class _ListaRomaneiosWidget extends State<ListaRomaneiosWidget> {
  final Usuario usur;
  final Banco bd;

  DateRangePickerController datas = DateRangePickerController();

  _ListaRomaneiosWidget(this.usur, this.bd);

  ///Variáveis para mostrar erro no TextField
  Color corDica = Colors.green.shade400;
  Color corBorda = Colors.green.shade700;
  String dica = 'Procure um Romaneio...';

  ///Variáveis para mostrar erro no TextField do Pedido
  Color corDica2 = Colors.green.shade400;
  Color corBorda2 = Colors.green.shade700;
  String dica2 = 'Procure um Pedido...';

  DateTime dtIni =
      (getCurrentTimestamp.subtract(const Duration(days: 31))).startOfDay;
  DateTime dtFim = (getCurrentTimestamp.endOfDay);
  late PickerDateRange datasRange;

  late StateSetter internalSetter;
  late ListaRomaneiosModel _model;

  late List<int> romaneiosSelecionadoint = [];

  ///Variáveis para Salvar e Modelar pedidos
  late Future<List<Romaneio>> romaneioResposta;
  List<Romaneio> romaneios = [];
  List<Romaneio> romaneiosSalvos = [];

  late Future<int> qtdFatFut;
  late Future<int> qtdCancFut;
  int qtdFat = 0;
  int qtdCanc = 0;


  late Future<List<Pedido>> pedidosResposta;
  List<Pedido> pedidos = [];
  List<Pedido> pedidosSalvos = [];

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
    romaneioResposta = bd.romaneiosFinalizados(dtIni, dtFim);
    qtdCancFut = bd.qtdCanc();
    qtdFatFut = bd.qtdFat();
    var teste = await romaneioResposta;
    for (var i in teste) {
      romaneiosSelecionadoint.add(i.romaneio!);
    }
          pedidosResposta = bd.selectpedidosromaneio(romaneiosSelecionadoint);
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
          IconButton(icon: const Icon(Icons.lock_reset_outlined),onPressed: () async {
            romaneioResposta = bd.romaneiosFinalizados(dtIni, dtFim);
            var teste = await romaneioResposta;
            for (var i in teste) {
              romaneiosSelecionadoint.add(i.romaneio!);
            }
            pedidosResposta = bd.selectpedidosromaneio(romaneiosSelecionadoint);
            setState(() {
            });
          }, color: Colors.white,),
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
                        maxWidth: 970,
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
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            16, 40, 0, 40),
                                        child: SizedBox(
                                          width: 500,
                                          child: TextFormField(
                                            canRequestFocus: true,
                                            onChanged: (value) {
                                              _model.textController2?.value = TextEditingValue.empty;
                                                if (romaneiosSalvos.length <
                                                    romaneios.length) {
                                                  romaneiosSalvos = romaneios;
                                                }
                                                if (value.isNotEmpty) {
                                                  var x =
                                                  romaneiosSalvos.where((element) {
                                                    var texto =
                                                    element.romaneio.toString();
                                                    texto.startsWith(value);
                                                    return texto.startsWith(value);
                                                  });
                                                  if (x.isNotEmpty) {
                                                    romaneios = x.toList();
                                                  } else {
                                                    romaneios = [];
                                                    dica = 'Romaneio não encontrado';
                                                    corDica = Colors.red.shade400;
                                                    corBorda = Colors.red.shade700;
                                                  }
                                                } else {
                                                  romaneios = romaneiosSalvos;
                                                  dica = 'Procure por um Romaneio...';
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
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            16, 40, 0, 40),
                                        child: SizedBox(
                                          width: 500,
                                          child: TextFormField(
                                            canRequestFocus: true,
                                            controller: _model.textController2,
                                            onChanged: (value) {
                                              if (pedidosSalvos.length <
                                                    pedidos.length) {

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
                                                    pedidos = x.toList();
                                                  } else {
                                                    pedidos = [];
                                                    dica2 = 'Pedido não encontrado';
                                                    corDica2 = Colors.red.shade400;
                                                    corBorda2 = Colors.red.shade700;
                                                  }
                                                } else {
                                                  pedidos = pedidosSalvos;
                                                  dica2 = 'Procure por um Pedido...';
                                                  corDica2 = Colors.green.shade400;
                                                  corBorda2 = Colors.green.shade700;
                                                }
                                              for( var i in pedidos){
                                                romaneios = romaneiosSalvos.where((element) => element.romaneio == i.romaneio).toList();
                                              }
                                              setState(() {

                                              });
                                            },
                                            focusNode: _model.textFieldFocusNode2,
                                            autofocus: false,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              labelText: dica2,
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
                                                  color: corBorda2,
                                                  width: 2,
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: corDica2,
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
                                            validator: _model.textControllerValidator2
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
                                                (dtIni.add(const Duration(
                                                    days: 31)))) {
                                              dtFim = dtIni
                                                  .add(const Duration(days: 31))
                                                  .endOfDay;
                                            } else {
                                              dtFim = (datasRange.endDate!).endOfDay;
                                            }
                                          } else {
                                            dtFim = (datasRange.endDate ?? dtIni)
                                                .endOfDay;
                                          }
                                        } catch(e){
                                          print(e);
                                        }
                                        datasRange = PickerDateRange(dtIni, dtFim);
                                        datas.selectedRange = datasRange;
                                        romaneioResposta =
                                            bd.romaneiosFinalizados(dtIni, dtFim);
                                        var teste = await romaneioResposta;
                                        if (teste.isNotEmpty) {
                                          for (var i in teste) {
                                            if (romaneiosSelecionadoint.contains(i.romaneio!) == false){
                                              romaneiosSelecionadoint.add(
                                                  i.romaneio!);
                                            }
                                          }
                                          pedidosResposta =
                                              bd.selectpedidosromaneio(
                                                  romaneiosSelecionadoint);
                                        }

                                        setState(() {
                                          _model.textController?.value = TextEditingValue.empty;
                                          _model.textController2?.value = TextEditingValue.empty;
                                          dica = 'Procure por um Romaneio...';
                                          corDica = Colors.green.shade400;
                                          corBorda = Colors.green.shade700;
                                          dica2 = 'Procure por um Pedido...';
                                          corDica2 = Colors.green.shade400;
                                          corBorda2 = Colors.green.shade700;
                                        });
                                      }
                                      setState(() {});
                                    },
                                    minDate: DateTime.utc(2024, 6, 5),
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
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16, 0, 0, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Romaneio',
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
                                        child: Padding(
                                          padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 4, 40, 4),
                                          child: Text(
                                            'Volumes',
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
                                    if (responsiveVisibility(
                                      context: context,
                                      phone: false,
                                      tablet: false,
                                    ))
                                      Expanded(
                                        child: Padding(
                                          padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 4, 40, 4),
                                          child: Text(
                                            'Dt. Fechamento',
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
                                    if (responsiveVisibility(
                                      context: context,
                                      phone: false,
                                      tablet: false,
                                    ))
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0, 4, 40, 4),
                                          child: Text(
                                            'Transportadora',
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
                              future: romaneioResposta,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (romaneiosSalvos != snapshot.data) {
                                    romaneios = snapshot.data ?? [];
                                    romaneiosSalvos = romaneios;
                                  }
                                  return FutureBuilder(
                                      future: pedidosResposta,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          if (pedidosSalvos != snapshot.data) {
                                            pedidos = snapshot.data ?? [];
                                            pedidosSalvos = pedidos;
                                          }
                                          return ListView.builder(
                                            itemCount: romaneios.length,
                                            padding: const EdgeInsets.fromLTRB(
                                              0,
                                              0,
                                              0,
                                              44,
                                            ),
                                            reverse: true,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              var corStatus =
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground;
                                              var corTextoStatus = Colors.black;
                                              var pedidosRomaneio = pedidos
                                                  .where((element) =>
                                              element.romaneio ==
                                                  romaneios[index].romaneio)
                                                  .toList();
                                              if (pedidosRomaneio.isNotEmpty) {
                                                return Padding(
                                                  padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 10, 0, 0),
                                                  child: Theme(
                                                    data: ThemeData(
                                                        splashColor:
                                                        Colors.transparent,
                                                        hoverColor:
                                                        Colors.transparent,
                                                        highlightColor:
                                                        Colors.transparent),
                                                    child: ExpansionTile(
                                                      enableFeedback: true,
                                                      childrenPadding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          35, 0, 80, 0),
                                                      expansionAnimationStyle:
                                                      AnimationStyle
                                                          .noAnimation,
                                                      shape: Border.all(
                                                          color:
                                                          Colors.transparent),
                                                      title: Container(
                                                        width: double.infinity,
                                                        decoration: BoxDecoration(
                                                          color: corStatus,
                                                          borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  20)),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                              16, 12, 16, 12),
                                                          child: Row(
                                                            mainAxisSize:
                                                            MainAxisSize.max,
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  '${romaneios[index].romaneio}',
                                                                  style: FlutterFlowTheme
                                                                      .of(context)
                                                                      .bodyMedium
                                                                      .override(
                                                                    color:
                                                                    corTextoStatus,
                                                                    fontFamily:
                                                                    'Readex Pro',
                                                                    letterSpacing:
                                                                    0,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  textAlign:
                                                                  TextAlign
                                                                      .center,
                                                                  '${romaneios[index].vol!}',
                                                                  style: FlutterFlowTheme
                                                                      .of(context)
                                                                      .bodyMedium
                                                                      .override(
                                                                    color:
                                                                    corTextoStatus,
                                                                    fontFamily:
                                                                    'Readex Pro',
                                                                    letterSpacing:
                                                                    0,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  textAlign:
                                                                  TextAlign
                                                                      .center,
                                                                  DateFormat(
                                                                      'HH:mm dd/MM/yyyy')
                                                                      .format(romaneios[
                                                                  index]
                                                                      .dtFechamento!),
                                                                  style: FlutterFlowTheme
                                                                      .of(context)
                                                                      .bodyMedium
                                                                      .override(
                                                                    color:
                                                                    corTextoStatus,
                                                                    fontFamily:
                                                                    'Readex Pro',
                                                                    letterSpacing:
                                                                    0,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  romaneios[index]
                                                                          .transportadora ??
                                                                      'Não cadastrada',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        color:
                                                                            corTextoStatus,
                                                                        fontFamily:
                                                                            'Readex Pro',
                                                                        letterSpacing:
                                                                            0,
                                                                      ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      children: [
                                                        ListView.builder(
                                                          scrollDirection:
                                                          Axis.vertical,
                                                          shrinkWrap: true,
                                                          itemCount: pedidosRomaneio
                                                              .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return Padding(
                                                                padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(0,
                                                                    0, 0, 10),
                                                                child: Container(
                                                                  padding:
                                                                  const EdgeInsetsDirectional
                                                                      .all(10),
                                                                  height: 130,
                                                                  decoration:
                                                                  BoxDecoration(
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                        20),
                                                                    color:
                                                                    corStatus,
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                    mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                    children: [
                                                                      Column(
                                                                        mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                        mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                        crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                        children: [
                                                                          RichText(
                                                                            textAlign:
                                                                            TextAlign.start,
                                                                            text:
                                                                            TextSpan(
                                                                              children: [
                                                                                const TextSpan(
                                                                                  text: 'Pedido \n',
                                                                                  style: TextStyle(fontSize: 12),
                                                                                ),
                                                                                TextSpan(
                                                                                  text: '${pedidosRomaneio[index].ped}',
                                                                                  style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                    fontSize: 20,
                                                                                  ),
                                                                                )
                                                                              ],
                                                                              style: FlutterFlowTheme.of(context)
                                                                                  .bodyLarge
                                                                                  .override(
                                                                                fontFamily: 'Readex Pro',
                                                                                fontWeight: FontWeight.normal,
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
                                                                                  style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                    fontSize: 10,
                                                                                  ),
                                                                                ),
                                                                                TextSpan(
                                                                                  text: '${pedidosRomaneio[index].nota}',
                                                                                  style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                    fontSize: 12,
                                                                                  ),
                                                                                )
                                                                              ],
                                                                              style: FlutterFlowTheme.of(context).bodyLarge.override(
                                                                                fontFamily: 'Readex Pro',
                                                                                fontWeight: FontWeight.normal,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          RichText(
                                                                            textAlign:
                                                                            TextAlign.end,
                                                                            text:
                                                                            TextSpan(
                                                                              children: [
                                                                                const TextSpan(
                                                                                  text: 'Volumetria : ',
                                                                                  style: TextStyle(fontSize: 10),
                                                                                ),
                                                                                TextSpan(
                                                                                  text: '${pedidosRomaneio[index].vol}',
                                                                                  style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                    fontSize: 14,
                                                                                  ),
                                                                                )
                                                                              ],
                                                                              style: FlutterFlowTheme.of(context)
                                                                                  .bodyLarge
                                                                                  .override(
                                                                                fontFamily: 'Readex Pro',
                                                                                fontWeight: FontWeight.normal,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          RichText(
                                                                            textAlign:
                                                                            TextAlign.end,
                                                                            text:
                                                                            TextSpan(
                                                                              children: [
                                                                                const TextSpan(
                                                                                  text: 'Palete : ',
                                                                                  style: TextStyle(fontSize: 10),
                                                                                ),
                                                                                TextSpan(
                                                                                  text: pedidosRomaneio[index].palete,
                                                                                  style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                    fontSize: 14,
                                                                                  ),
                                                                                )
                                                                              ],
                                                                              style: FlutterFlowTheme.of(context)
                                                                                  .bodyLarge
                                                                                  .override(
                                                                                fontFamily: 'Readex Pro',
                                                                                fontWeight: FontWeight.normal,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Flexible(
                                                                        flex: 2,
                                                                        child:
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left:
                                                                              20),
                                                                          child:
                                                                          SizedBox(
                                                                            width:
                                                                            400,
                                                                            child:
                                                                            Column(
                                                                              mainAxisSize:
                                                                              MainAxisSize.max,
                                                                              crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                              mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                              children: [
                                                                                RichText(
                                                                                  textAlign: TextAlign.start,
                                                                                  overflow: TextOverflow.fade,
                                                                                  softWrap: true,
                                                                                  text: TextSpan(
                                                                                    children: [
                                                                                      TextSpan(
                                                                                        text: 'Cliente \n ',
                                                                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                          fontFamily: 'Readex Pro',
                                                                                          letterSpacing: 0,
                                                                                          fontSize: 10,
                                                                                        ),
                                                                                      ),
                                                                                      TextSpan(
                                                                                        text: '${pedidosRomaneio[index].codCli} - ${pedidosRomaneio[index].cliente}',
                                                                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                          fontFamily: 'Readex Pro',
                                                                                          letterSpacing: 0,
                                                                                          fontSize: 12,
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                                                                                      fontFamily: 'Readex Pro',
                                                                                      fontWeight: FontWeight.normal,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                RichText(
                                                                                  text: TextSpan(
                                                                                    children: [
                                                                                      TextSpan(
                                                                                        text: 'Cidade \n ',
                                                                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                          fontFamily: 'Readex Pro',
                                                                                          letterSpacing: 0,
                                                                                          fontSize: 10,
                                                                                        ),
                                                                                      ),
                                                                                      TextSpan(
                                                                                        text: pedidosRomaneio[index].cidade,
                                                                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                          fontFamily: 'Readex Pro',
                                                                                          letterSpacing: 0,
                                                                                          fontSize: 12,
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                                                                                      fontFamily: 'Readex Pro',
                                                                                      fontWeight: FontWeight.normal,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Flexible(
                                                                        flex: 1,
                                                                        child:
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left:
                                                                              20),
                                                                          child:
                                                                          SizedBox(
                                                                            width:
                                                                            400,
                                                                            child:
                                                                            Column(
                                                                              mainAxisSize:
                                                                              MainAxisSize.max,
                                                                              crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                              mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                              children: [
                                                                                RichText(
                                                                                  textAlign: TextAlign.start,
                                                                                  overflow: TextOverflow.fade,
                                                                                  softWrap: true,
                                                                                  text: TextSpan(
                                                                                    children: [
                                                                                      TextSpan(
                                                                                        text: 'Dt. Pedido \n ',
                                                                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                          fontFamily: 'Readex Pro',
                                                                                          letterSpacing: 0,
                                                                                          fontSize: 10,
                                                                                        ),
                                                                                      ),
                                                                                      TextSpan(
                                                                                        text: pedidosRomaneio[index].dtPedido != null ? DateFormat('dd/MM/yyyy').format(pedidosRomaneio[index].dtPedido!) : '',
                                                                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                          fontFamily: 'Readex Pro',
                                                                                          letterSpacing: 0,
                                                                                          fontSize: 12,
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                                                                                      fontFamily: 'Readex Pro',
                                                                                      fontWeight: FontWeight.normal,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                RichText(
                                                                                  text: TextSpan(
                                                                                    children: [
                                                                                      TextSpan(
                                                                                        text: 'Dt. Faturamento \n ',
                                                                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                          fontFamily: 'Readex Pro',
                                                                                          letterSpacing: 0,
                                                                                          fontSize: 10,
                                                                                        ),
                                                                                      ),
                                                                                      TextSpan(
                                                                                        text: pedidosRomaneio[index].dtFat != null ? DateFormat('dd/MM/yyyy').format(pedidosRomaneio[index].dtFat!) : '',
                                                                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                          fontFamily: 'Readex Pro',
                                                                                          letterSpacing: 0,
                                                                                          fontSize: 12,
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                                                                                      fontFamily: 'Readex Pro',
                                                                                      fontWeight: FontWeight.normal,
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
                                                                        child:
                                                                        Column(
                                                                          mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                          crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                          mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                          children: [
                                                                            RichText(
                                                                              text:
                                                                              TextSpan(
                                                                                children: [
                                                                                  TextSpan(
                                                                                    text: 'R\$ ',
                                                                                    style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                      fontFamily: 'Readex Pro',
                                                                                      letterSpacing: 0,
                                                                                      fontSize: 16,
                                                                                    ),
                                                                                  ),
                                                                                  TextSpan(
                                                                                    text: (((NumberFormat('#,##0.0', 'pt_BR').format(pedidosRomaneio[index].valor)).replaceAll('.', ':')).replaceAll('.', ',')).replaceAll(':', '.'),
                                                                                    style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                      fontFamily: 'Readex Pro',
                                                                                      letterSpacing: 0,
                                                                                      fontSize: 20,
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                                style: FlutterFlowTheme.of(context).bodyLarge.override(
                                                                                  fontFamily: 'Readex Pro',
                                                                                  fontWeight: FontWeight.normal,
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
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }
                                              return Container();
                                            },
                                          );
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      });
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              },
                            ),
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
