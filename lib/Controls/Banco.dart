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

  insert(String cod, String ped, int pallet, a) async {
    try {
      await conn.execute(
          'insert into "Teste"("Codigo","Pedido","Pallet", "DiaBipagem") values ($cod, $ped, $pallet,current_timestamp);');
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

  Future<List<Contagem>> select(String cod, int Pallet) async {
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
      if (Pallet != 0) {
        Pedidos = await conn2
            .execute('select * from "Teste" where "Pallet" = $Pallet;');
      } else {
        if (cod != '') {
          Pedidos = await conn2
              .execute('select * from "Teste" where "Pedido" = $cod;');
        }
      }
    } catch (e) {
      print(e);
    }
    Pedidos!.forEach((element) {
      teste.add(Contagem('0${element[0]}', element[2] as int));
    });
    return teste;
  }

  update() async {
    await conn.execute('update Teste ');
  }
}
