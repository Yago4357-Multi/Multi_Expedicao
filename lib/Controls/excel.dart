import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../Models/cidade.dart';
import '../Models/cliente.dart';
import '../Models/pedido.dart';
import 'banco.dart';

class ExcelClass {

  List<Pedido> bancoPed = [];
  List<Cliente> bancoCli = [];
  List<Cidade> bancoCid = [];
  Banco bd = Banco();


  init(){
    pickCli();
    pickCid();
    pickPed();
  }

  ///Importar Pedidos para o Banco
  void pickPed() async {

    bancoPed = await bd.selectAllPedidos();

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
          await bd.updatePedido(teste[0]);

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


           await bd.insertPedido(teste[0]);
        }
      }

    }




  }

  ///Importar Clientes para o Banco
  void pickCli() async {

    bancoCli = await bd.selectAllClientes();

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

          await bd.updateCliente(teste[0]);

        } else {

          teste.add(Cliente((i[0] != '' && i[0] != null ? i[0] : null) as int?, (i[5] != '' && i[5] != null ? i[5] : null) as int?, (i[1] != '' && i[1] != null ? i[1] : null) as String?, (i[2] != '' && i[2] != null ? i[2] : null) as String?, (i[3] != '' && i[3] != null ? i[3] : null) as String?, (i[4] != '' && i[4] != null ? i[4] : null) as String?));

          await bd.insertCliente(teste[0]);
        }
      }

    }




  }

  void pickCid() async {

    bancoCid = await bd.selectAllCidades();

    var file = '//192.168.17.104/bi_compartilhado/INTEGRACOES/MULTI_CARREGAMENTO/BASE_CIDADES.csv';
    final input = File(file).openRead();
    final fields = await input.transform(utf8.decoder).transform(const CsvToListConverter()).toList();

    for (var i in fields){
      if (i != fields[0]) {
        List<Cidade> teste = bancoCid.where((element) =>
        element.cod_cidade == i[0]).toList();

        if (teste.isNotEmpty) {

          teste[0].cidade = i[1] != '' && i[1] != null ? i[1] : null;
          teste[0].cod_ibge = i[2] != '' && i[2] != null ? i[2] : null;
          teste[0].uf = i[3] != '' && i[3] != null ? i[3] : null;

          await bd.updateCidade(teste[0]);

        } else {

          teste.add(Cidade(i[0] != '' && i[0] != null ? i[0] : null, i[2] != '' && i[2] != null ? i[2] : null, i[1] != '' && i[1] != null ? i[1] : null, i[3] != '' && i[3] != null ? i[3] : null));

          await bd.insertCidade(teste[0]);
        }
      }

    }




  }

}