import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '/Components/Widget/drawer_widget.dart';
import '../Components/Model/lista_romaneio.dart';
import '../Components/Widget/atualizacao.dart';
import '../Controls/banco.dart';
import '../Models/palete.dart';
import '../Models/pedido.dart';
import '../Models/transportadora.dart';
import '../Models/usur.dart';
import 'home_widget.dart';
import 'lista_cancelados.dart';
import 'lista_faturados.dart';
import 'lista_pedido_widget.dart';

///Página da listagem de Romaneio
class ListaRomaneioWidget extends StatefulWidget {
  ///Variável para definir permissões do usuário
  final Usuario usur;

  ///Variável para puxar o número do romaneio
  final int romaneio;

  ///Variável para manter conexão com o Banco
  final Banco bd;

  ///Construtor da página
  const ListaRomaneioWidget(this.romaneio, this.usur,
      {super.key, required this.bd});

  @override
  State<ListaRomaneioWidget> createState() =>
      _ListaRomaneioWidgetState(romaneio, usur, bd);
}

class _ListaRomaneioWidgetState extends State<ListaRomaneioWidget> {
  int romaneio;
  final Usuario usur;
  late final pdf = pw.Document(title: 'Romaneio $romaneio');

  final Banco bd;

  _ListaRomaneioWidgetState(this.romaneio, this.usur, this.bd);

  ///Variáveis para mostrar erro no TextField
  Color corDica = Colors.green.shade400;
  Color corBorda = Colors.green.shade700;
  String dica = 'Procure um pedido...';

  late StateSetter internalSetter;
  late ListaRomaneioModel _model;

  final TextEditingController transNome = TextEditingController();
  final TextEditingController trans = TextEditingController();

  int transportadoraSelecionada = 0;

  late Future<List<Transportadora>> transportadoraFut;
  late List<Transportadora> transportadora;

  ///Variáveis para Salvar e Modelar Paletes
  late Future<List<Paletes>> paletesFin;
  late Future<List<int>> getPaletes;

  late List<Paletes> palete = [];
  late List<int> paleteSelecionadoint = [];

  ///Variáveis para Salvar e Modelar pedidos
  late Future<List<Pedido>> pedidoResposta;
  List<Pedido> pedidos = [];
  List<Pedido> pedidosSalvos = [];

  late Future<int> qtdFatFut;
  late Future<int> qtdCancFut;
  int qtdFat = 0;
  int qtdCanc = 0;

  List<String> acessos = ['BI', 'Comercial', 'Logística'];
  List<String> acessosADM = ['BI'];
  List<String> acessosCol = ['Logística'];
  List<String> acessosPC = ['Comercial'];

