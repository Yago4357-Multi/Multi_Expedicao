import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../Components/Model/lista_faturados.dart';
import '../Controls/banco.dart';
import '../Models/palete.dart';
import '../Models/pedido.dart';
import '../Models/usur.dart';
import '/Components/Widget/drawer_widget.dart';

///Página da listagem de Romaneio
class ListaFaturadosWidget extends StatefulWidget {
  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///Variável para manter conexão com o Banco
  final Banco bd;

  ///Construtor da página
  const ListaFaturadosWidget(this.usur, {super.key, required this.bd});

  @override
  State<ListaFaturadosWidget> createState() => _ListaFaturadosWidget(usur, bd);
}

class _ListaFaturadosWidget extends State<ListaFaturadosWidget> {
  final Usuario usur;
  final Banco bd;

  DateRangePickerController datas = DateRangePickerController();

  _ListaFaturadosWidget(this.usur, this.bd);

  ///Variáveis para mostrar erro no TextField
  Color corDica = Colors.green.shade400;
  Color corBorda = Colors.green.shade700;
  String dica = 'Procure um pedido...';

  DateTime dtIni =
      (getCurrentTimestamp.subtract(const Duration(days: 7))).startOfDay;
  DateTime? dtFim = (getCurrentTimestamp).endOfDay;
  late PickerDateRange datasRange;

  late StateSetter internalSetter;
  late ListaFaturadosModel _model;

  late List<Paletes> palete = [];
  late List<int> paleteSelecionadoint = [];

  ///Variáveis para Salvar e Modelar pedidos
  late Future<List<Pedido>> pedidoResposta;
  List<Pedido> pedidos = [];
  List<Pedido> pedidosSalvos = [];

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    datasRange = PickerDateRange(dtIni, dtFim);
    super.initState();
    _model = createModel(context, ListaFaturadosModel.new);
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    _model.choiceChipsValue;
    _model.choiceChipsValueController = FormFieldController<List<String>>(
      ['Todos'],
    );
    rodarBanco();
  }

  void rodarBanco() async {
    pedidoResposta = bd.faturadosNBipados(dtIni, dtFim!);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_reset_outlined),
            onPressed: () async {
              pedidoResposta = bd.faturadosNBipados(dtIni, dtFim!);
              setState(() {});
            },
            color: Colors.white,
          ),
        ],
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
              child: Align(
                alignment: const AlignmentDirectional(0, -1),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    maxWidth: 1000,
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
                                  FlutterFlowChoiceChips(
                                      options: const [
                                        ChipData('Todos'),
                                        ChipData('N Ignorados'),
                                      ],
                                      onChanged: (val) {
                                        setState(() {
                                          if (_model.choiceChipsValue == 'Todos') {
                                            pedidos = pedidosSalvos;
                                          } else {
                                            pedidos = pedidosSalvos
                                                .where((element) =>
                                            element.ignorar ==
                                                false)
                                                .toList();
                                          }
                                        });
                                      },
                                      selectedChipStyle: ChipStyle(
                                        backgroundColor: Colors.green.shade700,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                          fontFamily: 'Readex Pro',
                                          color:
                                          FlutterFlowTheme.of(context).info,
                                          letterSpacing: 0,
                                        ),
                                        iconColor:
                                        FlutterFlowTheme.of(context).info,
                                        iconSize: 18,
                                        elevation: 2,
                                        borderColor:
                                        FlutterFlowTheme.of(context).accent1,
                                        borderWidth: 1,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      unselectedChipStyle: ChipStyle(
                                        backgroundColor:
                                        FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                          fontFamily: 'Readex Pro',
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          letterSpacing: 0,
                                        ),
                                        iconColor: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        iconSize: 18,
                                        elevation: 0,
                                        borderColor:
                                        FlutterFlowTheme.of(context).alternate,
                                        borderWidth: 1,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      chipSpacing: 8,
                                      rowSpacing: 12,
                                      multiselect: false,
                                      alignment: WrapAlignment.start,
                                      controller:
                                      _model.choiceChipsValueController!),
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
                                      _model.choiceChipsValueController?.value = ['Todos'];
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
                                              .startOfDay;
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
                                    setState(() {});
                                    pedidoResposta =
                                        bd.faturadosNBipados(dtIni, dtFim);
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
                                  return Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 960,
                                          decoration: BoxDecoration(
                                            color: corStatus,
                                            borderRadius:
                                                const BorderRadius.all(
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
                                                    flex: 1,
                                                    child: Text(
                                                      '${pedidos[index].nota}',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            color:
                                                                corTextoStatus,
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
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            color:
                                                                corTextoStatus,
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
                                                      pedidos[index].cliente ??
                                                          '',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            color:
                                                                corTextoStatus,
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
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            color:
                                                                corTextoStatus,
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
                                                          '${pedidos[index].vol}',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodySmall
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
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Checkbox(
                                            value: pedidos[index].ignorar,
                                            onChanged: (value) async {
                                              bd.updateIgnorar(
                                                  pedidos[index].ped, value);
                                              pedidoResposta =
                                                  bd.faturadosNBipados(
                                                      dtIni, dtFim!);
                                              setState(() {});
                                            })
                                      ],
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
