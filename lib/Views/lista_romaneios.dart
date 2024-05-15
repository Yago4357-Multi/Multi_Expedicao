import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../Components/Model/lista_romaneios.dart';
import '../Controls/banco.dart';
import '../Models/palete.dart';
import '../Models/romaneio.dart';
import '../Models/usur.dart';
import '/Components/Widget/drawer_widget.dart';

///Página da listagem de Romaneio
class ListaRomaneiosWidget extends StatefulWidget {
  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///Construtor da página
  const ListaRomaneiosWidget(this.usur, {super.key});

  @override
  State<ListaRomaneiosWidget> createState() =>
      _ListaRomaneiosWidget(usur);
}

class _ListaRomaneiosWidget extends State<ListaRomaneiosWidget> {
  final Usuario usur;

  DateRangePickerController datas = DateRangePickerController();

  _ListaRomaneiosWidget(this.usur);

  ///Variáveis para mostrar erro no TextField
  Color corDica = Colors.green.shade400;
  Color corBorda = Colors.green.shade700;
  String dica = 'Procure um Romaneio...';

  DateTime dt_ini = (getCurrentTimestamp.subtract(const Duration(days: 30))).startOfDay;
  DateTime dt_fim = (getCurrentTimestamp.endOfDay);
  late PickerDateRange datasRange;


  late StateSetter internalSetter;
  late ListaRomaneiosModel _model;


  late List<Paletes> palete = [];
  late List<int> paleteSelecionadoint = [];

  ///Variáveis para Salvar e Modelar pedidos
  late Future<List<Romaneio>> pedidoResposta;
  List<Romaneio> pedidos = [];
  List<Romaneio> pedidosSalvos = [];

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final Banco bd = Banco();

  @override
  void initState() {
    datasRange = PickerDateRange(dt_ini, dt_fim);
    super.initState();
    _model = createModel(context, ListaRomaneiosModel.new);
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    rodarBanco();
  }

  void rodarBanco() async {
    pedidoResposta = bd.romaneiosFinalizados(dt_ini, dt_fim);
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
            usur: usur,context: context,
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
                            desktop: true
                        ))

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
                                          var x = pedidosSalvos.where((element) {
                                            var texto = element.romaneio.toString();
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
                                          color:
                                          FlutterFlowTheme.of(context).error,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                          FlutterFlowTheme.of(context).error,
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
                            SizedBox(
                              width: 300,
                              height: 300,
                              child: SfDateRangePicker(
                                view: DateRangePickerView.year,
                                navigationDirection: DateRangePickerNavigationDirection.vertical,
                                maxDate: getCurrentTimestamp,
                                startRangeSelectionColor: Colors.green.shade700,
                                initialDisplayDate: dt_fim,
                                onSelectionChanged: (dateRangePickerSelectionChangedArgs) async {
                                  datasRange = dateRangePickerSelectionChangedArgs.value;
                                  dt_ini = (datasRange.startDate ?? DateTime.parse('01/01/2000')).startOfDay;
                                  dt_fim = (datasRange.endDate ?? DateTime(dt_ini.year,dt_ini.month + 1, 0)).endOfDay;
                                  datasRange = PickerDateRange(dt_ini, dt_fim);
                                  print(datasRange);
                                  pedidoResposta = bd.romaneiosFinalizados(dt_ini, dt_fim);
                                  setState(() {});
                                },
                                monthViewSettings: const DateRangePickerMonthViewSettings(
                                  weekendDays: [6,7],
                                  weekNumberStyle: DateRangePickerWeekNumberStyle(backgroundColor: Colors.grey, textStyle: TextStyle(fontWeight: FontWeight.w200) ),
                                ),
                                initialSelectedRange: PickerDateRange(dt_ini, dt_fim),
                                headerStyle: const DateRangePickerHeaderStyle(
                                  backgroundColor: Colors.white,
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  )
                                ),
                                allowViewNavigation: false,
                                showNavigationArrow: true,
                                monthFormat: 'MM',
                                rangeSelectionColor: Colors.green.shade100,
                                backgroundColor: Colors.white,
                                endRangeSelectionColor: Colors.green.shade700,
                                selectionColor: Colors.green.shade200,
                                todayHighlightColor: Colors.green.shade600,
                                selectionMode: DateRangePickerSelectionMode.range,
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
                                  var corTextoStatus = Colors.black;
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0, 10, 0, 0),
                                    child: Theme(
                                      data: ThemeData(splashColor: Colors.transparent, hoverColor: Colors.transparent, highlightColor: Colors.transparent),
                                      child: ExpansionTile(
                                        expansionAnimationStyle: AnimationStyle.noAnimation,
                                        shape: Border.all(color: Colors.transparent),
                                        title: Container(
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
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${pedidos[index].romaneio}',
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
                                                Expanded(
                                                  child: Text(textAlign: TextAlign.center,
                                                    '${pedidos[index].vol!}',
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
                                                Expanded(
                                                  child: Text(textAlign: TextAlign.center,
                                                    DateFormat('HH:mm dd/MM/yyyy').format(pedidos[index].dtFechamento!),
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
                                              ],
                                            ),
                                          ),
                                        ),
                                        children: [
                                          Container(color: Colors.red,child: Text('TESTO'),),
                                          Container(color: Colors.green,)
                                        ],

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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
