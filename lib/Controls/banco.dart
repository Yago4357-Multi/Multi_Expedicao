import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

import '../Models/Contagem.dart';
import '../Models/Palete.dart';
import '../Models/Pedido.dart';
import '../Views/lista_romaneio_conf_widget.dart';

///Classe para manter funções do Banco
class Banco {
  ///Variável para guardar a conexão com o Banco
  late final Connection conn;

  ///Construtor do Banco
  Banco() {
    init();
  }

  ///Função para iniciar o Banco de Dados
  void init() async {
    conn = await Connection.open(
        Endpoint(
          host: '192.168.1.183',
          database: 'Teste',
          username: 'BI',
          password: '123456',
          port: 5432,
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable));
  }

  ///Função para inserir dados no Banco
  void insert(String cod, int pallet, BuildContext a) async {
    var codArrumado = cod.substring(14, 33);
    var ped = codArrumado.substring(0, 10);
    var vol = codArrumado.substring(17, 19);
    var cx = codArrumado.substring(14, 16);
    try {
      try {
        await conn.execute(
            'insert into "Pedidos"("NUMPED","VOLUME_TOTAL") values ($ped,$vol) ON CONFLICT ("NUMPED") DO NOTHING;');
      } on Exception catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
      await conn.execute(
          'insert into "Bipagem"("PEDIDO","PALETE","DATA_BIPAGEM","VOLUME_CAIXA","COD_BARRA","ID_USER_BIPAGEM") values ($ped, $pallet,current_timestamp,$cx,$codArrumado,1);');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  ///Função para criar novos Paletes
  void createPalete() async {
    await conn.execute(
        'insert into "Romaneio" ("DATA_INCLUSAO","ID_USUR_CRIACAO") values (current_timestamp,1);');
  }

  ///Função para verificar se o Palete já existe
  void paleteExiste(int palete, BuildContext a) async {
    Object? teste2 = DateTime.timestamp();
    var teste = 0;

    ///Variável para manter a resposta do Banco
    late final Result pedidos;
    final conn2 = await Connection.open(
        Endpoint(
          host: '192.168.1.183',
          database: 'Teste',
          username: 'BI',
          password: '123456',
          port: 5432,
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable));

    try {
      pedidos = await conn2.execute(
          'select "ID","DATA_FECHAMENTO" from "Palete" where "ID" = $palete;');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      teste = (element[0] ?? 0) as int;
      teste2 = element[1];
    }
    if (a.mounted) {
      if (teste == 0) {
        await showCupertinoModalPopup(
          context: a,
          barrierDismissible: false,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text('Palete não encontrado'),
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
        );
        return;
      }
      if (teste2 != null) {
        await showCupertinoModalPopup(
            barrierDismissible: false,
            builder: (context) {
              return CupertinoAlertDialog(
                title: const Text(
                  'Palete finalizado\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: const Text(
                    'Escolha outro palete ou converse com a Supervisão'),
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
        return;
      }
      Navigator.pop(a);
      await Navigator.push(
          a,
          MaterialPageRoute(
              builder: (context) => ListaRomaneioConfWidget(palete: teste)));
    }
  }

  ///Função para buscar o último Romaneio do Banco
  Future<int> getPalete() async {
    var teste = 0;
    late final Result pedidos;
    final conn2 = await Connection.open(
        Endpoint(
          host: '192.168.1.183',
          database: 'Teste',
          username: 'BI',
          password: '123456',
          port: 5432,
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable));
    try {
      pedidos =
          await conn2.execute('select COALESCE(MAX("ID"),0) from "Palete";');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      teste = (element[0] ?? 0) as int;
    }
    return teste + 1;
  }

  ///Função para verificar se o palete foi finalizado
  Future<List<palete>> paleteFinalizado() async {
    var teste = <palete>[];
    late final Result pedidos;
    final conn2 = await Connection.open(
        Endpoint(
          host: '192.168.1.183',
          database: 'Teste',
          username: 'BI',
          password: '123456',
          port: 5432,
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable));
    try {
      pedidos = await conn2.execute(
          'select "Palete"."ID","ID_USUR_CRIACAO","DATA_INCLUSAO",count("Bipagem"."PEDIDO"),"ID_USUR_FECHAMENTO","Palete"."DATA_FECHAMENTO" from "Palete" left join "Romaneio" on 	"ID_ROMANEIO" = "Romaneio"."ID" left join "Bipagem" on "PALETE" = "Palete"."ID" where "Palete"."DATA_FECHAMENTO" is not null and "Romaneio"."DATA_FECHAMENTO" is null group by "Palete"."ID", "ID_USUR_CRIACAO", "DATA_INCLUSAO", "ID_USUR_FECHAMENTO", "Palete"."DATA_FECHAMENTO" order by "ID";');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      if (element[4] == null) {
        teste.add(palete(element[0] as int?, element[1] as int?,
            element[2] as DateTime?, element[3] as int?));
      } else {
        teste.add(palete(element[0] as int?, element[1] as int?,
            element[2] as DateTime?, element[3] as int?,
            id_usur_fechamento: element[4] as int?,
            dt_fechamento: element[5] as DateTime?));
      }
    }
    return teste;
  }

  ///Função para finalizar Paletes
  void endPalete(int palete) async {
    await conn.execute(
        'update "Palete" set "DATA_FECHAMENTO" = current_timestamp where "ID" = $palete');
  }

  ///Função para criar novos Romaneios
  void createRomaneio() async {
    await conn.execute(
        'insert into "Romaneio" ("DATA_ROMANEIO","ID_USUR") values (current_timestamp,1);');
  }

  ///Função para buscar o último Romaneio do Banco
  Future<int?> getRomaneio(BuildContext a) async {
    int? teste;
    late final Result pedidos;
    final conn2 = await Connection.open(
        Endpoint(
          host: '192.168.1.183',
          database: 'Teste',
          username: 'BI',
          password: '123456',
          port: 5432,
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable));
    try {
      pedidos = await conn2.execute(
          'select COALESCE(MAX("ID"),0) from "Romaneio" where "DATA_FECHAMENTO" IS NULL;');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      teste = element[0] as int?;
    }
    if (teste == 0) {
      if (a.mounted) {
        await showCupertinoModalPopup(
            barrierDismissible: false,
            builder: (context) {
              return CupertinoAlertDialog(
                title: const Text('Nenhum Romaneio em Aberto'),
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
    } else {
      return teste;
    }
    return 0;
  }

  ///Funlção para finalizar Romaneio
  void endRomaneio(int romaneio) async {
    await conn.execute(
        'update "Romaneio" set "DATA_FECHAMENTO" = current_timestamp where "ID" = $romaneio;');
  }

  ///Função para Buscar todas as bipagens do Banco
  Future<List<Contagem>> selectAll() async {
    var teste = <Contagem>[];
    late final Result pedidos;
    late Result volumeResponse;
    final conn2 = await Connection.open(
        Endpoint(
          host: '192.168.1.183',
          database: 'Teste',
          username: 'BI',
          password: '123456',
          port: 5432,
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable));

    try {
      pedidos = await conn2.execute('select * from "Bipagem";');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    for (var element in pedidos) {
      try {
        volumeResponse = (await conn2.execute(
            'select "VOLUME_TOTAL" from "Pedidos" where "NUMPED" = ${element[1]};'));
        for (var element2 in volumeResponse) {
          if (element2[0] != null) {
            teste.add(Contagem(element[1] as int?, element[5] as int?,
                element[4] as int?, (int.parse('${element2[0]}'))));
          }
        }
      } on Exception catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
    return teste;
  }

  ///Função para buscar todas as bipagens dos paletes selecionados para a tela do Romaneio
  Future<List<pedido>> selectPalletRomaneio(
      Future<List<int>> listaPaletes) async {
    var paletes = await listaPaletes;
    var teste = <pedido>[];
    late final Result pedidos;
    var status = 'OK';
    final conn2 = await Connection.open(
        Endpoint(
          host: '192.168.1.183',
          database: 'Teste',
          username: 'BI',
          password: '123456',
          port: 5432,
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable));
    try {
      if (paletes.isNotEmpty) {
        pedidos = await conn2.execute(
            'select P."NUMPED", string_agg(distinct cast(B."PALETE" as varchar) , '
            "', '"
            ') as PALETES, count(B."PEDIDO") as CAIXAS, P."VOLUME_TOTAL" from "Pedidos" as P left join "Bipagem" as B on P."NUMPED" = B."PEDIDO"  where B."PEDIDO" in (Select "PEDIDO" from "Bipagem" where "PALETE" in (${paletes.join(',')})) group by P."NUMPED";');
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      if ((element[2] as int) < (element[3] as int) ||
          element[1].toString().replaceAll(RegExp(',| '), '').length >
              paletes.length) {
        status = 'Errado';
      } else {
        status = 'OK';
      }
      teste.add(pedido(element[0] as int, element[1] as String,
          element[2] as int, element[3] as int, status));
    }
    return teste;
  }

  ///Função para buscar
  Future<List<Contagem>> selectPallet(int palete) async {
    var teste = <Contagem>[];
    late final Result pedidos;
    late Result volumeResponse;
    final conn2 = await Connection.open(
        Endpoint(
          host: '192.168.1.183',
          database: 'Teste',
          username: 'BI',
          password: '123456',
          port: 5432,
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable));

    try {
      pedidos = await conn2.execute(
          'select * from "Bipagem" where "PALETE" = $palete order by "ID";');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    try {
      for (var element in pedidos) {
        try {
          volumeResponse = await conn2.execute(
              'select "VOLUME_TOTAL" from "Pedidos" where "NUMPED" = ${element[1]};');
          for (var element2 in volumeResponse) {
            if (element2[0] != null) {
              teste.add(Contagem(element[1] as int?, element[5] as int?,
                  element[4] as int?, (int.parse('${element2[0]}'))));
            }
          }
        } on Exception catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return teste;
  }

  ///Buscar Bipagem pelo número do Pedido
  Future<List<Contagem>> selectPedido(int cod) async {
    var teste = <Contagem>[];
    late final Result pedidos;
    late Result volumeResponse;
    final conn2 = await Connection.open(
        Endpoint(
          host: '192.168.1.183',
          database: 'Teste',
          username: 'BI',
          password: '123456',
          port: 5432,
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable));

    try {
      pedidos = await conn2.execute(
          'select * from "Bipagem" where "PEDIDO" = $cod order by "VOLUME_CAIXA";');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      try {
        volumeResponse = (await conn2.execute(
            'select "VOLUME_TOTAL" from "Pedidos" where "NUMPED" = ${element[1]};'));
        for (var element2 in volumeResponse) {
          if (element2[0] != null) {
            teste.add(Contagem(element[1] as int?, element[5] as int?,
                element[4] as int?, (int.parse('${element2[0]}'))));
          }
        }
      } on Exception catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
    return teste;
  }

  ///Função para atualizar o palete da Caixa
  void updatePedido(List<Contagem> pedidos) async {
    for (var element in pedidos) {
      await conn.execute(
          'update "Bipagem" set "PALETE" = ${element.Pallet} where "PEDIDO" = ${element.Ped} and "VOLUME_CAIXA" = ${element.Cx};');
    }
  }

  ///Função para excluir a caixa
  excluiPedido(List<Contagem> pedidos) async {
    late Result pedidosResponse;
    final conn2 = await Connection.open(
        Endpoint(
          host: '192.168.1.183',
          database: 'Teste',
          username: 'BI',
          password: '123456',
          port: 5432,
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable));

    for (var element in pedidos) {
      try {
        pedidosResponse = await conn2.execute(
            'select * from "Bipagem" where "PEDIDO" = ${element.Ped} and "VOLUME_CAIXA" = ${element.Cx} order by "VOLUME_CAIXA";');
        for (var element2 in pedidosResponse) {
          await conn2.execute(
              "insert into \"Bipagem_Excluida\" values (${element2[0]},${element2[1]},to_timestamp('${element2[2]}','YYYY-MM-DD HH24:MI:SS'),${element2[3]},${element2[4]},${element2[5]},${element2[6]},current_timestamp,1);");
          await conn2.execute(
              'delete from "Bipagem" where "PEDIDO" = ${element.Ped} and "VOLUME_CAIXA" = ${element.Cx};');
        }
      } on Exception catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
  }

  ///Função para atualizar o romaneio do Palete
  void updatePalete(int romaneio, List<int> paletes) async {
    await conn.execute(
        'update "Palete" set "ID_ROMANEIO" = $romaneio where "ID" in (${paletes.join(',')});');
  }

  ///Função para remover o romaneio do palete
  void removePalete(int romaneio, List<int> paletes) async {
    if (paletes.isNotEmpty) {
      await conn.execute(
          'update "Palete" set "ID_ROMANEIO" = null where "ID" not in (${paletes.join(',')}) and "ID_ROMANEIO" = $romaneio;');
    } else {
      await conn.execute(
          'update "Palete" set "ID_ROMANEIO" = null where "ID_ROMANEIO" = $romaneio;');
    }
  }

  ///Função para puxar os paletes que estão no romaneio
  Future<List<int>> selectRomaneio(int romaneio) async {
    var teste = <int>[];
    late final Result pedidos;
    final conn2 = await Connection.open(
        Endpoint(
          host: '192.168.1.183',
          database: 'Teste',
          username: 'BI',
          password: '123456',
          port: 5432,
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable));
    try {
      pedidos = await conn2.execute(
          'select "ID" from "Palete" where "ID_ROMANEIO" = $romaneio;');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      teste.add(element[0] as int);
    }
    return teste;
  }
}
