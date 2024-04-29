import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../Components/Model/lista_romaneio.dart';
import '../Controls/banco.dart';
import '../Models/palete.dart';
import '../Models/pedido.dart';
import '../Models/usur.dart';
import '/Components/Widget/drawer_widget.dart';
import 'lista_pedido_widget.dart';
import 'progress_widget.dart';

///Página da listagem de Romaneio
class ListaRomaneioWidget extends StatefulWidget {
  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///Variável para puxar o número do romaneio
  final int romaneio;

  ///Construtor da página
  const ListaRomaneioWidget(this.romaneio, this.usur, {super.key});

  @override
  State<ListaRomaneioWidget> createState() =>
      _ListaRomaneioWidgetState(romaneio, usur);
}

class _ListaRomaneioWidgetState extends State<ListaRomaneioWidget> {
  int romaneio;
  final Usuario usur;
  late final pdf = pw.Document(title: 'Romaneio $romaneio');

  _ListaRomaneioWidgetState(this.romaneio, this.usur);

  ///Variáveis para mostrar erro no TextField
  Color corDica = Colors.green.shade400;
  Color corBorda = Colors.green.shade700;
  String dica = 'Procure um pedido...';

  late StateSetter internalSetter;
  late ListaRomaneioModel _model;

  ///Variáveis para Salvar e Modelar Paletes
  late Future<List<Paletes>> paletesFin;
  late Future<List<int>> getPaletes;

  late List<Paletes> palete = [];
  late List<int> paleteSelecionadoint = [];

