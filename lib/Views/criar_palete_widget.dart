import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:romaneio_teste/Views/lista_pedido_widget.dart';
import '../Components/Model/criar_palete_model.dart';
import '../Components/Widget/drawer_widget.dart';
export '../Components/Model/criar_palete_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

import '../Controls/banco.dart';
import 'lista_romaneio_conf_widget.dart';

class CriarPaleteWidget extends StatefulWidget {
  const CriarPaleteWidget({super.key});

  @override
  State<CriarPaleteWidget> createState() => _CriarPaleteWidgetState();
}

class _CriarPaleteWidgetState extends State<CriarPaleteWidget> {
  late final bd = Banco();
  late Future<int> getPalete;
  final pdf = pw.Document();
  late CriarPaleteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getPalete = bd.getPalete();
    _model = createModel(context, () => CriarPaleteModel());
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
            'Criar Palete',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Outfit',
              color: FlutterFlowTheme.of(context).primaryBackground,
            ),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 2,
        ),
        drawer: Drawer(
          elevation: 16,
          child: wrapWithModel(
            model: _model.drawerModel,
            updateCallback: () => setState(() {}),
            child: const DrawerWidget(),
          ),
        ),
        body: SafeArea(
          top: true,
          child: FutureBuilder(
            future: getPalete,
            builder: (context, snapshot) {
              int i = 0;
              i = snapshot.data ?? 0;
              return Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: const AlignmentDirectional(-1, 0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Criar novo Palete',
                              textAlign: TextAlign.start,
                              style: FlutterFlowTheme.of(context)
                                  .headlineMedium
                                  .override(
                                fontFamily: 'Outfit',
                                letterSpacing: 0,
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                              child: Text(
                                'Criar novo Palete para bipagem',
                                textAlign: TextAlign.start,
                                style: FlutterFlowTheme.of(context)
                                    .labelLarge
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
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      BarcodeWidget(
                        data: '$i',
                        barcode: Barcode.code128(),
                        width: 300,
                        height: 90,
                        color: FlutterFlowTheme.of(context).primaryText,
                        backgroundColor: Colors.transparent,
                        errorBuilder: (context, error) => const SizedBox(
                          width: 300,
                          height: 90,
                        ),
                        drawText: true,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Readex Pro',
                          fontSize: 20,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 12),
                    child: FFButtonWidget(
                      onPressed: () async {
                        bd.createPalete();
                        pdf.addPage(pw.Page(
                          pageFormat: PdfPageFormat.a4,
                          build: (context2) {
                            return pw.BarcodeWidget(
                                data: '$i',
                                barcode: Barcode.code128(),
                                width: 800,
                                height: 200,
                                color: PdfColors.black,
                                drawText: true,
                                textStyle: const pw.TextStyle(
                                  fontSize: 20,
                                  letterSpacing: 0,
                                ));
                          },
                        ));
                        await Printing.layoutPdf(onLayout: (format) => pdf.save());
                        print(i);
                        Navigator.pop(context);
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => ListaRomaneioConfWidget(palete: i ),));
                      },
                      text: 'Criar Palete e Imprimir Cód.',
                      icon: const Icon(
                        Icons.receipt_long,
                        size: 15,
                      ),
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 54,
                        padding: const EdgeInsets.all(0),
                        iconPadding:
                        const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: Colors.green.shade700,
                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
              );
            },
          ),
        ),
      ),
    );
  }
}
