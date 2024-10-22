import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/carregamento.dart';
import '../Models/cidade.dart';
import '../Models/cliente.dart';
import '../Models/contagem.dart';
import '../Models/declaracao.dart';
import '../Models/palete.dart';
import '../Models/pedido.dart';
import '../Models/romaneio.dart';
import '../Models/transportadora.dart';
import '../Models/usur.dart';
import '../Views/conferencia_widget.dart';

///Classe para manter funções do Banco
class Banco {
  ///Variável para guardar a conexão com o Banco
  late Connection conn;

  ///Guardar uma conexão com a API
  http.Client cliente = http.Client();

  ///Guardar o header padrão que tem que ser inserido juntamente com uma requisição
  var headerDefault = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS,DELETE,PUT',
    'Content-Type': 'application/json',
    'Accept': '*/*'
  };

  ///Variável para guardar o link da API de Pedidos
  Uri pedidosAPI = Uri.http('127.0.0.1:5000', '/Pedidos');

  ///Variável para guardar o link da API de Usuarios
  Uri usuariosAPI = Uri.http('127.0.0.1:5000', '/Usuarios');

  ///Variável para guardar o link da API de Clientes
  Uri clientesAPI = Uri.http('127.0.0.1:5000', '/Clientes');

  ///Variável para guardar o link da API de Transportadoras
  Uri transportadoraAPI = Uri.http('127.0.0.1:5000', '/Transportadoras');

  ///Variável para guardar o link da API de Romaneios
  Uri romaneioAPI = Uri.http('127.0.0.1:5000', '/Romaneios');

  ///Variável para guardar o link da API de Cidades
  Uri cidadesAPI = Uri.http('127.0.0.1:5000', '/Cidades');

  ///Variável para guardar o link da API de Paletes
  Uri paletesAPI = Uri.http('127.0.0.1:5000', '/Paletes');

  ///Variável para guardar o link da API de Bipagens
  Uri bipagensAPI = Uri.http('127.0.0.1:5000', '/Bipagens');

  ///Variáveis para manter dados de conexão do Banco
  late String host, database, username, password;

  ///Construtor do Banco
  Banco(context) {
    init(context);
  }

  // ----------------------- Conexão de Banco ----------------------------------

  void init(BuildContext context) async {
    if (kIsWeb == true) {
      print('Web Daora');
    } else {
      if (kDebugMode) {
        host = '192.168.17.104';
        database = 'postgres';
        username = 'postgres';
        password = 'Multi@bd7';
      } else {
        host = '192.168.17.104';
        database = 'multiexpedicao';
        username = 'multi';
        password = '@#Multi4785';
      }

      try {
        conn = await Connection.open(
            Endpoint(
              host: host,
              database: database,
              username: username,
              password: password,
              port: 5432,
            ),
            settings: ConnectionSettings(
                sslMode: SslMode.disable,
                onOpen: (connection) =>
                    connection.execute('SET search_path TO public')));
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
  }

  Future<int> connected(BuildContext context) async {
    if (kIsWeb == true) {
      return 1;
    } else {
      try {
        if (conn.isOpen) {
          return 1;
        } else {
          conn = await Connection.open(
              Endpoint(
                host: host,
                database: database,
                username: username,
                password: password,
                port: 5432,
              ),
              settings: ConnectionSettings(
                sslMode: SslMode.disable,
                onOpen: (connection) =>
                    connection.execute('SET search_path TO public'),
              ));
          if (conn.isOpen) {
            return 1;
          } else {
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
      } on SocketException {
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
      } catch (e) {
        try {
          conn = await Connection.open(
              Endpoint(
                host: host,
                database: database,
                username: username,
                password: password,
                port: 5432,
              ),
              settings: ConnectionSettings(
                sslMode: SslMode.disable,
                onOpen: (connection) =>
                    connection.execute('SET search_path TO public'),
              ));

          return 1;
        } catch (e) {
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
          return 0;
        }
      }
    }
  }

  Future<String> conexao() async {
    if (kIsWeb == true) {
      return 'WEB';
    } else {
      late final Result pedidos;
    pedidos = await conn.execute(
        'SELECT datname FROM pg_stat_activity WHERE pid = pg_backend_pid();');
    for (var i in pedidos) {
      if (i[0] == 'postgres') {
          return 'Homolog';
        } else {
          return 'Produção';
        }
      }
      return '';
    }
  }

  // ------------------------ Login --------------------------------------------

  void auth(String login, String senha, BuildContext context, Banco bd) async {
    Usuario? usur;
    late final http.Response volumeResponse;
    var prefs = await SharedPreferences.getInstance();

    volumeResponse = await cliente.get(Uri.http('127.0.0.1:5000', '/Login', {
      'login': login,
      'senha': senha,
        }),
        headers: headerDefault);

    var lista = jsonDecode(utf8.decode(volumeResponse.bodyBytes)) as List;

    for (var element in lista) {
      if (element != null) {
        usur = Usuario(element['ID'] as int, element['SETOR'] as String,
            element['NOME'] as String);

        await prefs.setString('Usuario', element['NOME'] as String);
        await prefs.setString('Permissão', element['SETOR'] as String);
        await prefs.setInt('ID_Usur', element['ID'] as int);
      }
    }
    if (usur?.acess != null) {
      if (context.mounted) {
        await Navigator.popAndPushNamed(context, '/Home', arguments: bd);
      }
    } else {
      if (context.mounted) {
        await showCupertinoModalPopup(
          context: context,
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

  //// ------------------------ Funções da Bipagem -----------------------------

  // 1 - Create

  Future<List<Contagem>> insert(String cod, int pallet, BuildContext context,
      Usuario usur) async {
    if (cod.length != 33) {
      if (context.mounted) {
        await showCupertinoModalPopup(
          context: context,
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
      var cx = codArrumado.substring(13, 16);

      print(cx);

      try {
        await conn.execute(
            'insert into bipagem(PEDIDO,PALETE,DATA_BIPAGEM,VOLUME_CAIXA,COD_BARRA,ID_USER_BIPAGEM) values ($ped, $pallet,current_timestamp,$cx,$codArrumado,${usur.id});');
      } on Exception {
        if (context.mounted) {
          await showCupertinoModalPopup(
            context: context,
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
          'Select ID, PEDIDO, DATA_BIPAGEM, COD_BARRA, VOLUME_CAIXA, PALETE, ID_USER_BIPAGEM from bipagem where PALETE = $pallet order by ID desc;');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    try {
      for (var element in pedidos) {
        try {
          volumeResponse = await conn.execute(
              'select VOLUME_TOTAL, count(ID) from pedidos left join bipagem on bipagem.PEDIDO = pedidos.pedido where pedidos.pedido = ${element[1]} and PALETE = $pallet group by VOLUME_TOTAL;');
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

  // 2 - Read

  Future<List<Pedido>> selectPalletromaneio(
      Future<List<int>> listapaletes) async {
    var paletes = await listapaletes;
    var teste = <Pedido>[];
    late final Result pedidos;
    var status = 'Correto';

    if ((await listapaletes).isNotEmpty) {
      try {
        if (paletes.isNotEmpty) {
          pedidos = await conn.execute('''
                                      SELECT
                                        P.pedido,
                                        COALESCE(string_agg(DISTINCT CAST(B.PALETE AS varchar) , ',' ), '0') AS PALETES,
                                        COALESCE(count(B.PEDIDO), 0) AS CAIXAS,
                                        P.VOLUME_TOTAL,
                                        C.CNPJ,
                                        C.CLIENTE,
                                        CID.CIDADE,
                                        P.NF,
                                        P.VLTOTAL,
                                        C.cod_cli,
                                        P.STATUS
                                      FROM
                                        pedidos AS P
                                      LEFT JOIN bipagem AS B ON
                                        P.pedido = B.PEDIDO
                                      LEFT JOIN clientes AS C ON
                                        C.cod_cli = P.cod_cli
                                      LEFT JOIN cidades AS CID ON
                                        CID.COD_CIDADE = C.COD_CIDADE
                                      WHERE
                                        B.PEDIDO IN (
                                        SELECT
                                          PEDIDO
                                        FROM
                                          bipagem
                                        WHERE
                                          PALETE IN (${paletes.join(',')}))
                                      GROUP BY
                                        P.pedido,
                                        C.CNPJ,
                                        C.CLIENTE,
                                        CID.CIDADE,
                                        P.NF,
                                        P.VLTOTAL,
                                        C.cod_cli,
                                        P.STATUS;''');
        }
      } on Exception catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
      var teste3 = <int>[];
      for (var element in pedidos) {
        try {
          teste3 = (element[1]).toString().split(',').map(int.parse).toList();
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
        if ((element[2] as int) < (element[3] as int) ||
            element[3] == 0 ||
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
              situacao: element[10] as String?,
              codTrans: 417));
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }
    }

    return teste;
  }

  Future<List<Contagem>> selectPedido(int cod) async {
    var teste = <Contagem>[];
    var bipLista = [];
    late final http.Response bipResponse;
    late final Result volumeResponse;
    try {
      bipResponse = await cliente.get(
        Uri.http('127.0.0.1:5000', '/Bipagens', {'Pedido': cod}),
        headers: headerDefault,
      );

      bipLista = jsonDecode(utf8.decode(bipResponse.bodyBytes)) as List;

      // bipResponse = await conn.execute(
      //     'Select ID, PEDIDO, DATA_BIPAGEM, COD_BARRA, VOLUME_CAIXA, PALETE, ID_USER_BIPAGEM from bipagem where PEDIDO = $cod order by VOLUME_CAIXA;');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in bipLista) {
      try {
        volumeResponse = (await conn.execute(
            'select VOLUME_TOTAL, VLTOTAL, CLIENTE, cidades.CIDADE, STATUS from pedidos left join clientes on clientes.cod_cli = pedidos.cod_cli LEFT JOIN cidades on clientes.COD_CIDADE = cidades.COD_CIDADE where pedidos.pedido = ${element['Pedido']};'));

        for (var element2 in volumeResponse) {
          if (element2[0] != null) {
            teste.add(Contagem(element[1] as int?, element[5] as int?,
                element[4] as int?, (int.parse('${element2[0]}')),
                cliente: '${element2[2]}',
                cidade: '${element2[3]}',
                status: switch (element2[4] ?? 'D') {
                  'F' => 'Faturado',
                  'C' => 'Cancelado',
                  'L' => 'Liberado',
                  'B' => 'Bloqueado',
                  'D' => 'Desconhecido',
                  'M' => 'Montado',
                  Object() => 'Diversos',
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

  // 3 - Update

  Future<List<Contagem>> updatePedidoBip(
      List<Contagem> pedidos, int cod) async {
    for (var element in pedidos) {
      await conn.execute(
          'update bipagem set PALETE = ${element.palete} where PEDIDO = ${element.ped} and VOLUME_CAIXA = ${element.caixa};');
    }
    var teste = <Contagem>[];
    late final Result pedidos2;
    late Result volumeResponse;

    try {
      pedidos2 = await conn.execute(
          'Select ID, PEDIDO, DATA_BIPAGEM, COD_BARRA, VOLUME_CAIXA, PALETE, ID_USER_BIPAGEM from bipagem where PEDIDO = $cod order by VOLUME_CAIXA;');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos2) {
      try {
        volumeResponse = (await conn.execute(
            'select VOLUME_TOTAL, VLTOTAL, CLIENTE, cidades.CIDADE, STATUS from pedidos left join clientes on clientes.cod_cli = pedidos.cod_cli LEFT JOIN cidades on clientes.COD_CIDADE = cidades.COD_CIDADE where pedidos.pedido = ${element[1]};'));
        for (var element2 in volumeResponse) {
          if (element2[0] != null) {
            teste.add(Contagem(element[1] as int?, element[5] as int?,
                element[4] as int?, (int.parse('${element2[0]}')),
                cliente: '${element2[2]}',
                cidade: '${element2[3]}',
                status: switch (element2[4] ?? 'D') {
                  'F' => 'Faturado',
                  'C' => 'Cancelado',
                  'L' => 'Liberado',
                  'B' => 'Bloqueado',
                  'D' => 'Desconhecido',
                  'M' => 'Montado',
                  Object() => 'Diversos',
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

  // 4 - Delete

  Future<List<Contagem>> excluiPedido(
      List<Contagem> pedidos, Usuario usur, int cod) async {
    late Result pedidosResponse;

    for (var element in pedidos) {
      try {
        pedidosResponse = await conn.execute(
            'Select ID, PEDIDO, DATA_BIPAGEM, COD_BARRA, VOLUME_CAIXA, PALETE, ID_USER_BIPAGEM from bipagem where PEDIDO = ${element.ped} and VOLUME_CAIXA = ${element.caixa} order by VOLUME_CAIXA;');

        await conn.execute(
            'delete from bipagem where PEDIDO = ${element.ped} and VOLUME_CAIXA = ${element.caixa};');
        for (var element2 in pedidosResponse) {
          await conn.execute(
              "insert into bipagem_excluida values (${element2[0]},${element2[1]},to_timestamp('${element2[2]}','YYYY-MM-DD HH24:MI:SS'),${element2[3]},${element2[4]},${element2[5]},${element2[6]},current_timestamp,${usur.id});");
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
          'Select ID, PEDIDO, DATA_BIPAGEM, COD_BARRA, VOLUME_CAIXA, PALETE, ID_USER_BIPAGEM from bipagem where PEDIDO = $cod order by VOLUME_CAIXA;');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos2) {
      try {
        volumeResponse = (await conn.execute(
            'select VOLUME_TOTAL, VLTOTAL, CLIENTE, cidades.CIDADE, STATUS from pedidos left join clientes on clientes.cod_cli = pedidos.cod_cli LEFT JOIN cidades on clientes.COD_CIDADE = cidades.COD_CIDADE where pedidos. = ${element[1]};'));
        for (var element2 in volumeResponse) {
          if (element2[0] != null) {
            teste.add(Contagem(element[1] as int?, element[5] as int?,
                element[4] as int?, (int.parse('${element2[0]}')),
                cliente: '${element2[2]}',
                cidade: '${element2[3]}',
                status: switch (element2[4] ?? 'D') {
                  'F' => 'Faturado',
                  'C' => 'Cancelado',
                  'L' => 'Liberado',
                  'B' => 'Bloqueado',
                  'D' => 'Desconhecido',
                  'M' => 'Montado',
                  Object() => 'Diversos',
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

  // ------------------------ Funções do Palete --------------------------------

  // 1 - Create

  void createpalete(Usuario usur) async {
    await conn.execute(
        'insert into palete (DATA_INCLUSAO,ID_USUR_CRIACAO) values (current_timestamp,${usur.id});');
  }

  // 2 - Read

  ///Busca o número do último palete criado e retorna o número + 1
  Future<int> novoPalete() async {
    var ultPalete = 0;
    late final http.Response resposta;

    try {
      resposta = await cliente.get(paletesAPI, headers: headerDefault);

      var listaResposta = jsonDecode(utf8.decode(resposta.bodyBytes)) as List;

      ultPalete = listaResposta[listaResposta.length - 1]['ID'];

    } catch (e) {
      print(e);
    }

    return ultPalete + 1;
  }

  ///Função para o verificar a existência e situação do Palete
  void conferirPalete(
      int palete, BuildContext context, Usuario usur, Banco bd) async {
    Object? teste2 = DateTime.timestamp();
    var teste = 0;
    late List pedidos;
    late final http.Response pedidosResponse;

    try {
      pedidosResponse = await cliente.get(paletesAPI, headers: headerDefault);

      pedidos = jsonDecode(utf8.decode(pedidosResponse.bodyBytes)) as List;

      // pedidos = await conn
      //     .execute('select ID,DATA_FECHAMENTO from palete where ID = $palete;');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      teste = (element['ID'] ?? 0) as int;
      teste2 = element['Data Fechamento'];
    }
    if (context.mounted) {
      if (teste == 0) {
        await showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text('palete não encontrado'),
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
            context: context);
        return;
      }
      if (context.mounted) {
        Navigator.pop(context);
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ListaRomaneioConfWidget(palete: teste, usur, bd: bd)));
      }
    }
  }

  Future<List<Paletes>> paleteFinalizado() async {
    var teste = <Paletes>[];
    late final Result pedidos;

    try {
      pedidos = await conn.execute(
          'select palete.ID,Bip.NOME,DATA_INCLUSAO,count(bipagem.PEDIDO),Fech.NOME,palete.DATA_FECHAMENTO from palete left join romaneio on ID_ROMANEIO = romaneio.ID left join bipagem on PALETE = palete.ID left join usuarios as Bip on Bip.ID = ID_USUR_CRIACAO left join usuarios as Fech on Fech.ID = ID_USUR_FECHAMENTO where palete.DATA_FECHAMENTO is not null and romaneio.DATA_FECHAMENTO is null group by palete.ID, Bip.NOME, DATA_INCLUSAO, Fech.NOME, palete.DATA_FECHAMENTO order by ID;');
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
            usurFechamento: element[4] as String?,
            dtFechamento: element[5] != '' && element[5] != null
                ? DateTime.parse('${element[5]}').toLocal()
                : null));
      }
    }

    return teste;
  }

  Future<List<Paletes>> paleteAll(int palete, BuildContext context) async {
    var teste = <Paletes>[];
    late final http.Response romResponse,
        usuFechResponse,
        usuCarrResponse,
        bipResponse,
        paleteResponse,
        usuCriacaoResponse;
    var bipList = [],
        romList = [],
        paleteList = [],
        usuCriacaoList = [],
        usuFechList = [],
        usuCarrList = [];

    try {
      paleteResponse = await cliente.get(
          Uri.http('127.0.0.1:5000', '/Paletes', {'palete': palete}),
          headers: headerDefault);

      paleteList = jsonDecode(utf8.decode(paleteResponse.bodyBytes)) as List;

      romResponse = await cliente.get(
          Uri.http(
              '127.0.0.1:5000', '/Romaneios', paleteList[0]['ID Romaneio']),
          headers: headerDefault);

      romList = jsonDecode(utf8.decode(romResponse.bodyBytes)) as List;

      bipResponse = await cliente.get(
          Uri.http('127.0.0.1:5000', '/Bipagens', {'palete': palete}),
          headers: headerDefault);

      bipList = jsonDecode(utf8.decode(bipResponse.bodyBytes)) as List;

      usuCriacaoResponse = await cliente.get(
          Uri.http('127.0.0.1:5000', '/Usuarios',
              {'id': paleteList[0]['ID Usur Criacao']}),
          headers: headerDefault);

      usuCriacaoList =
          jsonDecode(utf8.decode(usuCriacaoResponse.bodyBytes)) as List;

      usuFechResponse = await cliente.get(
          Uri.http('127.0.0.1:5000', '/Usuarios',
              {'id': paleteList[0]['ID Usur Fechamento']}),
          headers: headerDefault);

      usuFechList = jsonDecode(utf8.decode(usuFechResponse.bodyBytes)) as List;

      usuCarrResponse = await cliente.get(
          Uri.http('127.0.0.1:5000', '/Usuarios',
              {'id': paleteList[0]['ID Usur Carregamento']}),
          headers: headerDefault);

      usuCarrList = jsonDecode(utf8.decode(usuCarrResponse.bodyBytes)) as List;

      // pedidos = await conn.execute(
      //     'select palete.ID,Bip.NOME,DATA_INCLUSAO,count(bipagem.PEDIDO),Fech.NOME,palete.DATA_FECHAMENTO, Car.NOME,palete.DATA_CARREGAMENTO  from palete left join romaneio on ID_ROMANEIO = romaneio.ID left join bipagem on PALETE = palete.ID left join usuarios Bip on Bip.ID = ID_USUR_CRIACAO left join usuarios Fech on Fech.ID = ID_USUR_FECHAMENTO LEFT JOIN usuarios Car on Car.ID = ID_USUR_CARREGAMENTO where palete.ID = $palete group by palete.ID, Bip.NOME, DATA_INCLUSAO, Fech.NOME, palete.DATA_FECHAMENTO, Car.NOME,palete.DATA_CARREGAMENTO order by ID;');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    if (paleteList[0]['Data Fechamento'] == null) {
      teste.add(Paletes(
          paleteList[0]['ID'] as int?,
          usuCriacaoList[0]['NOME'] as String?,
          paleteList[0]['Data Inclus\u00e3o'] != '' &&
                  paleteList[0]['Data Inclus\u00e3o'] != null
              ? DateTime.parse('${paleteList[0]['Data Inclus\u00e3o']}')
                  .toLocal()
              : null,
          bipList.length as int?));
    } else {
      if (paleteList[0]['Data Carregamento'] == null) {
        teste.add(Paletes(
            paleteList[0]['ID'] as int?,
            usuCriacaoList[0]['NOME'] as String?,
            paleteList[0]['Data Inclus\u00e3o'] != '' &&
                    paleteList[0]['Data Inclus\u00e3o'] != null
                ? DateTime.parse('${paleteList[0]['Data Inclus\u00e3o']}')
                    .toLocal()
                : null,
            bipList.length as int?,
            usurFechamento: usuFechList[0]['NOME'] as String?,
            dtFechamento: paleteList[0]['Data Fechamento'] != '' &&
                    paleteList[0]['Data Fechamento'] != null
                ? DateTime.parse('${paleteList[0]['Data Fechamento']}')
                    .toLocal()
                : null));
      } else {
        teste.add(Paletes(
            paleteList[0]['ID'] as int?,
            usuCriacaoList[0]['NOME'] as String?,
            paleteList[0]['Data Inclus\u00e3o'] != '' &&
                    paleteList[0]['Data Inclus\u00e3o'] != null
                ? DateTime.parse('${paleteList[0]['Data Inclus\u00e3o']}')
                    .toLocal()
                : null,
            bipList.length as int?,
            usurFechamento: usuFechList[0]['NOME'] as String?,
            dtFechamento: paleteList[0]['Data Fechamento'] != '' &&
                    paleteList[0]['Data Fechamento'] != null
                ? DateTime.parse('${paleteList[0]['Data Fechamento']}')
                    .toLocal()
                : null,
            usurCarregamento: usuCarrList[0]['NOME'] as String?,
            dtCarregamento: paleteList[0]['Data Carregamento'] != '' &&
                    paleteList[0]['Data Carregamento'] != null
                ? DateTime.parse('${paleteList[0]['Data Carregamento']}')
                    .toLocal()
                : null));
      }
    }

    return teste;
  }

  Future<List<Contagem>> selectPallet(int palete, BuildContext context) async {
    var teste = <Contagem>[];
    late final Result pedidos;
    late Result volumeResponse;
    late Result response2;
    late int teste2;
    response2 =
        await conn.execute('select count(*) from palete where ID = $palete');
    for (var element in response2) {
      teste2 = element[0] as int;
    }
    if (teste2 == 0 && palete > 0) {
      if (context.mounted) {
        await showCupertinoModalPopup(
          context: context,
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
    } else {
      try {
        pedidos = await conn.execute(
            'Select ID, PEDIDO, DATA_BIPAGEM, COD_BARRA, VOLUME_CAIXA, PALETE, ID_USER_BIPAGEM from bipagem where PALETE = $palete order by ID desc;');
      } on Exception catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
      try {
        for (var element in pedidos) {
          try {
            volumeResponse = await conn.execute(
                'select VOLUME_TOTAL, clientes.cod_cli, clientes.CLIENTE, cidades.CIDADE, count(ID) from pedidos left join bipagem on bipagem.PEDIDO = pedidos.pedido left join clientes on clientes.cod_cli = pedidos.cod_cli left join cidades on clientes.COD_CIDADE = cidades.COD_CIDADE where pedidos.pedido = ${element[1]} and PALETE = $palete group by VOLUME_TOTAL, clientes.cod_cli,clientes.CLIENTE, cidades.CIDADE;');
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
      }
    }
    return teste;
  }

  Future<List<int>> selectromaneio(int romaneio) async {
    var teste = <int>[];
    late final Result pedidos;
    try {
      pedidos = await conn
          .execute('select ID from palete where ID_ROMANEIO = $romaneio;');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    if (pedidos.isNotEmpty) {
      for (var element in pedidos) {
        teste.add(element[0] as int);
      }
    }
    return teste;
  }

  Future<List<Paletes>> paletesFull() async {
    var teste = <Paletes>[];
    late Result volumeResponse;

    volumeResponse = await conn.execute(
        'select palete.ID, ID_ROMANEIO,Cri.NOME, DATA_INCLUSAO,Fech.NOME, DATA_FECHAMENTO,Car.NOME, DATA_CARREGAMENTO, count(bipagem.ID) from palete left join usuarios Cri on Cri.ID = ID_USUR_CRIACAO left join usuarios Fech on Fech.ID = ID_USUR_FECHAMENTO left join usuarios Car on Car.ID = ID_USUR_CARREGAMENTO left join bipagem on PALETE = palete.ID where DATA_CARREGAMENTO is null group by palete.ID, ID_ROMANEIO,Cri.NOME, DATA_INCLUSAO,Fech.NOME, DATA_FECHAMENTO,Car.NOME, DATA_CARREGAMENTO');
    for (var element in volumeResponse) {
      teste.add(Paletes(element[0] as int?, element[2] as String?,
          (element[3] as DateTime).toLocal(), element[8] as int?,
          romaneio: element[1] as int?,
          usurFechamento: element[4] as String?,
          dtFechamento:
              element[5] != null ? (element[5] as DateTime).toLocal() : null,
          usurCarregamento: element[6] as String?,
          dtCarregamento:
              element[7] != null ? (element[7] as DateTime).toLocal() : null));
    }
    return teste;
  }

  // 3 - Update

  Future<List<int>> updatepalete(int romaneio, List<int> paletes) async {
    await conn.execute(
        'update palete set ID_ROMANEIO = $romaneio where ID in (${paletes.join(',')});');

    var teste = <int>[];
    late final Result pedidos;
    try {
      pedidos = await conn
          .execute('select ID from palete where ID_ROMANEIO = $romaneio;');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    if (pedidos.isNotEmpty) {
      for (var element in pedidos) {
        teste.add(element[0] as int);
      }
    }
    return teste;
  }

  void endpalete(int palete, Usuario usur) async {
    await conn.execute(
        'update palete set DATA_FECHAMENTO = current_timestamp, ID_USUR_FECHAMENTO = ${usur.id} where ID = $palete');
  }

  void removepalete(int romaneio, List<int> paletes) async {
    if (paletes.isNotEmpty) {
      await conn.execute(
          'update palete set ID_ROMANEIO = null where ID not in (${paletes.join(',')}) and ID_ROMANEIO = $romaneio;');
    } else {
      await conn.execute(
          'update palete set ID_ROMANEIO = null where ID_ROMANEIO = $romaneio;');
    }
  }

  void reabrirpalete(int palete) async {
    await conn.execute(
        'update palete set DATA_FECHAMENTO = null, ID_USUR_FECHAMENTO = null, ID_ROMANEIO = null where ID = $palete;');
  }

  // ------------------------ Funções do Romaneio ------------------------------

  // 1 - Create

  ///Função para criar um Romaneio novo no Banco
  void createRomaneio() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getInt('ID_Usur');

    try {
      var teste = await http.post(
        romaneioAPI,
        headers: headerDefault,
        body: jsonEncode({'codUsur': '$id'}),
      );
      print('Response status: ${teste.statusCode}');
      print('Response body: ${teste.body}');
    } catch (e) {
      print(e);
    }

    // await conn.execute(
    //     'insert into romaneio (DATA_ROMANEIO,ID_USUR) values (current_timestamp,${usur.id});');
  }

  // 2 - Read

  ///Função para puxar todos os Romaneios que estão abertos no Banco
  Future<List<Romaneio>> romaneioExiste() async {
    var teste = <Romaneio>[];
    late http.Response romResponse, usuResponse, palResponse, bipResponse;
    var romaneioList = [], usuList = [], palList = [], bipList = [];

    try {
      romResponse = await cliente.get(romaneioAPI, headers: headerDefault);

      romaneioList = jsonDecode(utf8.decode(romResponse.bodyBytes)) as List;

      for (var romaneio in romaneioList) {
        palResponse = await cliente.get(
            Uri.http('127.0.0.1:5000', '/Paletes',
                {'romaneio': '${romaneio['ID']}'}),
            headers: headerDefault);

        palList = jsonDecode(utf8.decode(palResponse.bodyBytes)) as List;

        bipResponse = await cliente.get(
            Uri.http('127.0.0.1:5000', '/Bipagens', {
              'palete': palList
                  .map(
                    (e) {
                      return e["ID"];
                    },
                  )
                  .toString()
                  .replaceAll('(', '')
                  .replaceAll(')', '')
            }),
            headers: headerDefault);

        bipList = jsonDecode(utf8.decode(bipResponse.bodyBytes)) as List;

        try {
          usuResponse = await cliente.get(
              Uri.http('127.0.0.1:5000', '/Usuarios',
                  {'id': '${romaneio['Id Usur.']}'}),
              headers: headerDefault);

          usuList = jsonDecode(utf8.decode(usuResponse.bodyBytes)) as List;
        } catch (e) {
          print('getUsuario $e');
        }

        try {
          teste.add(Romaneio(
              romaneio['ID'] as int?,
              bipList.length as int?,
              (romaneio['Data Fechamento'] != null
                  ? (DateFormat('EEE, d MMM yyyy HH:mm:ss')
                          .parse(romaneio['Data Fechamento']))
                      .toLocal()
                  : null),
              (romaneio['Data Romaneio'] != null
                  ? (DateFormat('EEE, d MMM yyyy HH:mm:ss')
                          .parse(romaneio['Data Romaneio']))
                      .toLocal()
                  : null),
              (usuList.isNotEmpty ? usuList[usuList.length - 1]['NOME'] : null)
                  as String?,
              palList
                  .map(
                    (e) {
                      return e["ID"];
                    },
                  )
                  .toString()
                  .replaceAll('(', '')
                  .replaceAll(')', '') as String?,
              (romaneio['Cod. Trans.'] ?? 0) as int?,
              ''));
        } catch (e) {
          print(e);
        }
      }

      // pedidos = await conn.execute(
      //     'select romaneio.ID,romaneio.DATA_FECHAMENTO, romaneio.DATA_ROMANEIO, usuarios.NOME, COALESCE(string_agg(distinct cast(palete.ID as varchar) , \', \' ),\'0\'), count(bipagem.ID) from romaneio left join palete on palete.ID_ROMANEIO = romaneio.ID left join bipagem on palete.ID = bipagem.PALETE left join usuarios on usuarios.ID = romaneio.ID_USUR group by romaneio.ID, romaneio.DATA_FECHAMENTO, romaneio.DATA_ROMANEIO, usuarios.NOME, usuarios.NOME;');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return teste;
  }

  Future<List<Romaneio>> romaneioFinalizado() async {
    var teste = <Romaneio>[];
    late final Result pedidos;

    try {
      pedidos = await conn.execute(
          'select romaneio.ID, count(bipagem.PEDIDO),romaneio.DATA_FECHAMENTO from palete left join romaneio on ID_ROMANEIO = romaneio.ID left join bipagem on PALETE = palete.ID left join (select palete.ID from palete left join romaneio on romaneio.ID = ID_ROMANEIO where palete.DATA_CARREGAMENTO is null) as palete2 on palete2.ID = palete.ID where romaneio.DATA_FECHAMENTO is not null and palete2.ID is not null group by romaneio.ID, romaneio.ID_USUR, romaneio.DATA_FECHAMENTO order by ID');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      teste.add(Romaneio(
          element[0] as int?,
          element[1] as int?,
          DateTime.parse('${element[2]}').toLocal() as DateTime?,
          null,
          null,
          null,
          0,
          ''));
    }

    return teste;
  }

  ///Função para puxar o último romaneio criado
  Future<int> novoRomaneio(BuildContext context) async {
    int teste = 0;
    late final http.Response romResponse;
    var pedidosLista = [];
    // late final Result pedidos;

    try {
      romResponse = await cliente.get(romaneioAPI, headers: headerDefault);

      pedidosLista = jsonDecode(utf8.decode(romResponse.bodyBytes)) as List;

      // pedidos = await conn.execute(
      //     'select COALESCE(MAX(ID),0) from romaneio where DATA_FECHAMENTO IS NULL;');

      teste = pedidosLista[pedidosLista.length - 1]['ID'];
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return teste;
    }

    teste = pedidosLista[pedidosLista.length - 1]['ID'] ?? 0;

    print(teste);

    return (teste);
  }

  Future<List<Romaneio>> romaneiosFinalizados(
      DateTime dtIni, DateTime dtFim) async {
    var teste = <Romaneio>[];
    late Result volumeResponse;

    volumeResponse = await conn.execute(
        'select romaneio.ID, DATA_FECHAMENTO, sum(VOLUME_TOTAL), transportadora from romaneio left join pedidos on pedidos.id_romaneio = romaneio.ID left join transportadora on transportadora.cod_trans = romaneio.cod_trans where DATA_FECHAMENTO is not null and DATA_FECHAMENTO between \'$dtIni\' and \'$dtFim\' group by romaneio.ID, DATA_FECHAMENTO, transportadora order by DATA_FECHAMENTO');
    for (var element in volumeResponse) {
      if (element.isNotEmpty) {
        teste.add(Romaneio(
            element[0] as int,
            (element[2] ?? 0) as int,
            element[1] != '' ? DateTime.parse('${element[1]}').toLocal() : null,
            null,
            null,
            null,
            0,
            element[3] as String?));
      }
    }

    return teste;
  }

  // 3 - Update

  void endromaneio(int romaneio, List<Pedido> pedidos, int trans) async {
    for (var i in pedidos) {
      await conn.execute(
          'update pedidos set id_romaneio = $romaneio where pedido = ${i.ped}');
    }
    await conn.execute(
        'update romaneio set DATA_FECHAMENTO = current_timestamp, cod_trans = $trans where ID = $romaneio;');
  }

  // ------------------------ Funções do Carregamento --------------------------

  // 2 - Read

  Future<List<Carregamento>> getCarregamento(int romaneio) async {
    late var carregamento = <Carregamento>[];
    late final Result pedidos;

    try {
      pedidos = await conn.execute(
          'select palete.ID, count(bipagem.PEDIDO), DATA_CARREGAMENTO from palete left join romaneio on ID_ROMANEIO = romaneio.ID left join bipagem on PALETE = palete.ID where romaneio.ID = $romaneio group by palete.ID, DATA_CARREGAMENTO order by palete.ID;');
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

  // 3 - Update

  void updateCarregamento(int palete, Usuario usur) async {
    await conn.execute(
        'update palete set DATA_CARREGAMENTO = current_timestamp, ID_USUR_CARREGAMENTO = ${usur.id} where ID = $palete;');
  }

  // ------------------------ Funções do Pedido --------------------------------

  // 2 - Read

  Future<List<Pedido>> selectpedidosromaneio(List<int> cods) async {
    var teste = <Pedido>[];
    if (cods.isNotEmpty) {
      late Result volumeResponse;
      volumeResponse = await conn.execute(
          'select pedidos.pedido, VOLUME_TOTAL, clientes.cod_cli, CLIENTE, VLTOTAL, NF, cidades.CIDADE, pedidos.id_romaneio, DATA_FATURAMENTO, DATA_PEDIDO, COALESCE(string_agg(distinct cast(palete.ID as varchar) , \', \' ),\'0\') from pedidos left join bipagem on bipagem.PEDIDO = pedidos.pedido left join palete on bipagem.PALETE = palete.ID left join clientes on clientes.cod_cli = pedidos.cod_cli left join cidades on cidades.COD_CIDADE = clientes.COD_CIDADE where pedidos.id_romaneio in (${cods.join(',')}) group by pedidos.pedido, VOLUME_TOTAL, clientes.cod_cli, CLIENTE, VLTOTAL, NF, cidades.CIDADE, pedidos.id_romaneio, DATA_FATURAMENTO, DATA_PEDIDO;');
      for (var element in volumeResponse) {
        if (element.isNotEmpty) {
          teste.add(Pedido(
            element[0]! as int,
            element[10] as String,
            0,
            element[1]! as int,
            'Correto',
            codCli: element[2]! as int,
            cliente: element[3]!.toString(),
            valor: element[4]! as double,
            nota: element[5] as int,
            cidade: element[6].toString(),
            romaneio: element[7] as int?,
            dtFat: element[8] as DateTime?,
            dtPedido: element[9] as DateTime?,
          ));
        }
      }
    }
    return teste;
  }

  Future<int> qtdFat() async {
    var teste = 69;
    late Result volumeResponse;

    // try {
    //   volumeResponse = await conn.execute(
    //       'select count(*) from pedidos left join bipagem on bipagem.PEDIDO = pedidos.pedido left join clientes on clientes.cod_cli = pedidos.cod_cli left join cidades on cidades.COD_CIDADE = clientes.COD_CIDADE where bipagem.PEDIDO is null and STATUS like \'F\' and VOLUME_TOTAL <> 0 and IGNORAR = false;');
    // } catch (e) {
    //   if (kDebugMode) {
    //     print(e);
    //   }
    // }
    // for (var element in volumeResponse) {
    //   if (element.isNotEmpty) {
    //     teste = (element[0] ?? 0) as int;
    //   }
    // }

    return teste;
  }

  Future<List<Pedido>> faturadosNBipados(
      DateTime dtIni, DateTime? dtFim) async {
    var teste = <Pedido>[];
    late Result volumeResponse;

    volumeResponse = await conn.execute(
        'select pedidos.pedido, VOLUME_TOTAL, clientes.cod_cli, CLIENTE, VLTOTAL, NF, cidades.CIDADE, IGNORAR from pedidos left join bipagem on bipagem.PEDIDO = pedidos.pedido left join clientes on clientes.cod_cli = pedidos.cod_cli left join cidades on cidades.COD_CIDADE = clientes.COD_CIDADE where bipagem.PEDIDO is null and STATUS like \'F\' and VOLUME_TOTAL <> 0 and DATA_FATURAMENTO between \'$dtIni\' and \'$dtFim\';');
    for (var element in volumeResponse) {
      if (element.isNotEmpty) {
        teste.add(Pedido(
            element[0]! as int, '0', 0, element[1]! as int, 'Incorreto',
            codCli: element[2]! as int,
            cliente: element[3]!.toString(),
            valor: element[4]! as double,
            nota: element[5] as int,
            cidade: element[6].toString(),
            ignorar: element[7] as bool?));
      }
    }

    return teste;
  }

  Future<int> qtdCanc() async {
    var teste = 69;
    late Result volumeResponse;

    // volumeResponse = await conn.execute(
    //     'select count(*) from pedidos left join bipagem on bipagem.PEDIDO = pedidos.pedido left join clientes on clientes.cod_cli = pedidos.cod_cli left join cidades on cidades.COD_CIDADE = clientes.COD_CIDADE where bipagem.PEDIDO is not null and (DATA_CANC_PED IS NOT NULL OR DATA_CANC_NF IS NOT NULL) and IGNORAR = false group by pedidos.pedido, VOLUME_TOTAL, clientes.cod_cli, CLIENTE, NF, cidades.CIDADE;');
    // for (var element in volumeResponse) {
    //   try {
    //     if (element.isNotEmpty) {
    //       teste = (element[0] ?? 0) as int;
    //     }
    //   } catch (e) {
    //     if (kDebugMode) {
    //       print(e);
    //     }
    //   }
    // }

    return teste;
  }

  Future<List<Pedido>> canceladosBipados() async {
    var teste = <Pedido>[];
    late Result volumeResponse;

    volumeResponse = await conn.execute(
        'select pedidos.pedido, VOLUME_TOTAL, clientes.cod_cli, CLIENTE, count(bipagem.ID), NF, cidades.CIDADE from pedidos left join bipagem on bipagem.PEDIDO = pedidos.pedido left join clientes on clientes.cod_cli = pedidos.cod_cli left join cidades on cidades.COD_CIDADE = clientes.COD_CIDADE where bipagem.PEDIDO is not null and (DATA_CANC_PED IS NOT NULL OR DATA_CANC_NF IS NOT NULL) group by pedidos.pedido, VOLUME_TOTAL, clientes.cod_cli, CLIENTE, NF, cidades.CIDADE;');
    for (var element in volumeResponse) {
      try {
        if (element.isNotEmpty) {
          teste.add(Pedido(element[0]! as int, '0', element[4] as int,
              element[1]! as int, 'Incorreto',
              codCli: element[2]! as int,
              cliente: element[3]!.toString(),
              nota: element[5] as int,
              cidade: element[6].toString()));
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }

    return teste;
  }

  Future<int?> selectAllpedidos(int cod) async {
    late Result volumeResponse;

    try {
      volumeResponse = await conn
          .execute('select count(*) from pedidos where pedidos.pedido = $cod;');
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    late int? teste;

    for (var element in volumeResponse) {
      teste = element[0] as int?;
    }

    if (teste == 0) {
      return 2;
    } else {
      volumeResponse = await conn.execute(
          'select count(STATUS) from pedidos where pedidos.pedido = $cod and STATUS = \'C\';');
      for (var element in volumeResponse) {
        teste = element[0] as int?;
      }
      if (teste != 0) {
        return 1;
      } else {
        return 0;
      }
    }
  }

  // 3 - Update

  Future<void> updateIgnorar(int ped, {bool? ignorar}) async {
    await conn.execute(
        'update pedidos set IGNORAR = $ignorar where pedidos.pedido = $ped;');
  }

  // ------------------------ Funções da Declaração ----------------------------

  // 1 - Create

  Future<List<Pedido>> createDeclaracao(
      Declaracao dec, DateTime dtIni, DateTime dtFim) async {
    await conn.execute(
        'INSERT INTO pedidos(pedido, VOLUME_TOTAL, DATA_FATURAMENTO, VLTOTAL, cod_cli, STATUS, NF, COND_VENDA, DATA_PEDIDO, VOLUME_NF, DATA_FIM_CHECKOUT, TIPO, MOTIVO)VALUES(\'${dec.ped}\',\'${dec.vol}\',current_timestamp, \'${dec.valor}\',\'${dec.codCli}\',\'F\',\'${dec.ped}\',1,current_timestamp, \'${dec.vol}\', current_timestamp, \'D\', \'${dec.motivo}\');');

    var teste = <Pedido>[];
    late Result volumeResponse;
    volumeResponse = await conn.execute(
        'select pedidos.pedido, VOLUME_TOTAL, clientes.cod_cli, CLIENTE, VLTOTAL, NF, cidades.CIDADE, pedidos.id_romaneio, DATA_FATURAMENTO, DATA_PEDIDO, COALESCE(string_agg(distinct cast(palete.ID as varchar) , \', \' ),\'0\') from pedidos left join bipagem on bipagem.PEDIDO = pedidos.pedido left join palete on bipagem.PALETE = palete.ID left join clientes on clientes.cod_cli = pedidos.cod_cli left join cidades on cidades.COD_CIDADE = clientes.COD_CIDADE where pedidos.TIPO like \'D\' and DATA_PEDIDO between \'$dtIni\' and \'$dtFim\' group by pedidos.pedido, VOLUME_TOTAL, clientes.cod_cli, CLIENTE, VLTOTAL, NF, cidades.CIDADE, pedidos.id_romaneio, DATA_FATURAMENTO, DATA_PEDIDO;');
    for (var element in volumeResponse) {
      if (element.isNotEmpty) {
        teste.add(Pedido(
          element[0]! as int,
          element[10] as String,
          0,
          element[1]! as int,
          'Correto',
          codCli: element[2]! as int,
          cliente: element[3]!.toString(),
          valor: element[4]! as double,
          nota: element[5] as int,
          cidade: element[6].toString(),
          romaneio: element[7] as int?,
          dtFat: element[8] as DateTime?,
          dtPedido: element[9] as DateTime?,
        ));
      }
    }

    return teste;
  }

  // 2 - Read

  Future<List<Pedido>> allDeclaracoes(DateTime? dtIni, DateTime? dtFim) async {
    var teste = <Pedido>[];
    late Result volumeResponse;
    volumeResponse = await conn.execute(
        'select pedidos.pedido, VOLUME_TOTAL, clientes.cod_cli, CLIENTE, VLTOTAL, NF, cidades.CIDADE, pedidos.id_romaneio, DATA_FATURAMENTO, DATA_PEDIDO, COALESCE(string_agg(distinct cast(palete.ID as varchar) , \', \' ),\'0\') from pedidos left join bipagem on bipagem.PEDIDO = pedidos.pedido left join palete on bipagem.PALETE = palete.ID left join clientes on clientes.cod_cli = pedidos.cod_cli left join cidades on cidades.COD_CIDADE = clientes.COD_CIDADE where pedidos.TIPO like \'D\' and DATA_PEDIDO between \'$dtIni\' and \'$dtFim\' group by pedidos.pedido, VOLUME_TOTAL, clientes.cod_cli, CLIENTE, VLTOTAL, NF, cidades.CIDADE, pedidos.id_romaneio, DATA_FATURAMENTO, DATA_PEDIDO;');
    for (var element in volumeResponse) {
      if (element.isNotEmpty) {
        teste.add(Pedido(
          element[0]! as int,
          element[10] as String,
          0,
          element[1]! as int,
          'Correto',
          codCli: element[2]! as int,
          cliente: element[3]!.toString(),
          valor: element[4]! as double,
          nota: element[5] as int,
          cidade: element[6].toString(),
          romaneio: element[7] as int?,
          dtFat: element[8] as DateTime?,
          dtPedido: element[9] as DateTime?,
        ));
      }
    }
    return teste;
  }

  Future<int> ultDec() async {
    var teste = 0;
    late final Result pedidos;

    try {
      pedidos = await conn.execute(
          'select COALESCE(MAX(pedidos.pedido),0) from pedidos where TIPO = \'D\';');
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

  // ------------------------ Funções de Atualização ---------------------------
  //Todo : remover, funções não será necessária após alteração para API

  // 2 - Read

  Future<DateTime?> ultAttget() async {
    late DateTime? ultAtt;
    late Result volumeResponse;
    volumeResponse = await conn
        .execute('Select data_ult_atualizacao from public.atualizacao');

    for (var element in volumeResponse) {
      ultAtt = element[0] as DateTime?;
    }

    return ultAtt;
  }

  // 3 - Update

  void atualizar(DateTime? ultAtt, BuildContext context) async {
    if (DateTime.now().difference(ultAtt!.toLocal()) >=
        const Duration(minutes: 5)) {
      if (context.mounted) {
        await showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return CupertinoAlertDialog(
              title:
                  const Text('Dados irão ser atualizados, por favor aguarde'),
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
      await conn.execute('update atualizacao set atualizar = true');
    } else {
      if (context.mounted) {
        await showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text('Dados atualizados a menos de 5 minutos'),
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

  void atualizarFull(DateTime? ultAtt, BuildContext context) async {
    if (DateTime.now().difference(ultAtt!.toLocal()) >=
        const Duration(minutes: 5)) {
      if (context.mounted) {
        await showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return CupertinoAlertDialog(
              title:
                  const Text('Dados irão ser atualizados, por favor aguarde'),
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
      await conn.execute('update atualizacao set atualizar_full = true');
    } else {
      if (context.mounted) {
        await showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text('Dados atualizados a menos de 5 minutos'),
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

  // ------------------------ Funções do Cliente -------------------------------

  // 2 - Read

  Future<Cliente> selectCliente(int cod) async {
    late var cli = Cliente(0, 0, '', '', '', '');
    late http.Response volumeResponse;

    volumeResponse = await cliente.get(Uri.http('127.0.0.1:5000', '/Clientes'),
        headers: headerDefault);

    // volumeResponse = await conn.execute(
    //     'select CLIENTE, CNPJ, concat(CIDADE,\',\',UF), BAIRRO, CEP, ENDERECO, TELEFONE_COMERCIAL from clientes left join cidades ON cidades.COD_CIDADE = clientes.COD_CIDADE where clientes.cod_cli = $cod');

    var clienteLista =
        jsonDecode(utf8.decode(volumeResponse.bodyBytes)) as List;

    if (cod != 0) {
      for (var element in clienteLista) {
        cli = Cliente(
            element['Cod_Cli'],
            element['Cod_Cidade'],
            element['Cliente'],
            element['Nome_Fantasia'],
            element['CPF/CNPJ'],
            element['Tipo']);
      }
    }

    return cli;
  }

  // ------------------------ Funções da Cidade -------------------------------

  // 2 - Read

  Future<Cidade> selectCidade(int cod) async {
    late var cli = Cidade(0, 0, '', '');
    late http.Response volumeResponse;

    volumeResponse = await cliente.get(
        Uri.http('127.0.0.1:5000', '/Cidades', {'codibge': cod}),
        headers: headerDefault);

    // volumeResponse = await conn.execute(
    //     'select CLIENTE, CNPJ, concat(CIDADE,\',\',UF), BAIRRO, CEP, ENDERECO, TELEFONE_COMERCIAL from clientes left join cidades ON cidades.COD_CIDADE = clientes.COD_CIDADE where clientes.cod_cli = $cod');

    var cidadeLista = jsonDecode(utf8.decode(volumeResponse.bodyBytes)) as List;

    if (cod != 0) {
      for (var element in cidadeLista) {
        cli = Cidade(element['Cod_Cidade'], element['Cod_IBGE'],
            element['Cidade'], element['UF']);
      }
    }

    return cli;
  }

  // ------------------------ Funções da Transportadora ------------------------

  // 2 - Read

  Future<List<Transportadora>> selectTransportadora({String? cod}) async {
    var trans = <Transportadora>[];
    late http.Response volumeResponse;

    volumeResponse = await cliente.get(Uri.http(
        '127.0.0.1:5000',
        '/Transportadoras',
        cod != null
            ? {
                'codigo': cod,
              }
            : {}));

    var lista = jsonDecode(utf8.decode(volumeResponse.bodyBytes)) as List;

    if (lista.isNotEmpty) {
      for (var element in lista) {
        trans.add(Transportadora(element['Codigo'] as int,
            element['Transportadora'] as String, element['CGC'] as String));
      }
    } else {
      trans = [Transportadora(0, 'Transportadora não Encontrada', '')];
    }

    return trans;
  }

}
