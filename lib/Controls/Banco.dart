import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
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
    String Cod_Arrumado = cod.substring(14, 33);
    String ped = Cod_Arrumado.substring(0, 10);
    String vol = Cod_Arrumado.substring(17, 19);
    String cx = Cod_Arrumado.substring(14, 16);
    try {
      try {
        await conn.execute(
            'insert into "Pedidos"("NUMPED","VOLUME_TOTAL") values ($ped,$vol) ON CONFLICT ("NUMPED") DO NOTHING;');
      } catch (e) {
        print('insert $e');
      }
      await conn.execute(
          'insert into "Bipagem"("PEDIDO","PALETE","DATA_BIPAGEM","VOLUME_CAIXA","COD_BARRA","ID_USER_BIPAGEM") values ($ped, $pallet,current_timestamp,$cx,$Cod_Arrumado,1);');
    } on Exception catch (e) {
      print(e);
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

  createPalete() async {
    await conn.execute(
        'insert into "Palete" ("DATA_INCLUSAO","ID_USUR_CRIACAO") values (current_timestamp,1);');
  }

  Future<int> getPalete() async {
    var teste;
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
      Pedidos =
          await conn2.execute('select COALESCE(MAX("ID"),0) from "Palete";');
    } catch (e) {
      print(e);
    }
    Pedidos!.forEach((element) {
      teste = element[0];
    });
    return teste + 1;
  }

  Future<List<Contagem>> selectAll() async {
    var teste = <Contagem>[];
    late final Pedidos;
    late Result VolumeResponse;
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
      Pedidos = await conn2.execute('select * from "Bipagem";');
    } catch (e) {
      print(e);
    }
    Pedidos!.forEach((element) async {
      try {
        VolumeResponse = (await conn2.execute(
            'select "VOLUME_TOTAL" from "Pedidos" where "NUMPED" = ${element[1]};'));
        VolumeResponse!.forEach((element2) async {
          if (element2[0] != null) {
            teste.add(Contagem(element[1], element[5], element[4],
                (int.parse('${element2[0]}'))));
          }
        });
      } catch (e) {
        print(e);
      }
    });
    return teste;
  }

  Future<List<Contagem>> selectPallet(int Pallet) async {
    var teste = <Contagem>[];
    late final Pedidos;
    late Result VolumeResponse;
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
          .execute('select * from "Bipagem" where "PALETE" = $Pallet;');
    } catch (e) {
      print(e);
    }
    try {
      Pedidos!.forEach((element) async {
        try {
          VolumeResponse = await conn2.execute(
              'select "VOLUME_TOTAL" from "Pedidos" where "NUMPED" = ${element[1]};');
          VolumeResponse.forEach((element2) async {
            if (element2[0] != null) {
              teste.add(Contagem(element[1], element[5], element[4],
                  (int.parse('${element2[0]}'))));
            }
          });
        } catch (e) {
          print(e);
        }
      });
    } catch (e) {
      print(e);
    }
    return teste;
  }

  Future<List<Contagem>> selectPedido(int cod) async {
    var teste = <Contagem>[];
    late final Pedidos;
    late Result VolumeResponse;
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
      Pedidos =
          await conn2.execute('select * from "Bipagem" where "PEDIDO" = $cod;');
    } catch (e) {
      print(e);
    }
    Pedidos!.forEach((element) async {
      try {
        VolumeResponse = (await conn2.execute(
            'select "VOLUME_TOTAL" from "Pedidos" where "NUMPED" = ${element[1]};'));
        VolumeResponse!.forEach((element2) async {
          if (element2[0] != null) {
            teste.add(Contagem(element[1], element[5], element[4],
                (int.parse('${element2[0]}'))));
          }
        });
      } catch (e) {
        print(e);
      }
    });
    return teste;
  }

  update() async {
    await conn.execute('update "Bipagem" ');
  }
}
