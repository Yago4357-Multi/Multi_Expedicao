import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

import '../Models/carregamento.dart';
import '../Models/cliente.dart';
import '../Models/contagem.dart';
import '../Models/declaracao.dart';
import '../Models/palete.dart';
import '../Models/pedido.dart';
import '../Models/romaneio.dart';
import '../Models/usur.dart';
import '../Views/conferencia_widget.dart';
import '../Views/home_widget.dart';

///Classe para manter funções do Banco
class Banco {
  ///Variável para guardar a conexão com o Banco
  late Connection conn;

  ///Construtor do Banco
  Banco(context) {
    init(context);
  }

  ///Função para iniciar o Banco de Dados
  void init(BuildContext context) async {
    try {
      conn = await Connection.open(
          Endpoint(
            host: '192.168.17.104',
            database: 'postgres',
            username: 'postgres',
            password: 'Multi@bd7',
            port: 5432,
          ),
          settings: ConnectionSettings(sslMode: SslMode.disable, onOpen: (connection) => connection.execute('SET search_path TO multiexpedicao'),));
    } on SocketException {
      if (context.mounted) {
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
  }

  ///Função para verificar a conexão com o Banco
  Future<int> connected(BuildContext context) async {
    try {
      if (conn.isOpen) {
        return 1;
      } else {
        conn = await Connection.open(
            Endpoint(
              host: '192.168.17.104',
              database: 'postgres',
              username: 'postgres',
              password: 'Multi@bd7',
              port: 5432,
            ),
            settings: ConnectionSettings(sslMode: SslMode.disable, onOpen: (connection) => connection.execute('SET search_path TO multiexpedicao'),));
        if (conn.isOpen) {
          return 1;
        }
        else {
          if (context.mounted) {
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
    } catch(e){
      try {
        conn = await Connection.open(
            Endpoint(
              host: '192.168.17.104',
              database: 'postgres',
              username: 'postgres',
              password: 'Multi@bd7',
              port: 5432,
            ),
            settings: ConnectionSettings(sslMode: SslMode.disable, onOpen: (connection) => connection.execute('SET search_path TO multiexpedicao'),));

        return 1;
      } catch (e) {
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
  }

  ///Função para inserir dados no Banco
  Future<List<Contagem>> insert(String cod, int pallet, BuildContext a, Usuario usur) async {
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
      var cx = codArrumado.substring(14, 16);

      try {
        await conn.execute(
            'insert into "Bipagem"("PEDIDO","PALETE","DATA_BIPAGEM","VOLUME_CAIXA","COD_BARRA","ID_USER_BIPAGEM") values ($ped, $pallet,current_timestamp,$cx,$codArrumado,${usur.id});');
      } on Exception{
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

    var teste = <Contagem>[];
    late final Result pedidos;
    late Result volumeResponse;

    try {
      pedidos = await conn.execute(
          'Select "ID", "PEDIDO", "DATA_BIPAGEM", "COD_BARRA", "VOLUME_CAIXA", "PALETE", "ID_USER_BIPAGEM" from "Bipagem" where "PALETE" = $pallet order by "ID" desc;');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    try {
      for (var element in pedidos) {
        try {
          volumeResponse = await conn.execute(
              'select "VOLUME_TOTAL", count("ID") from "Pedidos" left join "Bipagem" on "PEDIDO" = "NUMPED" where "NUMPED" = ${element[1]} and "PALETE" = $pallet group by "VOLUME_TOTAL";');
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

  ///Função para atualizar dados do Carregamento
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
      pedidos = await conn.execute('Select "ID", "PEDIDO", "DATA_BIPAGEM", "COD_BARRA", "VOLUME_CAIXA", "PALETE", "ID_USER_BIPAGEM" from "Bipagem";');
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
  Future<List<Pedido>>  selectPalletRomaneio(Future<List<int>> listaPaletes) async {
    var paletes = await listaPaletes;
    var teste = <Pedido>[];
    late final Result pedidos;
    var status = 'Correto';

    print(listaPaletes);

    if ((await listaPaletes).isNotEmpty) {
      try {
        if (paletes.isNotEmpty) {
          pedidos = await conn.execute(
              'select P."NUMPED", COALESCE(string_agg(distinct cast(B."PALETE" as varchar) , \',\' ),\'0\') as PALETES, COALESCE(count(B."PEDIDO"),0) as CAIXAS, P."VOLUME_TOTAL", C."CNPJ", C."CLIENTE", CID."CIDADE", P."NF", P."VLTOTAL", C."COD_CLI", P."STATUS" from "Pedidos" as P left join "Bipagem" as B on P."NUMPED" = B."PEDIDO" left join "Clientes" as C on C."COD_CLI" = P."ID_CLI" left join "Cidades" as CID on CID."CODCIDADE" = C."COD_CIDADE" where B."PEDIDO" in (Select "PEDIDO" from "Bipagem" where "PALETE" in (${paletes
                  .join(
                  ',')})) group by P."NUMPED", C."CNPJ", C."CLIENTE", CID."CIDADE", P."NF", P."VLTOTAL", C."COD_CLI", P."STATUS";');
        }
      } on Exception catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
      List<int> teste3 = [];
      for (var element in pedidos) {
        print('TESTEEEEE ${
            element[1]
                .toString()
                .replaceAll(RegExp(',| '), ', ')
        }');
        if ((element[2] as int) < (element[3] as int) || element[3] == 0 ||
            !paletes.toSet().containsAll(teste3.toSet()) ||
            (element[10] != 'F')) {
          status = 'Incorreto';
        } else {
          status = 'Correto';
        }
        try {
          teste.add(Pedido(element[0] as int, element[1] as String,
              element[2] as int, element[3] as int, status,
              cnpj: element[4] as String?,
              cliente: element[5] as String?,
              cidade: element[6] as String?,
              nota: element[7] as int?,
              valor: element[8] as double?,
              volfat: (element[3] ?? 0) as int?,
              codCli: element[9] as int?,
              situacao: element[10] as String?));
        } catch(e){
          print(e);
        }
      }
      print(teste);
    }


    return teste;
  }

  ///Função para buscar
  Future<List<Contagem>> selectPallet(int palete, BuildContext a) async {
    var teste = <Contagem>[];
    late final Result pedidos;
    late Result volumeResponse;
    late Result response2;
    late int teste2;
    response2 = await conn.execute('select count(*) from "Palete" where "ID" = $palete');
    for (var element in response2){
      teste2 = element[0] as int;
    }
    if (teste2 == 0 && palete > 0){
      if (a.mounted) {
        await showCupertinoModalPopup(
          context: a,
          barrierDismissible: false,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text(
                'Palete Inválido',
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
    }else{
      try {
        pedidos = await conn.execute(
            'Select "ID", "PEDIDO", "DATA_BIPAGEM", "COD_BARRA", "VOLUME_CAIXA", "PALETE", "ID_USER_BIPAGEM" from "Bipagem" where "PALETE" = $palete order by "ID" desc;');
      } on Exception catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
      try {
        for (var element in pedidos) {
          try {
            volumeResponse = await conn.execute(
                'select "VOLUME_TOTAL", "Clientes"."COD_CLI", "Clientes"."CLIENTE", "Cidades"."CIDADE", count("ID") from "Pedidos" left join "Bipagem" on "PEDIDO" = "NUMPED" left join "Clientes" on "Clientes"."COD_CLI" = "Pedidos"."ID_CLI" left join "Cidades" on "COD_CIDADE" = "Cidades"."CODCIDADE" where "NUMPED" = ${element[1]} and "PALETE" = $palete group by "VOLUME_TOTAL", "Clientes"."COD_CLI","Clientes"."CLIENTE", "Cidades"."CIDADE";');
            for (var element2 in volumeResponse) {
              if (element2[0] != null) {
                teste.add(Contagem(element[1] as int?, element[5] as int?,
                    element[4] as int?, (int.parse('${element2[0]}')),
                    volBip: int.parse('${element2[4]}'),
                    cliente: '${element2[1]} - ${element2[2]}' as String?,
                    cidade: element2[3] as String?));
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
      }}
    return teste;
  }

  ///Buscar Bipagem pelo número do Pedido
  Future<List<Contagem>> selectPedido(int cod) async {
    var teste = <Contagem>[];
    late final Result pedidos;
    late Result volumeResponse;
    try {
      pedidos = await conn.execute(
          'Select "ID", "PEDIDO", "DATA_BIPAGEM", "COD_BARRA", "VOLUME_CAIXA", "PALETE", "ID_USER_BIPAGEM" from "Bipagem" where "PEDIDO" = $cod order by "VOLUME_CAIXA";');
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
  Future<List<Contagem>> updatePedidoBip(List<Contagem> pedidos, cod) async {
    for (var element in pedidos) {
      await conn.execute(
          'update "Bipagem" set "PALETE" = ${element.palete} where "PEDIDO" = ${element.ped} and "VOLUME_CAIXA" = ${element.caixa};');
    }
    var teste = <Contagem>[];
    late final Result pedidos2;
    late Result volumeResponse;

    try {
      pedidos2 = await conn.execute(
          'Select "ID", "PEDIDO", "DATA_BIPAGEM", "COD_BARRA", "VOLUME_CAIXA", "PALETE", "ID_USER_BIPAGEM" from "Bipagem" where "PEDIDO" = $cod order by "VOLUME_CAIXA";');
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

  ///Função para excluir a caixa
  Future<List<Contagem>> excluiPedido(List<Contagem> pedidos, Usuario usur, int cod) async {
    late Result pedidosResponse;

    for (var element in pedidos) {
      try {
        pedidosResponse = await conn.execute(
            'Select "ID", "PEDIDO", "DATA_BIPAGEM", "COD_BARRA", "VOLUME_CAIXA", "PALETE", "ID_USER_BIPAGEM" from "Bipagem" where "PEDIDO" = ${element.ped} and "VOLUME_CAIXA" = ${element.caixa} order by "VOLUME_CAIXA";');

        await conn.execute(
            'delete from "Bipagem" where "PEDIDO" = ${element.ped} and "VOLUME_CAIXA" = ${element.caixa};');
        for (var element2 in pedidosResponse) {
          await conn.execute(
              "insert into \"Bipagem_Excluida\" values (${element2[0]},${element2[1]},to_timestamp('${element2[2]}','YYYY-MM-DD HH24:MI:SS'),${element2[3]},${element2[4]},${element2[5]},${element2[6]},current_timestamp,${usur.id});");
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
          'Select "ID", "PEDIDO", "DATA_BIPAGEM", "COD_BARRA", "VOLUME_CAIXA", "PALETE", "ID_USER_BIPAGEM" from "Bipagem" where "PEDIDO" = $cod order by "VOLUME_CAIXA";');
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
  Future<List<int>> updatePalete(int romaneio, List<int> paletes) async {
    print(paletes);
    await conn.execute(
        'update "Palete" set "ID_ROMANEIO" = $romaneio where "ID" in (${paletes.join(',')});');

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
    if (await pedidos.isNotEmpty) {
      for (var element in pedidos) {
        teste.add(element[0] as int);
      }
    }
    return teste;
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
    if (await pedidos.isNotEmpty) {
      for (var element in pedidos) {
        teste.add(element[0] as int);
      }
    }
    return teste;
  }

  ///Função para verificar login do Banco
  void auth(String login, String senha, BuildContext a, Banco bd) async {
    Usuario? usur;
    late final Result pedidos;
    try {
      pedidos = await conn.execute(
          "select \"ID\", \"SETOR\", \"NOME\" from \"Usuarios\" where upper(\"APELIDO\") like upper('$login') and \"SENHA\" like '$senha';");
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      if (element[0] != null) {
        usur = Usuario(element[0] as int, element[1] as String, element[2] as String);
      }
    }
    if (usur?.acess != null) {
      if (a.mounted) {
        Navigator.pop(a);
        await Navigator.push(
            a,
            MaterialPageRoute(
              builder: (context) => HomeWidget(usur!, bd: bd),
            ));
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

  ///Busca pedidos do Banco por Roameneio
  Future<List<Pedido>> selectPedidosRomaneio(List<int> cods) async {
    var teste = <Pedido>[];
    if (cods.isNotEmpty) {
      late Result volumeResponse;
      volumeResponse = await conn.execute(
          'select "Pedidos"."NUMPED", "VOLUME_TOTAL", "COD_CLI", "CLIENTE", "VLTOTAL", "NF", "Cidades"."CIDADE", "IDROMANEIO", "DATA_FATURAMENTO", "DATA_PEDIDO", COALESCE(string_agg(distinct cast("Palete"."ID" as varchar) , \', \' ),\'0\') from "Pedidos" left join "Bipagem" on "Bipagem"."PEDIDO" = "Pedidos"."NUMPED" left join "Palete" on "Bipagem"."PALETE" = "Palete"."ID" left join "Clientes" on "COD_CLI" = "ID_CLI" left join "Cidades" on "CODCIDADE" = "COD_CIDADE" where "IDROMANEIO" in (${cods
              .join(
              ',')}) group by "Pedidos"."NUMPED", "VOLUME_TOTAL", "COD_CLI", "CLIENTE", "VLTOTAL", "NF", "Cidades"."CIDADE", "IDROMANEIO", "DATA_FATURAMENTO", "DATA_PEDIDO";');
      for (var element in volumeResponse) {
        if (element.isNotEmpty) {
          teste.add(Pedido(
            element[0]! as int,
            element[10] as String,
            0,
            element[1]! as int, 'Correto',
            codCli: element[2]! as int,
            cliente: element[3]!.toString(),
            valor: element[4]! as double,
            nota: element[5] as int,
            cidade: element[6].toString(),
            romaneio: element[7] as int?,
            dtFat: element[8] as DateTime?,
            dtPedido: element[9] as DateTime?,));
        }
      }
    }
    return teste;
  }

  ///Busca as declarações na tabela de Pedidos
  Future<List<Pedido>> allDeclaracoes(dtIni, dtFim) async {
    var teste = <Pedido>[];
    late Result volumeResponse;
    volumeResponse = await conn.execute(
        'select "Pedidos"."NUMPED", "VOLUME_TOTAL", "COD_CLI", "CLIENTE", "VLTOTAL", "NF", "Cidades"."CIDADE", "IDROMANEIO", "DATA_FATURAMENTO", "DATA_PEDIDO", COALESCE(string_agg(distinct cast("Palete"."ID" as varchar) , \', \' ),\'0\') from "Pedidos" left join "Bipagem" on "Bipagem"."PEDIDO" = "Pedidos"."NUMPED" left join "Palete" on "Bipagem"."PALETE" = "Palete"."ID" left join "Clientes" on "COD_CLI" = "ID_CLI" left join "Cidades" on "CODCIDADE" = "COD_CIDADE" where "Pedidos"."TIPO" like \'D\' and "DATA_PEDIDO" between \'$dtIni\' and \'$dtFim\' group by "Pedidos"."NUMPED", "VOLUME_TOTAL", "COD_CLI", "CLIENTE", "VLTOTAL", "NF", "Cidades"."CIDADE", "IDROMANEIO", "DATA_FATURAMENTO", "DATA_PEDIDO";');
    for (var element in volumeResponse) {
      if (element.isNotEmpty) {
        teste.add(Pedido(
          element[0]! as int,
          element[10] as String,
          0,
          element[1]! as int, 'Correto',
          codCli: element[2]! as int,
          cliente: element[3]!.toString(),
          valor: element[4]! as double,
          nota: element[5] as int,
          cidade: element[6].toString(),
          romaneio: element[7] as int?,
          dtFat: element[8] as DateTime?,
          dtPedido: element[9] as DateTime?,));
      }
    }
    return teste;
  }

  ///Busca pedidos não bipados que foram faturados
  Future<List<Pedido>> faturadosNBipados(
      DateTime dtIni, DateTime? dtFim) async {
    var teste = <Pedido>[];
    late Result volumeResponse;

    volumeResponse = await conn.execute(
        'select "Pedidos"."NUMPED", "VOLUME_TOTAL", "COD_CLI", "CLIENTE", "VLTOTAL", "NF", "Cidades"."CIDADE", "IGNORAR" from "Pedidos" left join "Bipagem" on "Bipagem"."PEDIDO" = "Pedidos"."NUMPED" left join "Clientes" on "COD_CLI" = "ID_CLI" left join "Cidades" on "CODCIDADE" = "COD_CIDADE" where "Bipagem"."PEDIDO" is null and "STATUS" like \'F\' and "VOLUME_TOTAL" <> 0 and "DATA_FATURAMENTO" between \'$dtIni\' and \'$dtFim\';');
    for (var element in volumeResponse) {
      if (element.isNotEmpty) {
        teste.add(Pedido(
            element[0]! as int, '0', 0, element[1]! as int, 'Incorreto',
            codCli: element[2]! as int,
            cliente: element[3]!.toString(),
            valor: element[4]! as double,
            nota: element[5] as int,
            cidade: element[6].toString(),
            ignorar: element[7] as bool?
        ));
      }
    }

    return teste;
  }

  ///Função para buscar pedidos que já foram Bipados e forma cancelados após isso.
  Future<List<Pedido>> canceladosBipados() async {
    var teste = <Pedido>[];
    late Result volumeResponse;

    volumeResponse = await conn.execute(
        'select "Pedidos"."NUMPED", "VOLUME_TOTAL", "COD_CLI", "CLIENTE", count("Bipagem"."ID"), "NF", "Cidades"."CIDADE" from "Pedidos" left join "Bipagem" on "Bipagem"."PEDIDO" = "Pedidos"."NUMPED" left join "Clientes" on "COD_CLI" = "ID_CLI" left join "Cidades" on "CODCIDADE" = "COD_CIDADE" where "Bipagem"."PEDIDO" is not null and ("DATA_CANC_PED" IS NOT NULL OR "DATA_CANC_NF" IS NOT NULL) group by "Pedidos"."NUMPED", "VOLUME_TOTAL", "COD_CLI", "CLIENTE", "NF", "Cidades"."CIDADE";');
    for (var element in volumeResponse) {
      try{
        if (element.isNotEmpty) {
          teste.add(Pedido(
              element[0]! as int, '0', element[4] as int, element[1]! as int, 'Incorreto',
              codCli: element[2]! as int,
              cliente: element[3]!.toString(),
              nota: element[5] as int,
              cidade: element[6].toString()));
        }
      }catch(e){
        print(e);
      }
    }

    return teste;
  }

  Future<List<Paletes>> paletesFull() async{
    var teste = <Paletes>[];
    late Result volumeResponse;

    volumeResponse = await conn.execute(
        'select "Palete"."ID", "ID_ROMANEIO",Cri."NOME", "DATA_INCLUSAO",Fech."NOME", "DATA_FECHAMENTO",Car."NOME", "DATA_CARREGAMENTO", count("Bipagem"."ID") from "Palete" left join "Usuarios" Cri on Cri."ID" = "ID_USUR_CRIACAO" left join "Usuarios" Fech on Fech."ID" = "ID_USUR_FECHAMENTO" left join "Usuarios" Car on Car."ID" = "ID_USUR_CARREGAMENTO" left join "Bipagem" on "PALETE" = "Palete"."ID" where "DATA_CARREGAMENTO" is null group by "Palete"."ID", "ID_ROMANEIO",Cri."NOME", "DATA_INCLUSAO",Fech."NOME", "DATA_FECHAMENTO",Car."NOME", "DATA_CARREGAMENTO"');
    for (var element in volumeResponse) {
      teste.add(Paletes(element[0] as int?, element[2] as String?,
          (element[3] as DateTime).toLocal(), element[8] as int?,
          romaneio: element[1] as int?,
          UsurFechamento: element[4] as String?,
          dtFechamento: element[5] != null ? (
              element[5] as DateTime).toLocal() : null,
          UsurCarregamento: element[6] as String?,
          dtCarregamento: element[7] != null ? (
              element[7] as DateTime).toLocal() : null));
    }
    return teste;
  }

  Future<int?> selectAllPedidos(int cod) async {
    late Result volumeResponse;

    try {
      volumeResponse = await conn.execute(
          'select count(*) from "Pedidos" where "NUMPED" = $cod;');
    }
    catch(e){
      print(e);
    }
    late int? teste;

    for (var element in volumeResponse){
      teste = element[0] as int?;
    }

    if (teste == 0 ){
      return 2;
    }else{
      volumeResponse = await conn.execute(
          'select count("STATUS") from "Pedidos" where "NUMPED" = $cod and "STATUS" = \'C\';');
      for (var element in volumeResponse){
        teste = element[0] as int?;
      }
      if (teste != 0){
        return 1;
      }else{
        return 0;
      }
    }

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
            (element[2] ?? 0) as int,
            element[1] != ''
                ? DateTime.parse('${element[1]}').toLocal()
                : null, null , null, null));
      }
    }

    return teste;
  }

  Future<int> qtdFat() async {
    int teste = 0;
    late Result volumeResponse;

    try {
      volumeResponse = await conn.execute(
          'select count(*) from "Pedidos" left join "Bipagem" on "Bipagem"."PEDIDO" = "Pedidos"."NUMPED" left join "Clientes" on "COD_CLI" = "ID_CLI" left join "Cidades" on "CODCIDADE" = "COD_CIDADE" where "Bipagem"."PEDIDO" is null and "STATUS" like \'F\' and "VOLUME_TOTAL" <> 0 and "IGNORAR" = false;');
    } catch(e){
      print(e);
    }
    for (var element in volumeResponse) {
      if (element.isNotEmpty) {
        teste = (element[0] ?? 0) as int;
      }
    }

    return teste;
  }

  Future<int> qtdCanc() async {
    int teste = 0;
    late Result volumeResponse;

    volumeResponse = await conn.execute(
        'select count(*) from "Pedidos" left join "Bipagem" on "Bipagem"."PEDIDO" = "Pedidos"."NUMPED" left join "Clientes" on "COD_CLI" = "ID_CLI" left join "Cidades" on "CODCIDADE" = "COD_CIDADE" where "Bipagem"."PEDIDO" is not null and ("DATA_CANC_PED" IS NOT NULL OR "DATA_CANC_NF" IS NOT NULL) and "IGNORAR" = false group by "Pedidos"."NUMPED", "VOLUME_TOTAL", "COD_CLI", "CLIENTE", "NF", "Cidades"."CIDADE";');
    for (var element in volumeResponse) {
      try{
        if (element.isNotEmpty) {
          teste = (element[0] ?? 0) as int;
        }
      }catch(e){
        print(e);
      }
    }

    return teste;
  }

  void updateIgnorar(int ped, bool? value) {
    conn.execute('update multiexpedicao."Pedidos" set "IGNORAR" = $value where "NUMPED" = $ped;');
  }

  ///Seleciona o número da última declaração criada
  Future<int> ultDec() async {
    var teste = 0;
    late final Result pedidos;

    try {
      pedidos =
      await conn.execute('select COALESCE(MAX("NUMPED"),0) from "Pedidos" where "TIPO" = \'D\';');
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

  Future<Cliente> selectCliente(int cod) async {
    late var cli = Cliente(0, 0, '', '', '', '');
    late Result volumeResponse;
    volumeResponse = await conn.execute('select "CLIENTE", "CNPJ", concat("CIDADE",\',\',"UF"), "BAIRRO", "CEP", "ENDERECO", "TELEFONE_COMERCIAL" from "Clientes" left join "Cidades" ON "CODCIDADE" = "COD_CIDADE" where "COD_CLI" = $cod');

    if (cod != 0) {
      for (var element in volumeResponse) {
        cli = Cliente(
            cod, 0, element[0] as String?, '', element[1] as String?, '',
            cidade: element[2] as String?, bairro: element[3] as String?, cep: '${element[4]}' as String?, endereco: element[5] as String?, telefone_celular: element[6] as String?);
      }

    }

    return cli;

  }

  Future<List<Pedido>> createDeclaracao(Declaracao dec, DateTime dtIni, DateTime dtFim) async {
    await conn.execute('INSERT INTO "Pedidos"("NUMPED", "VOLUME_TOTAL", "DATA_FATURAMENTO", "VLTOTAL", "ID_CLI", "STATUS", "NF", "COND_VENDA", "DATA_PEDIDO", "VOLUME_NF", "DATA_FIM_CHECKOUT", "TIPO", "MOTIVO")VALUES(\'${dec.ped}\',\'${dec.vol}\',current_timestamp, \'${dec.valor}\',\'${dec.codCli}\',\'F\',\'${dec.ped}\',1,current_timestamp, \'${dec.vol}\', current_timestamp, \'D\', \'${dec.motivo}\');');

    var teste = <Pedido>[];
    late Result volumeResponse;
    volumeResponse = await conn.execute(
        'select "Pedidos"."NUMPED", "VOLUME_TOTAL", "COD_CLI", "CLIENTE", "VLTOTAL", "NF", "Cidades"."CIDADE", "IDROMANEIO", "DATA_FATURAMENTO", "DATA_PEDIDO", COALESCE(string_agg(distinct cast("Palete"."ID" as varchar) , \', \' ),\'0\') from "Pedidos" left join "Bipagem" on "Bipagem"."PEDIDO" = "Pedidos"."NUMPED" left join "Palete" on "Bipagem"."PALETE" = "Palete"."ID" left join "Clientes" on "COD_CLI" = "ID_CLI" left join "Cidades" on "CODCIDADE" = "COD_CIDADE" where "Pedidos"."TIPO" like \'D\' and "DATA_PEDIDO" between \'$dtIni\' and \'$dtFim\' group by "Pedidos"."NUMPED", "VOLUME_TOTAL", "COD_CLI", "CLIENTE", "VLTOTAL", "NF", "Cidades"."CIDADE", "IDROMANEIO", "DATA_FATURAMENTO", "DATA_PEDIDO";');
    for (var element in volumeResponse) {
      if (element.isNotEmpty) {
        teste.add(Pedido(
          element[0]! as int,
          element[10] as String,
          0,
          element[1]! as int, 'Correto',
          codCli: element[2]! as int,
          cliente: element[3]!.toString(),
          valor: element[4]! as double,
          nota: element[5] as int,
          cidade: element[6].toString(),
          romaneio: element[7] as int?,
          dtFat: element[8] as DateTime?,
          dtPedido: element[9] as DateTime?,));
      }
    }

    return teste;
  }


}
