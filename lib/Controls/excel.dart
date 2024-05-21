import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:postgres/postgres.dart';

import '../Models/cidade.dart';
import '../Models/cliente.dart';
import '../Models/pedido.dart';

class ExcelClass {

  late final Connection conn;
  
  List<Pedido> bancoPed = [];
  List<Cliente> bancoCli = [];
  List<Cidade> bancoCid = [];

  Excel(){
    init();
  }
  
  init() async {
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
      while (true) {
        if (conn.isOpen) {
          pickCli();
          pickCid();
          pickPed();
        }else{
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
        await Future.delayed(const Duration(minutes: 5));
      }
    } on SocketException catch(e){
      print(e);
    }
  }
  
  ///Importar Pedidos para o Banco
  void pickPed() async {

    bancoPed = await selectAllPedidos();

    var file = '//192.168.17.104/bi_compartilhado/INTEGRACOES/MULTI_CARREGAMENTO/BASE_PEDIDOS.csv';
    final input = File(file).openRead();
    final fields = await input.transform(utf8.decoder).transform(const CsvToListConverter()).toList();

    for (var i in fields){
      if (i != fields[0]) {
        var teste = bancoPed.where((element) =>
        element.ped == i[0]).toList();

        if (teste.isNotEmpty) {
          teste[0].cod_venda = (i[1] != '' && i[1] != null ? i[1] : 0);
          teste[0].cod_cli = (i[2] != '' && i[2] != null ? i[2] : '');
          teste[0].situacao = (i[3] != '' && i[3] != null ? i[3] : '').toString();
          teste[0].dt_pedido =
          i[4] != '' && i[4] != null ? DateFormat('dd/MM/yyyy').parse(i[4]) : null;
          teste[0].dt_cancel_ped =
          i[5] != '' && i[5] != null ? DateFormat('dd/MM/yyyy').parse(i[5]) : null;
          teste[0].dt_fat =
          i[6] != '' && i[6] != null ? DateFormat('dd/MM/yyyy').parse(i[6]) : null;
          teste[0].dt_cancel_nf =
          i[7] != '' && i[7] != null ? DateFormat('dd/MM/yyyy').parse(i[7]) : null;
          teste[0].nota = (i[8]) != '' && (i[8]) != null ? int.parse(i[8].toString()) : null;
          teste[0].valor = (i[10] ?? i[9]) != '' && (i[10] ?? i[9]) != null? double.parse((i[10] ?? i[9])) : null;
          teste[0].volfat = (i[12] ?? i[11]) != '' && (i[12] ?? i[11]) != null ? int.parse((i[12] ?? i[11])) : null;
          await updatePedido(teste[0]);

        } else {
          teste.add(Pedido(
            (i[0]), '0', 0, 0, 'Errado', cod_venda: (i[1] != null && i[1] != '' ? i[1] : null),
            cod_cli: (i[2] != null && i[2] != '' ? i[2] : null),
            situacao: (i[3] != null && i[3] != '' ? i[3] : null).toString(),
            dt_pedido: i[4] != '' && i[4] != null ? DateFormat('dd/MM/yyyy').parse(i[4]) : null,
            dt_cancel_ped: i[5] != '' && i[5] != null
              ? DateFormat('dd/MM/yyyy').parse(i[5])
                : null,
            dt_fat: i[6] != '' && i[6] != null ? DateFormat('dd/MM/yyyy').parse(i[6]) : null,
            dt_cancel_nf: i[7] != '' && i[7] != null
              ? DateFormat('dd/MM/yyyy').parse(i[7])
                : null,
            valor: (i[10] ?? i[9]) != null && (i[10] ?? i[9]) != '' ? double.parse((i[10] ?? i[9])) : null,
            nota: i[8] != '' && i[8] == null ? int.parse(i[8].toString()) : null,
            volfat: (i[12] ?? i[11]) != '' && (i[12] ?? i[11]) != null ? int.parse( (i[12] ?? i[11])) : null,));


           await insertPedido(teste[0]);
        }
      }

    }




  }

