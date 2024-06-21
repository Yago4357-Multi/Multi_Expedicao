import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../Components/Model/criar_palete_model.dart';
import '../Components/Widget/atualizacao.dart';
import '../Components/Widget/drawer_widget.dart';
import '../Controls/banco.dart';
import '../Models/palete.dart';
import '../Models/pedido.dart';
import '../Models/usur.dart';
import 'home_widget.dart';
import 'lista_cancelados.dart';
import 'lista_faturados.dart';

///Página para a criação de novos Paletes
class ReimpriprimirRomaneioWidget extends StatefulWidget {
  ///Variável para definir permissões do Usur.
  final Usuario usur;

  ///Variável para guardar número do palete
  final int romaneio;

  ///Variável para manter conexão com o Banco
  final Banco bd;

  ///Construtor da página de criação de novos Paletes
  const ReimpriprimirRomaneioWidget(
    this.usur,
    this.romaneio, {
    super.key,
    required this.bd,
  });

  @override
  State<ReimpriprimirRomaneioWidget> createState() =>
      _ReimpriprimirRomaneioWidget(usur, romaneio, bd);
}

class _ReimpriprimirRomaneioWidget extends State<ReimpriprimirRomaneioWidget> {
  late Banco bd;

  ///Variáveis para Salvar e Modelar Paletes
  late Future<List<Paletes>> paletesFin;
  late Future<List<int>> getPaletes;

  late Future<int> qtdFatFut;
  late Future<int> qtdCancFut;
  int qtdFat = 0;
  int qtdCanc = 0;

  ///Variáveis para Salvar e Modelar pedidos
  late Future<List<Pedido>> pedidoResposta;
  List<Pedido> pedidos = [];

  final Usuario usur;
  int palete = 0;
  String paleteText = '';

  late StateSetter internalSetter;

  late List<int> paletes;
  final pdf = pw.Document();
  late CriarPaleteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  _ReimpriprimirRomaneioWidget(this.usur, this.palete, this.bd);

  @override
  void initState() {
    super.initState();
    rodarBanco();
    _model = createModel(context, CriarPaleteModel.new);
  }