  final scaffoldKey = GlobalKey<ScaffoldState>();

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
    getPaletes = bd.selectromaneio(romaneio);
    pedidoResposta = bd.selectPalletromaneio(getPaletes);
    transportadoraFut = bd.selectAlltransportadora();
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
                  if (qtdFat > 0) {
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
                  } else {
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
                                              ListaCanceladosWidget(usur,
                                                  bd: bd),
                                        ));
                                  },
                                  icon: const Icon(
                                    Icons.assignment_late,
                                    color: Colors.orange,
                                  ),
                                )
                              ])));
                    } else {
                      return Container();
                    }
                  }),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_reset_outlined),
            onPressed: () async {
              paletesFin = bd.paleteFinalizado();
              getPaletes = bd.selectromaneio(romaneio);
              pedidoResposta = bd.selectPalletromaneio(getPaletes);
              qtdCancFut = bd.qtdCanc();
              qtdFatFut = bd.qtdFat();
              setState(() {});
            },
            color: Colors.white,
          ),
          (['BI', 'Comercial'].contains(usur.acess))
              ? Padding(
            padding: const EdgeInsets.all(5),
            child: SizedBox(
              width: 220,
              height: 60,
              child: FloatingActionButton(
                onPressed: () async {
                  await showCupertinoModalPopup(
                      barrierDismissible: false,
                      builder: (context2) {
                        if (paleteSelecionadoint.isNotEmpty) {
                          if (pedidosSalvos
                              .where((element) =>
                          element.status == 'Incorreto')
                              .isEmpty) {
                            if (trans.text != '') {
                              if (pedidosSalvos
                                  .where((element) =>
                              element.status == 'Alerta')
                                  .isNotEmpty) {
                                return CupertinoAlertDialog(
                                  title:
                                  const Text('Alertas no Romaneio'),
                                  content: const Text(
                                      'Existem alertas no Romaneio, deseja continuar ?'),
                                  actions: <CupertinoDialogAction>[
                                    CupertinoDialogAction(
                                        isDefaultAction: true,
                                        isDestructiveAction: true,
                                        onPressed: () async {
                                          await showCupertinoModalPopup(
                                            context: context,
                                            builder: (context) {
                                              return CupertinoAlertDialog(
                                                title: Text(
                                                    'Você deseja finalizar o Romaneio $romaneio ?'),
                                                content: const Text(
                                                    'Essa ação bloqueará o Romaneio de alterações Futuras'),
                                                actions: <
                                                    CupertinoDialogAction>[
                                                  CupertinoDialogAction(
                                                      isDefaultAction:
                                                      true,
                                                      isDestructiveAction:
                                                      true,
                                                      onPressed:
                                                          () async {
                                                        if (await bd.connected(
                                                            context) ==
                                                            1) {
                                                          var vol = 0;
                                                          for (var ped
                                                          in pedidos) {
                                                            vol +=
                                                                ped.vol;
                                                          }
                                                          bd.endromaneio(
                                                              romaneio,
                                                              pedidos,
                                                              int.parse(trans
                                                                  .text));
                                                          pdf.addPage(pw
                                                              .MultiPage(
                                                              margin: const pw
                                                                  .EdgeInsets
                                                                  .all(
                                                                  20),
                                                              build:
                                                                  (context) {
                                                                return [
                                                                  pw.Padding(
                                                                    padding: const pw
                                                                        .EdgeInsets
                                                                        .fromLTRB(
                                                                        0, 0, 0,
                                                                        20),
                                                                    child: pw
                                                                        .Row(
                                                                      mainAxisSize: pw
                                                                          .MainAxisSize
                                                                          .max,
                                                                      mainAxisAlignment: pw
                                                                          .MainAxisAlignment
                                                                          .spaceEvenly,
                                                                      children: [
                                                                        pw
                                                                            .Column(
                                                                          mainAxisSize: pw
                                                                              .MainAxisSize
                                                                              .max,
                                                                          children: [
                                                                            pw
                                                                                .Text(
                                                                                'MULTILIST DISTRIBUIDORA DE COSMÉTICOS',
                                                                                style: pw
                                                                                    .TextStyle(
                                                                                  fontSize: 12,
                                                                                  fontWeight: pw
                                                                                      .FontWeight
                                                                                      .bold,
                                                                                )),
                                                                            pw
                                                                                .Text(
                                                                                '07.759.795/001-06',
                                                                                style: pw
                                                                                    .TextStyle(
                                                                                  fontSize: 12,
                                                                                  fontWeight: pw
                                                                                      .FontWeight
                                                                                      .bold,
                                                                                )),
                                                                            pw
                                                                                .Text(
                                                                                'Anfilóquio Nunes Pires, 4155',
                                                                                style: pw
                                                                                    .TextStyle(
                                                                                  fontSize: 12,
                                                                                  fontWeight: pw
                                                                                      .FontWeight
                                                                                      .bold,
                                                                                )),
                                                                            pw
                                                                                .Text(
                                                                                'Bela Vista - (47) 3337-1992',
                                                                                style: pw
                                                                                    .TextStyle(
                                                                                  fontSize: 12,
                                                                                  fontWeight: pw
                                                                                      .FontWeight
                                                                                      .bold,
                                                                                )),
                                                                            pw
                                                                                .Text(
                                                                                'GASPAR',
                                                                                style: pw
                                                                                    .TextStyle(
                                                                                  fontSize: 12,
                                                                                  fontWeight: pw
                                                                                      .FontWeight
                                                                                      .bold,
                                                                                )),
                                                                            pw
                                                                                .Text(
                                                                                'DATA ${DateFormat(
                                                                                    'dd/MM/yyyy')
                                                                                    .format(
                                                                                    DateTime
                                                                                        .now())}',
                                                                                style: pw
                                                                                    .TextStyle(
                                                                                  fontSize: 12,
                                                                                  fontWeight: pw
                                                                                      .FontWeight
                                                                                      .bold,
                                                                                )),
                                                                          ],
                                                                        ),
                                                                        pw
                                                                            .Column(
                                                                          children: [
                                                                            pw
                                                                                .Padding(
                                                                              padding: const pw
                                                                                  .EdgeInsets
                                                                                  .fromLTRB(
                                                                                  20,
                                                                                  0,
                                                                                  0,
                                                                                  0),
                                                                              child: pw
                                                                                  .Container(
                                                                                width: 160,
                                                                                height: 20,
                                                                                decoration: pw
                                                                                    .BoxDecoration(
                                                                                  color: const PdfColor
                                                                                      .fromInt(
                                                                                      0xFFFFFFFF),
                                                                                  border: pw
                                                                                      .Border
                                                                                      .all(
                                                                                    width: 2,
                                                                                  ),
                                                                                ),
                                                                                child: pw
                                                                                    .Row(
                                                                                  mainAxisSize: pw
                                                                                      .MainAxisSize
                                                                                      .max,
                                                                                  mainAxisAlignment: pw
                                                                                      .MainAxisAlignment
                                                                                      .spaceEvenly,
                                                                                  children: [
                                                                                    pw
                                                                                        .Text(
                                                                                        'ROMANEIO Nº',
                                                                                        style: pw
                                                                                            .TextStyle(
                                                                                          fontSize: 11,
                                                                                          fontWeight: pw
                                                                                              .FontWeight
                                                                                              .bold,
                                                                                        )),
                                                                                    pw
                                                                                        .SizedBox(
                                                                                      height: 100,
                                                                                      child: pw
                                                                                          .VerticalDivider(
                                                                                        thickness: 2,
                                                                                        color: const PdfColor
                                                                                            .fromInt(
                                                                                            0xCC000000),
                                                                                      ),
                                                                                    ),
                                                                                    pw
                                                                                        .Text(
                                                                                        '$romaneio',
                                                                                        textAlign: pw
                                                                                            .TextAlign
                                                                                            .center,
                                                                                        style: pw
                                                                                            .TextStyle(
                                                                                          fontSize: 11,
                                                                                          fontWeight: pw
                                                                                              .FontWeight
                                                                                              .bold,
                                                                                        )),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            pw
                                                                                .Padding(
                                                                                padding: const pw
                                                                                    .EdgeInsets
                                                                                    .fromLTRB(
                                                                                    20,
                                                                                    10,
                                                                                    0,
                                                                                    0),
                                                                                child: pw
                                                                                    .SizedBox(
                                                                                  width: 150,
                                                                                  height: 50,
                                                                                  child: pw
                                                                                      .BarcodeWidget(
                                                                                    data: '$romaneio',
                                                                                    barcode: Barcode
                                                                                        .code128(),
                                                                                    width: 150,
                                                                                    height: 50,
                                                                                    color: PdfColors
                                                                                        .black,
                                                                                    drawText: false,
                                                                                  ),
                                                                                )),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  pw.Container(
                                                                    height: 20,
                                                                    decoration: pw
                                                                        .BoxDecoration(
                                                                      color: const PdfColor
                                                                          .fromInt(
                                                                          0xFFFFFFFF),
                                                                      border: pw
                                                                          .Border
                                                                          .all(
                                                                        width: 1,
                                                                      ),
                                                                    ),
                                                                    child: pw
                                                                        .Row(
                                                                      mainAxisSize: pw
                                                                          .MainAxisSize
                                                                          .max,
                                                                      mainAxisAlignment: pw
                                                                          .MainAxisAlignment
                                                                          .spaceEvenly,
                                                                      children: [
                                                                        pw
                                                                            .Expanded(
                                                                          flex: 1,
                                                                          child: pw
                                                                              .Text(
                                                                              'SEQ',
                                                                              textAlign: pw
                                                                                  .TextAlign
                                                                                  .center,
                                                                              style: pw
                                                                                  .TextStyle(
                                                                                fontSize: 8,
                                                                                fontWeight: pw
                                                                                    .FontWeight
                                                                                    .bold,
                                                                              )),
                                                                        ),
                                                                        pw
                                                                            .VerticalDivider(
                                                                          width: 0,
                                                                          thickness: 1,
                                                                          color: const PdfColor
                                                                              .fromInt(
                                                                              0xCC000000),
                                                                        ),
                                                                        pw
                                                                            .Expanded(
                                                                          flex: 4,
                                                                          child: pw
                                                                              .Text(
                                                                              'C.N.P.J.',
                                                                              textAlign: pw
                                                                                  .TextAlign
                                                                                  .center,
                                                                              style: pw
                                                                                  .TextStyle(
                                                                                fontSize: 8,
                                                                                fontWeight: pw
                                                                                    .FontWeight
                                                                                    .bold,
                                                                              )),
                                                                        ),
                                                                        pw
                                                                            .VerticalDivider(
                                                                          width: 0,
                                                                          thickness: 1,
                                                                          color: const PdfColor
                                                                              .fromInt(
                                                                              0xCC000000),
                                                                        ),
                                                                        pw
                                                                            .Expanded(
                                                                          flex: 12,
                                                                          child: pw
                                                                              .Text(
                                                                              'CLIENTE',
                                                                              textAlign: pw
                                                                                  .TextAlign
                                                                                  .center,
                                                                              style: pw
                                                                                  .TextStyle(
                                                                                fontSize: 8,
                                                                                fontWeight: pw
                                                                                    .FontWeight
                                                                                    .bold,
                                                                              )),
                                                                        ),
                                                                        pw
                                                                            .VerticalDivider(
                                                                          width: 0,
                                                                          thickness: 1,
                                                                          color: const PdfColor
                                                                              .fromInt(
                                                                              0xCC000000),
                                                                        ),
                                                                        pw
                                                                            .Expanded(
                                                                          flex: 4,
                                                                          child: pw
                                                                              .Text(
                                                                              'CIDADE',
                                                                              textAlign: pw
                                                                                  .TextAlign
                                                                                  .center,
                                                                              style: pw
                                                                                  .TextStyle(
                                                                                fontSize: 8,
                                                                                fontWeight: pw
                                                                                    .FontWeight
                                                                                    .bold,
                                                                              )),
                                                                        ),
                                                                        pw
                                                                            .VerticalDivider(
                                                                          width: 0,
                                                                          thickness: 1,
                                                                          color: const PdfColor
                                                                              .fromInt(
                                                                              0xCC000000),
                                                                        ),
                                                                        pw
                                                                            .Expanded(
                                                                          flex: 2,
                                                                          child: pw
                                                                              .Text(
                                                                              'PEDIDO',
                                                                              textAlign: pw
                                                                                  .TextAlign
                                                                                  .center,
                                                                              style: pw
                                                                                  .TextStyle(
                                                                                fontSize: 8,
                                                                                fontWeight: pw
                                                                                    .FontWeight
                                                                                    .bold,
                                                                              )),
                                                                        ),
                                                                        pw
                                                                            .VerticalDivider(
                                                                          width: 0,
                                                                          thickness: 1,
                                                                          color: const PdfColor
                                                                              .fromInt(
                                                                              0xCC000000),
                                                                        ),
                                                                        pw
                                                                            .Expanded(
                                                                          flex: 2,
                                                                          child: pw
                                                                              .Text(
                                                                              'NOTA',
                                                                              textAlign: pw
                                                                                  .TextAlign
                                                                                  .center,
                                                                              style: pw
                                                                                  .TextStyle(
                                                                                fontSize: 8,
                                                                                fontWeight: pw
                                                                                    .FontWeight
                                                                                    .bold,
                                                                              )),
                                                                        ),
                                                                        pw
                                                                            .VerticalDivider(
                                                                          width: 0,
                                                                          thickness: 1,
                                                                          color: const PdfColor
                                                                              .fromInt(
                                                                              0xCC000000),
                                                                        ),
                                                                        pw
                                                                            .Expanded(
                                                                          flex: 2,
                                                                          child: pw
                                                                              .Text(
                                                                              'VALOR',
                                                                              textAlign: pw
                                                                                  .TextAlign
                                                                                  .center,
                                                                              style: pw
                                                                                  .TextStyle(
                                                                                fontSize: 8,
                                                                                fontWeight: pw
                                                                                    .FontWeight
                                                                                    .bold,
                                                                              )),
                                                                        ),
                                                                        pw
                                                                            .VerticalDivider(
                                                                          width: 0,
                                                                          thickness: 1,
                                                                          color: const PdfColor
                                                                              .fromInt(
                                                                              0xCC000000),
                                                                        ),
                                                                        pw
                                                                            .Expanded(
                                                                          flex: 1,
                                                                          child: pw
                                                                              .Text(
                                                                              'VOL',
                                                                              textAlign: pw
                                                                                  .TextAlign
                                                                                  .center,
                                                                              style: pw
                                                                                  .TextStyle(
                                                                                fontSize: 8,
                                                                                fontWeight: pw
                                                                                    .FontWeight
                                                                                    .bold,
                                                                              )),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  pw.ListView
                                                                      .builder(
                                                                    itemCount: pedidos
                                                                        .isNotEmpty
                                                                        ? pedidos
                                                                        .length
                                                                        : 0,
                                                                    padding: pw
                                                                        .EdgeInsets
                                                                        .zero,
                                                                    itemBuilder: (
                                                                        context,
                                                                        index) {
                                                                      if (pedidos[index]
                                                                          .codTrans !=
                                                                          (trans
                                                                              .text !=
                                                                              ''
                                                                              ? int
                                                                              .parse(
                                                                              trans
                                                                                  .text)
                                                                              : 0) &&
                                                                          pedidos[index]
                                                                              .status ==
                                                                              'Correto') {
                                                                        pedidos[index]
                                                                            .status =
                                                                        'Alerta';
                                                                      } else {
                                                                        pedidos[index]
                                                                            .status ==
                                                                            'Correto';
                                                                      }
                                                                      return pw
                                                                          .Container(
                                                                        height: 20,
                                                                        decoration: pw
                                                                            .BoxDecoration(
                                                                          color: const PdfColor
                                                                              .fromInt(
                                                                              0xFFFFFFFF),
                                                                          border: pw
                                                                              .Border
                                                                              .all(
                                                                            width: 0.5,
                                                                          ),
                                                                        ),
                                                                        child: pw
                                                                            .Row(
                                                                          mainAxisSize: pw
                                                                              .MainAxisSize
                                                                              .max,
                                                                          mainAxisAlignment: pw
                                                                              .MainAxisAlignment
                                                                              .start,
                                                                          children: [
                                                                            pw
                                                                                .Expanded(
                                                                              flex: 1,
                                                                              child: pw
                                                                                  .Text(
                                                                                  '${index +
                                                                                      1}',
                                                                                  textAlign: pw
                                                                                      .TextAlign
                                                                                      .center,
                                                                                  style: pw
                                                                                      .TextStyle(
                                                                                    fontSize: 7,
                                                                                    fontWeight: pw
                                                                                        .FontWeight
                                                                                        .bold,
                                                                                  )),
                                                                            ),
                                                                            pw
                                                                                .VerticalDivider(
                                                                              width: 0,
                                                                              thickness: 0.5,
                                                                              color: const PdfColor
                                                                                  .fromInt(
                                                                                  0xCC000000),
                                                                            ),
                                                                            pw
                                                                                .Expanded(
                                                                              flex: 4,
                                                                              child: pw
                                                                                  .Text(
                                                                                  pedidos[index]
                                                                                      .cnpj ??
                                                                                      '',
                                                                                  textAlign: pw
                                                                                      .TextAlign
                                                                                      .center,
                                                                                  style: const pw
                                                                                      .TextStyle(
                                                                                    fontSize: 7,
                                                                                  )),
                                                                            ),
                                                                            pw
                                                                                .VerticalDivider(
                                                                              width: 0,
                                                                              thickness: 0.5,
                                                                              color: const PdfColor
                                                                                  .fromInt(
                                                                                  0xCC000000),
                                                                            ),
                                                                            pw
                                                                                .Expanded(
                                                                              flex: 12,
                                                                              child: pw
                                                                                  .Padding(
                                                                                padding: const pw
                                                                                    .EdgeInsets
                                                                                    .fromLTRB(
                                                                                    10,
                                                                                    0,
                                                                                    0,
                                                                                    0),
                                                                                child: pw
                                                                                    .Text(
                                                                                    pedidos[index]
                                                                                        .cliente ??
                                                                                        '',
                                                                                    style: const pw
                                                                                        .TextStyle(
                                                                                      fontSize: 7,
                                                                                    )),
                                                                              ),
                                                                            ),
                                                                            pw
                                                                                .VerticalDivider(
                                                                              width: 0,
                                                                              thickness: 0.5,
                                                                              color: const PdfColor
                                                                                  .fromInt(
                                                                                  0xCC000000),
                                                                            ),
                                                                            pw
                                                                                .Expanded(
                                                                              flex: 4,
                                                                              child: pw
                                                                                  .Text(
                                                                                  pedidos[index]
                                                                                      .cidade ??
                                                                                      '',
                                                                                  textAlign: pw
                                                                                      .TextAlign
                                                                                      .center,
                                                                                  style: const pw
                                                                                      .TextStyle(
                                                                                    fontSize: 7,
                                                                                  )),
                                                                            ),
                                                                            pw
                                                                                .VerticalDivider(
                                                                              width: 0,
                                                                              thickness: 0.5,
                                                                              color: const PdfColor
                                                                                  .fromInt(
                                                                                  0xCC000000),
                                                                            ),
                                                                            pw
                                                                                .Expanded(
                                                                              flex: 2,
                                                                              child: pw
                                                                                  .Text(
                                                                                  '${pedidos[index]
                                                                                      .ped}',
                                                                                  textAlign: pw
                                                                                      .TextAlign
                                                                                      .center,
                                                                                  style: const pw
                                                                                      .TextStyle(
                                                                                    fontSize: 7,
                                                                                  )),
                                                                            ),
                                                                            pw
                                                                                .VerticalDivider(
                                                                              width: 0,
                                                                              thickness: 0.5,
                                                                              color: const PdfColor
                                                                                  .fromInt(
                                                                                  0xCC000000),
                                                                            ),
                                                                            pw
                                                                                .Expanded(
                                                                              flex: 2,
                                                                              child: pw
                                                                                  .Text(
                                                                                  '${pedidos[index]
                                                                                      .nota ??
                                                                                      ''}',
                                                                                  textAlign: pw
                                                                                      .TextAlign
                                                                                      .center,
                                                                                  style: const pw
                                                                                      .TextStyle(
                                                                                    fontSize: 7,
                                                                                  )),
                                                                            ),
                                                                            pw
                                                                                .VerticalDivider(
                                                                              width: 0,
                                                                              thickness: 0.5,
                                                                              color: const PdfColor
                                                                                  .fromInt(
                                                                                  0xCC000000),
                                                                            ),
                                                                            pw
                                                                                .Expanded(
                                                                              flex: 2,
                                                                              child: pw
                                                                                  .Text(
                                                                                  (((NumberFormat(
                                                                                      '#,##0.00')
                                                                                      .format(
                                                                                      pedidos[index]
                                                                                          .valor))
                                                                                      .replaceAll(
                                                                                      ',',
                                                                                      ':'))
                                                                                      .replaceAll(
                                                                                      '.',
                                                                                      ','))
                                                                                      .replaceAll(
                                                                                      ':',
                                                                                      '.'),
                                                                                  textAlign: pw
                                                                                      .TextAlign
                                                                                      .center,
                                                                                  style: const pw
                                                                                      .TextStyle(
                                                                                    fontSize: 7,
                                                                                  )),
                                                                            ),
                                                                            pw
                                                                                .VerticalDivider(
                                                                              width: 0,
                                                                              thickness: 0.5,
                                                                              color: const PdfColor
                                                                                  .fromInt(
                                                                                  0xCC000000),
                                                                            ),
                                                                            pw
                                                                                .Expanded(
                                                                              flex: 1,
                                                                              child: pw
                                                                                  .Text(
                                                                                  '${pedidos[index]
                                                                                      .vol}',
                                                                                  textAlign: pw
                                                                                      .TextAlign
                                                                                      .center,
                                                                                  style: const pw
                                                                                      .TextStyle(
                                                                                    fontSize: 7,
                                                                                  )),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                  pw.Container(
                                                                    height: 20,
                                                                    decoration: pw
                                                                        .BoxDecoration(
                                                                      color: const PdfColor
                                                                          .fromInt(
                                                                          0xFFFFFFFF),
                                                                      border: pw
                                                                          .Border
                                                                          .all(
                                                                        width: 1,
                                                                      ),
                                                                    ),
                                                                    child: pw
                                                                        .Row(
                                                                      mainAxisSize: pw
                                                                          .MainAxisSize
                                                                          .max,
                                                                      mainAxisAlignment: pw
                                                                          .MainAxisAlignment
                                                                          .spaceEvenly,
                                                                      children: [
                                                                        pw
                                                                            .Expanded(
                                                                          flex: 5,
                                                                          child: pw
                                                                              .Text(
                                                                              'TOTAL',
                                                                              textAlign: pw
                                                                                  .TextAlign
                                                                                  .center,
                                                                              style: pw
                                                                                  .TextStyle(
                                                                                fontSize: 11,
                                                                                fontWeight: pw
                                                                                    .FontWeight
                                                                                    .bold,
                                                                              )),
                                                                        ),
                                                                        pw
                                                                            .VerticalDivider(
                                                                          width: 0,
                                                                          thickness: 1,
                                                                          color: const PdfColor
                                                                              .fromInt(
                                                                              0xCC000000),
                                                                        ),
                                                                        pw
                                                                            .Spacer(
                                                                            flex: 22),
                                                                        pw
                                                                            .VerticalDivider(
                                                                          width: 0,
                                                                          thickness: 1,
                                                                          color: const PdfColor
                                                                              .fromInt(
                                                                              0xCC000000),
                                                                        ),
                                                                        pw
                                                                            .Expanded(
                                                                          flex: 1,
                                                                          child: pw
                                                                              .Text(
                                                                              '$vol',
                                                                              textAlign: pw
                                                                                  .TextAlign
                                                                                  .center,
                                                                              style: pw
                                                                                  .TextStyle(
                                                                                fontSize: 11,
                                                                                fontWeight: pw
                                                                                    .FontWeight
                                                                                    .bold,
                                                                              )),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  pw.Padding(
                                                                    padding: const pw
                                                                        .EdgeInsets
                                                                        .fromLTRB(
                                                                        0, 10,
                                                                        0, 0),
                                                                    child: pw
                                                                        .Container(
                                                                      decoration: const pw
                                                                          .BoxDecoration(
                                                                        color: PdfColor
                                                                            .fromInt(
                                                                            0xFFFFFFFF),
                                                                      ),
                                                                      child: pw
                                                                          .Column(
                                                                        mainAxisSize: pw
                                                                            .MainAxisSize
                                                                            .min,
                                                                        mainAxisAlignment: pw
                                                                            .MainAxisAlignment
                                                                            .start,
                                                                        children: [
                                                                          pw
                                                                              .Container(
                                                                            height: 40,
                                                                            decoration: const pw
                                                                                .BoxDecoration(),
                                                                            child: pw
                                                                                .Row(
                                                                              mainAxisSize: pw
                                                                                  .MainAxisSize
                                                                                  .max,
                                                                              mainAxisAlignment: pw
                                                                                  .MainAxisAlignment
                                                                                  .spaceEvenly,
                                                                              children: [
                                                                                pw
                                                                                    .Spacer(
                                                                                    flex: 5),
                                                                                pw
                                                                                    .Column(
                                                                                  mainAxisSize: pw
                                                                                      .MainAxisSize
                                                                                      .max,
                                                                                  children: [
                                                                                    pw
                                                                                        .Row(
                                                                                      mainAxisSize: pw
                                                                                          .MainAxisSize
                                                                                          .max,
                                                                                      children: [
                                                                                        pw
                                                                                            .Container(
                                                                                          width: 174,
                                                                                          height: 20,
                                                                                          decoration: const pw
                                                                                              .BoxDecoration(
                                                                                            color: PdfColor
                                                                                                .fromInt(
                                                                                                0xFFFFFFFF),
                                                                                          ),
                                                                                        ),
                                                                                        pw
                                                                                            .Container(
                                                                                          width: 76,
                                                                                          height: 20,
                                                                                          decoration: pw
                                                                                              .BoxDecoration(
                                                                                            border: pw
                                                                                                .Border
                                                                                                .all(
                                                                                              width: 1,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    pw
                                                                                        .Container(
                                                                                      width: 250,
                                                                                      height: 20,
                                                                                      decoration: pw
                                                                                          .BoxDecoration(
                                                                                        color: const PdfColor
                                                                                            .fromInt(
                                                                                            0xFFFFFFFF),
                                                                                        border: pw
                                                                                            .Border
                                                                                            .all(
                                                                                          width: 1,
                                                                                        ),
                                                                                      ),
                                                                                      child: pw
                                                                                          .Row(
                                                                                        mainAxisSize: pw
                                                                                            .MainAxisSize
                                                                                            .max,
                                                                                        crossAxisAlignment: pw
                                                                                            .CrossAxisAlignment
                                                                                            .center,
                                                                                        children: [
                                                                                          pw
                                                                                              .Expanded(
                                                                                            flex: 7,
                                                                                            child: pw
                                                                                                .Container(
                                                                                              decoration: const pw
                                                                                                  .BoxDecoration(
                                                                                                color: PdfColor
                                                                                                    .fromInt(
                                                                                                    0xFFB0B0B0),
                                                                                              ),
                                                                                              child: pw
                                                                                                  .Align(
                                                                                                alignment: const pw
                                                                                                    .AlignmentDirectional(
                                                                                                    0,
                                                                                                    0),
                                                                                                child: pw
                                                                                                    .Text(
                                                                                                    'PALETES',
                                                                                                    textAlign: pw
                                                                                                        .TextAlign
                                                                                                        .center,
                                                                                                    style: pw
                                                                                                        .TextStyle(
                                                                                                      fontSize: 11,
                                                                                                      fontWeight: pw
                                                                                                          .FontWeight
                                                                                                          .bold,
                                                                                                    )),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          pw
                                                                                              .VerticalDivider(
                                                                                            width: 2,
                                                                                            thickness: 1,
                                                                                            color: const PdfColor
                                                                                                .fromInt(
                                                                                                0xCC000000),
                                                                                          ),
                                                                                          pw
                                                                                              .Spacer(
                                                                                              flex: 3),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                pw
                                                                                    .Spacer(),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          pw
                                                                              .Padding(
                                                                            padding: const pw
                                                                                .EdgeInsetsDirectional
                                                                                .fromSTEB(
                                                                                10,
                                                                                5,
                                                                                10,
                                                                                0),
                                                                            child: pw
                                                                                .Row(
                                                                              mainAxisSize: pw
                                                                                  .MainAxisSize
                                                                                  .max,
                                                                              children: [
                                                                                pw
                                                                                    .Expanded(
                                                                                  flex: 1,
                                                                                  child: pw
                                                                                      .Text(
                                                                                      'MOTORISTA: ',
                                                                                      textAlign: pw
                                                                                          .TextAlign
                                                                                          .center,
                                                                                      style: const pw
                                                                                          .TextStyle(
                                                                                        fontSize: 9,
                                                                                      )),
                                                                                ),
                                                                                pw
                                                                                    .Expanded(
                                                                                  flex: 3,
                                                                                  child: pw
                                                                                      .Container(
                                                                                    width: 250,
                                                                                    height: 20,
                                                                                    decoration: const pw
                                                                                        .BoxDecoration(
                                                                                        color: PdfColor
                                                                                            .fromInt(
                                                                                            0xFFFFFFFF),
                                                                                        shape: pw
                                                                                            .BoxShape
                                                                                            .rectangle,
                                                                                        border: pw
                                                                                            .Border(
                                                                                          bottom: pw
                                                                                              .BorderSide(
                                                                                              width: 1,
                                                                                              color: PdfColors
                                                                                                  .black),
                                                                                        )),
                                                                                  ),
                                                                                ),
                                                                                pw
                                                                                    .Container(
                                                                                  width: 40,
                                                                                  height: 20,
                                                                                  decoration: const pw
                                                                                      .BoxDecoration(
                                                                                    color: PdfColor
                                                                                        .fromInt(
                                                                                        0xFFFFFFFF),
                                                                                  ),
                                                                                ),
                                                                                pw
                                                                                    .Expanded(
                                                                                  flex: 1,
                                                                                  child: pw
                                                                                      .Text(
                                                                                      'EXPEDIÇÃO:',
                                                                                      textAlign: pw
                                                                                          .TextAlign
                                                                                          .center,
                                                                                      style: const pw
                                                                                          .TextStyle(
                                                                                        fontSize: 9,
                                                                                      )),
                                                                                ),
                                                                                pw
                                                                                    .Expanded(
                                                                                  flex: 3,
                                                                                  child: pw
                                                                                      .Container(
                                                                                    width: 250,
                                                                                    height: 20,
                                                                                    decoration: const pw
                                                                                        .BoxDecoration(
                                                                                        color: PdfColor
                                                                                            .fromInt(
                                                                                            0xFFFFFFFF),
                                                                                        shape: pw
                                                                                            .BoxShape
                                                                                            .rectangle,
                                                                                        border: pw
                                                                                            .Border(
                                                                                          bottom: pw
                                                                                              .BorderSide(
                                                                                              width: 1,
                                                                                              color: PdfColors
                                                                                                  .black),
                                                                                        )),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          pw
                                                                              .Padding(
                                                                            padding: const pw
                                                                                .EdgeInsetsDirectional
                                                                                .fromSTEB(
                                                                                10,
                                                                                10,
                                                                                10,
                                                                                0),
                                                                            child: pw
                                                                                .Row(
                                                                              mainAxisSize: pw
                                                                                  .MainAxisSize
                                                                                  .max,
                                                                              children: [
                                                                                pw
                                                                                    .Expanded(
                                                                                  flex: 1,
                                                                                  child: pw
                                                                                      .Text(
                                                                                      'MOTORISTA: ',
                                                                                      textAlign: pw
                                                                                          .TextAlign
                                                                                          .center,
                                                                                      style: const pw
                                                                                          .TextStyle(
                                                                                        fontSize: 9,
                                                                                      )),
                                                                                ),
                                                                                pw
                                                                                    .Expanded(
                                                                                  flex: 3,
                                                                                  child: pw
                                                                                      .Container(
                                                                                    width: 250,
                                                                                    height: 20,
                                                                                    decoration: const pw
                                                                                        .BoxDecoration(
                                                                                        color: PdfColor
                                                                                            .fromInt(
                                                                                            0xFFFFFFFF),
                                                                                        shape: pw
                                                                                            .BoxShape
                                                                                            .rectangle,
                                                                                        border: pw
                                                                                            .Border(
                                                                                          bottom: pw
                                                                                              .BorderSide(
                                                                                              width: 1,
                                                                                              color: PdfColors
                                                                                                  .black),
                                                                                        )),
                                                                                  ),
                                                                                ),
                                                                                pw
                                                                                    .Container(
                                                                                  width: 40,
                                                                                  height: 20,
                                                                                  decoration: const pw
                                                                                      .BoxDecoration(
                                                                                    color: PdfColor
                                                                                        .fromInt(
                                                                                        0xFFFFFFFF),
                                                                                  ),
                                                                                ),
                                                                                pw
                                                                                    .Expanded(
                                                                                  flex: 1,
                                                                                  child: pw
                                                                                      .Text(
                                                                                      'EXPEDIÇÃO:',
                                                                                      textAlign: pw
                                                                                          .TextAlign
                                                                                          .center,
                                                                                      style: const pw
                                                                                          .TextStyle(
                                                                                        fontSize: 9,
                                                                                      )),
                                                                                ),
                                                                                pw
                                                                                    .Expanded(
                                                                                  flex: 3,
                                                                                  child: pw
                                                                                      .Container(
                                                                                    width: 250,
                                                                                    height: 20,
                                                                                    decoration: const pw
                                                                                        .BoxDecoration(
                                                                                        color: PdfColor
                                                                                            .fromInt(
                                                                                            0xFFFFFFFF),
                                                                                        shape: pw
                                                                                            .BoxShape
                                                                                            .rectangle,
                                                                                        border: pw
                                                                                            .Border(
                                                                                          bottom: pw
                                                                                              .BorderSide(
                                                                                              width: 1,
                                                                                              color: PdfColors
                                                                                                  .black),
                                                                                        )),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          pw
                                                                              .Container(
                                                                            height: 40,
                                                                            decoration: const pw
                                                                                .BoxDecoration(),
                                                                            child: pw
                                                                                .Row(
                                                                              mainAxisSize: pw
                                                                                  .MainAxisSize
                                                                                  .max,
                                                                              mainAxisAlignment: pw
                                                                                  .MainAxisAlignment
                                                                                  .spaceEvenly,
                                                                              children: [
                                                                                pw
                                                                                    .Spacer(
                                                                                    flex: 5),
                                                                                pw
                                                                                    .Column(
                                                                                  mainAxisSize: pw
                                                                                      .MainAxisSize
                                                                                      .max,
                                                                                  mainAxisAlignment: pw
                                                                                      .MainAxisAlignment
                                                                                      .end,
                                                                                  children: [
                                                                                    pw
                                                                                        .Container(
                                                                                      width: 250,
                                                                                      height: 20,
                                                                                      decoration: pw
                                                                                          .BoxDecoration(
                                                                                        color: const PdfColor
                                                                                            .fromInt(
                                                                                            0xFFFFFFFF),
                                                                                        border: pw
                                                                                            .Border
                                                                                            .all(
                                                                                          width: 1,
                                                                                        ),
                                                                                      ),
                                                                                      child: pw
                                                                                          .Row(
                                                                                        mainAxisSize: pw
                                                                                            .MainAxisSize
                                                                                            .max,
                                                                                        crossAxisAlignment: pw
                                                                                            .CrossAxisAlignment
                                                                                            .center,
                                                                                        children: [
                                                                                          pw
                                                                                              .Expanded(
                                                                                            flex: 7,
                                                                                            child: pw
                                                                                                .Container(
                                                                                              decoration: const pw
                                                                                                  .BoxDecoration(
                                                                                                color: PdfColor
                                                                                                    .fromInt(
                                                                                                    0xFFB0B0B0),
                                                                                              ),
                                                                                              child: pw
                                                                                                  .Align(
                                                                                                alignment: const pw
                                                                                                    .AlignmentDirectional(
                                                                                                    0,
                                                                                                    0),
                                                                                                child: pw
                                                                                                    .Text(
                                                                                                  'HORÁRIO COLETA',
                                                                                                  textAlign: pw
                                                                                                      .TextAlign
                                                                                                      .center,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          pw
                                                                                              .VerticalDivider(
                                                                                            width: 1,
                                                                                            thickness: 1,
                                                                                            color: const PdfColor
                                                                                                .fromInt(
                                                                                                0xCC000000),
                                                                                          ),
                                                                                          pw
                                                                                              .Spacer(
                                                                                              flex: 3),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                pw
                                                                                    .Spacer(),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                                ];
                                                              }));
                                                          await Printing
                                                              .layoutPdf(
                                                              onLayout:
                                                                  (format) =>
                                                                  pdf.save());
                                                          if (context
                                                              .mounted) {
                                                            Navigator.pop(
                                                                context);
                                                            await Navigator
                                                                .push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (
                                                                      context) =>
                                                                      HomeWidget(
                                                                          usur,
                                                                          bd: bd),
                                                                ));
                                                          }
                                                        }
                                                        setState(() {});
                                                      },
                                                      child: const Text(
                                                        'Continuar',
                                                      )),
                                                  CupertinoDialogAction(
                                                      isDefaultAction:
                                                      true,
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context2);
                                                      },
                                                      child: const Text(
                                                          'Voltar'))
                                                ],
                                              );
                                            },
                                          );
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
                                  title: Text(
                                      'Você deseja finalizar o Romaneio $romaneio ?'),
                                  content: const Text(
                                      'Essa ação bloqueará o Romaneio de alterações Futuras'),
                                  actions: <CupertinoDialogAction>[
                                    CupertinoDialogAction(
                                        isDefaultAction: true,
                                        isDestructiveAction: true,
                                        onPressed: () async {
                                          if (await bd
                                              .connected(context) ==
                                              1) {
                                            var vol = 0;
                                            for (var ped in pedidos) {
                                              vol += ped.vol;
                                            }
                                            bd.endromaneio(
                                                romaneio,
                                                pedidos,
                                                int.parse(trans.text));
                                            pdf.addPage(pw.MultiPage(
                                                margin: const pw
                                                    .EdgeInsets.all(20),
                                                build: (context) {
                                                  return [
                                                    pw.Padding(
                                                      padding: const pw
                                                          .EdgeInsets.fromLTRB(
                                                          0, 0, 0, 20),
                                                      child: pw.Row(
                                                        mainAxisSize: pw
                                                            .MainAxisSize
                                                            .max,
                                                        mainAxisAlignment: pw
                                                            .MainAxisAlignment
                                                            .spaceEvenly,
                                                        children: [
                                                          pw.Column(
                                                            mainAxisSize: pw
                                                                .MainAxisSize
                                                                .max,
                                                            children: [
                                                              pw.Text(
                                                                  'MULTILIST DISTRIBUIDORA DE COSMÉTICOS',
                                                                  style: pw
                                                                      .TextStyle(
                                                                    fontSize:
                                                                    12,
                                                                    fontWeight: pw
                                                                        .FontWeight
                                                                        .bold,
                                                                  )),
                                                              pw.Text(
                                                                  '07.759.795/001-06',
                                                                  style: pw
                                                                      .TextStyle(
                                                                    fontSize:
                                                                    12,
                                                                    fontWeight: pw
                                                                        .FontWeight
                                                                        .bold,
                                                                  )),
                                                              pw.Text(
                                                                  'Anfilóquio Nunes Pires, 4155',
                                                                  style: pw
                                                                      .TextStyle(
                                                                    fontSize:
                                                                    12,
                                                                    fontWeight: pw
                                                                        .FontWeight
                                                                        .bold,
                                                                  )),
                                                              pw.Text(
                                                                  'Bela Vista - (47) 3337-1992',
                                                                  style: pw
                                                                      .TextStyle(
                                                                    fontSize:
                                                                    12,
                                                                    fontWeight: pw
                                                                        .FontWeight
                                                                        .bold,
                                                                  )),
                                                              pw.Text(
                                                                  'GASPAR',
                                                                  style: pw
                                                                      .TextStyle(
                                                                    fontSize:
                                                                    12,
                                                                    fontWeight: pw
                                                                        .FontWeight
                                                                        .bold,
                                                                  )),
                                                              pw.Text(
                                                                  'DATA ${DateFormat(
                                                                      'dd/MM/yyyy')
                                                                      .format(
                                                                      DateTime
                                                                          .now())}',
                                                                  style: pw
                                                                      .TextStyle(
                                                                    fontSize:
                                                                    12,
                                                                    fontWeight: pw
                                                                        .FontWeight
                                                                        .bold,
                                                                  )),
                                                            ],
                                                          ),
                                                          pw.Column(
                                                            children: [
                                                              pw.Padding(
                                                                padding: const pw
                                                                    .EdgeInsets
                                                                    .fromLTRB(
                                                                    20,
                                                                    0,
                                                                    0,
                                                                    0),
                                                                child: pw
                                                                    .Container(
                                                                  width:
                                                                  160,
                                                                  height:
                                                                  20,
                                                                  decoration:
                                                                  pw
                                                                      .BoxDecoration(
                                                                    color: const PdfColor
                                                                        .fromInt(
                                                                        0xFFFFFFFF),
                                                                    border:
                                                                    pw.Border
                                                                        .all(
                                                                      width:
                                                                      2,
                                                                    ),
                                                                  ),
                                                                  child: pw
                                                                      .Row(
                                                                    mainAxisSize: pw
                                                                        .MainAxisSize
                                                                        .max,
                                                                    mainAxisAlignment: pw
                                                                        .MainAxisAlignment
                                                                        .spaceEvenly,
                                                                    children: [
                                                                      pw.Text(
                                                                          'ROMANEIO Nº',
                                                                          style: pw
                                                                              .TextStyle(
                                                                            fontSize: 11,
                                                                            fontWeight: pw
                                                                                .FontWeight
                                                                                .bold,
                                                                          )),
                                                                      pw
                                                                          .SizedBox(
                                                                        height: 100,
                                                                        child: pw
                                                                            .VerticalDivider(
                                                                          thickness: 2,
                                                                          color: const PdfColor
                                                                              .fromInt(
                                                                              0xCC000000),
                                                                        ),
                                                                      ),
                                                                      pw.Text(
                                                                          '$romaneio',
                                                                          textAlign: pw
                                                                              .TextAlign
                                                                              .center,
                                                                          style: pw
                                                                              .TextStyle(
                                                                            fontSize: 11,
                                                                            fontWeight: pw
                                                                                .FontWeight
                                                                                .bold,
                                                                          )),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              pw.Padding(
                                                                  padding: const pw
                                                                      .EdgeInsets
                                                                      .fromLTRB(
                                                                      20,
                                                                      10,
                                                                      0,
                                                                      0),
                                                                  child: pw
                                                                      .SizedBox(
                                                                    width:
                                                                    150,
                                                                    height:
                                                                    50,
                                                                    child:
                                                                    pw
                                                                        .BarcodeWidget(
                                                                      data:
                                                                      '$romaneio',
                                                                      barcode:
                                                                      Barcode
                                                                          .code128(),
                                                                      width:
                                                                      150,
                                                                      height:
                                                                      50,
                                                                      color:
                                                                      PdfColors
                                                                          .black,
                                                                      drawText:
                                                                      false,
                                                                    ),
                                                                  )),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    pw.Container(
                                                      height: 20,
                                                      decoration: pw
                                                          .BoxDecoration(
                                                        color:
                                                        const PdfColor
                                                            .fromInt(
                                                            0xFFFFFFFF),
                                                        border:
                                                        pw.Border.all(
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: pw.Row(
                                                        mainAxisSize: pw
                                                            .MainAxisSize
                                                            .max,
                                                        mainAxisAlignment: pw
                                                            .MainAxisAlignment
                                                            .spaceEvenly,
                                                        children: [
                                                          pw.Expanded(
                                                            flex: 1,
                                                            child: pw.Text(
                                                                'SEQ',
                                                                textAlign: pw
                                                                    .TextAlign
                                                                    .center,
                                                                style: pw
                                                                    .TextStyle(
                                                                  fontSize:
                                                                  8,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold,
                                                                )),
                                                          ),
                                                          pw.VerticalDivider(
                                                            width: 0,
                                                            thickness: 1,
                                                            color: const PdfColor
                                                                .fromInt(
                                                                0xCC000000),
                                                          ),
                                                          pw.Expanded(
                                                            flex: 4,
                                                            child: pw.Text(
                                                                'C.N.P.J.',
                                                                textAlign: pw
                                                                    .TextAlign
                                                                    .center,
                                                                style: pw
                                                                    .TextStyle(
                                                                  fontSize:
                                                                  8,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold,
                                                                )),
                                                          ),
                                                          pw.VerticalDivider(
                                                            width: 0,
                                                            thickness: 1,
                                                            color: const PdfColor
                                                                .fromInt(
                                                                0xCC000000),
                                                          ),
                                                          pw.Expanded(
                                                            flex: 12,
                                                            child: pw.Text(
                                                                'CLIENTE',
                                                                textAlign: pw
                                                                    .TextAlign
                                                                    .center,
                                                                style: pw
                                                                    .TextStyle(
                                                                  fontSize:
                                                                  8,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold,
                                                                )),
                                                          ),
                                                          pw.VerticalDivider(
                                                            width: 0,
                                                            thickness: 1,
                                                            color: const PdfColor
                                                                .fromInt(
                                                                0xCC000000),
                                                          ),
                                                          pw.Expanded(
                                                            flex: 4,
                                                            child: pw.Text(
                                                                'CIDADE',
                                                                textAlign: pw
                                                                    .TextAlign
                                                                    .center,
                                                                style: pw
                                                                    .TextStyle(
                                                                  fontSize:
                                                                  8,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold,
                                                                )),
                                                          ),
                                                          pw.VerticalDivider(
                                                            width: 0,
                                                            thickness: 1,
                                                            color: const PdfColor
                                                                .fromInt(
                                                                0xCC000000),
                                                          ),
                                                          pw.Expanded(
                                                            flex: 2,
                                                            child: pw.Text(
                                                                'PEDIDO',
                                                                textAlign: pw
                                                                    .TextAlign
                                                                    .center,
                                                                style: pw
                                                                    .TextStyle(
                                                                  fontSize:
                                                                  8,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold,
                                                                )),
                                                          ),
                                                          pw.VerticalDivider(
                                                            width: 0,
                                                            thickness: 1,
                                                            color: const PdfColor
                                                                .fromInt(
                                                                0xCC000000),
                                                          ),
                                                          pw.Expanded(
                                                            flex: 2,
                                                            child: pw.Text(
                                                                'NOTA',
                                                                textAlign: pw
                                                                    .TextAlign
                                                                    .center,
                                                                style: pw
                                                                    .TextStyle(
                                                                  fontSize:
                                                                  8,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold,
                                                                )),
                                                          ),
                                                          pw.VerticalDivider(
                                                            width: 0,
                                                            thickness: 1,
                                                            color: const PdfColor
                                                                .fromInt(
                                                                0xCC000000),
                                                          ),
                                                          pw.Expanded(
                                                            flex: 2,
                                                            child: pw.Text(
                                                                'VALOR',
                                                                textAlign: pw
                                                                    .TextAlign
                                                                    .center,
                                                                style: pw
                                                                    .TextStyle(
                                                                  fontSize:
                                                                  8,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold,
                                                                )),
                                                          ),
                                                          pw.VerticalDivider(
                                                            width: 0,
                                                            thickness: 1,
                                                            color: const PdfColor
                                                                .fromInt(
                                                                0xCC000000),
                                                          ),
                                                          pw.Expanded(
                                                            flex: 1,
                                                            child: pw.Text(
                                                                'VOL',
                                                                textAlign: pw
                                                                    .TextAlign
                                                                    .center,
                                                                style: pw
                                                                    .TextStyle(
                                                                  fontSize:
                                                                  8,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold,
                                                                )),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    pw.ListView.builder(
                                                      itemCount: pedidos
                                                          .isNotEmpty
                                                          ? pedidos.length
                                                          : 0,
                                                      padding: pw
                                                          .EdgeInsets
                                                          .zero,
                                                      itemBuilder:
                                                          (context,
                                                          index) {
                                                        if (pedidos[index]
                                                            .codTrans !=
                                                            (trans.text !=
                                                                ''
                                                                ? int.parse(
                                                                trans
                                                                    .text)
                                                                : 0) &&
                                                            pedidos[index]
                                                                .status ==
                                                                'Correto') {
                                                          pedidos[index]
                                                              .status =
                                                          'Alerta';
                                                        } else {
                                                          pedidos[index]
                                                              .status ==
                                                              'Correto';
                                                        }
                                                        return pw
                                                            .Container(
                                                          height: 20,
                                                          decoration: pw
                                                              .BoxDecoration(
                                                            color: const PdfColor
                                                                .fromInt(
                                                                0xFFFFFFFF),
                                                            border:
                                                            pw.Border
                                                                .all(
                                                              width: 0.5,
                                                            ),
                                                          ),
                                                          child: pw.Row(
                                                            mainAxisSize: pw
                                                                .MainAxisSize
                                                                .max,
                                                            mainAxisAlignment: pw
                                                                .MainAxisAlignment
                                                                .start,
                                                            children: [
                                                              pw.Expanded(
                                                                flex: 1,
                                                                child: pw.Text(
                                                                    '${index +
                                                                        1}',
                                                                    textAlign: pw
                                                                        .TextAlign
                                                                        .center,
                                                                    style:
                                                                    pw
                                                                        .TextStyle(
                                                                      fontSize:
                                                                      7,
                                                                      fontWeight:
                                                                      pw
                                                                          .FontWeight
                                                                          .bold,
                                                                    )),
                                                              ),
                                                              pw
                                                                  .VerticalDivider(
                                                                width: 0,
                                                                thickness:
                                                                0.5,
                                                                color: const PdfColor
                                                                    .fromInt(
                                                                    0xCC000000),
                                                              ),
                                                              pw.Expanded(
                                                                flex: 4,
                                                                child: pw.Text(
                                                                    pedidos[index]
                                                                        .cnpj ??
                                                                        '',
                                                                    textAlign: pw
                                                                        .TextAlign
                                                                        .center,
                                                                    style:
                                                                    const pw
                                                                        .TextStyle(
                                                                      fontSize:
                                                                      7,
                                                                    )),
                                                              ),
                                                              pw
                                                                  .VerticalDivider(
                                                                width: 0,
                                                                thickness:
                                                                0.5,
                                                                color: const PdfColor
                                                                    .fromInt(
                                                                    0xCC000000),
                                                              ),
                                                              pw.Expanded(
                                                                flex: 12,
                                                                child: pw
                                                                    .Padding(
                                                                  padding: const pw
                                                                      .EdgeInsets
                                                                      .fromLTRB(
                                                                      10,
                                                                      0,
                                                                      0,
                                                                      0),
                                                                  child: pw
                                                                      .Text(
                                                                      pedidos[index]
                                                                          .cliente ??
                                                                          '',
                                                                      style:
                                                                      const pw
                                                                          .TextStyle(
                                                                        fontSize: 7,
                                                                      )),
                                                                ),
                                                              ),
                                                              pw
                                                                  .VerticalDivider(
                                                                width: 0,
                                                                thickness:
                                                                0.5,
                                                                color: const PdfColor
                                                                    .fromInt(
                                                                    0xCC000000),
                                                              ),
                                                              pw.Expanded(
                                                                flex: 4,
                                                                child: pw.Text(
                                                                    pedidos[index]
                                                                        .cidade ??
                                                                        '',
                                                                    textAlign: pw
                                                                        .TextAlign
                                                                        .center,
                                                                    style:
                                                                    const pw
                                                                        .TextStyle(
                                                                      fontSize:
                                                                      7,
                                                                    )),
                                                              ),
                                                              pw
                                                                  .VerticalDivider(
                                                                width: 0,
                                                                thickness:
                                                                0.5,
                                                                color: const PdfColor
                                                                    .fromInt(
                                                                    0xCC000000),
                                                              ),
                                                              pw.Expanded(
                                                                flex: 2,
                                                                child: pw.Text(
                                                                    '${pedidos[index]
                                                                        .ped}',
                                                                    textAlign: pw
                                                                        .TextAlign
                                                                        .center,
                                                                    style:
                                                                    const pw
                                                                        .TextStyle(
                                                                      fontSize:
                                                                      7,
                                                                    )),
                                                              ),
                                                              pw
                                                                  .VerticalDivider(
                                                                width: 0,
                                                                thickness:
                                                                0.5,
                                                                color: const PdfColor
                                                                    .fromInt(
                                                                    0xCC000000),
                                                              ),
                                                              pw.Expanded(
                                                                flex: 2,
                                                                child: pw.Text(
                                                                    '${pedidos[index]
                                                                        .nota ??
                                                                        ''}',
                                                                    textAlign: pw
                                                                        .TextAlign
                                                                        .center,
                                                                    style:
                                                                    const pw
                                                                        .TextStyle(
                                                                      fontSize:
                                                                      7,
                                                                    )),
                                                              ),
                                                              pw
                                                                  .VerticalDivider(
                                                                width: 0,
                                                                thickness:
                                                                0.5,
                                                                color: const PdfColor
                                                                    .fromInt(
                                                                    0xCC000000),
                                                              ),
                                                              pw.Expanded(
                                                                flex: 2,
                                                                child: pw.Text(
                                                                    (((NumberFormat(
                                                                        '#,##0.00')
                                                                        .format(
                                                                        pedidos[index]
                                                                            .valor))
                                                                        .replaceAll(
                                                                        ',',
                                                                        ':'))
                                                                        .replaceAll(
                                                                        '.',
                                                                        ','))
                                                                        .replaceAll(
                                                                        ':',
                                                                        '.'),
                                                                    textAlign: pw
                                                                        .TextAlign
                                                                        .center,
                                                                    style:
                                                                    const pw
                                                                        .TextStyle(
                                                                      fontSize:
                                                                      7,
                                                                    )),
                                                              ),
                                                              pw
                                                                  .VerticalDivider(
                                                                width: 0,
                                                                thickness:
                                                                0.5,
                                                                color: const PdfColor
                                                                    .fromInt(
                                                                    0xCC000000),
                                                              ),
                                                              pw.Expanded(
                                                                flex: 1,
                                                                child: pw.Text(
                                                                    '${pedidos[index]
                                                                        .vol}',
                                                                    textAlign: pw
                                                                        .TextAlign
                                                                        .center,
                                                                    style:
                                                                    const pw
                                                                        .TextStyle(
                                                                      fontSize:
                                                                      7,
                                                                    )),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    pw.Container(
                                                      height: 20,
                                                      decoration: pw
                                                          .BoxDecoration(
                                                        color:
                                                        const PdfColor
                                                            .fromInt(
                                                            0xFFFFFFFF),
                                                        border:
                                                        pw.Border.all(
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: pw.Row(
                                                        mainAxisSize: pw
                                                            .MainAxisSize
                                                            .max,
                                                        mainAxisAlignment: pw
                                                            .MainAxisAlignment
                                                            .spaceEvenly,
                                                        children: [
                                                          pw.Expanded(
                                                            flex: 5,
                                                            child: pw.Text(
                                                                'TOTAL',
                                                                textAlign: pw
                                                                    .TextAlign
                                                                    .center,
                                                                style: pw
                                                                    .TextStyle(
                                                                  fontSize:
                                                                  11,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold,
                                                                )),
                                                          ),
                                                          pw.VerticalDivider(
                                                            width: 0,
                                                            thickness: 1,
                                                            color: const PdfColor
                                                                .fromInt(
                                                                0xCC000000),
                                                          ),
                                                          pw.Spacer(
                                                              flex: 22),
                                                          pw.VerticalDivider(
                                                            width: 0,
                                                            thickness: 1,
                                                            color: const PdfColor
                                                                .fromInt(
                                                                0xCC000000),
                                                          ),
                                                          pw.Expanded(
                                                            flex: 1,
                                                            child: pw.Text(
                                                                '$vol',
                                                                textAlign: pw
                                                                    .TextAlign
                                                                    .center,
                                                                style: pw
                                                                    .TextStyle(
                                                                  fontSize:
                                                                  11,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold,
                                                                )),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    pw.Padding(
                                                      padding: const pw
                                                          .EdgeInsets.fromLTRB(
                                                          0, 10, 0, 0),
                                                      child: pw.Container(
                                                        decoration: const pw
                                                            .BoxDecoration(
                                                          color: PdfColor
                                                              .fromInt(
                                                              0xFFFFFFFF),
                                                        ),
                                                        child: pw.Column(
                                                          mainAxisSize: pw
                                                              .MainAxisSize
                                                              .min,
                                                          mainAxisAlignment:
                                                          pw.MainAxisAlignment
                                                              .start,
                                                          children: [
                                                            pw.Container(
                                                              height: 40,
                                                              decoration:
                                                              const pw
                                                                  .BoxDecoration(),
                                                              child:
                                                              pw.Row(
                                                                mainAxisSize: pw
                                                                    .MainAxisSize
                                                                    .max,
                                                                mainAxisAlignment: pw
                                                                    .MainAxisAlignment
                                                                    .spaceEvenly,
                                                                children: [
                                                                  pw.Spacer(
                                                                      flex:
                                                                      5),
                                                                  pw.Column(
                                                                    mainAxisSize: pw
                                                                        .MainAxisSize
                                                                        .max,
                                                                    children: [
                                                                      pw.Row(
                                                                        mainAxisSize: pw
                                                                            .MainAxisSize
                                                                            .max,
                                                                        children: [
                                                                          pw
                                                                              .Container(
                                                                            width: 174,
                                                                            height: 20,
                                                                            decoration: const pw
                                                                                .BoxDecoration(
                                                                              color: PdfColor
                                                                                  .fromInt(
                                                                                  0xFFFFFFFF),
                                                                            ),
                                                                          ),
                                                                          pw
                                                                              .Container(
                                                                            width: 76,
                                                                            height: 20,
                                                                            decoration: pw
                                                                                .BoxDecoration(
                                                                              border: pw
                                                                                  .Border
                                                                                  .all(
                                                                                width: 1,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      pw
                                                                          .Container(
                                                                        width: 250,
                                                                        height: 20,
                                                                        decoration: pw
                                                                            .BoxDecoration(
                                                                          color: const PdfColor
                                                                              .fromInt(
                                                                              0xFFFFFFFF),
                                                                          border: pw
                                                                              .Border
                                                                              .all(
                                                                            width: 1,
                                                                          ),
                                                                        ),
                                                                        child: pw
                                                                            .Row(
                                                                          mainAxisSize: pw
                                                                              .MainAxisSize
                                                                              .max,
                                                                          crossAxisAlignment: pw
                                                                              .CrossAxisAlignment
                                                                              .center,
                                                                          children: [
                                                                            pw
                                                                                .Expanded(
                                                                              flex: 7,
                                                                              child: pw
                                                                                  .Container(
                                                                                decoration: const pw
                                                                                    .BoxDecoration(
                                                                                  color: PdfColor
                                                                                      .fromInt(
                                                                                      0xFFB0B0B0),
                                                                                ),
                                                                                child: pw
                                                                                    .Align(
                                                                                  alignment: const pw
                                                                                      .AlignmentDirectional(
                                                                                      0,
                                                                                      0),
                                                                                  child: pw
                                                                                      .Text(
                                                                                      'PALETES',
                                                                                      textAlign: pw
                                                                                          .TextAlign
                                                                                          .center,
                                                                                      style: pw
                                                                                          .TextStyle(
                                                                                        fontSize: 11,
                                                                                        fontWeight: pw
                                                                                            .FontWeight
                                                                                            .bold,
                                                                                      )),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            pw
                                                                                .VerticalDivider(
                                                                              width: 2,
                                                                              thickness: 1,
                                                                              color: const PdfColor
                                                                                  .fromInt(
                                                                                  0xCC000000),
                                                                            ),
                                                                            pw
                                                                                .Spacer(
                                                                                flex: 3),
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
                                                              padding:
                                                              const pw
                                                                  .EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  10,
                                                                  5,
                                                                  10,
                                                                  0),
                                                              child:
                                                              pw.Row(
                                                                mainAxisSize: pw
                                                                    .MainAxisSize
                                                                    .max,
                                                                children: [
                                                                  pw.Expanded(
                                                                    flex:
                                                                    1,
                                                                    child: pw
                                                                        .Text(
                                                                        'MOTORISTA: ',
                                                                        textAlign: pw
                                                                            .TextAlign
                                                                            .center,
                                                                        style: const pw
                                                                            .TextStyle(
                                                                          fontSize: 9,
                                                                        )),
                                                                  ),
                                                                  pw.Expanded(
                                                                    flex:
                                                                    3,
                                                                    child:
                                                                    pw
                                                                        .Container(
                                                                      width:
                                                                      250,
                                                                      height:
                                                                      20,
                                                                      decoration: const pw
                                                                          .BoxDecoration(
                                                                          color: PdfColor
                                                                              .fromInt(
                                                                              0xFFFFFFFF),
                                                                          shape: pw
                                                                              .BoxShape
                                                                              .rectangle,
                                                                          border: pw
                                                                              .Border(
                                                                            bottom: pw
                                                                                .BorderSide(
                                                                                width: 1,
                                                                                color: PdfColors
                                                                                    .black),
                                                                          )),
                                                                    ),
                                                                  ),
                                                                  pw.Container(
                                                                    width:
                                                                    40,
                                                                    height:
                                                                    20,
                                                                    decoration:
                                                                    const pw
                                                                        .BoxDecoration(
                                                                      color:
                                                                      PdfColor
                                                                          .fromInt(
                                                                          0xFFFFFFFF),
                                                                    ),
                                                                  ),
                                                                  pw.Expanded(
                                                                    flex:
                                                                    1,
                                                                    child: pw
                                                                        .Text(
                                                                        'EXPEDIÇÃO:',
                                                                        textAlign: pw
                                                                            .TextAlign
                                                                            .center,
                                                                        style: const pw
                                                                            .TextStyle(
                                                                          fontSize: 9,
                                                                        )),
                                                                  ),
                                                                  pw.Expanded(
                                                                    flex:
                                                                    3,
                                                                    child:
                                                                    pw
                                                                        .Container(
                                                                      width:
                                                                      250,
                                                                      height:
                                                                      20,
                                                                      decoration: const pw
                                                                          .BoxDecoration(
                                                                          color: PdfColor
                                                                              .fromInt(
                                                                              0xFFFFFFFF),
                                                                          shape: pw
                                                                              .BoxShape
                                                                              .rectangle,
                                                                          border: pw
                                                                              .Border(
                                                                            bottom: pw
                                                                                .BorderSide(
                                                                                width: 1,
                                                                                color: PdfColors
                                                                                    .black),
                                                                          )),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            pw.Padding(
                                                              padding:
                                                              const pw
                                                                  .EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  10,
                                                                  10,
                                                                  10,
                                                                  0),
                                                              child:
                                                              pw.Row(
                                                                mainAxisSize: pw
                                                                    .MainAxisSize
                                                                    .max,
                                                                children: [
                                                                  pw.Expanded(
                                                                    flex:
                                                                    1,
                                                                    child: pw
                                                                        .Text(
                                                                        'MOTORISTA: ',
                                                                        textAlign: pw
                                                                            .TextAlign
                                                                            .center,
                                                                        style: const pw
                                                                            .TextStyle(
                                                                          fontSize: 9,
                                                                        )),
                                                                  ),
                                                                  pw.Expanded(
                                                                    flex:
                                                                    3,
                                                                    child:
                                                                    pw
                                                                        .Container(
                                                                      width:
                                                                      250,
                                                                      height:
                                                                      20,
                                                                      decoration: const pw
                                                                          .BoxDecoration(
                                                                          color: PdfColor
                                                                              .fromInt(
                                                                              0xFFFFFFFF),
                                                                          shape: pw
                                                                              .BoxShape
                                                                              .rectangle,
                                                                          border: pw
                                                                              .Border(
                                                                            bottom: pw
                                                                                .BorderSide(
                                                                                width: 1,
                                                                                color: PdfColors
                                                                                    .black),
                                                                          )),
                                                                    ),
                                                                  ),
                                                                  pw.Container(
                                                                    width:
                                                                    40,
                                                                    height:
                                                                    20,
                                                                    decoration:
                                                                    const pw
                                                                        .BoxDecoration(
                                                                      color:
                                                                      PdfColor
                                                                          .fromInt(
                                                                          0xFFFFFFFF),
                                                                    ),
                                                                  ),
                                                                  pw.Expanded(
                                                                    flex:
                                                                    1,
                                                                    child: pw
                                                                        .Text(
                                                                        'EXPEDIÇÃO:',
                                                                        textAlign: pw
                                                                            .TextAlign
                                                                            .center,
                                                                        style: const pw
                                                                            .TextStyle(
                                                                          fontSize: 9,
                                                                        )),
                                                                  ),
                                                                  pw.Expanded(
                                                                    flex:
                                                                    3,
                                                                    child:
                                                                    pw
                                                                        .Container(
                                                                      width:
                                                                      250,
                                                                      height:
                                                                      20,
                                                                      decoration: const pw
                                                                          .BoxDecoration(
                                                                          color: PdfColor
                                                                              .fromInt(
                                                                              0xFFFFFFFF),
                                                                          shape: pw
                                                                              .BoxShape
                                                                              .rectangle,
                                                                          border: pw
                                                                              .Border(
                                                                            bottom: pw
                                                                                .BorderSide(
                                                                                width: 1,
                                                                                color: PdfColors
                                                                                    .black),
                                                                          )),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            pw.Container(
                                                              height: 40,
                                                              decoration:
                                                              const pw
                                                                  .BoxDecoration(),
                                                              child:
                                                              pw.Row(
                                                                mainAxisSize: pw
                                                                    .MainAxisSize
                                                                    .max,
                                                                mainAxisAlignment: pw
                                                                    .MainAxisAlignment
                                                                    .spaceEvenly,
                                                                children: [
                                                                  pw.Spacer(
                                                                      flex:
                                                                      5),
                                                                  pw.Column(
                                                                    mainAxisSize: pw
                                                                        .MainAxisSize
                                                                        .max,
                                                                    mainAxisAlignment: pw
                                                                        .MainAxisAlignment
                                                                        .end,
                                                                    children: [
                                                                      pw
                                                                          .Container(
                                                                        width: 250,
                                                                        height: 20,
                                                                        decoration: pw
                                                                            .BoxDecoration(
                                                                          color: const PdfColor
                                                                              .fromInt(
                                                                              0xFFFFFFFF),
                                                                          border: pw
                                                                              .Border
                                                                              .all(
                                                                            width: 1,
                                                                          ),
                                                                        ),
                                                                        child: pw
                                                                            .Row(
                                                                          mainAxisSize: pw
                                                                              .MainAxisSize
                                                                              .max,
                                                                          crossAxisAlignment: pw
                                                                              .CrossAxisAlignment
                                                                              .center,
                                                                          children: [
                                                                            pw
                                                                                .Expanded(
                                                                              flex: 7,
                                                                              child: pw
                                                                                  .Container(
                                                                                decoration: const pw
                                                                                    .BoxDecoration(
                                                                                  color: PdfColor
                                                                                      .fromInt(
                                                                                      0xFFB0B0B0),
                                                                                ),
                                                                                child: pw
                                                                                    .Align(
                                                                                  alignment: const pw
                                                                                      .AlignmentDirectional(
                                                                                      0,
                                                                                      0),
                                                                                  child: pw
                                                                                      .Text(
                                                                                    'HORÁRIO COLETA',
                                                                                    textAlign: pw
                                                                                        .TextAlign
                                                                                        .center,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            pw
                                                                                .VerticalDivider(
                                                                              width: 1,
                                                                              thickness: 1,
                                                                              color: const PdfColor
                                                                                  .fromInt(
                                                                                  0xCC000000),
                                                                            ),
                                                                            pw
                                                                                .Spacer(
                                                                                flex: 3),
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
                                                    )
                                                  ];
                                                }));
                                            await Printing.layoutPdf(
                                                onLayout: (format) =>
                                                    pdf.save());
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        HomeWidget(usur,
                                                            bd: bd),
                                                  ));
                                            }
                                          }
                                          setState(() {});
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
                              }
                            } else {
                              return CupertinoAlertDialog(
                                title:
                                const Text('Defina a transportadora'),
                                content: const Text(
                                    'É preciso definir a transportadora antes de finalizar o Romaenio'),
                                actions: <CupertinoDialogAction>[
                                  CupertinoDialogAction(
                                      isDefaultAction: true,
                                      onPressed: () {
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
                              title: const Text(
                                  'O Romaneio possui problemas'),
                              content: const Text(
                                  'Corrija os erros no Romaneio antes de tentar finaliza-lo'),
                              actions: <CupertinoDialogAction>[
                                CupertinoDialogAction(
                                    isDefaultAction: true,
                                    onPressed: () {
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
                                    Navigator.pop(context2, '/Home');
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
            ),
          )
              : Container(),
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
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      (['BI', 'Comercial'].contains(usur.acess))
                                          ? Padding(
                                        padding:
                                        const EdgeInsets.fromLTRB(
                                            0, 10, 0, 0),
                                        child: FFButtonWidget(
                                          text: '+ Palete',
                                          onPressed: () async {
                                            _model.choiceChipsValue =
                                            'Todos';
                                            return showDialog(
                                              context: context,
                                              builder: (context) {
                                                return StatefulBuilder(
                                                  builder: (context,
                                                      void Function(
                                                          void
                                                          Function())
                                                      setter) {
                                                    internalSetter =
                                                        setter;
                                                    return FutureBuilder(
                                                      future: paletesFin,
                                                      builder: (context,
                                                          snapshot) {
                                                        if (snapshot
                                                            .connectionState ==
                                                            ConnectionState
                                                                .done) {
                                                          palete = snapshot
                                                              .data ??
                                                              [];
                                                          return Dialog(
                                                            backgroundColor:
                                                            Colors
                                                                .white,
                                                            child: Stack(
                                                              children: [
                                                                Column(
                                                                  mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                                  children: [
                                                                    Container(
                                                                      height:
                                                                      MediaQuery
                                                                          .of(
                                                                          context)
                                                                          .size
                                                                          .height *
                                                                          0.1,
                                                                      width:
                                                                      MediaQuery
                                                                          .of(
                                                                          context)
                                                                          .size
                                                                          .width,
                                                                      decoration:
                                                                      const BoxDecoration(
                                                                          color: Colors
                                                                              .white,
                                                                          borderRadius: BorderRadiusDirectional
                                                                              .vertical(
                                                                              top: Radius
                                                                                  .circular(
                                                                                  20))),
                                                                      child:
                                                                      Align(
                                                                        alignment: Alignment
                                                                            .center,
                                                                        child: Text(
                                                                          'Paletes Finalizados',
                                                                          textAlign: TextAlign
                                                                              .center,
                                                                          style: FlutterFlowTheme
                                                                              .of(
                                                                              context)
                                                                              .headlineMedium
                                                                              .override(
                                                                            fontFamily: 'Outfit',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                      width:
                                                                      double
                                                                          .infinity,
                                                                      decoration:
                                                                      BoxDecoration(
                                                                        color: FlutterFlowTheme
                                                                            .of(
                                                                            context)
                                                                            .primaryBackground,
                                                                        boxShadow: const [
                                                                          BoxShadow(
                                                                            blurRadius: 0,
                                                                            color: Color(
                                                                                0xFFE0E3E7),
                                                                            offset: Offset(
                                                                              0.0,
                                                                              1,
                                                                            ),
                                                                          )
                                                                        ],
                                                                        borderRadius: BorderRadius
                                                                            .circular(
                                                                            0),
                                                                        shape: BoxShape
                                                                            .rectangle,
                                                                      ),
                                                                      child:
                                                                      Container(
                                                                        width: double
                                                                            .infinity,
                                                                        height: 60,
                                                                        decoration: BoxDecoration(
                                                                          color: FlutterFlowTheme
                                                                              .of(
                                                                              context)
                                                                              .primaryBackground,
                                                                          borderRadius: BorderRadius
                                                                              .circular(
                                                                              12),
                                                                        ),
                                                                        alignment: const AlignmentDirectional(
                                                                            -1,
                                                                            0),
                                                                        child: Padding(
                                                                          padding: const EdgeInsetsDirectional
                                                                              .fromSTEB(
                                                                              16,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                          child: Row(
                                                                            mainAxisSize: MainAxisSize
                                                                                .max,
                                                                            mainAxisAlignment: MainAxisAlignment
                                                                                .spaceBetween,
                                                                            crossAxisAlignment: CrossAxisAlignment
                                                                                .center,
                                                                            children: [
                                                                              Expanded(
                                                                                child: Text(
                                                                                  'Palete',
                                                                                  style: FlutterFlowTheme
                                                                                      .of(
                                                                                      context)
                                                                                      .labelSmall
                                                                                      .override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                    fontSize: 20,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Text(
                                                                                  'Conferênca',
                                                                                  style: FlutterFlowTheme
                                                                                      .of(
                                                                                      context)
                                                                                      .labelSmall
                                                                                      .override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                    fontSize: 20,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Text(
                                                                                  'Data da Conferênca',
                                                                                  style: FlutterFlowTheme
                                                                                      .of(
                                                                                      context)
                                                                                      .labelSmall
                                                                                      .override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                    fontSize: 20,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Text(
                                                                                  softWrap: true,
                                                                                  'Usuário de Fechamento',
                                                                                  style: FlutterFlowTheme
                                                                                      .of(
                                                                                      context)
                                                                                      .labelSmall
                                                                                      .override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                    fontSize: 20,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Text(
                                                                                  'Data de Fechamento',
                                                                                  style: FlutterFlowTheme
                                                                                      .of(
                                                                                      context)
                                                                                      .labelSmall
                                                                                      .override(
                                                                                    fontFamily: 'Readex Pro',
                                                                                    letterSpacing: 0,
                                                                                    fontSize: 20,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Text(
                                                                                  'Volumetria',
                                                                                  style: FlutterFlowTheme
                                                                                      .of(
                                                                                      context)
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
                                                                    SizedBox(
                                                                      width:
                                                                      MediaQuery
                                                                          .of(
                                                                          context)
                                                                          .size
                                                                          .width,
                                                                      height:
                                                                      MediaQuery
                                                                          .of(
                                                                          context)
                                                                          .size
                                                                          .height *
                                                                          0.7,
                                                                      child:
                                                                      ListView
                                                                          .builder(
                                                                        physics: const BouncingScrollPhysics(),
                                                                        shrinkWrap: true,
                                                                        padding: EdgeInsets
                                                                            .zero,
                                                                        scrollDirection: Axis
                                                                            .vertical,
                                                                        itemCount: palete
                                                                            .length,
                                                                        itemBuilder: (
                                                                            context,
                                                                            index) {
                                                                          if (paleteSelecionadoint
                                                                              .contains(
                                                                              palete[index]
                                                                                  .pallet)) {
                                                                            return Padding(
                                                                              padding: const EdgeInsetsDirectional
                                                                                  .fromSTEB(
                                                                                  0,
                                                                                  0,
                                                                                  0,
                                                                                  1),
                                                                              child: Container(
                                                                                width: double
                                                                                    .infinity,
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors
                                                                                      .yellow
                                                                                      .shade50,
                                                                                  boxShadow: const [
                                                                                    BoxShadow(
                                                                                      blurRadius: 0,
                                                                                      color: Color(
                                                                                          0xFFE0E3E7),
                                                                                      offset: Offset(
                                                                                        0.0,
                                                                                        1,
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                  borderRadius: BorderRadius
                                                                                      .circular(
                                                                                      0),
                                                                                  shape: BoxShape
                                                                                      .rectangle,
                                                                                ),
                                                                                child: InkWell(
                                                                                  splashColor: Colors
                                                                                      .transparent,
                                                                                  focusColor: Colors
                                                                                      .transparent,
                                                                                  hoverColor: Colors
                                                                                      .transparent,
                                                                                  highlightColor: Colors
                                                                                      .transparent,
                                                                                  onTap: () async {
                                                                                    if (await bd
                                                                                        .connected(
                                                                                        context) ==
                                                                                        1) {
                                                                                      setter(() {
                                                                                        paleteSelecionadoint
                                                                                            .remove(
                                                                                            palete[index]
                                                                                                .pallet);
                                                                                        bd
                                                                                            .removepalete(
                                                                                            romaneio,
                                                                                            paleteSelecionadoint);
                                                                                        getPaletes =
                                                                                            bd
                                                                                                .selectromaneio(
                                                                                                romaneio);
                                                                                        setState(() {
                                                                                          pedidoResposta =
                                                                                          (bd
                                                                                              .selectPalletromaneio(
                                                                                              getPaletes));
                                                                                        });
                                                                                      });
                                                                                    }
                                                                                    setState(() {});
                                                                                  },
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets
                                                                                        .all(
                                                                                        8),
                                                                                    child: Row(
                                                                                      mainAxisSize: MainAxisSize
                                                                                          .max,
                                                                                      children: [
                                                                                        Container(
                                                                                          width: 4,
                                                                                          height: 50,
                                                                                          decoration: BoxDecoration(
                                                                                            color: Colors
                                                                                                .green
                                                                                                .shade400,
                                                                                            borderRadius: BorderRadius
                                                                                                .circular(
                                                                                                2),
                                                                                          ),
                                                                                        ),
                                                                                        Expanded(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsetsDirectional
                                                                                                .fromSTEB(
                                                                                                12,
                                                                                                0,
                                                                                                0,
                                                                                                0),
                                                                                            child: Text(
                                                                                              '${palete[index]
                                                                                                  .pallet}',
                                                                                              style: FlutterFlowTheme
                                                                                                  .of(
                                                                                                  context)
                                                                                                  .labelLarge
                                                                                                  .override(
                                                                                                fontFamily: 'Readex Pro',
                                                                                                letterSpacing: 0,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Expanded(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsetsDirectional
                                                                                                .fromSTEB(
                                                                                                12,
                                                                                                0,
                                                                                                0,
                                                                                                0),
                                                                                            child: Text(
                                                                                              '${palete[index].usurInclusao}',
                                                                                                    style: FlutterFlowTheme
                                                                                                  .of(
                                                                                                  context)
                                                                                                  .labelLarge
                                                                                                  .override(
                                                                                                fontFamily: 'Readex Pro',
                                                                                                letterSpacing: 0,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Expanded(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsetsDirectional
                                                                                                .fromSTEB(
                                                                                                12,
                                                                                                0,
                                                                                                0,
                                                                                                0),
                                                                                            child: Text(
                                                                                              DateFormat(
                                                                                                  'dd/MM/yyyy   kk:mm')
                                                                                                  .format(
                                                                                                  palete[index]
                                                                                                      .dtInclusao!),
                                                                                              style: FlutterFlowTheme
                                                                                                  .of(
                                                                                                  context)
                                                                                                  .labelLarge
                                                                                                  .override(
                                                                                                fontFamily: 'Readex Pro',
                                                                                                letterSpacing: 0,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Expanded(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsetsDirectional
                                                                                                .fromSTEB(
                                                                                                12,
                                                                                                0,
                                                                                                0,
                                                                                                0),
                                                                                            child: Text(
                                                                                              '${palete[index].usurFechamento}',
                                                                                                    style: FlutterFlowTheme
                                                                                                  .of(
                                                                                                  context)
                                                                                                  .labelLarge
                                                                                                  .override(
                                                                                                fontFamily: 'Readex Pro',
                                                                                                letterSpacing: 0,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        if (responsiveVisibility(
                                                                                          context: context,
                                                                                          phone: true,
                                                                                          tablet: true,
                                                                                          desktop: false,
                                                                                        ))
                                                                                          Expanded(
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsetsDirectional
                                                                                                  .fromSTEB(
                                                                                                  12,
                                                                                                  0,
                                                                                                  0,
                                                                                                  0),
                                                                                              child: Text(
                                                                                                DateFormat(
                                                                                                    'dd/MM/yyyy   kk:mm')
                                                                                                    .format(
                                                                                                    palete[index]
                                                                                                        .dtFechamento!),
                                                                                                style: FlutterFlowTheme
                                                                                                    .of(
                                                                                                    context)
                                                                                                    .labelLarge
                                                                                                    .override(
                                                                                                  fontFamily: 'Readex Pro',
                                                                                                  letterSpacing: 0,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        Expanded(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsetsDirectional
                                                                                                .fromSTEB(
                                                                                                12,
                                                                                                0,
                                                                                                0,
                                                                                                0),
                                                                                            child: Text(
                                                                                              '${palete[index]
                                                                                                  .volumetria}',
                                                                                              style: FlutterFlowTheme
                                                                                                  .of(
                                                                                                  context)
                                                                                                  .labelLarge
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
                                                                              ),
                                                                            );
                                                                          } else {
                                                                            return Padding(
                                                                              padding: const EdgeInsetsDirectional
                                                                                  .fromSTEB(
                                                                                  0,
                                                                                  0,
                                                                                  0,
                                                                                  1),
                                                                              child: Container(
                                                                                width: double
                                                                                    .infinity,
                                                                                decoration: BoxDecoration(
                                                                                  color: FlutterFlowTheme
                                                                                      .of(
                                                                                      context)
                                                                                      .primaryBackground,
                                                                                  boxShadow: const [
                                                                                    BoxShadow(
                                                                                      blurRadius: 0,
                                                                                      color: Color(
                                                                                          0xFFE0E3E7),
                                                                                      offset: Offset(
                                                                                        0.0,
                                                                                        1,
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                  borderRadius: BorderRadius
                                                                                      .circular(
                                                                                      0),
                                                                                  shape: BoxShape
                                                                                      .rectangle,
                                                                                ),
                                                                                child: InkWell(
                                                                                  onTap: () async {
                                                                                    if (await bd
                                                                                        .connected(
                                                                                        context) ==
                                                                                        1) {
                                                                                      paleteSelecionadoint
                                                                                          .add(
                                                                                          palete[index]
                                                                                              .pallet ??
                                                                                              0);
                                                                                      paleteSelecionadoint
                                                                                          .sort(
                                                                                            (
                                                                                            a,
                                                                                            b) =>
                                                                                            a
                                                                                                .compareTo(
                                                                                                b),
                                                                                      );
                                                                                      getPaletes =
                                                                                          bd
                                                                                              .updatepalete(
                                                                                              romaneio,
                                                                                              paleteSelecionadoint);
                                                                                      pedidoResposta =
                                                                                          bd
                                                                                              .selectPalletromaneio(
                                                                                              getPaletes);
                                                                                      setter(() {
                                                                                        setState(() {});
                                                                                      });
                                                                                    }
                                                                                    setState(() {});
                                                                                  },
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets
                                                                                        .all(
                                                                                        8),
                                                                                    child: Row(
                                                                                      mainAxisSize: MainAxisSize
                                                                                          .max,
                                                                                      children: [
                                                                                        Container(
                                                                                          width: 4,
                                                                                          height: 50,
                                                                                          decoration: BoxDecoration(
                                                                                            color: FlutterFlowTheme
                                                                                                .of(
                                                                                                context)
                                                                                                .alternate,
                                                                                            borderRadius: BorderRadius
                                                                                                .circular(
                                                                                                2),
                                                                                          ),
                                                                                        ),
                                                                                        Expanded(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsetsDirectional
                                                                                                .fromSTEB(
                                                                                                12,
                                                                                                0,
                                                                                                0,
                                                                                                0),
                                                                                            child: Text(
                                                                                              '${palete[index]
                                                                                                  .pallet}',
                                                                                              style: FlutterFlowTheme
                                                                                                  .of(
                                                                                                  context)
                                                                                                  .labelLarge
                                                                                                  .override(
                                                                                                fontFamily: 'Readex Pro',
                                                                                                letterSpacing: 0,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Expanded(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsetsDirectional
                                                                                                .fromSTEB(
                                                                                                12,
                                                                                                0,
                                                                                                0,
                                                                                                0),
                                                                                            child: Text(
                                                                                              '${palete[index].usurInclusao}',
                                                                                                    style: FlutterFlowTheme
                                                                                                  .of(
                                                                                                  context)
                                                                                                  .labelLarge
                                                                                                  .override(
                                                                                                fontFamily: 'Readex Pro',
                                                                                                letterSpacing: 0,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Expanded(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsetsDirectional
                                                                                                .fromSTEB(
                                                                                                12,
                                                                                                0,
                                                                                                0,
                                                                                                0),
                                                                                            child: Text(
                                                                                              DateFormat(
                                                                                                  'dd/MM/yyyy   kk:mm')
                                                                                                  .format(
                                                                                                  palete[index]
                                                                                                      .dtInclusao!),
                                                                                              style: FlutterFlowTheme
                                                                                                  .of(
                                                                                                  context)
                                                                                                  .labelLarge
                                                                                                  .override(
                                                                                                fontFamily: 'Readex Pro',
                                                                                                letterSpacing: 0,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Expanded(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsetsDirectional
                                                                                                .fromSTEB(
                                                                                                12,
                                                                                                0,
                                                                                                0,
                                                                                                0),
                                                                                            child: Text(
                                                                                              '${palete[index].usurFechamento}',
                                                                                                    style: FlutterFlowTheme
                                                                                                  .of(
                                                                                                  context)
                                                                                                  .labelLarge
                                                                                                  .override(
                                                                                                fontFamily: 'Readex Pro',
                                                                                                letterSpacing: 0,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        if (responsiveVisibility(
                                                                                          context: context,
                                                                                          phone: true,
                                                                                          tablet: true,
                                                                                          desktop: false,
                                                                                        ))
                                                                                          Expanded(
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsetsDirectional
                                                                                                  .fromSTEB(
                                                                                                  12,
                                                                                                  0,
                                                                                                  0,
                                                                                                  0),
                                                                                              child: Text(
                                                                                                DateFormat(
                                                                                                    'dd/MM/yyyy   kk:mm')
                                                                                                    .format(
                                                                                                    palete[index]
                                                                                                        .dtFechamento!),
                                                                                                style: FlutterFlowTheme
                                                                                                    .of(
                                                                                                    context)
                                                                                                    .labelLarge
                                                                                                    .override(
                                                                                                  fontFamily: 'Readex Pro',
                                                                                                  letterSpacing: 0,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        Expanded(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsetsDirectional
                                                                                                .fromSTEB(
                                                                                                12,
                                                                                                0,
                                                                                                0,
                                                                                                0),
                                                                                            child: Text(
                                                                                              '${palete[index]
                                                                                                  .volumetria}',
                                                                                              style: FlutterFlowTheme
                                                                                                  .of(
                                                                                                  context)
                                                                                                  .labelLarge
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
                                                                              ),
                                                                            );
                                                                          }
                                                                        },
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                        child: Container(
                                                                          decoration:
                                                                          const BoxDecoration(
                                                                              color: Colors
                                                                                  .white,
                                                                              borderRadius: BorderRadius
                                                                                  .only(
                                                                                  bottomLeft: Radius
                                                                                      .circular(
                                                                                      20),
                                                                                  bottomRight: Radius
                                                                                      .circular(
                                                                                      20))),
                                                                        ))
                                                                  ],
                                                                ),
                                                                Positioned(
                                                                    bottom:
                                                                    10,
                                                                    right:
                                                                    10,
                                                                    child: Container(
                                                                        decoration: BoxDecoration(
                                                                            color: Colors
                                                                                .green,
                                                                            borderRadius: BorderRadius
                                                                                .circular(
                                                                                10)),
                                                                        width: 50,
                                                                        height: 50,
                                                                        child: IconButton(
                                                                          onPressed: () async {
                                                                            if (await bd
                                                                                .connected(
                                                                                context) ==
                                                                                1) {
                                                                              if (context
                                                                                  .mounted) {
                                                                                Navigator
                                                                                    .pop(
                                                                                    context);
                                                                              }
                                                                            }
                                                                            setState(() {});
                                                                          },
                                                                          icon: const Icon(
                                                                              Icons
                                                                                  .check,
                                                                              color: Colors
                                                                                  .white),
                                                                        )))
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
                                            padding:
                                            const EdgeInsetsDirectional
                                                .fromSTEB(
                                                24, 0, 24, 0),
                                            iconPadding:
                                            const EdgeInsetsDirectional
                                                .fromSTEB(0, 0, 0, 0),
                                            color: Colors.green.shade700,
                                            textStyle:
                                            FlutterFlowTheme
                                                .of(
                                                context)
                                                .titleSmall
                                                .override(
                                              fontFamily:
                                              'Readex Pro',
                                              color: Colors.white,
                                              letterSpacing: 0,
                                            ),
                                            elevation: 3,
                                            borderSide: const BorderSide(
                                              color: Colors.transparent,
                                              width: 1,
                                            ),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                        ),
                                      )
                                          : Container(),
                                    ],
                                  ),
                                  FutureBuilder(
                                    future: getPaletes,
                                    builder: (context, snapshot) {
                                      paleteSelecionadoint =
                                          snapshot.data ?? [];
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
                                              padding:
                                              const EdgeInsetsDirectional
                                                  .fromSTEB(16, 0, 0, 0),
                                              child: Text(
                                                'Paletes Nesse Romaneio',
                                                style:
                                                FlutterFlowTheme
                                                    .of(context)
                                                    .labelMedium
                                                    .override(
                                                  fontFamily:
                                                  'Readex Pro',
                                                  fontSize: 18,
                                                  letterSpacing: 0,
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment:
                                              const AlignmentDirectional(
                                                  0, 0),
                                              child: Text(
                                                paleteSelecionadoint
                                                    .join(' - '),
                                                textAlign: TextAlign.end,
                                                style:
                                                FlutterFlowTheme
                                                    .of(context)
                                                    .bodyMedium
                                                    .override(
                                                  fontFamily:
                                                  'Readex Pro',
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
                                      paleteSelecionadoint =
                                          snapshot.data ?? [];
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
                                              padding:
                                              const EdgeInsetsDirectional
                                                  .fromSTEB(0, 10, 0, 0),
                                              child: Text(
                                                'Paletes Nesse Romaneio',
                                                style:
                                                FlutterFlowTheme
                                                    .of(context)
                                                    .labelMedium
                                                    .override(
                                                  fontFamily:
                                                  'Readex Pro',
                                                  fontSize: 18,
                                                  letterSpacing: 0,
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment:
                                              const AlignmentDirectional(
                                                  0, 0),
                                              child: Text(
                                                paleteSelecionadoint
                                                    .join(' - '),
                                                textAlign: TextAlign.end,
                                                style:
                                                FlutterFlowTheme
                                                    .of(context)
                                                    .bodyMedium
                                                    .override(
                                                  fontFamily:
                                                  'Readex Pro',
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
                                      0, 8, 0, 8),
                                  child: FlutterFlowChoiceChips(
                                      options: const [
                                        ChipData('Todos'),
                                        ChipData('Incorretos'),
                                        ChipData('Alertas'),
                                        ChipData('Corretos'),
                                      ],
                                      onChanged: (val) {
                                        if (_model.choiceChipsValue ==
                                            'Todos') {
                                          pedidos = pedidosSalvos;
                                        } else {
                                          pedidos = pedidosSalvos
                                              .where((element) =>
                                                  '${element.status}s' ==
                                                  _model.choiceChipsValue)
                                              .toList();
                                        }
                                        setState(() {});
                                      },
                                      selectedChipStyle: ChipStyle(
                                        backgroundColor: Colors.green.shade700,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                          fontFamily: 'Readex Pro',
                                          color:
                                          FlutterFlowTheme
                                              .of(context)
                                              .info,
                                          letterSpacing: 0,
                                        ),
                                        iconColor:
                                        FlutterFlowTheme
                                            .of(context)
                                            .info,
                                        iconSize: 18,
                                        elevation: 2,
                                        borderColor:
                                        FlutterFlowTheme
                                            .of(context)
                                            .accent1,
                                        borderWidth: 1,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      unselectedChipStyle: ChipStyle(
                                        backgroundColor:
                                        FlutterFlowTheme
                                            .of(context)
                                            .secondaryBackground,
                                        textStyle: FlutterFlowTheme
                                            .of(context)
                                            .bodyMedium
                                            .override(
                                          fontFamily: 'Readex Pro',
                                          color:
                                          FlutterFlowTheme
                                              .of(context)
                                              .secondaryText,
                                          letterSpacing: 0,
                                        ),
                                        iconColor: FlutterFlowTheme
                                            .of(context)
                                            .secondaryText,
                                        iconSize: 18,
                                        elevation: 0,
                                        borderColor:
                                        FlutterFlowTheme
                                            .of(context)
                                            .alternate,
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
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
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
                                              var x = pedidosSalvos
                                                  .where((element) {
                                                var texto =
                                                element.ped.toString();
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
                                        FlutterFlowTheme
                                            .of(context)
                                            .primary,
                                        validator: _model
                                            .textControllerValidator
                                            .asValidator(context),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            ((acessosPC.contains(usur.acess) ||
                                    acessosADM.contains(usur.acess) &&
                                        ((responsiveVisibility(
                                            context: context,
                                            phone: false,
                                            tablet: false,
                                            desktop: true)))))
                                ? (Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0, 0, 0, 20),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 120,
                                          child: TextFormField(
                                            cursorWidth: 1,
                                            onFieldSubmitted: (value) async {
                                              if (await bd.connected(context) ==
                                                  1) {
                                                if (value != '') {
                                                  trans.text = value;
                                                  transNome.text = await bd
                                                      .selectTransportadora(
                                                          value);
                                                  if (transNome.text ==
                                                      'Transportadora não encontrada') {
                                                    trans.text = '';
                                                  }
                                                } else {
                                                  trans.text = '';
                                                  transNome.text = '';
                                                }
                                                pedidoResposta =
                                                    bd.selectPalletromaneio(
                                                        getPaletes);
                                                setState(() {});
                                              }
                                            },
                                            autofocus: true,
                                            obscureText: false,
                                            controller: trans,
                                            decoration: InputDecoration(
                                              labelText: 'Cód. Trans.',
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
                                                  color: transNome.text !=
                                                          'Transportadora não encontrada'
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .alternate
                                                      : Colors.red.shade500,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: transNome.text !=
                                                          'Transportadora não encontrada'
                                                      ? Colors.green.shade500
                                                      : Colors.red.shade500,
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
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: SizedBox(
                                            width: 500,
                                            child: TextFormField(
                                              cursorWidth: 1,
                                              onFieldSubmitted:
                                                  (value) async {},
                                              readOnly: true,
                                              obscureText: false,
                                              controller: transNome,
                                              decoration: InputDecoration(
                                                labelText: 'Transportadora',
                                                labelStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .labelMedium
                                                    .override(
                                                      fontFamily: 'Readex Pro',
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
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: transNome.text !=
                                                            'Transportadora não encontrada'
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .alternate
                                                        : Colors.red.shade500,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color:
                                                        Colors.green.shade500,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color:
                                                        Colors.green.shade100,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color:
                                                        Colors.green.shade100,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium,
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: IconButton(
                                                    onPressed: () async {
                                                      if (await bd.connected(
                                                              context) ==
                                                          1) {
                                                        if (context.mounted) {
                                                          await showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return StatefulBuilder(
                                                                builder:
                                                                    (context,
                                                                        setter) {
                                                                  internalSetter =
                                                                      setter;
                                                                  return Dialog(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    child:
                                                                        Stack(
                                                                      children: [
                                                                        Column(
                                                                          children: [
                                                                            Container(
                                                                              height: MediaQuery.of(context).size.height * 0.1,
                                                                              width: MediaQuery.of(context).size.width,
                                                                              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(20))),
                                                                              child: Align(
                                                                                alignment: Alignment.center,
                                                                                child: Text(
                                                                                  'Transportadoras',
                                                                                  textAlign: TextAlign.center,
                                                                                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                                                                                        fontFamily: 'Outfit',
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              padding: const EdgeInsets.all(10),
                                                                              width: double.infinity,
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                boxShadow: const [
                                                                                  BoxShadow(
                                                                                    blurRadius: 0,
                                                                                    color: Color(0xFFE0E3E7),
                                                                                    offset: Offset(
                                                                                      0.0,
                                                                                      1,
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                                borderRadius: BorderRadius.circular(0),
                                                                                shape: BoxShape.rectangle,
                                                                              ),
                                                                              child: Container(
                                                                                width: double.infinity,
                                                                                height: 40,
                                                                                decoration: BoxDecoration(
                                                                                  color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                  borderRadius: BorderRadius.circular(12),
                                                                                ),
                                                                                alignment: const AlignmentDirectional(-1, 0),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                                                                                  child: Row(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      Expanded(
                                                                                        flex: 1,
                                                                                        child: Text(
                                                                                          'Cód. Trans.',
                                                                                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                                fontFamily: 'Readex Pro',
                                                                                                letterSpacing: 0,
                                                                                                fontSize: 15,
                                                                                              ),
                                                                                        ),
                                                                                      ),
                                                                                      Expanded(
                                                                                        flex: 4,
                                                                                        child: Text(
                                                                                          'Transportadora',
                                                                                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                                fontFamily: 'Readex Pro',
                                                                                                letterSpacing: 0,
                                                                                                fontSize: 15,
                                                                                              ),
                                                                                        ),
                                                                                      ),
                                                                                      Expanded(
                                                                                        flex: 2,
                                                                                        child: Text(
                                                                                          'CGC',
                                                                                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                                fontFamily: 'Readex Pro',
                                                                                                letterSpacing: 0,
                                                                                                fontSize: 15,
                                                                                              ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            FutureBuilder(
                                                                              future: transportadoraFut,
                                                                              builder: (context, snapshot) {
                                                                                transportadora = snapshot.data ?? [];
                                                                                if (snapshot.connectionState == ConnectionState.done) {
                                                                                  return SizedBox(
                                                                                    width: MediaQuery.of(context).size.width,
                                                                                    height: MediaQuery.of(context).size.height * 0.7,
                                                                                    child: ListView.builder(
                                                                                      itemCount: transportadora.length,
                                                                                      itemBuilder: (context, index) {
                                                                                        if (transportadoraSelecionada == transportadora[index].cod) {
                                                                                          return Padding(
                                                                                            padding: const EdgeInsetsDirectional.symmetric(vertical: 2),
                                                                                            child: Container(
                                                                                              width: double.infinity,
                                                                                              height: 50,
                                                                                              decoration: BoxDecoration(
                                                                                                color: Colors.yellow.shade50,
                                                                                                borderRadius: BorderRadius.circular(12),
                                                                                              ),
                                                                                              alignment: const AlignmentDirectional(-1, 0),
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                                                                                                child: Row(
                                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                  children: [
                                                                                                    Expanded(
                                                                                                      flex: 1,
                                                                                                      child: Text(
                                                                                                        '${transportadora[index].cod}',
                                                                                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                                              fontFamily: 'Readex Pro',
                                                                                                              letterSpacing: 0,
                                                                                                              fontSize: 15,
                                                                                                            ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Expanded(
                                                                                                      flex: 4,
                                                                                                      child: Text(
                                                                                                        transportadora[index].transportadora,
                                                                                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                                              fontFamily: 'Readex Pro',
                                                                                                              letterSpacing: 0,
                                                                                                              fontSize: 15,
                                                                                                            ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Expanded(
                                                                                                      flex: 2,
                                                                                                      child: Text(
                                                                                                        transportadora[index].cgc,
                                                                                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                                              fontFamily: 'Readex Pro',
                                                                                                              letterSpacing: 0,
                                                                                                              fontSize: 15,
                                                                                                            ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          );
                                                                                        } else {
                                                                                          return InkWell(
                                                                                            splashColor: Colors.transparent,
                                                                                            focusColor: Colors.transparent,
                                                                                            hoverColor: Colors.transparent,
                                                                                            highlightColor: Colors.transparent,
                                                                                            onTap: () {
                                                                                              transportadoraSelecionada = transportadora[index].cod;
                                                                                              setter(() {});
                                                                                            },
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsetsDirectional.symmetric(vertical: 2),
                                                                                              child: Container(
                                                                                                width: double.infinity,
                                                                                                height: 50,
                                                                                                decoration: BoxDecoration(
                                                                                                  color: Colors.white,
                                                                                                  borderRadius: BorderRadius.circular(12),
                                                                                                ),
                                                                                                alignment: const AlignmentDirectional(-1, 0),
                                                                                                child: Padding(
                                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                                                                                                  child: Row(
                                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                    children: [
                                                                                                      Expanded(
                                                                                                        flex: 1,
                                                                                                        child: Text(
                                                                                                          '${transportadora[index].cod}',
                                                                                                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                                                fontFamily: 'Readex Pro',
                                                                                                                letterSpacing: 0,
                                                                                                                fontSize: 15,
                                                                                                              ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      Expanded(
                                                                                                        flex: 4,
                                                                                                        child: Text(
                                                                                                          transportadora[index].transportadora,
                                                                                                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                                                fontFamily: 'Readex Pro',
                                                                                                                letterSpacing: 0,
                                                                                                                fontSize: 15,
                                                                                                              ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      Expanded(
                                                                                                        flex: 2,
                                                                                                        child: Text(
                                                                                                          transportadora[index].cgc,
                                                                                                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                                                fontFamily: 'Readex Pro',
                                                                                                                letterSpacing: 0,
                                                                                                                fontSize: 15,
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
                                                                                  );
                                                                                } else {
                                                                                  return const Center(
                                                                                    child: CircularProgressIndicator(),
                                                                                  );
                                                                                }
                                                                              },
                                                                            )
                                                                          ],
                                                                        ),
                                                                        Positioned(
                                                                            bottom:
                                                                                10,
                                                                            right:
                                                                                10,
                                                                            child: Container(
                                                                                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
                                                                                width: 50,
                                                                                height: 50,
                                                                                child: IconButton(
                                                                                  onPressed: () async {
                                                                                    if (await bd.connected(context) == 1) {
                                                                                      trans.text = '$transportadoraSelecionada';
                                                                                      transNome.text = await bd.selectTransportadora('$transportadoraSelecionada');
                                                                                    }
                                                                                    setState(() {});
                                                                                    if (context.mounted) {
                                                                                      Navigator.pop(context);
                                                                                    }
                                                                                  },
                                                                                  icon: const Icon(Icons.check, color: Colors.white),
                                                                                )))
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          );
                                                        }
                                                      }
                                                    },
                                                    icon: const Icon(
                                                        Icons.search_rounded,
                                                        color: Colors.white))))
                                      ],
                                    ),
                                  ))
                                : Container(),
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
                                      MainAxisAlignment.spaceBetween,
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
                                        child: Text(
                                          'Palete',
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
                                        child: Text(
                                          'Situação',
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
                                          'Transp.',
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
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0, 4, 40, 4),
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
                                    pedidos.sort(
                                          (a, b) {
                                        return a.nota
                                            ?.compareTo((b.nota ?? 0)) ??
                                            0;
                                      },
                                    );
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
                                    physics:
                                    const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      if (pedidos[index].codTrans !=
                                              (trans.text != ''
                                                  ? int.parse(trans.text)
                                                  : 0) &&
                                          pedidos[index].status == 'Correto') {
                                        pedidos[index].status = 'Alerta';
                                        pedidosSalvos.singleWhere(
                                              (element) {
                                                return element.ped ==
                                                    pedidos[index].ped;
                                              },
                                            ).status ==
                                            'Alerta';
                                      } else {
                                        pedidos[index].status == 'Correto';
                                        pedidosSalvos.singleWhere(
                                              (element) {
                                                return element.ped ==
                                                    pedidos[index].ped;
                                              },
                                            ).status ==
                                            'Correto';
                                      }
                                      var corStatus =
                                          FlutterFlowTheme.of(context)
                                              .primaryBackground;
                                      var corTextoStatus = Colors.black;
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
                                                        cont:
                                                        pedidos[index].ped,
                                                        usur,
                                                        bd: bd),
                                              ));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 0, 0),
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: corStatus,
                                              borderRadius:
                                              const BorderRadius.all(
                                                  Radius.circular(20)),
                                            ),
                                            child: Padding(
                                              padding:
                                              const EdgeInsetsDirectional
                                                  .fromSTEB(16, 12, 16, 12),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${pedidos[index].ped}',
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
                                                      child: Text(
                                                        '${pedidos[index].codCli}',
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
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: SizedBox(
                                                          width: 50,
                                                          height: 30,
                                                          child: Container(
                                                            decoration:
                                                            BoxDecoration(
                                                              color: (pedidos[index]
                                                                  .palete
                                                                  .split(
                                                                  ',')
                                                                  .map(int
                                                                  .parse))
                                                                  .toSet()
                                                                  .difference(
                                                                  paleteSelecionadoint
                                                                      .toSet())
                                                                  .isNotEmpty
                                                                  ? Colors.red
                                                                  .shade100
                                                                  : Colors
                                                                  .transparent,
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  8),
                                                              border:
                                                              Border.all(
                                                                width: 1.5,
                                                                color: (pedidos[index]
                                                                    .palete
                                                                    .split(
                                                                    ',')
                                                                    .map(int
                                                                    .parse))
                                                                    .toSet()
                                                                    .difference(
                                                                    paleteSelecionadoint
                                                                        .toSet())
                                                                    .isNotEmpty
                                                                    ? Colors.red
                                                                    : Colors
                                                                    .transparent,
                                                              ),
                                                            ),
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              pedidos[index]
                                                                  .palete,
                                                              style: FlutterFlowTheme
                                                                  .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                color: (pedidos[index]
                                                                    .palete
                                                                    .split(',')
                                                                    .map(
                                                                    int.parse))
                                                                    .toSet()
                                                                    .difference(
                                                                    paleteSelecionadoint
                                                                        .toSet())
                                                                    .isNotEmpty
                                                                    ? Colors
                                                                    .red
                                                                    : Colors
                                                                    .black,
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
                                                  Expanded(
                                                    child: Align(
                                                      alignment:
                                                      AlignmentDirectional
                                                          .centerStart,
                                                      child: SizedBox(
                                                        width: 50,
                                                        height: 30,
                                                        child: Container(
                                                          decoration:
                                                          BoxDecoration(
                                                            color: pedidos[index]
                                                                .caixas !=
                                                                pedidos[index]
                                                                    .vol
                                                                ? Colors.red
                                                                .shade100
                                                                : Colors
                                                                .transparent,
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                8),
                                                            border: Border.all(
                                                              width: 1.5,
                                                              color: pedidos[index]
                                                                  .caixas !=
                                                                  pedidos[index]
                                                                      .vol
                                                                  ? Colors.red
                                                                  : Colors
                                                                  .transparent,
                                                            ),
                                                          ),
                                                          alignment:
                                                          Alignment.center,
                                                          child: Text(
                                                            '${pedidos[index]
                                                                .caixas} / ${pedidos[index]
                                                                .volfat}',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: FlutterFlowTheme
                                                                .of(context)
                                                                .bodyMedium
                                                                .override(
                                                              color: pedidos[index]
                                                                  .caixas !=
                                                                  pedidos[index]
                                                                      .vol
                                                                  ? Colors
                                                                  .red
                                                                  : Colors
                                                                  .black,
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
                                                  if (responsiveVisibility(
                                                    context: context,
                                                    phone: false,
                                                    tablet: false,
                                                  ))
                                                    Expanded(
                                                      child: Align(
                                                        child: SizedBox(
                                                          width: 100,
                                                          height: 30,
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                            BoxDecoration(
                                                              color: pedidos[index]
                                                                  .situacao !=
                                                                  'F'
                                                                  ? Colors.red
                                                                  .shade100
                                                                  : Colors
                                                                  .transparent,
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  8),
                                                              border:
                                                              Border.all(
                                                                width: 1.5,
                                                                color: pedidos[index]
                                                                    .situacao !=
                                                                    'F'
                                                                    ? Colors.red
                                                                    : Colors
                                                                    .transparent,
                                                              ),
                                                            ),
                                                            child: Text(
                                                              switch (pedidos[
                                                              index]
                                                                  .situacao ??
                                                                  'D') {
                                                                'F' =>
                                                                'Faturado',
                                                                'C' =>
                                                                'Cancelado',
                                                                'L' =>
                                                                'Liberado',
                                                                'B' =>
                                                                'Bloqueado',
                                                                'D' =>
                                                                'Desconhecido',
                                                                'M' =>
                                                                'Montado',
                                                                Object() =>
                                                                'Diversos',
                                                              },
                                                              textAlign:
                                                              TextAlign
                                                                  .center,
                                                              style: FlutterFlowTheme
                                                                  .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                color: pedidos[index]
                                                                    .situacao !=
                                                                    'F'
                                                                    ? Colors
                                                                    .red
                                                                    : Colors
                                                                    .black,
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
                                                  if (responsiveVisibility(
                                                    context: context,
                                                    phone: false,
                                                    tablet: false,
                                                  ))
                                                    Expanded(
                                                      child: Align(
                                                        child: SizedBox(
                                                          width: 100,
                                                          height: 30,
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                            BoxDecoration(
                                                              color: pedidos[index]
                                                                  .status ==
                                                                  'Alerta'
                                                                  ? Colors
                                                                  .orange
                                                                  .shade100
                                                                  : Colors
                                                                  .transparent,
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  8),
                                                              border:
                                                              Border.all(
                                                                width: 1.5,
                                                                color: pedidos[index]
                                                                    .status ==
                                                                    'Alerta'
                                                                    ? Colors
                                                                    .orange
                                                                    : Colors
                                                                    .transparent,
                                                              ),
                                                            ),
                                                            child: Text(
                                                              '${pedidos[index]
                                                                  .codTrans ??
                                                                  'Não Faturado'}',
                                                              textAlign:
                                                              TextAlign
                                                                  .center,
                                                              style: FlutterFlowTheme
                                                                  .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                color: pedidos[index]
                                                                    .status ==
                                                                    'Alerta'
                                                                    ? Colors
                                                                    .orange
                                                                    : Colors
                                                                    .black,
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
                                                  if (responsiveVisibility(
                                                    context: context,
                                                    phone: false,
                                                    tablet: false,
                                                  ))
                                                    Expanded(
                                                      child: Align(
                                                        alignment:
                                                        Alignment.center,
                                                        child: SizedBox(
                                                          width: 80,
                                                          height: 30,
                                                          child: Container(
                                                            decoration:
                                                            BoxDecoration(
                                                              color: pedidos[index]
                                                                  .status !=
                                                                  'Correto'
                                                                  ? pedidos[index]
                                                                  .status !=
                                                                  'Alerta'
                                                                  ? Colors
                                                                  .red
                                                                  .shade100
                                                                  : Colors
                                                                  .orange
                                                                  .shade100
                                                                  : FlutterFlowTheme
                                                                  .of(
                                                                  context)
                                                                  .accent2,
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  8),
                                                              border:
                                                              Border.all(
                                                                width: 1.5,
                                                                color: pedidos[index]
                                                                    .status !=
                                                                    'Correto'
                                                                    ? pedidos[index]
                                                                    .status !=
                                                                    'Alerta'
                                                                    ? Colors
                                                                    .red
                                                                    : Colors
                                                                    .orange
                                                                    : FlutterFlowTheme
                                                                    .of(
                                                                    context)
                                                                    .secondary,
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
                                                                    8,
                                                                    4,
                                                                    8,
                                                                    4),
                                                                child: Text(
                                                                  pedidos[index]
                                                                      .status,
                                                                  style: FlutterFlowTheme
                                                                      .of(
                                                                      context)
                                                                      .bodySmall
                                                                      .override(
                                                                    color: pedidos[index]
                                                                        .status !=
                                                                        'Correto'
                                                                        ? pedidos[index]
                                                                        .status !=
                                                                        'Alerta'
                                                                        ? Colors
                                                                        .red
                                                                        : Colors
                                                                        .orange
                                                                        : FlutterFlowTheme
                                                                        .of(
                                                                        context)
                                                                        .secondary,
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
            Positioned(
                right: 0,
                bottom: 0,
                child: AtualizacaoWidget(
                  bd: bd,
                  context: context,
                  usur: usur,
                ))
          ],
        ),
      ),
    );
  }
}