  ///Importar Clientes para o Banco
  void pickCli() async {

    bancoCli = await selectAllClientes();

    var file = '//192.168.17.104/bi_compartilhado/INTEGRACOES/MULTI_CARREGAMENTO/BASE_CLIENTES.csv';
    final input = File(file).openRead();
    final fields = await input.transform(utf8.decoder).transform(const CsvToListConverter()).toList();

    for (var i in fields){
      if (i != fields[0]) {
        List<Cliente> teste = bancoCli.where((element) =>
        element.cod_cli == i[0]).toList();

        if (teste.isNotEmpty) {

          teste[0].cliente = i[1] != '' && i[1] != null ? i[1] : null;
          teste[0].nome_fantasia = i[2] != '' && i[2] != null ? i[2] : null;
          teste[0].cnpj = i[3] != '' && i[3] != null ? i[3] : null;
          teste[0].tipo = i[4] != '' && i[4] != null ? i[4] : null;
          teste[0].cod_cid = i[5] != '' && i[5] != null ? i[5] : null;

          await updateCliente(teste[0]);

        } else {

          teste.add(Cliente((i[0] != '' && i[0] != null ? i[0] : null) as int?, (i[5] != '' && i[5] != null ? i[5] : null) as int?, (i[1] != '' && i[1] != null ? i[1] : null) as String?, (i[2] != '' && i[2] != null ? i[2] : null) as String?, (i[3] != '' && i[3] != null ? i[3] : null) as String?, (i[4] != '' && i[4] != null ? i[4] : null) as String?));

          await insertCliente(teste[0]);
        }
      }

    }
  }

