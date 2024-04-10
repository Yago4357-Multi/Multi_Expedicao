import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:postgres/postgres.dart';

import '../Models/Contagem.dart';

class Banco {
  late final Connection conn;

  Banco() {
    init();
  }

  init() async {
    conn = await Connection.open(
        Endpoint(
          host: 'localhost',
          database: 'Teste',
          username: 'BI',
          password: '123456',
          port: 5432,
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable));
  }

  insert(String cod, int pallet, a) async {
    String Cod_Arrumado = cod.substring(14,33);
    String ped = Cod_Arrumado.substring(0,10);
    String vol = Cod_Arrumado.substring(17,19);
    String cx = Cod_Arrumado.substring(14,16);
    try {
      await conn.execute(
          'insert into "Bipagem"("Pedido","Pallet", "DiaBipagem","Caixa","Volumes") values ($ped, $pallet,current_timestamp,$cx,$vol);');
    } on Exception {
      await showCupertinoModalPopup(
          barrierDismissible: false,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text('Código Duplicado'),
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
          context: a);
    }
  }

  Future<List<Contagem>> selectPallet(int Pallet) async {
    var teste = <Contagem>[];
    late final Pedidos;
    var conn2 = await Connection.open(
        Endpoint(
          host: 'localhost',
          database: 'Teste',
          username: 'BI',
          password: '123456',
          port: 5432,
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable));

    try {
        Pedidos = await conn2
            .execute('select * from "Bipagem" where "Pallet" = $Pallet;');
    } catch (e) {
      print(e);
    }
    Pedidos!.forEach((element) {
      teste.add(Contagem(element[0], element[1], element[3], element[4]));
    });
    return teste;
  }

  Future<List<Contagem>> selectPedido(String cod) async {
    var teste = <Contagem>[];
    late final Pedidos;
    var conn2 = await Connection.open(
        Endpoint(
          host: 'localhost',
          database: 'Teste',
          username: 'BI',
          password: '123456',
          port: 5432,
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable));

    try {
        Pedidos = await conn2
            .execute('select * from "Bipagem" where "Pedido" = $cod;');
    } catch (e) {
      print(e);
    }
    Pedidos!.forEach((element) {
      teste.add(Contagem(element[0], element[1], element[3], element[4]));
    });
    return teste;
  }

  update() async {
    await conn.execute('update "Bipagem" ');
  }
}