  void rodarBanco() async {
    getPaletes = bd.selectromaneio(palete);
    pedidoResposta = bd.selectPalletromaneio(getPaletes);
    qtdCancFut = bd.qtdCanc();
    qtdFatFut = bd.qtdFat();
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
          title: Text(
            'Reimprimir Romaneio',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Outfit',
                  color: FlutterFlowTheme.of(context).primaryBackground,
                ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.lock_reset_outlined),
              onPressed: () async {
                getPaletes = bd.selectromaneio(palete);
                pedidoResposta = bd.selectPalletromaneio(getPaletes);
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
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              StreamBuilder<Object>(
                stream: null,
                builder: (context, snapshot) {
                  return FutureBuilder(
                    future: pedidoResposta,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        pedidos = (snapshot.data ?? []);
                        pedidos.sort((a, b) {
                          return a.nota?.compareTo(b.nota ?? 0) ?? 0;
                        },);
                        return Center(
                          widthFactor: double.infinity,
                          heightFactor: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Container()),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 40, right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 200,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        canRequestFocus: true,
                                        onChanged: (value) {
                                          paleteText = value;
                                        },
                                        onFieldSubmitted: (value) async {
                                          paleteText = value;
                                          palete = int.parse(value);
                                          getPaletes = bd.selectromaneio(palete);
                                          pedidoResposta = bd.selectPalletromaneio(getPaletes);
                                          setState(() {});
                                        },
                                        autofocus: false,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelText: 'Insira um Romaneio',
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
                                            borderSide: const BorderSide(
                                              color: Colors.green,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Colors.green,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(context).error,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(context).error,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          contentPadding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  20, 0, 0, 0),
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
                                    Container(
                                      width: 10,
                                    ),
                                    Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(10)),
                                        child: IconButton(
                                          onPressed: () async {
                                            if (await bd.connected(context) == 1) {
                                              palete = int.parse(paleteText);
                                            }
                                            setState(() {});
                                          },
                                          icon: const Icon(Icons.check_rounded),
                                          color: Colors.white,
                                        )),
                                    Container(
                                      width: 10,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                 Text('Romaneio Selecionado \n$palete', style: FlutterFlowTheme.of(context).headlineLarge, textAlign: TextAlign.center,),
                                ],
                              ),
                              Expanded(child: Container()),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    300, 24, 300, 12),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    if (await bd.connected(context) == 1) {

                                      var vol = 0;
                                      for (var ped in pedidos) {
                                        vol += ped.vol;
                                      }
                                      pdf.addPage(pw
                                          .MultiPage(
                                          margin: const pw
                                              .EdgeInsets.all(
                                              20),
                                          build:
                                              (context) {
                                            return [
                                              pw.Padding(
                                                padding: const pw.EdgeInsets.fromLTRB(0, 0, 0, 20),
                                                child: pw.Row(
                                                  mainAxisSize: pw.MainAxisSize.max,
                                                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    pw.Column(
                                                      mainAxisSize: pw.MainAxisSize.max,
                                                      children: [
                                                        pw.Text('MULTILIST DISTRIBUIDORA DE COSMÉTICOS',
                                                            style: pw.TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: pw.FontWeight.bold,
                                                            )),
                                                        pw.Text('07.759.795/001-06',
                                                            style: pw.TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: pw.FontWeight.bold,
                                                            )),
                                                        pw.Text('Anfilóquio Nunes Pires, 4155',
                                                            style: pw.TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: pw.FontWeight.bold,
                                                            )),
                                                        pw.Text('Bela Vista - (47) 3337-1992',
                                                            style: pw.TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: pw.FontWeight.bold,
                                                            )),
                                                        pw.Text('GASPAR',
                                                            style: pw.TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: pw.FontWeight.bold,
                                                            )),
                                                        pw.Text('DATA ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                                                            style: pw.TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: pw.FontWeight.bold,
                                                            )),
                                                      ],
                                                    ),
                                                    pw.Column(
                                                      children: [
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
                                                                pw.Text('ROMANEIO Nº',
                                                                    style: pw.TextStyle(
                                                                      fontSize: 11,
                                                                      fontWeight: pw.FontWeight.bold,
                                                                    )),
                                                                pw.SizedBox(
                                                                  height: 100,
                                                                  child: pw.VerticalDivider(
                                                                    thickness: 2,
                                                                    color: const PdfColor.fromInt(0xCC000000),
                                                                  ),
                                                                ),
                                                                pw.Text('$palete',
                                                                    textAlign: pw.TextAlign.center,
                                                                    style: pw.TextStyle(
                                                                      fontSize: 11,
                                                                      fontWeight: pw.FontWeight.bold,
                                                                    )),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        pw.Padding(
                                                            padding: const pw.EdgeInsets.fromLTRB(20, 10, 0, 0),
                                                            child: pw.SizedBox(
                                                              width: 150,
                                                              height: 50,
                                                              child: pw.BarcodeWidget(
                                                                data: '$palete',
                                                                barcode: Barcode.code128(),
                                                                width: 150,
                                                                height: 50,
                                                                color: PdfColors.black,
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
                                                      child: pw.Text('SEQ',
                                                          textAlign: pw.TextAlign.center,
                                                          style: pw.TextStyle(
                                                            fontSize: 8,
                                                            fontWeight: pw.FontWeight.bold,
                                                          )),
                                                    ),
                                                    pw.VerticalDivider(
                                                      width: 0,
                                                      thickness: 1,
                                                      color: const PdfColor.fromInt(0xCC000000),
                                                    ),
                                                    pw.Expanded(
                                                      flex: 4,
                                                      child: pw.Text('C.N.P.J.',
                                                          textAlign: pw.TextAlign.center,
                                                          style: pw.TextStyle(
                                                            fontSize: 8,
                                                            fontWeight: pw.FontWeight.bold,
                                                          )),
                                                    ),
                                                    pw.VerticalDivider(
                                                      width: 0,
                                                      thickness: 1,
                                                      color: const PdfColor.fromInt(0xCC000000),
                                                    ),
                                                    pw.Expanded(
                                                      flex: 12,
                                                      child: pw.Text('CLIENTE',
                                                          textAlign: pw.TextAlign.center,
                                                          style: pw.TextStyle(
                                                            fontSize: 8,
                                                            fontWeight: pw.FontWeight.bold,
                                                          )),
                                                    ),
                                                    pw.VerticalDivider(
                                                      width: 0,
                                                      thickness: 1,
                                                      color: const PdfColor.fromInt(0xCC000000),
                                                    ),
                                                    pw.Expanded(
                                                      flex: 4,
                                                      child: pw.Text('CIDADE',
                                                          textAlign: pw.TextAlign.center,
                                                          style: pw.TextStyle(
                                                            fontSize: 8,
                                                            fontWeight: pw.FontWeight.bold,
                                                          )),
                                                    ),
                                                    pw.VerticalDivider(
                                                      width: 0,
                                                      thickness: 1,
                                                      color: const PdfColor.fromInt(0xCC000000),
                                                    ),
                                                    pw.Expanded(
                                                      flex: 2,
                                                      child: pw.Text('PEDIDO',
                                                          textAlign: pw.TextAlign.center,
                                                          style: pw.TextStyle(
                                                            fontSize: 8,
                                                            fontWeight: pw.FontWeight.bold,
                                                          )),
                                                    ),
                                                    pw.VerticalDivider(
                                                      width: 0,
                                                      thickness: 1,
                                                      color: const PdfColor.fromInt(0xCC000000),
                                                    ),
                                                    pw.Expanded(
                                                      flex: 2,
                                                      child: pw.Text('NOTA',
                                                          textAlign: pw.TextAlign.center,
                                                          style: pw.TextStyle(
                                                            fontSize: 8,
                                                            fontWeight: pw.FontWeight.bold,
                                                          )),
                                                    ),
                                                    pw.VerticalDivider(
                                                      width: 0,
                                                      thickness: 1,
                                                      color: const PdfColor.fromInt(0xCC000000),
                                                    ),
                                                    pw.Expanded(
                                                      flex: 2,
                                                      child: pw.Text('VALOR',
                                                          textAlign: pw.TextAlign.center,
                                                          style: pw.TextStyle(
                                                            fontSize: 8,
                                                            fontWeight: pw.FontWeight.bold,
                                                          )),
                                                    ),
                                                    pw.VerticalDivider(
                                                      width: 0,
                                                      thickness: 1,
                                                      color: const PdfColor.fromInt(0xCC000000),
                                                    ),
                                                    pw.Expanded(
                                                      flex: 1,
                                                      child: pw.Text('VOL',
                                                          textAlign: pw.TextAlign.center,
                                                          style: pw.TextStyle(
                                                            fontSize: 8,
                                                            fontWeight: pw.FontWeight.bold,
                                                          )),
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
                                                          child: pw.Text('${index + 1}',
                                                              textAlign: pw.TextAlign.center,
                                                              style: pw.TextStyle(
                                                                fontSize: 7,
                                                                fontWeight: pw.FontWeight.bold,
                                                              )),
                                                        ),
                                                        pw.VerticalDivider(
                                                          width: 0,
                                                          thickness: 0.5,
                                                          color: const PdfColor.fromInt(0xCC000000),
                                                        ),
                                                        pw.Expanded(
                                                          flex: 4,
                                                          child: pw.Text(pedidos[index].cnpj ?? '',
                                                              textAlign: pw.TextAlign.center,
                                                              style: const pw.TextStyle(
                                                                fontSize: 7,
                                                              )),
                                                        ),
                                                        pw.VerticalDivider(
                                                          width: 0,
                                                          thickness: 0.5,
                                                          color: const PdfColor.fromInt(0xCC000000),
                                                        ),
                                                        pw.Expanded(
                                                          flex: 12,
                                                          child: pw.Padding(
                                                            padding: const pw.EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                            child: pw.Text(pedidos[index].cliente ?? '',
                                                                style: const pw.TextStyle(
                                                                  fontSize: 7,
                                                                )),
                                                          ),
                                                        ),
                                                        pw.VerticalDivider(
                                                          width: 0,
                                                          thickness: 0.5,
                                                          color: const PdfColor.fromInt(0xCC000000),
                                                        ),
                                                        pw.Expanded(
                                                          flex: 4,
                                                          child: pw.Text(pedidos[index].cidade ?? '',
                                                              textAlign: pw.TextAlign.center,
                                                              style: const pw.TextStyle(
                                                                fontSize: 7,
                                                              )),
                                                        ),
                                                        pw.VerticalDivider(
                                                          width: 0,
                                                          thickness: 0.5,
                                                          color: const PdfColor.fromInt(0xCC000000),
                                                        ),
                                                        pw.Expanded(
                                                          flex: 2,
                                                          child: pw.Text('${pedidos[index].ped}',
                                                              textAlign: pw.TextAlign.center,
                                                              style: const pw.TextStyle(
                                                                fontSize: 7,
                                                              )),
                                                        ),
                                                        pw.VerticalDivider(
                                                          width: 0,
                                                          thickness: 0.5,
                                                          color: const PdfColor.fromInt(0xCC000000),
                                                        ),
                                                        pw.Expanded(
                                                          flex: 2,
                                                          child: pw.Text('${pedidos[index].nota ?? ''}',
                                                              textAlign: pw.TextAlign.center,
                                                              style: const pw.TextStyle(
                                                                fontSize: 7,
                                                              )),
                                                        ),
                                                        pw.VerticalDivider(
                                                          width: 0,
                                                          thickness: 0.5,
                                                          color: const PdfColor.fromInt(0xCC000000),
                                                        ),
                                                        pw.Expanded(
                                                          flex: 2,
                                                          child: pw.Text((((NumberFormat('#,##0.00').format(pedidos[index].valor)).replaceAll(',', ':')).replaceAll('.', ',')).replaceAll(':', '.'),
                                                              textAlign: pw.TextAlign.center,
                                                              style: const pw.TextStyle(
                                                                fontSize: 7,
                                                              )),
                                                        ),
                                                        pw.VerticalDivider(
                                                          width: 0,
                                                          thickness: 0.5,
                                                          color: const PdfColor.fromInt(0xCC000000),
                                                        ),
                                                        pw.Expanded(
                                                          flex: 1,
                                                          child: pw.Text('${pedidos[index].vol}',
                                                              textAlign: pw.TextAlign.center,
                                                              style: const pw.TextStyle(
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
                                                      child: pw.Text('TOTAL',
                                                          textAlign: pw.TextAlign.center,
                                                          style: pw.TextStyle(
                                                            fontSize: 11,
                                                            fontWeight: pw.FontWeight.bold,
                                                          )),
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
                                                      child: pw.Text('$vol',
                                                          textAlign: pw.TextAlign.center,
                                                          style: pw.TextStyle(
                                                            fontSize: 11,
                                                            fontWeight: pw.FontWeight.bold,
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              pw.Padding(
                                                padding: const pw.EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                                                                            child: pw.Text('PALETES',
                                                                                textAlign: pw.TextAlign.center,
                                                                                style: pw.TextStyle(
                                                                                  fontSize: 11,
                                                                                  fontWeight: pw.FontWeight.bold,
                                                                                )),
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
                                                              child: pw.Text('MOTORISTA: ',
                                                                  textAlign: pw.TextAlign.center,
                                                                  style: const pw.TextStyle(
                                                                    fontSize: 9,
                                                                  )),
                                                            ),
                                                            pw.Expanded(
                                                              flex: 3,
                                                              child: pw.Container(
                                                                width: 250,
                                                                height: 20,
                                                                decoration: const pw.BoxDecoration(
                                                                    color: PdfColor.fromInt(0xFFFFFFFF),
                                                                    shape: pw.BoxShape.rectangle,
                                                                    border: pw.Border(
                                                                      bottom: pw.BorderSide(width: 1, color: PdfColors.black),
                                                                    )),
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
                                                              child: pw.Text('EXPEDIÇÃO:',
                                                                  textAlign: pw.TextAlign.center,
                                                                  style: const pw.TextStyle(
                                                                    fontSize: 9,
                                                                  )),
                                                            ),
                                                            pw.Expanded(
                                                              flex: 3,
                                                              child: pw.Container(
                                                                width: 250,
                                                                height: 20,
                                                                decoration: const pw.BoxDecoration(
                                                                    color: PdfColor.fromInt(0xFFFFFFFF),
                                                                    shape: pw.BoxShape.rectangle,
                                                                    border: pw.Border(
                                                                      bottom: pw.BorderSide(width: 1, color: PdfColors.black),
                                                                    )),
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
                                                              child: pw.Text('MOTORISTA: ',
                                                                  textAlign: pw.TextAlign.center,
                                                                  style: const pw.TextStyle(
                                                                    fontSize: 9,
                                                                  )),
                                                            ),
                                                            pw.Expanded(
                                                              flex: 3,
                                                              child: pw.Container(
                                                                width: 250,
                                                                height: 20,
                                                                decoration: const pw.BoxDecoration(
                                                                    color: PdfColor.fromInt(0xFFFFFFFF),
                                                                    shape: pw.BoxShape.rectangle,
                                                                    border: pw.Border(
                                                                      bottom: pw.BorderSide(width: 1, color: PdfColors.black),
                                                                    )),
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
                                                              child: pw.Text('EXPEDIÇÃO:',
                                                                  textAlign: pw.TextAlign.center,
                                                                  style: const pw.TextStyle(
                                                                    fontSize: 9,
                                                                  )),
                                                            ),
                                                            pw.Expanded(
                                                              flex: 3,
                                                              child: pw.Container(
                                                                width: 250,
                                                                height: 20,
                                                                decoration: const pw.BoxDecoration(
                                                                    color: PdfColor.fromInt(0xFFFFFFFF),
                                                                    shape: pw.BoxShape.rectangle,
                                                                    border: pw.Border(
                                                                      bottom: pw.BorderSide(width: 1, color: PdfColors.black),
                                                                    )),
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
                                              )
                                            ];
                                          }));
                                      await Printing.layoutPdf(
                                          onLayout:
                                              (format) =>
                                              pdf.save());
                                      if (context
                                          .mounted) {
                                        Navigator.pop(
                                            context);
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => HomeWidget(
                                                  usur,
                                                  bd: bd),
                                            ));
                                      }
                                    }
                                  },
                                  text: 'Reimprimir Romaneio',
                                  icon: const Icon(
                                    Icons.receipt_long,
                                    size: 15,
                                  ),
                                  options: FFButtonOptions(
                                    width: double.infinity,
                                    height: 54,
                                    padding: const EdgeInsets.all(0),
                                    iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 0, 0),
                                    color: Colors.green.shade700,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          color: Colors.white,
                                          letterSpacing: 0,
                                        ),
                                    elevation: 4,
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  );
                }
              ),
              Positioned(right: 0,bottom: 0, child: AtualizacaoWidget(bd: bd,context: context, usur: usur,))
            ],
          ),
        ),
      ),
    );
  }
}
