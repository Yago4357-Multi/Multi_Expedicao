import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../../Controls/banco.dart';
import '../../Models/usur.dart';
import '../Model/drawer_model.dart';

export '../Model/drawer_model.dart';

///Widget para puxar o mesmo Drawer em todas as telas
class AtualizacaoWidget extends StatefulWidget {
  ///Variável para definir permissões do usuário
  final Usuario usur;

  final BuildContext context;

  final Banco bd;

  ///Construtor do Drawer
  const AtualizacaoWidget(
      {required this.usur, required this.context, required this.bd, super.key});

  @override
  State<AtualizacaoWidget> createState() =>
      _AtualizacaoWidgetState(usur, context, bd);
}

class _AtualizacaoWidgetState extends State<AtualizacaoWidget> {
  late DrawerModel _model;
  late final bd;

  final Usuario usur;

  final BuildContext context2;

  late Future<DateTime?> ultAttfut;
  late DateTime? ultAtt;

  _AtualizacaoWidgetState(this.usur, this.context2, this.bd);

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    rodarBanco();
    _model = createModel(context, DrawerModel.new);
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  void rodarBanco() async {
    ultAttfut = bd.ultAttget();
  }

  @override
  Widget build(BuildContext context) {
    return (responsiveVisibility(
        context: context,
        phone: false,
        tablet: false,
        desktop: true)) ? Container(
      width: 150,
      height: 40,
      decoration: const BoxDecoration(
          color: Color.fromRGBO(56, 142, 62, 120),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20))),
      child: FutureBuilder(
        future: ultAttfut,
        builder: (context, snapshot) {
          ultAtt = snapshot.data;
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                  Text('Última Atualização',
                      style: FlutterFlowTheme.of(context)
                          .headlineLarge
                          .override(fontFamily: 'Readex Pro', fontSize: 10, color: Colors.white),
                      textAlign: TextAlign.center),
                  Text(
                      ultAtt != null
                          ? DateFormat('dd/MM/yyyy kk:mm:ss')
                              .format(ultAtt!.toLocal())
                          : 'Não atualizado',
                      style: FlutterFlowTheme.of(context)
                          .headlineLarge
                          .override(fontFamily: 'Readex Pro', fontSize: 12, color: Colors.white),
                      textAlign: TextAlign.center)
                ]));
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    ) : Container();
  }
}