  Future<void> updatePedido(Pedido pedidos) async {
    await conn.execute('update "Pedidos" set "COND_VENDA" = ${pedidos.cod_venda}, "ID_CLI" = ${pedidos.cod_cli} , "STATUS" = \'${pedidos.situacao}\', "DATA_PEDIDO" = ${pedidos.dt_pedido != null ? 'to_timestamp(\'${pedidos.dt_pedido}\',\'YYYY-MM-DD HH24:MI:SS\')' : null}, "DATA_CANC_PED" = ${pedidos.dt_cancel_ped != null ? 'to_timestamp(\'${pedidos.dt_cancel_ped}\',\'YYYY-MM-DD HH24:MI:SS\')' : null}, "DATA_FATURAMENTO" = ${pedidos.dt_fat != null ? 'to_timestamp(\'${pedidos.dt_fat}\',\'YYYY-MM-DD HH24:MI:SS\')' : null}, "DATA_CANC_NF" = ${pedidos.dt_cancel_nf != null ? 'to_timestamp(\'${pedidos.dt_cancel_nf}\',\'YYYY-MM-DD HH24:MI:SS\')' : null}, "NF" = ${pedidos.nota} , "VLTOTAL" = ${pedidos.valor}, "VOLUME_NF" = ${pedidos.volfat} where "NUMPED" = ${pedidos.ped};');
  }

  Future<void> insertPedido(Pedido pedidos) async {
    await conn.execute(
        'insert into "Pedidos"("NUMPED","VOLUME_TOTAL", "DATA_FATURAMENTO", "VLTOTAL", "ID_CLI","STATUS", "NF", "COND_VENDA", "DATA_PEDIDO", "DATA_CANC_PED", "DATA_CANC_NF", "VOLUME_NF") values (${pedidos.ped}, ${pedidos.vol}, ${pedidos.dt_fat != null ? 'to_timestamp(\'${pedidos.dt_fat}\',\'YYYY-MM-DD HH24:MI:SS\')' : null}, ${pedidos.valor}, ${pedidos.cod_cli}, \'${pedidos.situacao}\', ${pedidos.nota}, ${pedidos.cod_venda}, ${pedidos.dt_pedido != null ? 'to_timestamp(\'${pedidos.dt_pedido}\',\'YYYY-MM-DD HH24:MI:SS\')' : null}, ${pedidos.dt_cancel_ped != null ? 'to_timestamp(\'${pedidos.dt_cancel_ped}\',\'YYYY-MM-DD HH24:MI:SS\')' : null}, ${pedidos.dt_cancel_nf != null ? 'to_timestamp(\'${pedidos.dt_cancel_nf}\',\'YYYY-MM-DD HH24:MI:SS\')' : null}, ${pedidos.volfat}) ON CONFLICT DO NOTHING;');
  }

  void pickCid() async {

    bancoCid = await selectAllCidades();

    var file = '//192.168.17.104/bi_compartilhado/INTEGRACOES/MULTI_CARREGAMENTO/BASE_CIDADES.csv';
    final input = File(file).openRead();
    final fields = await input.transform(utf8.decoder).transform(const CsvToListConverter()).toList();

    for (var i in fields) {
      if (i != fields[0]) {
        List<Cidade> teste = bancoCid.where((element) =>
        element.cod_cidade == i[0]).toList();

        if (teste.isNotEmpty) {
          teste[0].cidade = i[1] != '' && i[1] != null ? i[1] : null;
          teste[0].cod_ibge = i[2] != '' && i[2] != null ? i[2] : null;
          teste[0].uf = i[3] != '' && i[3] != null ? i[3] : null;

          await updateCidade(teste[0]);
        } else {
          teste.add(Cidade(i[0] != '' && i[0] != null ? i[0] : null,
              i[2] != '' && i[2] != null ? i[2] : null,
              i[1] != '' && i[1] != null ? i[1] : null,
              i[3] != '' && i[3] != null ? i[3] : null));

          await insertCidade(teste[0]);
        }
      }
    }

  }

  ///Função para selecionar todos os clientes do Banco
  Future<List<Cliente>> selectAllClientes() async {
    var teste = <Cliente>[];
    late final Result pedidos;

    try {
      pedidos = await conn.execute(
          'select * from "Clientes"');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      teste.add(Cliente(element[0] as int?, element[5] as int?, element[1] as String?, element[3] as String?, element[2] as String?, element[4] as String?));
    }

    return teste;
  }

  ///Atualizar base de Clientes
  Future<void> updateCliente(Cliente clientes) async {
    await conn.execute('update "Clientes" set "CLIENTE" = \'${clientes.cliente?.replaceAll('\'','\'\'')}\', "CNPJ" = \'${clientes.cnpj}\', "NOME_FANTASIA" = \'${clientes.nome_fantasia?.replaceAll('\'','\'\'')}\', "TIPO_CLIENTE" = \'${clientes.tipo}\', "COD_CIDADE" = ${clientes.cod_cid} where "COD_CLI" = ${clientes.cod_cli};');
  }

  ///Inserir novos clientes baseado na Base de Clientes
  Future<void> insertCliente(Cliente clientes) async {
    await conn.execute(
        'insert into "Clientes"("COD_CLI", "CLIENTE","CNPJ", "NOME_FANTASIA", "TIPO_CLIENTE", "COD_CIDADE") values (${clientes.cod_cli}, \'${clientes.cliente?.replaceAll('\'','\'\'')}\', \'${clientes.cnpj}\', \'${clientes.nome_fantasia?.replaceAll('\'','\'\'')}\',\'${clientes.tipo}\', ${clientes.cod_cid}) ON CONFLICT DO NOTHING;');
  }

  ///Busca todas as cidades do Banc
  Future<List<Cidade>> selectAllCidades() async {
    var teste = <Cidade>[];
    late final Result pedidos;

    try {
      pedidos = await conn.execute(
          'select * from "Cidades"');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    for (var element in pedidos) {
      teste.add(Cidade(element[0] as int?, element[2] as int?, element[1] as String?, element[3] as String?));
    }

    return teste;
  }

  ///Atualizar base de Cidades
  Future<void> updateCidade(Cidade cidades) async {
    await conn.execute('update "Cidades" set "CIDADE" = \'${cidades.cidade?.replaceAll('\'','\'\'')}\', "CODIBGE" = ${cidades.cod_ibge}, "UF" = \'${cidades.uf}\' where "CODCIDADE" = ${cidades.cod_cidade};');
  }

  ///Inserir novos clientes baseado na Base de Cidades
  Future<void> insertCidade(Cidade cidades) async {
    await conn.execute(
        'insert into "Cidades"("CODCIDADE", "CIDADE","CODIBGE", "UF") values (${cidades.cod_cidade}, \'${cidades.cidade?.replaceAll('\'','\'\'')}\', ${cidades.cod_ibge}, \'${cidades.uf}\') ON CONFLICT DO NOTHING;');
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
          element[2] as int, element[3] as int, status, cnpj: element[4] as String?, cliente: element[5] as String?, cidade: element[6] as String?, nota: element[7] as int?, valor: element[8] as double?));
    }

    return teste;
  }

}