  ///Variáveis para Salvar e Modelar pedidos
  late Future<List<Pedido>> pedidoResposta;
  List<Pedido> pedidos = [];
  List<Pedido> pedidosSalvos = [];

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final Banco bd = Banco();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ListaRomaneioModel.new);
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    _model.choiceChipsValue;
    _model.choiceChipsValueController = FormFieldController<List<String>>(
      ['Todos'],
    );
    rodarBanco();
  }

  void rodarBanco() async {
    paletesFin = bd.paleteFinalizado();
      getPaletes = bd.selectRomaneio(romaneio);
      pedidoResposta = bd.selectPalletRomaneio(getPaletes);

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
      floatingActionButton: (['BI', 'Comercial'].contains(usur.acess))
          ? SizedBox(
              width: 300,
              height: 60,
              child: FloatingActionButton(
                onPressed: () async {
                  await showCupertinoModalPopup(
                      barrierDismissible: false,
                      builder: (context2) {
                        if (paleteSelecionadoint.isNotEmpty) {
                          if (pedidosSalvos
                              .where((element) => element.status == 'Errado')
                              .isEmpty) {
                            return CupertinoAlertDialog(
                              title: Text(
                                  'Você deseja finalizar o Romaneio $romaneio ?'),
                              content: const Text(
                                  'Essa ação bloqueará o Romaneio de alterações Futuras'),
                              actions: <CupertinoDialogAction>[
                                CupertinoDialogAction(
                                    isDefaultAction: true,
                                    isDestructiveAction: true,
                                    onPressed: () async {
                                      var vol = 0;
                                      for (var ped in pedidos){
                                        vol += ped.vol;
                                      }
                                      bd.endRomaneio(romaneio);
                                      pdf.addPage(pw.MultiPage(
                                          margin: const pw.EdgeInsets.all(20),
                                          build: (context) {
                                            return [pw.Padding(
                                              padding: const pw.EdgeInsets.fromLTRB(0, 0, 0, 20),
                                              child: pw.Row(
                                                mainAxisSize: pw.MainAxisSize.max,
                                                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  pw.Column(
                                                    mainAxisSize: pw.MainAxisSize.max,
                                                    children: [
                                                      pw.Text(
                                                          'MULTILIST DISTRIBUIDORA DE COSMÉTICOS',
                                                          style: pw.TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: pw.FontWeight.bold,
                                                          )
                                                      ),
                                                      pw.Text(
                                                          '07.759.795/001-06',
                                                          style: pw.TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: pw.FontWeight.bold,
                                                          )
                                                      ),
                                                      pw.Text(
                                                          'Anfilóquio Nunes Pires, 4155',
                                                          style: pw.TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: pw.FontWeight.bold,
                                                          )
                                                      ),
                                                      pw.Text(
                                                          'Bela Vista - (47) 3337-1992',
                                                          style: pw.TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: pw.FontWeight.bold,
                                                          )
                                                      ),
                                                      pw.Text(
                                                          'GASPAR',
                                                          style: pw.TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: pw.FontWeight.bold,
                                                          )
                                                      ),
                                                      pw.Text(
                                                          'DATA ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                                                          style: pw.TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: pw.FontWeight.bold,
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                  pw.Padding(
                                                    padding: const pw.EdgeInsets.fromLTRB(20, 0, 0, 0),
                                                    child: pw.Container(
                                                      width: 160,
                                                      height: 20,
                                                      decoration: pw.BoxDecoration(
                                                        color: const PdfColor.fromInt(0xFFFFFFFF),
                                                        border: pw.Border.all(
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: pw.Row(
                                                        mainAxisSize: pw.MainAxisSize.max,
                                                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                          pw.Text(
                                                              'ROMANEIO Nº',
                                                              style: pw.TextStyle(
                                                                fontSize: 11,
                                                                fontWeight: pw.FontWeight.bold,
                                                              )
                                                          ),
                                                          pw.SizedBox(
                                                            height: 100,
                                                            child: pw.VerticalDivider(
                                                              thickness: 2,
                                                              color: const PdfColor.fromInt(0xCC000000),
                                                            ),
                                                          ),
                                                          pw.Text(
                                                              '$romaneio',
                                                              textAlign: pw.TextAlign.center,
                                                              style: pw.TextStyle(
                                                                fontSize: 11,
                                                                fontWeight: pw.FontWeight.bold,
                                                              )
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            pw.Container(
                                              height: 20,
                                              decoration: pw.BoxDecoration(
                                                color: const PdfColor.fromInt(0xFFFFFFFF),
                                                border: pw.Border.all(
                                                  width: 1,
                                                ),
                                              ),
                                              child: pw.Row(
                                                mainAxisSize: pw.MainAxisSize.max,
                                                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  pw.Expanded(
                                                    flex: 1,
                                                    child: pw.Text(
                                                        'SEQ',
                                                        textAlign: pw.TextAlign.center,
                                                        style: pw.TextStyle(
                                                          fontSize: 8,
                                                          fontWeight: pw.FontWeight.bold,
                                                        )
                                                    ),
                                                  ),
                                                  pw.VerticalDivider(
                                                    width: 0,
                                                    thickness: 1,
                                                    color: const PdfColor.fromInt(0xCC000000),
                                                  ),
                                                  pw.Expanded(
                                                    flex: 4,
                                                    child: pw.Text(
                                                        'C.N.P.J.',
                                                        textAlign: pw.TextAlign.center,
                                                        style: pw.TextStyle(
                                                          fontSize: 8,
                                                          fontWeight: pw.FontWeight.bold,
                                                        )
                                                    ),
                                                  ),
                                                  pw.VerticalDivider(
                                                    width: 0,
                                                    thickness: 1,
                                                    color: const PdfColor.fromInt(0xCC000000),
                                                  ),
                                                  pw.Expanded(
                                                    flex: 12,
                                                    child: pw.Text(
                                                        'CLIENTE',
                                                        textAlign: pw.TextAlign.center,
                                                        style: pw.TextStyle(
                                                          fontSize: 8,
                                                          fontWeight: pw.FontWeight.bold,
                                                        )
                                                    ),
                                                  ),
                                                  pw.VerticalDivider(
                                                    width: 0,
                                                    thickness: 1,
                                                    color: const PdfColor.fromInt(0xCC000000),
                                                  ),
                                                  pw.Expanded(
                                                    flex: 4,
                                                    child: pw.Text(
                                                        'CIDADE',
                                                        textAlign: pw.TextAlign.center,
                                                        style: pw.TextStyle(
                                                          fontSize: 8,
                                                          fontWeight: pw.FontWeight.bold,
                                                        )
                                                    ),
                                                  ),
                                                  pw.VerticalDivider(
                                                    width: 0,
                                                    thickness: 1,
                                                    color: const PdfColor.fromInt(0xCC000000),
                                                  ),
                                                  pw.Expanded(
                                                    flex: 2,
                                                    child: pw.Text(
                                                        'PEDIDO',
                                                        textAlign: pw.TextAlign.center,
                                                        style: pw.TextStyle(
                                                          fontSize: 8,
                                                          fontWeight: pw.FontWeight.bold,
                                                        )
                                                    ),
                                                  ),
                                                  pw.VerticalDivider(
                                                    width: 0,
                                                    thickness: 1,
                                                    color: const PdfColor.fromInt(0xCC000000),
                                                  ),
                                                  pw.Expanded(
                                                    flex: 2,
                                                    child: pw.Text(
                                                        'NOTA',
                                                        textAlign: pw.TextAlign.center,
                                                        style: pw.TextStyle(
                                                          fontSize: 8,
                                                          fontWeight: pw.FontWeight.bold,
                                                        )
                                                    ),
                                                  ),
                                                  pw.VerticalDivider(
                                                    width: 0,
                                                    thickness: 1,
                                                    color: const PdfColor.fromInt(0xCC000000),
                                                  ),
                                                  pw.Expanded(
                                                    flex: 2,
                                                    child: pw.Text(
                                                        'VALOR',
                                                        textAlign: pw.TextAlign.center,
                                                        style: pw.TextStyle(
                                                          fontSize: 8,
                                                          fontWeight: pw.FontWeight.bold,
                                                        )
                                                    ),
                                                  ),
                                                  pw.VerticalDivider(
                                                    width: 0,
                                                    thickness: 1,
                                                    color: const PdfColor.fromInt(0xCC000000),
                                                  ),
                                                  pw.Expanded(
                                                    flex: 1,
                                                    child: pw.Text(
                                                        'VOL',
                                                        textAlign: pw.TextAlign.center,
                                                        style: pw.TextStyle(
                                                          fontSize: 8,
                                                          fontWeight: pw.FontWeight.bold,
                                                        )
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            pw.ListView.builder(
                                              itemCount: pedidos.isNotEmpty ? pedidos.length : 0,
                                              padding: pw.EdgeInsets.zero,
                                              itemBuilder: (context, index) {
                                                return pw.Container(
                                                  height: 20,
                                                  decoration: pw.BoxDecoration(
                                                    color: const PdfColor.fromInt(0xFFFFFFFF),
                                                    border: pw.Border.all(
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                  child: pw.Row(
                                                    mainAxisSize: pw.MainAxisSize.max,
                                                    mainAxisAlignment: pw.MainAxisAlignment.start,
                                                    children: [
                                                      pw.Expanded(
                                                        flex: 1,
                                                        child: pw.Text(
                                                            '${index + 1}',
                                                            textAlign: pw.TextAlign.center,
                                                            style: pw.TextStyle(
                                                              fontSize: 7,
                                                              fontWeight: pw.FontWeight.bold,
                                                            )
                                                        ),
                                                      ),
                                                      pw.VerticalDivider(
                                                        width: 0,
                                                        thickness: 0.5,
                                                        color: const PdfColor.fromInt(0xCC000000),
                                                      ),
                                                      pw.Expanded(
                                                        flex: 4,
                                                        child: pw.Text(
                                                            '11.111.111/1111-11',
                                                            textAlign: pw.TextAlign.center,
                                                            style: const pw.TextStyle(
                                                              fontSize: 7,
                                                            )
                                                        ),
                                                      ),
                                                      pw.VerticalDivider(
                                                        width: 0,
                                                        thickness: 0.5,
                                                        color: const PdfColor.fromInt(0xCC000000),
                                                      ),
                                                      pw.Expanded(
                                                        flex: 12,
                                                        child: pw.Text(
                                                            'FARMACIA FARMACIA FARMACIA FARMACIA FARMACIA',
                                                            style: const pw.TextStyle(
                                                              fontSize: 7,
                                                            )
                                                        ),
                                                      ),
                                                      pw.VerticalDivider(
                                                        width: 0,
                                                        thickness: 0.5,
                                                        color: const PdfColor.fromInt(0xCC000000),
                                                      ),
                                                      pw.Expanded(
                                                        flex: 4,
                                                        child: pw.Text(
                                                            'CIDADE CIDADE',
                                                            textAlign: pw.TextAlign.center,
                                                            style: const pw.TextStyle(
                                                              fontSize:7,
                                                            )
                                                        ),
                                                      ),
                                                      pw.VerticalDivider(
                                                        width: 0,
                                                        thickness: 0.5,
                                                        color: const PdfColor.fromInt(0xCC000000),
                                                      ),
                                                      pw.Expanded(
                                                        flex: 2,
                                                        child: pw.Text(
                                                            '${pedidos[index].ped}',
                                                            textAlign: pw.TextAlign.center,
                                                            style: const pw.TextStyle(
                                                              fontSize:7,
                                                            )
                                                        ),
                                                      ),
                                                      pw.VerticalDivider(
                                                        width: 0,
                                                        thickness: 0.5,
                                                        color: const PdfColor.fromInt(0xCC000000),
                                                      ),
                                                      pw.Expanded(
                                                        flex: 2,
                                                        child: pw.Text(
                                                            'NOTA DE SAIDA',
                                                            textAlign: pw.TextAlign.center,
                                                            style: const pw.TextStyle(
                                                              fontSize: 7,
                                                            )
                                                        ),
                                                      ),
                                                      pw.VerticalDivider(
                                                        width: 0,
                                                        thickness: 1,
                                                        color: const PdfColor.fromInt(0xCC000000),
                                                      ),
                                                      pw.Expanded(
                                                        flex: 2,
                                                        child: pw.Text(
                                                            'VALOR DINHEIRO',
                                                            textAlign: pw.TextAlign.center,
                                                            style: const pw.TextStyle(
                                                              fontSize: 7,
                                                            )
                                                        ),
                                                      ),
                                                      pw.VerticalDivider(
                                                        width: 0,
                                                        thickness: 0.5,
                                                        color: const PdfColor.fromInt(0xCC000000),
                                                      ),
                                                      pw.Expanded(
                                                        flex: 1,
                                                        child: pw.Text(
                                                            '${pedidos[index].vol}',
                                                            textAlign: pw.TextAlign.center,
                                                            style: const pw.TextStyle(
                                                              fontSize: 7,
                                                            )
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                            pw.Container(
                                              height: 20,
                                              decoration: pw.BoxDecoration(
                                                color: const PdfColor.fromInt(0xFFFFFFFF),
                                                border: pw.Border.all(
                                                  width: 1,
                                                ),
                                              ),
                                              child: pw.Row(
                                                mainAxisSize: pw.MainAxisSize.max,
                                                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  pw.Expanded(
                                                    flex: 5,
                                                    child: pw.Text(
                                                        'TOTAL',
                                                        textAlign: pw.TextAlign.center,
                                                        style: pw.TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: pw.FontWeight.bold,
                                                        )
                                                    ),
                                                  ),
                                                  pw.VerticalDivider(
                                                    width: 0,
                                                    thickness: 1,
                                                    color: const PdfColor.fromInt(0xCC000000),
                                                  ),
                                                  pw.Spacer(flex: 22),
                                                  pw.VerticalDivider(
                                                    width: 0,
                                                    thickness: 1,
                                                    color: const PdfColor.fromInt(0xCC000000),
                                                  ),
                                                  pw.Expanded(
                                                    flex: 1,
                                                    child: pw.Text(
                                                        '$vol',
                                                        textAlign: pw.TextAlign.center,
                                                        style: pw.TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: pw.FontWeight.bold,
                                                        )
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            pw.Padding(
                                              padding: const pw.EdgeInsets.fromLTRB(0, 10,0,0),
                                              child: pw.Container(
                                                decoration: const pw.BoxDecoration(
                                                  color: PdfColor.fromInt(0xFFFFFFFF),
                                                ),
                                                child: pw.Column(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                                  children: [
                                                    pw.Container(
                                                      height: 40,
                                                      decoration: const pw.BoxDecoration(),
                                                      child: pw.Row(
                                                        mainAxisSize: pw.MainAxisSize.max,
                                                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                          pw.Spacer(flex: 5),
                                                          pw.Column(
                                                            mainAxisSize: pw.MainAxisSize.max,
                                                            children: [
                                                              pw.Row(
                                                                mainAxisSize: pw.MainAxisSize.max,
                                                                children: [
                                                                  pw.Container(
                                                                    width: 174,
                                                                    height: 20,
                                                                    decoration: const pw.BoxDecoration(
                                                                      color: PdfColor.fromInt(0xFFFFFFFF),
                                                                    ),
                                                                  ),
                                                                  pw.Container(
                                                                    width: 76,
                                                                    height: 20,
                                                                    decoration: pw.BoxDecoration(
                                                                      border: pw.Border.all(
                                                                        width: 1,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              pw.Container(
                                                                width: 250,
                                                                height: 20,
                                                                decoration: pw.BoxDecoration(
                                                                  color: const PdfColor.fromInt(0xFFFFFFFF),
                                                                  border: pw.Border.all(
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                                child: pw.Row(
                                                                  mainAxisSize: pw.MainAxisSize.max,
                                                                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                                                                  children: [
                                                                    pw.Expanded(
                                                                      flex: 7,
                                                                      child: pw.Container(
                                                                        decoration: const pw.BoxDecoration(
                                                                          color: PdfColor.fromInt(0xFFB0B0B0),
                                                                        ),
                                                                        child: pw.Align(
                                                                          alignment: const pw.AlignmentDirectional(0, 0),
                                                                          child: pw.Text(
                                                                              'PALETES',
                                                                              textAlign: pw.TextAlign.center,
                                                                              style: pw.TextStyle(
                                                                                fontSize: 11,
                                                                                fontWeight: pw.FontWeight.bold,
                                                                              )
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    pw.VerticalDivider(
                                                                      width: 2,
                                                                      thickness: 1,
                                                                      color: const PdfColor.fromInt(0xCC000000),
                                                                    ),
                                                                    pw.Spacer(flex: 3),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          pw.Spacer(),
                                                        ],
                                                      ),
                                                    ),
                                                    pw.Padding(
                                                      padding: const pw.EdgeInsetsDirectional.fromSTEB(10, 5, 10, 0),
                                                      child: pw.Row(
                                                        mainAxisSize: pw.MainAxisSize.max,
                                                        children: [
                                                          pw.Expanded(
                                                            flex: 1,
                                                            child: pw.Text(
                                                                'MOTORISTA: ',
                                                                textAlign: pw.TextAlign.center,
                                                                style: const pw.TextStyle(
                                                                  fontSize: 9,
                                                                )
                                                            ),
                                                          ),
                                                          pw.Expanded(
                                                            flex: 3,
                                                            child: pw.Container(
                                                              width: 250,
                                                              height: 20,
                                                              decoration: const pw.BoxDecoration(
                                                                  color:
                                                                  PdfColor.fromInt(0xFFFFFFFF),
                                                                  shape: pw.BoxShape.rectangle,
                                                                  border: pw.Border(
                                                                    bottom: pw.BorderSide(width: 1, color: PdfColors.black),
                                                                  )
                                                              ),
                                                            ),
                                                          ),
                                                          pw.Container(
                                                            width: 40,
                                                            height: 20,
                                                            decoration: const pw.BoxDecoration(
                                                              color: PdfColor.fromInt(0xFFFFFFFF),
                                                            ),
                                                          ),
                                                          pw.Expanded(
                                                            flex: 1,
                                                            child: pw.Text(
                                                                'EXPEDIÇÃO:',
                                                                textAlign: pw.TextAlign.center,
                                                                style: const pw.TextStyle(
                                                                  fontSize: 9,
                                                                )
                                                            ),
                                                          ),
                                                          pw.Expanded(
                                                            flex: 3,
                                                            child: pw.Container(
                                                              width: 250,
                                                              height: 20,
                                                              decoration: const pw.BoxDecoration(
                                                                  color:
                                                                  PdfColor.fromInt(0xFFFFFFFF),
                                                                  shape: pw.BoxShape.rectangle,
                                                                  border: pw.Border(
                                                                    bottom: pw.BorderSide(width: 1, color: PdfColors.black),
                                                                  )
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    pw.Padding(
                                                      padding: const pw.EdgeInsetsDirectional.fromSTEB(10, 10, 10, 0),
                                                      child: pw.Row(
                                                        mainAxisSize: pw.MainAxisSize.max,
                                                        children: [
                                                          pw.Expanded(
                                                            flex: 1,
                                                            child: pw.Text(
                                                                'MOTORISTA: ',
                                                                textAlign: pw.TextAlign.center,
                                                                style: const pw.TextStyle(
                                                                  fontSize: 9,
                                                                )
                                                            ),
                                                          ),
                                                          pw.Expanded(
                                                            flex: 3,
                                                            child: pw.Container(
                                                              width: 250,
                                                              height: 20,
                                                              decoration: const pw.BoxDecoration(
                                                                  color:
                                                                  PdfColor.fromInt(0xFFFFFFFF),
                                                                  shape: pw.BoxShape.rectangle,
                                                                  border: pw.Border(
                                                                    bottom: pw.BorderSide(width: 1, color: PdfColors.black),
                                                                  )
                                                              ),
                                                            ),
                                                          ),
                                                          pw.Container(
                                                            width: 40,
                                                            height: 20,
                                                            decoration: const pw.BoxDecoration(
                                                              color: PdfColor.fromInt(0xFFFFFFFF),
                                                            ),
                                                          ),
                                                          pw.Expanded(
                                                            flex: 1,
                                                            child: pw.Text(
                                                                'EXPEDIÇÃO:',
                                                                textAlign: pw.TextAlign.center,
                                                                style: const pw.TextStyle(
                                                                  fontSize: 9,
                                                                )
                                                            ),
                                                          ),
                                                          pw.Expanded(
                                                            flex: 3,
                                                            child: pw.Container(
                                                              width: 250,
                                                              height: 20,
                                                              decoration: const pw.BoxDecoration(
                                                                  color:
                                                                  PdfColor.fromInt(0xFFFFFFFF),
                                                                  shape: pw.BoxShape.rectangle,
                                                                  border: pw.Border(
                                                                    bottom: pw.BorderSide(width: 1, color: PdfColors.black),
                                                                  )
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    pw.Container(
                                                      height: 40,
                                                      decoration: const pw.BoxDecoration(),
                                                      child: pw.Row(
                                                        mainAxisSize: pw.MainAxisSize.max,
                                                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                          pw.Spacer(flex: 5),
                                                          pw.Column(
                                                            mainAxisSize: pw.MainAxisSize.max,
                                                            mainAxisAlignment: pw.MainAxisAlignment.end,
                                                            children: [
                                                              pw.Container(
                                                                width: 250,
                                                                height: 20,
                                                                decoration: pw.BoxDecoration(
                                                                  color: const PdfColor.fromInt(0xFFFFFFFF),
                                                                  border: pw.Border.all(
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                                child: pw.Row(
                                                                  mainAxisSize: pw.MainAxisSize.max,
                                                                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                                                                  children: [
                                                                    pw.Expanded(
                                                                      flex: 7,
                                                                      child: pw.Container(
                                                                        decoration: const pw.BoxDecoration(
                                                                          color: PdfColor.fromInt(0xFFB0B0B0),
                                                                        ),
                                                                        child: pw.Align(
                                                                          alignment: const pw.AlignmentDirectional(0, 0),
                                                                          child: pw.Text(
                                                                            'HORÁRIO COLETA',
                                                                            textAlign: pw.TextAlign.center,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    pw.VerticalDivider(
                                                                      width: 1,
                                                                      thickness: 1,
                                                                      color: const PdfColor.fromInt(0xCC000000),
                                                                    ),
                                                                    pw.Spacer(flex: 3),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          pw.Spacer(),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )];
                                          }
                                      ));
                                      await Printing.layoutPdf(onLayout: (format) => pdf.save());
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        await Navigator.push(context, MaterialPageRoute(builder: (context) => ProgressWidget(usur),));
                                      }
                                    },
                                    child: const Text(
                                      'Continuar',
                                    )),
                                CupertinoDialogAction(
                                    isDefaultAction: true,
                                    onPressed: () {
                                      Navigator.pop(context2);
                                    },
                                    child: const Text('Voltar'))
                              ],
                            );
                          } else {
                            return CupertinoAlertDialog(
                              title: const Text('O Romaneio possui problemas'),
                              content: const Text(
                                  'Corrija os erros no Romaneio antes de tentar finaliza-lo'),
                              actions: <CupertinoDialogAction>[
                                CupertinoDialogAction(
                                    isDefaultAction: true,
                                    onPressed: () {
                                      // bd.endRomaneio(romaneio);
                                      Navigator.pop(context2);
                                    },
                                    child: const Text(
                                      'Voltar',
                                    )),
                              ],
                            );
                          }
                        } else {
                          return CupertinoAlertDialog(
                            title: const Text('Romaneio sem Paletes'),
                            content: const Text(
                                'Você deve selecionar pelo menos 1 palete para finalizar o Romaneio'),
                            actions: <CupertinoDialogAction>[
                              CupertinoDialogAction(
                                  isDefaultAction: true,
                                  onPressed: () {
                                    Navigator.pop(context2, '/Progress');
                                  },
                                  child: const Text(
                                    'Voltar',
                                  )),
                            ],
                          );
                        }
                      },
                      context: context);
                },
                backgroundColor: Colors.orange.shade400,
                elevation: 8,
                child: const Text(
                  'Finalizar Romaneio',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
            )
          : Container(),
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
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Romaneio : $romaneio',
                                    style: FlutterFlowTheme.of(context)
                                        .headlineMedium
                                        .override(
                                          fontFamily: 'Outfit',
                                          fontSize: 30,
                                          letterSpacing: 0,
                                        ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    child: FFButtonWidget(
                                      text: '+ Palete',
                                      onPressed: () async {
                                        _model.choiceChipsValue = 'Todos';
                                        return showDialog(
                                          context: context,
                                          builder: (context) {
                                            return StatefulBuilder(
                                              builder: (context,
                                                  void Function(void Function())
                                                  setter) {
                                                internalSetter = setter;
                                                return FutureBuilder(
                                                  future: paletesFin,
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                        .connectionState ==
                                                        ConnectionState.done) {
                                                      palete =
                                                          snapshot.data ?? [];
                                                      return Dialog(
                                                        backgroundColor:
                                                        Colors.white,
                                                        child: Column(
                                                          mainAxisSize:
                                                          MainAxisSize.max,
                                                          children: [
                                                            Container(
                                                              height: MediaQuery.of(
                                                                  context)
                                                                  .size
                                                                  .height *
                                                                  0.1,
                                                              width:
                                                              MediaQuery.of(
                                                                  context)
                                                                  .size
                                                                  .width,
                                                              decoration: const BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                  BorderRadiusDirectional.vertical(
                                                                      top: Radius.circular(
                                                                          20))),
                                                              child: Align(
                                                                alignment:
                                                                Alignment
                                                                    .center,
                                                                child: Text(
                                                                  'Paletes Finalizados',
                                                                  textAlign:
                                                                  TextAlign
                                                                      .center,
                                                                  style: FlutterFlowTheme.of(
                                                                      context)
                                                                      .headlineMedium
                                                                      .override(
                                                                    fontFamily:
                                                                    'Outfit',
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                              BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                    context)
                                                                    .primaryBackground,
                                                                boxShadow: const [
                                                                  BoxShadow(
                                                                    blurRadius:
                                                                    0,
                                                                    color: Color(
                                                                        0xFFE0E3E7),
                                                                    offset:
                                                                    Offset(
                                                                      0.0,
                                                                      1,
                                                                    ),
                                                                  )
                                                                ],
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    0),
                                                                shape: BoxShape
                                                                    .rectangle,
                                                              ),
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                height: 40,
                                                                decoration:
                                                                BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                      context)
                                                                      .primaryBackground,
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      12),
                                                                ),
                                                                alignment:
                                                                const AlignmentDirectional(
                                                                    -1, 0),
                                                                child: Padding(
                                                                  padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                      16,
                                                                      0,
                                                                      0,
                                                                      0),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                        Text(
                                                                          'Palete',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .override(
                                                                            fontFamily: 'Readex Pro',
                                                                            letterSpacing: 0,
                                                                            fontSize: 20,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                        Text(
                                                                          'Usuário de Bipagem',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .override(
                                                                            fontFamily: 'Readex Pro',
                                                                            letterSpacing: 0,
                                                                            fontSize: 20,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                        Text(
                                                                          'Data da Bipagem',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .override(
                                                                            fontFamily: 'Readex Pro',
                                                                            letterSpacing: 0,
                                                                            fontSize: 20,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                        Text(
                                                                          'Usuário de Fechamento',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .override(
                                                                            fontFamily: 'Readex Pro',
                                                                            letterSpacing: 0,
                                                                            fontSize: 20,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                        Text(
                                                                          'Data de Fechamento',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .override(
                                                                            fontFamily: 'Readex Pro',
                                                                            letterSpacing: 0,
                                                                            fontSize: 20,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                        Text(
                                                                          'Volumetria',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .override(
                                                                            fontFamily: 'Readex Pro',
                                                                            letterSpacing: 0,
                                                                            fontSize: 20,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            ListView.builder(
                                                              shrinkWrap: true,
                                                              padding:
                                                              EdgeInsets
                                                                  .zero,
                                                              scrollDirection:
                                                              Axis.vertical,
                                                              itemCount:
                                                              palete.length,
                                                              itemBuilder:
                                                                  (context,
                                                                  index) {
                                                                if (paleteSelecionadoint
                                                                    .contains(palete[
                                                                index]
                                                                    .pallet)) {
                                                                  return Padding(
                                                                    padding:
                                                                    const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                        0,
                                                                        0,
                                                                        0,
                                                                        1),
                                                                    child:
                                                                    Container(
                                                                      width: double
                                                                          .infinity,
                                                                      decoration:
                                                                      BoxDecoration(
                                                                        color: Colors
                                                                            .yellow
                                                                            .shade50,
                                                                        boxShadow: const [
                                                                          BoxShadow(
                                                                            blurRadius:
                                                                            0,
                                                                            color:
                                                                            Color(0xFFE0E3E7),
                                                                            offset:
                                                                            Offset(
                                                                              0.0,
                                                                              1,
                                                                            ),
                                                                          )
                                                                        ],
                                                                        borderRadius:
                                                                        BorderRadius.circular(0),
                                                                        shape: BoxShape
                                                                            .rectangle,
                                                                      ),
                                                                      child:
                                                                      InkWell(
                                                                        splashColor:
                                                                        Colors.transparent,
                                                                        focusColor:
                                                                        Colors.transparent,
                                                                        hoverColor:
                                                                        Colors.transparent,
                                                                        highlightColor:
                                                                        Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          setter(
                                                                                  () {
                                                                                paleteSelecionadoint.remove(palete[index].pallet);
                                                                                bd.removePalete(romaneio,
                                                                                    paleteSelecionadoint);
                                                                                getPaletes =
                                                                                    bd.selectRomaneio(romaneio);
                                                                                setState(() {
                                                                                  pedidoResposta = bd.selectPalletRomaneio(getPaletes);
                                                                                });
                                                                              });
                                                                        },
                                                                        child:
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8),
                                                                          child:
                                                                          Row(
                                                                            mainAxisSize:
                                                                            MainAxisSize.max,
                                                                            children: [
                                                                              Container(
                                                                                width: 4,
                                                                                height: 50,
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.green.shade400,
                                                                                  borderRadius: BorderRadius.circular(2),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                  child: Text(
                                                                                    '${palete[index].pallet}',
                                                                                    style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                      fontFamily: 'Readex Pro',
                                                                                      letterSpacing: 0,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                  child: Text(
                                                                                    '${palete[index].idUsurInclusao}',
                                                                                    style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                      fontFamily: 'Readex Pro',
                                                                                      letterSpacing: 0,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                  child: Text(
                                                                                    '${palete[index].dtInclusao}',
                                                                                    style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                      fontFamily: 'Readex Pro',
                                                                                      letterSpacing: 0,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                  child: Text(
                                                                                    '${palete[index].idUsurFechamento}',
                                                                                    style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                      fontFamily: 'Readex Pro',
                                                                                      letterSpacing: 0,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                  child: Text(
                                                                                    '${palete[index].dtFechamento}',
                                                                                    style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                      fontFamily: 'Readex Pro',
                                                                                      letterSpacing: 0,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                  child: Text(
                                                                                    '${palete[index].volumetria}',
                                                                                    style: FlutterFlowTheme.of(context).labelLarge.override(
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
                                                                    ),
                                                                  );
                                                                } else {
                                                                  return Padding(
                                                                    padding:
                                                                    const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                        0,
                                                                        0,
                                                                        0,
                                                                        1),
                                                                    child:
                                                                    Container(
                                                                      width: double
                                                                          .infinity,
                                                                      decoration:
                                                                      BoxDecoration(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryBackground,
                                                                        boxShadow: const [
                                                                          BoxShadow(
                                                                            blurRadius:
                                                                            0,
                                                                            color:
                                                                            Color(0xFFE0E3E7),
                                                                            offset:
                                                                            Offset(
                                                                              0.0,
                                                                              1,
                                                                            ),
                                                                          )
                                                                        ],
                                                                        borderRadius:
                                                                        BorderRadius.circular(0),
                                                                        shape: BoxShape
                                                                            .rectangle,
                                                                      ),
                                                                      child:
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          setter(
                                                                                  () {
                                                                                paleteSelecionadoint.add(palete[index].pallet ??
                                                                                    0);
                                                                                paleteSelecionadoint.sort(
                                                                                      (a, b) => a.compareTo(b),
                                                                                );
                                                                                bd.updatePalete(romaneio,
                                                                                    paleteSelecionadoint);
                                                                                getPaletes =
                                                                                    bd.selectRomaneio(romaneio);
                                                                                setState(() {
                                                                                  pedidoResposta = bd.selectPalletRomaneio(getPaletes);
                                                                                });
                                                                              });
                                                                        },
                                                                        child:
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8),
                                                                          child:
                                                                          Row(
                                                                            mainAxisSize:
                                                                            MainAxisSize.max,
                                                                            children: [
                                                                              Container(
                                                                                width: 4,
                                                                                height: 50,
                                                                                decoration: BoxDecoration(
                                                                                  color: FlutterFlowTheme.of(context).alternate,
                                                                                  borderRadius: BorderRadius.circular(2),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                  child: Text(
                                                                                    '${palete[index].pallet}',
                                                                                    style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                      fontFamily: 'Readex Pro',
                                                                                      letterSpacing: 0,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                  child: Text(
                                                                                    '${palete[index].idUsurInclusao}',
                                                                                    style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                      fontFamily: 'Readex Pro',
                                                                                      letterSpacing: 0,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                  child: Text(
                                                                                    '${palete[index].dtInclusao}',
                                                                                    style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                      fontFamily: 'Readex Pro',
                                                                                      letterSpacing: 0,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                  child: Text(
                                                                                    '${palete[index].idUsurFechamento}',
                                                                                    style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                      fontFamily: 'Readex Pro',
                                                                                      letterSpacing: 0,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                  child: Text(
                                                                                    '${palete[index].dtFechamento}',
                                                                                    style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                      fontFamily: 'Readex Pro',
                                                                                      letterSpacing: 0,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                                  child: Text(
                                                                                    '${palete[index].volumetria}',
                                                                                    style: FlutterFlowTheme.of(context).labelLarge.override(
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
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    } else {
                                                      return const CircularProgressIndicator();
                                                    }
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                      options: FFButtonOptions(
                                        height: 40,
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(24, 0, 24, 0),
                                        iconPadding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 0, 0, 0),
                                        color: Colors.green.shade700,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                          fontFamily: 'Readex Pro',
                                          color: Colors.white,
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
                                ],
                              ),
                              FutureBuilder(
                                future: getPaletes,
                                builder: (context, snapshot) {
                                  paleteSelecionadoint = snapshot.data ?? [];
                                  paleteSelecionadoint.sort(
                                    (a, b) => a.compareTo(b),
                                  );
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(16, 0, 0, 0),
                                          child: Text(
                                            'Paletes Nesse Romaneio',
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  fontSize: 18,
                                                  letterSpacing: 0,
                                                ),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              const AlignmentDirectional(0, 0),
                                          child: Text(
                                            paleteSelecionadoint.join(','),
                                            textAlign: TextAlign.end,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  fontSize: 40,
                                                  letterSpacing: 0,
                                                ),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                },
                              ),
                            ],
                          ),
                        if (responsiveVisibility(
                          context: context,
                          phone: true,
                          tablet: true,
                          desktop: false,
                        ))
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Romaneio : $romaneio',
                                textAlign: TextAlign.start,
                                style: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .override(
                                      fontFamily: 'Outfit',
                                      fontSize: 30,
                                      letterSpacing: 0,
                                    ),
                              ),

                              FutureBuilder(
                                future: getPaletes,
                                builder: (context, snapshot) {
                                  paleteSelecionadoint = snapshot.data ?? [];
                                  paleteSelecionadoint.sort(
                                    (a, b) => a.compareTo(b),
                                  );
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0, 10, 0, 0),
                                          child: Text(
                                            'Paletes Nesse Romaneio',
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  fontSize: 18,
                                                  letterSpacing: 0,
                                                ),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              const AlignmentDirectional(0, 0),
                                          child: Text(
                                            paleteSelecionadoint.join(','),
                                            textAlign: TextAlign.end,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  fontSize: 40,
                                                  letterSpacing: 0,
                                                ),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                },
                              ),
                            ],
                          ),
                        Container(
                          width: double.infinity,
                          height: 24,
                          decoration: const BoxDecoration(),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: (responsiveVisibility(
                            context: context,
                            phone: false,
                            tablet: false,
                          ))
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 8, 0, 40),
                              child: FlutterFlowChoiceChips(
                                  options: const [
                                    ChipData('Todos'),
                                    ChipData('Errado'),
                                    ChipData('OK')
                                  ],
                                  onChanged: (val) {
                                    setState(() {
                                      if (_model.choiceChipsValue == 'Todos') {
                                        pedidos = pedidosSalvos;
                                      } else {
                                        pedidos = pedidosSalvos
                                            .where((element) =>
                                                element.status ==
                                                _model.choiceChipsValue)
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
                            ),
                            if (responsiveVisibility(
                              context: context,
                              phone: false,
                              tablet: false,
                            ))
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16, 0, 0, 40),
                              child: SizedBox(
                                width: 300,
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
                                    child: Text(
                                      'Carregamento',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            letterSpacing: 0,
                                          ),
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    'Paletes',
                                    style: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          letterSpacing: 0,
                                        ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Conferido',
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
                                        'Status',
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
                                  if (pedidos[index].status == 'Errado') {
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
                                                    usur),
                                          ));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 10, 0, 0),
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
                                              Expanded(
                                                child: Text(
                                                  '?',
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
                                                  child: Text(
                                                    pedidos[index].palete,
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
                                                child: Text(
                                                  '${pedidos[index].caixas} / ${pedidos[index].vol}',
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
                                                          pedidos[index].status,
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
