import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

import '../Models/carregamento.dart';
import '../Models/contagem.dart';
import '../Models/palete.dart';
import '../Models/pedido.dart';
import '../Models/romaneio.dart';
import '../Models/usur.dart';
import '../Views/conferencia_widget.dart';
import '../Views/escolha_conferencia_widget.dart';
import '../Views/escolha_romaneio_widget.dart';
import '../Views/romaneio_widget.dart';

///Classe para manter funções do Banco
class Banco {
  ///Variável para guardar a conexão com o Banco
  late Connection conn;

  ///Construtor do Banco
  Banco(context) {
    init(context);
  }

  Future<int> connected(context) async {
    try {
      if (conn.isOpen) {
        return 1;
      } else {
        conn = await Connection.open(
            Endpoint(
              host: '192.168.1.183',
              database: 'Teste',
              username: 'BI',
              password: '123456',
              port: 5432,
            ),
            settings: const ConnectionSettings(sslMode: SslMode.disable));
        if (conn.isOpen) {
          return 1;
        }
        else {
          await showCupertinoModalPopup(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return CupertinoAlertDialog(
                title: const Text('Sem conexão com o Servidor'),
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
          return 0;
        }
      }
    } on SocketException{
      await showCupertinoModalPopup(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Sem conexão com a Internet'),
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
      return 0;
    }
  }

  ///Função para iniciar o Banco de Dados
  void init(context) async {
    try {
      conn = await Connection.open(
          Endpoint(
            host: '192.168.1.183',
            database: 'Teste',
            username: 'BI',
            password: '123456',
            port: 5432,
          ),
          settings: const ConnectionSettings(sslMode: SslMode.disable));
    } on SocketException {
      await showCupertinoModalPopup(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Sem conexão com o Servidor'),
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
    }
  }

  ///Função para inserir dados no Banco
  void insert(String cod, int pallet, BuildContext a, Usuario usur) async {
    if (cod.length != 33) {
      if (a.mounted) {
        await showCupertinoModalPopup(
          context: a,
          barrierDismissible: false,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text('Código de caixa inválido'),
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
      }
    } else {
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
            'insert into "Bipagem"("PEDIDO","PALETE","DATA_BIPAGEM","VOLUME_CAIXA","COD_BARRA","ID_USER_BIPAGEM") values ($ped, $pallet,current_timestamp with timezone,$cx,$codArrumado,${usur.id});');
      } on Exception {
        if (a.mounted) {
          await showCupertinoModalPopup(
            context: a,
            barrierDismissible: false,
            builder: (context) {
              return CupertinoAlertDialog(
                title: const Text('Caixa duplicada'),
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
        }
      }
    }
  }

  ///Função para criar novos Paletes
  void createPalete(Usuario usur) async {
    await conn.execute(
        'insert into "Palete" ("DATA_INCLUSAO","ID_USUR_CRIACAO") values (current_timestamp,${usur.id});');
  }

  ///Função para verificar se o Palete já existe
  void paleteExiste(int palete, BuildContext a, Usuario usur, Banco bd) async {
    Object? teste2 = DateTime.timestamp();
    var teste = 0;

    ///Variável para manter a resposta do Banco
    late final Result pedidos;

    try {
      pedidos = await conn.execute(
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
      if (a.mounted) {
        Navigator.pop(a);
        await Navigator.push(
            a,
            MaterialPageRoute(
                builder: (context) =>
                    ListaRomaneioConfWidget(palete: teste, usur, bd: bd)));
      }
    }
  }

  ///Função para puxar todos os Romaneios
  Future<List<Romaneio>> romaneioExiste() async {
    var teste = <Romaneio>[];

    ///Variável para manter a resposta do Banco
    late final Result pedidos;

    try {
      pedidos = await conn.execute(
          'select "Romaneio"."ID","Romaneio"."DATA_FECHAMENTO", "Romaneio"."DATA_ROMANEIO", "Usuarios"."NOME", COALESCE(string_agg(distinct cast("Palete"."ID" as varchar) , \', \' ),\'0\'), count("Bipagem"."ID") from "Romaneio" left join "Palete" on "Palete"."ID_ROMANEIO" = "Romaneio"."ID" left join "Bipagem" on "Palete"."ID" = "Bipagem"."PALETE" left join "Usuarios" on "Usuarios"."ID" = "Romaneio"."ID_USUR" group by "Romaneio"."ID", "Romaneio"."DATA_FECHAMENTO", "Romaneio"."DATA_ROMANEIO", "Usuarios"."NOME", "Usuarios"."NOME";');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      teste.add(Romaneio(element[0] as int?, element[5] as int?, (element[1] as DateTime?)?.toLocal(), (element[2] as DateTime?)?.toLocal(), element[3] as String?, element[4] as String?));
    }
    return teste;
  }

  ///Função para buscar o último Romaneio do Banco
  Future<int> getPalete() async {
    var teste = 0;
    late final Result pedidos;

    try {
      pedidos =
      await conn.execute('select COALESCE(MAX("ID"),0) from "Palete";');
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
  Future<List<Paletes>> paleteFinalizado() async {
    var teste = <Paletes>[];
    late final Result pedidos;

    try {
      pedidos = await conn.execute(
          'select "Palete"."ID",Bip."NOME","DATA_INCLUSAO",count("Bipagem"."PEDIDO"),Fech."NOME","Palete"."DATA_FECHAMENTO" from "Palete" left join "Romaneio" on "ID_ROMANEIO" = "Romaneio"."ID" left join "Bipagem" on "PALETE" = "Palete"."ID" left join "Usuarios" as Bip on Bip."ID" = "ID_USUR_CRIACAO" left join "Usuarios" as Fech on Fech."ID" = "ID_USUR_FECHAMENTO" where "Palete"."DATA_FECHAMENTO" is not null and "Romaneio"."DATA_FECHAMENTO" is null group by "Palete"."ID", Bip."NOME", "DATA_INCLUSAO", Fech."NOME", "Palete"."DATA_FECHAMENTO" order by "ID";');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      if (element[4] == null) {
        teste.add(Paletes(
            element[0] as int?,
            element[1] as String?,
            element[2] != '' && element[2] != null
                ? DateTime.parse('${element[2]}').toLocal()
                : null,
            element[3] as int?));
      } else {
        teste.add(Paletes(
            element[0] as int?,
            element[1] as String?,
            element[2] != '' && element[2] != null
                ? DateTime.parse('${element[2]}').toLocal()
                : null,
            element[3] as int?,
            UsurFechamento: element[4] as String?,
            dtFechamento: element[5] != '' && element[5] != null
                ? DateTime.parse('${element[5]}').toLocal()
                : null));
      }
    }

    return teste;
  }

  ///Função para verificar se o romaneio foi finalizado
  Future<List<Romaneio>> romaneioFinalizado() async {
    var teste = <Romaneio>[];
    late final Result pedidos;

    try {
      pedidos = await conn.execute(
          'select "Romaneio"."ID", count("Bipagem"."PEDIDO"),"Romaneio"."DATA_FECHAMENTO" from "Palete" left join "Romaneio" on "ID_ROMANEIO" = "Romaneio"."ID" left join "Bipagem" on "PALETE" = "Palete"."ID" left join (select "Palete"."ID" from "Palete" left join "Romaneio" on "Romaneio"."ID" = "ID_ROMANEIO" where "Palete"."DATA_CARREGAMENTO" is null) as "Palete2" on "Palete2"."ID" = "Palete"."ID" where "Romaneio"."DATA_FECHAMENTO" is not null and "Palete2"."ID" is not null group by "Romaneio"."ID", "Romaneio"."ID_USUR", "Romaneio"."DATA_FECHAMENTO" order by "ID"');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      teste.add(Romaneio(element[0] as int?, element[1] as int?,
          DateTime.parse('${element[2]}').toLocal() as DateTime?,null, null, null));
    }

    return teste;
  }

  ///Função para verificar se o palete foi finalizado
  Future<List<Paletes>> paleteAll(int palete, BuildContext a) async {
    var teste = <Paletes>[];
    late final Result pedidos;

    try {
      pedidos = await conn.execute(
          'select "Palete"."ID",Bip."NOME","DATA_INCLUSAO",count("Bipagem"."PEDIDO"),Fech."NOME","Palete"."DATA_FECHAMENTO", Car."NOME","Palete"."DATA_CARREGAMENTO"  from "Palete" left join "Romaneio" on "ID_ROMANEIO" = "Romaneio"."ID" left join "Bipagem" on "PALETE" = "Palete"."ID" left join "Usuarios" Bip on Bip."ID" = "ID_USUR_CRIACAO" left join "Usuarios" Fech on Fech."ID" = "ID_USUR_FECHAMENTO" LEFT JOIN "Usuarios" Car on Car."ID" = "ID_USUR_CARREGAMENTO" where "Palete"."ID" = $palete group by "Palete"."ID", Bip."NOME", "DATA_INCLUSAO", Fech."NOME", "Palete"."DATA_FECHAMENTO", Car."NOME","Palete"."DATA_CARREGAMENTO" order by "ID";');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      if (element[4] == null) {
        teste.add(Paletes(
            element[0] as int?,
            element[1] as String?,
            element[2] != '' && element[2] != null
                ? DateTime.parse('${element[2]}').toLocal()
                : null,
            element[3] as int?));
      } else {
        if (element[6] == null) {
          teste.add(Paletes(
              element[0] as int?,
              element[1] as String?,
              element[2] != '' && element[2] != null
                  ? DateTime.parse('${element[2]}').toLocal()
                  : null,
              element[3] as int?,
              UsurFechamento: element[4] as String?,
              dtFechamento: element[5] != '' && element[5] != null
                  ? DateTime.parse('${element[5]}').toLocal()
                  : null));
        } else {
          teste.add(Paletes(
              element[0] as int?,
              element[1] as String?,
              element[2] != '' && element[2] != null
                  ? DateTime.parse('${element[2]}').toLocal()
                  : null,
              element[3] as int?,
              UsurFechamento: element[4] as String?,
              dtFechamento: element[5] != '' && element[5] != null
                  ? DateTime.parse('${element[5]}').toLocal()
                  : null,
              UsurCarregamento: element[6] as String?,
              dtCarregamento: element[7] != '' && element[7] != null
                  ? DateTime.parse('${element[7]}').toLocal()
                  : null));
        }
      }
    }

    return teste;
  }

  ///Função para finalizar Paletes
  void endPalete(int palete, Usuario usur) async {
    await conn.execute(
        'update "Palete" set "DATA_FECHAMENTO" = current_timestamp, "ID_USUR_FECHAMENTO" = ${usur.id} where "ID" = $palete');
  }

  ///Função para criar novos Romaneios
  void createRomaneio(Usuario usur) async {
    await conn.execute(
        'insert into "Romaneio" ("DATA_ROMANEIO","ID_USUR") values (current_timestamp,${usur.id});');
  }

  void updateCarregamento(int palete, Usuario usur) async {
    await conn.execute(
        'update "Palete" set "DATA_CARREGAMENTO" = current_timestamp, "ID_USUR_CARREGAMENTO" = ${usur.id} where "ID" = $palete;');
  }

  ///Pegar palete baseado no Romaneio
  Future<List<Carregamento>> getCarregamento(int romaneio) async {
    late var carregamento = <Carregamento>[];
    late final Result pedidos;

    try {
      pedidos = await conn.execute(
          'select "Palete"."ID", count("Bipagem"."PEDIDO"), "DATA_CARREGAMENTO" from "Palete" left join "Romaneio" on "ID_ROMANEIO" = "Romaneio"."ID" left join "Bipagem" on "PALETE" = "Palete"."ID" where "Romaneio"."ID" = $romaneio group by "Palete"."ID", "DATA_CARREGAMENTO" order by "Palete"."ID";');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      if (element[2] == null) {
        carregamento.add(Carregamento(
            element[0] as int?, element[1] as int?, 'Não Carregado'));
      } else {
        carregamento.add(
            Carregamento(element[0] as int?, element[1] as int?, 'Carregado'));
      }
    }

    return carregamento;
  }

  ///Função para buscar o último Romaneio do Banco
  Future<int?> getRomaneio(BuildContext a) async {
    int? teste;
    late final Result pedidos;

    try {
      pedidos = await conn.execute(
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
  void endRomaneio(int romaneio, List<Pedido> pedidos) async {
    for (var i in pedidos) {
      await conn.execute(
          'update "Pedidos" set "IDROMANEIO" = $romaneio where "NUMPED" = ${i.ped}');
    }
    await conn.execute(
        'update "Romaneio" set "DATA_FECHAMENTO" = current_timestamp where "ID" = $romaneio;');
  }

  ///Função para Buscar todas as bipagens do Banco
  Future<List<Contagem>> selectAll() async {
    var teste = <Contagem>[];
    late final Result pedidos;
    late Result volumeResponse;

    try {
      pedidos = await conn.execute('select * from "Bipagem";');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    for (var element in pedidos) {
      try {
        volumeResponse = (await conn.execute(
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
  Future<List<Pedido>> selectPalletRomaneio(
      Future<List<int>> listaPaletes) async {
    var paletes = await listaPaletes;
    var teste = <Pedido>[];
    late final Result pedidos;
    var status = 'OK';

    try {
      if (paletes.isNotEmpty) {
        pedidos = await conn.execute(
            'select P."NUMPED", COALESCE(string_agg(distinct cast(B."PALETE" as varchar) , \',\' ),\'0\') as PALETES, COALESCE(count(B."PEDIDO"),0) as CAIXAS, P."VOLUME_TOTAL", C."CNPJ", C."CLIENTE", CID."CIDADE", P."NF", P."VLTOTAL", C."COD_CLI", P."STATUS" from "Pedidos" as P left join "Bipagem" as B on P."NUMPED" = B."PEDIDO" left join "Clientes" as C on C."COD_CLI" = P."ID_CLI" left join "Cidades" as CID on CID."CODCIDADE" = C."COD_CIDADE" where B."PEDIDO" in (Select "PEDIDO" from "Bipagem" where "PALETE" in (${paletes.join(',')})) group by P."NUMPED", C."CNPJ", C."CLIENTE", CID."CIDADE", P."NF", P."VLTOTAL", C."COD_CLI", P."STATUS";');
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      if ((element[2] as int) < (element[3] as int) ||
          !paletes.toString().contains(element[1]
              .toString()
              .replaceAll(RegExp(',| '), ', ')) ||
          (element[10] != 'F')) {
        status = 'Errado';
      } else {
        status = 'OK';
      }
      teste.add(Pedido(element[0] as int, element[1] as String,
          element[2] as int, element[3] as int, status,
          cnpj: element[4] as String?,
          cliente: element[5] as String?,
          cidade: element[6] as String?,
          nota: element[7] as int?,
          valor: element[8] as double?,
          cod_cli: element[9] as int?,
          situacao: element[10] as String?));
    }

    return teste;
  }

  ///Função para buscar todas os Pedidos
  Future<List<Pedido>> selectAllPedidos() async {
    var teste = <Pedido>[];
    late final Result pedidos;
    var status = 'OK';

    try {
      pedidos = await conn.execute(
          'select P."NUMPED", COALESCE(string_agg(distinct cast(B."PALETE" as varchar) , \',\' ),\'0\') as PALETES, COALESCE(count(B."PEDIDO"),0) as CAIXAS, P."VOLUME_TOTAL", C."CNPJ", C."CLIENTE", CID."CIDADE", P."NF", P."VLTOTAL" from "Pedidos" as P full join "Bipagem" as B on P."NUMPED" = B."PEDIDO" left join "Clientes" as C on C."COD_CLI" = P."ID_CLI" left join "Cidades" as CID on CID."CODCIDADE" = C."COD_CIDADE" group by P."NUMPED", C."CNPJ", C."CLIENTE", CID."CIDADE", P."NF";');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      teste.add(Pedido(element[0] as int, element[1] as String,
          element[2] as int, element[3] as int, status,
          cnpj: element[4] as String?,
          cliente: element[5] as String?,
          cidade: element[6] as String?,
          nota: element[7] as int?,
          valor: element[8] as double?));
    }

    return teste;
  }

  ///Função para buscar
  Future<List<Contagem>> selectPallet(int palete) async {
    var teste = <Contagem>[];
    late final Result pedidos;
    late Result volumeResponse;

    try {
      pedidos = await conn.execute(
          'select * from "Bipagem" where "PALETE" = $palete order by "ID" desc;');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    try {
      for (var element in pedidos) {
        try {
          volumeResponse = await conn.execute(
              'select "VOLUME_TOTAL", count("ID") from "Pedidos" left join "Bipagem" on "PEDIDO" = "NUMPED" where "NUMPED" = ${element[1]} group by "VOLUME_TOTAL";');
          for (var element2 in volumeResponse) {
            if (element2[0] != null) {
              teste.add(Contagem(element[1] as int?, element[5] as int?,
                  element[4] as int?, (int.parse('${element2[0]}')),
                  volBip: int.parse('${element2[1]}')));
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

    try {
      pedidos = await conn.execute(
          'select * from "Bipagem" where "PEDIDO" = $cod order by "VOLUME_CAIXA";');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      try {
        volumeResponse = (await conn.execute(
            'select "VOLUME_TOTAL", "VLTOTAL", "CLIENTE", "Cidades"."CIDADE", "STATUS" from "Pedidos" left join "Clientes" on "COD_CLI" = "ID_CLI" LEFT JOIN "Cidades" on "COD_CIDADE" = "CODCIDADE" where "NUMPED" = ${element[1]};'));
        for (var element2 in volumeResponse) {
          if (element2[0] != null) {
            teste.add(Contagem(element[1] as int?, element[5] as int?,
                element[4] as int?, (int.parse('${element2[0]}')),
                cliente: '${element2[2]}',
                cidade: '${element2[3]}',
                status: switch (element2[4] ?? 'D') {
                  'F' => 'Faturado',
                  'C' => 'Cancelado',
                  'L' => 'Libearado',
                  'D' => 'Desconhecido',
                  Object() => throw UnimplementedError(),
                }));
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
  void updatePedidoBip(List<Contagem> pedidos) async {
    for (var element in pedidos) {
      await conn.execute(
          'update "Bipagem" set "PALETE" = ${element.palete} where "PEDIDO" = ${element.ped} and "VOLUME_CAIXA" = ${element.caixa};');
    }
  }

  ///Função para excluir a caixa
  Future<List<Contagem>> excluiPedido(
      List<Contagem> pedidos, Usuario usur, int cod) async {
    late Result pedidosResponse;

    for (var element in pedidos) {
      try {
        pedidosResponse = await conn.execute(
            'select * from "Bipagem" where "PEDIDO" = ${element.ped} and "VOLUME_CAIXA" = ${element.caixa} order by "VOLUME_CAIXA";');
        for (var element2 in pedidosResponse) {
          await conn.execute(
              "insert into \"Bipagem_Excluida\" values (${element2[0]},${element2[1]},to_timestamp('${element2[2]}','YYYY-MM-DD HH24:MI:SS'),${element2[3]},${element2[4]},${element2[5]},${element2[6]},current_timestamp,${usur.id});");
          await conn.execute(
              'delete from "Bipagem" where "PEDIDO" = ${element.ped} and "VOLUME_CAIXA" = ${element.caixa};');
        }
      } on Exception catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }

    var teste = <Contagem>[];
    late final Result pedidos2;
    late Result volumeResponse;

    try {
      pedidos2 = await conn.execute(
          'select * from "Bipagem" where "PEDIDO" = $cod order by "VOLUME_CAIXA";');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos2) {
      try {
        volumeResponse = (await conn.execute(
            'select "VOLUME_TOTAL", "VLTOTAL", "CLIENTE", "Cidades"."CIDADE", "STATUS" from "Pedidos" left join "Clientes" on "COD_CLI" = "ID_CLI" LEFT JOIN "Cidades" on "COD_CIDADE" = "CODCIDADE" where "NUMPED" = ${element[1]};'));
        for (var element2 in volumeResponse) {
          if (element2[0] != null) {
            teste.add(Contagem(element[1] as int?, element[5] as int?,
                element[4] as int?, (int.parse('${element2[0]}')),
                cliente: '${element2[2]}',
                cidade: '${element2[3]}',
                status: switch (element2[4] ?? 'D') {
                  'F' => 'Faturado',
                  'C' => 'Cancelado',
                  'L' => 'Libearado',
                  'D' => 'Desconhecido',
                  Object() => throw UnimplementedError(),
                }));
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

  ///Função para reabrir o palete no Banco
  void reabrirPalete(int palete) async {
    await conn.execute(
        'update "Palete" set "DATA_FECHAMENTO" = null, "ID_USUR_FECHAMENTO" = null, "ID_ROMANEIO" = null where "ID" = $palete;');
  }

  ///Função para puxar os paletes que estão no romaneio
  Future<List<int>> selectRomaneio(int romaneio) async {
    var teste = <int>[];
    late final Result pedidos;

    try {
      pedidos = await conn.execute(
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

  ///Função para verificar login do Banco
  void auth(String login, String senha, BuildContext a, Banco bd) async {
    Usuario? usur;
    late final Result pedidos;
    try {
      pedidos = await conn.execute(
          "select \"ID\", \"SETOR\" from \"Usuarios\" where upper(\"APELIDO\") like upper('$login') and \"SENHA\" like '$senha';");
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      if (element[0] != null) {
        usur = Usuario(element[0] as int, element[1] as String);
      }
    }
    if (usur?.acess != null) {
      if (a.mounted) {
        if (Platform.isAndroid) {
          Navigator.pop(a);
          await Navigator.push(
              a,
              MaterialPageRoute(
                builder: (context) => EscolhaBipagemWidget(usur!, bd: bd),
              ));
        } else {
          Navigator.pop(a);
          await Navigator.push(
              a,
              MaterialPageRoute(
                builder: (context) => EscolhaRomaneioWidget(usur!, bd: bd),
              ));
        }
      }
    } else {
      if (a.mounted) {
        await showCupertinoModalPopup(
          context: a,
          barrierDismissible: false,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text(
                'Usuário ou Senha inválidos',
              ),
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
      }
    }
  }

  Future<void> updatePedido(Pedido pedidos) async {
    await conn.execute(
        'update "Pedidos" set "COND_VENDA" = ${pedidos.cod_venda}, "ID_CLI" = ${pedidos.cod_cli} , "STATUS" = \'${pedidos.situacao}\', "DATA_PEDIDO" = ${pedidos.dt_pedido != null ? 'to_timestamp(\'${pedidos.dt_pedido}\',\'YYYY-MM-DD HH24:MI:SS\')' : null}, "DATA_CANC_PED" = ${pedidos.dt_cancel_ped != null ? 'to_timestamp(\'${pedidos.dt_cancel_ped}\',\'YYYY-MM-DD HH24:MI:SS\')' : null}, "DATA_FATURAMENTO" = ${pedidos.dt_fat != null ? 'to_timestamp(\'${pedidos.dt_fat}\',\'YYYY-MM-DD HH24:MI:SS\')' : null}, "DATA_CANC_NF" = ${pedidos.dt_cancel_nf != null ? 'to_timestamp(\'${pedidos.dt_cancel_nf}\',\'YYYY-MM-DD HH24:MI:SS\')' : null}, "NF" = ${pedidos.nota} , "VLTOTAL" = ${pedidos.valor}, "VOLUME_NF" = ${pedidos.volfat} where "NUMPED" = ${pedidos.ped};');
  }

  Future<void> insertPedido(Pedido pedidos) async {
    await conn.execute(
        'insert into "Pedidos"("NUMPED","VOLUME_TOTAL", "DATA_FATURAMENTO", "VLTOTAL", "ID_CLI","STATUS", "NF", "COND_VENDA", "DATA_PEDIDO", "DATA_CANC_PED", "DATA_CANC_NF", "VOLUME_NF") values (${pedidos.ped}, ${pedidos.vol}, ${pedidos.dt_fat != null ? 'to_timestamp(\'${pedidos.dt_fat}\',\'YYYY-MM-DD HH24:MI:SS\')' : null}, ${pedidos.valor}, ${pedidos.cod_cli}, \'${pedidos.situacao}\', ${pedidos.nota}, ${pedidos.cod_venda}, ${pedidos.dt_pedido != null ? 'to_timestamp(\'${pedidos.dt_pedido}\',\'YYYY-MM-DD HH24:MI:SS\')' : null}, ${pedidos.dt_cancel_ped != null ? 'to_timestamp(\'${pedidos.dt_cancel_ped}\',\'YYYY-MM-DD HH24:MI:SS\')' : null}, ${pedidos.dt_cancel_nf != null ? 'to_timestamp(\'${pedidos.dt_cancel_nf}\',\'YYYY-MM-DD HH24:MI:SS\')' : null}, ${pedidos.volfat}) ON CONFLICT DO NOTHING;');
  }

  ///Busca pedidos do Banco por Roameneio
  Future<List<Pedido>> selectPedidosRomaneio(List<int> cods) async {
    var teste = <Pedido>[];
    late Result volumeResponse;

    volumeResponse = await conn.execute(
        'select "Pedidos"."NUMPED", "VOLUME_TOTAL", "COD_CLI", "CLIENTE", "VLTOTAL", "NF", "Cidades"."CIDADE", "IDROMANEIO", "DATA_FATURAMENTO" from "Pedidos" left join "Bipagem" on "Bipagem"."PEDIDO" = "Pedidos"."NUMPED" left join "Clientes" on "COD_CLI" = "ID_CLI" left join "Cidades" on "CODCIDADE" = "COD_CIDADE" where "IDROMANEIO" in (${cods.join(',')}) group by "Pedidos"."NUMPED", "VOLUME_TOTAL", "COD_CLI", "CLIENTE", "VLTOTAL", "NF", "Cidades"."CIDADE", "IDROMANEIO";');
    for (var element in volumeResponse) {
      if (element.isNotEmpty) {
        teste.add(Pedido(
            element[0]! as int, '0', 0, element[1]! as int, 'Errado',
            cod_cli: element[2]! as int,
            cliente: element[3]!.toString(),
            valor: element[4]! as double,
            nota: element[5] as int,
            cidade: element[6].toString(),
            romaneio: element[7] as int?,
            dt_fat: element[8] as DateTime?));
      }
    }

    return teste;
  }

  ///Busca pedidos não bipados que foram faturados
  Future<List<Pedido>> faturadosNBipados(
      DateTime dtIni, DateTime dtFim) async {
    var teste = <Pedido>[];
    late Result volumeResponse;

    volumeResponse = await conn.execute(
        'select "Pedidos"."NUMPED", "VOLUME_TOTAL", "COD_CLI", "CLIENTE", "VLTOTAL", "NF", "Cidades"."CIDADE" from "Pedidos" left join "Bipagem" on "Bipagem"."PEDIDO" = "Pedidos"."NUMPED" left join "Clientes" on "COD_CLI" = "ID_CLI" left join "Cidades" on "CODCIDADE" = "COD_CIDADE" where "Bipagem"."PEDIDO" is null and "STATUS" like \'F\' and "VOLUME_TOTAL" <> 0 and "DATA_FATURAMENTO" between \'${dtIni}\' and \'${dtFim}\';');
    for (var element in volumeResponse) {
      if (element.isNotEmpty) {
        teste.add(Pedido(
            element[0]! as int, '0', 0, element[1]! as int, 'Errado',
            cod_cli: element[2]! as int,
            cliente: element[3]!.toString(),
            valor: element[4]! as double,
            nota: element[5] as int,
            cidade: element[6].toString()));
      }
    }

    return teste;
  }

  Future<List<Romaneio>> romaneiosFinalizados(
      DateTime dtIni, DateTime dtFim) async {
    var teste = <Romaneio>[];
    late Result volumeResponse;

    volumeResponse = await conn.execute(
        'select "Romaneio"."ID", "DATA_FECHAMENTO", sum("VOLUME_TOTAL") from "Romaneio" left join "Pedidos" on "IDROMANEIO" = "Romaneio"."ID" where "DATA_FECHAMENTO" is not null and "DATA_FECHAMENTO" between \'$dtIni\' and \'$dtFim\' group by "Romaneio"."ID", "DATA_FECHAMENTO" order by "DATA_FECHAMENTO"');
    for (var element in volumeResponse) {
      if (element.isNotEmpty) {
        teste.add(Romaneio(
            element[0] as int,
            element[2] as int,
            element[1] != ''
                ? DateTime.parse('${element[1]}').toLocal()
                : null, null , null, null));
      }
    }

    return teste;
  }
}
