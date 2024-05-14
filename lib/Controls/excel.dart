import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

import '../Models/pedido.dart';
import 'banco.dart';

class ExcelClass {

  List<Pedido> pedExcel = [];
  List<Pedido> banco = [];
  Banco bd = Banco();

  ///Importar Pedidos para o Banco
  void pickPed() async {

    banco = await bd.selectAllPedidos();

    var file = '//192.168.17.104/bi_compartilhado/INTEGRACOES/MULTI_CARREGAMENTO/BASE_PEDIDOS.csv';
    final input = File(file).openRead();
    final fields = await input.transform(utf8.decoder).transform(const CsvToListConverter()).toList();

    for (var i in fields){
      if (i != fields[0]) {
        var teste = banco.where((element) =>
        element.ped == i[0]).toList();

        if (teste.isNotEmpty) {
          teste[0].cod_venda = (i[1] ?? 0);
          teste[0].cod_cli = (i[2] ?? '');
          teste[0].situacao = (i[3] ?? '').toString();
          teste[0].dt_pedido =
          i[4] != '' ? DateFormat('dd/MM/yyyy').parse(i[4]) : null;
          teste[0].dt_cancel_ped =
          i[5] != '' ? DateFormat('dd/MM/yyyy').parse(i[5]) : null;
          teste[0].dt_fat =
          i[6] != '' ? DateFormat('dd/MM/yyyy').parse(i[6]) : null;
          teste[0].dt_cancel_nf =
          i[7] != '' ? DateFormat('dd/MM/yyyy').parse(i[7]) : null;
          teste[0].nota = int.parse((i[8] == '' ? '0' : i[8]).toString());
          teste[0].valor = double.parse((i[10] ?? i[9]) ?? '0.0');
          teste[0].volfat = int.parse((i[12] ?? i[11]) == '' ? '0' : (i[12] ?? i[11]));
          await bd.updatePedido(teste[0]);

        } else {
          teste.add(Pedido(
            (i[0]), '0', 0, 0, 'Errado', cod_venda: (i[1] ?? 0),
            situacao: (i[3] ?? '').toString(),
            cod_cli: (i[2] ?? ''),
            dt_pedido: i[4] != '' ? DateFormat('dd/MM/yyyy').parse(i[4]) : null,
            dt_cancel_ped: i[5] != ''
                ? DateFormat('dd/MM/yyyy').parse(i[5])
                : null,
            dt_fat: i[6] != '' ? DateFormat('dd/MM/yyyy').parse(i[6]) : null,
            dt_cancel_nf: i[7] != ''
                ? DateFormat('dd/MM/yyyy').parse(i[7])
                : null,
            valor: double.parse((i[10] ?? i[9]) == '' ? '0.0' : (i[10] ?? i[9])),
            nota: int.parse((i[8] == '' ? '0' : i[8]).toString()),
            volfat: int.parse((i[12] ?? i[11]) == '' ? '0' : (i[12] ?? i[11])),));


           await bd.insertPedido(teste[0]);
        }
      }

    }




  }

  ///Importar Clientes para o Banco
  void pickCli() async {

    banco = await bd.selectAllPedidos();

    var file = '//192.168.17.104/bi_compartilhado/INTEGRACOES/MULTI_CARREGAMENTO/BASE_PEDIDOS.csv';
    final input = File(file).openRead();
    final fields = await input.transform(utf8.decoder).transform(const CsvToListConverter()).toList();

    for (var i in fields){
      if (i != fields[0]) {
        var teste = banco.where((element) =>
        element.ped == i[0]).toList();

        if (teste.isNotEmpty) {
          teste[0].cod_venda = (i[1] ?? 0);
          teste[0].cod_cli = (i[2] ?? '');
          teste[0].situacao = (i[3] ?? '').toString();
          teste[0].dt_pedido =
          i[4] != '' ? DateFormat('dd/MM/yyyy').parse(i[4]) : null;
          teste[0].dt_cancel_ped =
          i[5] != '' ? DateFormat('dd/MM/yyyy').parse(i[5]) : null;
          teste[0].dt_fat =
          i[6] != '' ? DateFormat('dd/MM/yyyy').parse(i[6]) : null;
          teste[0].dt_cancel_nf =
          i[7] != '' ? DateFormat('dd/MM/yyyy').parse(i[7]) : null;
          teste[0].nota = int.parse((i[8] ?? '').toString());
          teste[0].valor = double.parse((i[10] ?? i[9]) ?? '0.0');
          teste[0].volfat = int.parse((i[12] ?? i[11]) == '' ? '0' : (i[12] ?? i[11]));
          await bd.updatePedido(teste[0]);

        } else {
          teste.add(Pedido(
            (i[0]), '0', 0, 0, 'Errado', cod_venda: (i[1] ?? 0),
            situacao: (i[3] ?? '').toString(),
            cod_cli: (i[2] ?? ''),
            dt_pedido: i[4] != '' ? DateFormat('dd/MM/yyyy').parse(i[4]) : null,
            dt_cancel_ped: i[5] != ''
                ? DateFormat('dd/MM/yyyy').parse(i[5])
                : null,
            dt_fat: i[6] != '' ? DateFormat('dd/MM/yyyy').parse(i[6]) : null,
            dt_cancel_nf: i[7] != ''
                ? DateFormat('dd/MM/yyyy').parse(i[7])
                : null,
            valor: double.parse((i[10] ?? i[9]) == '' ? '0.0' : (i[10] ?? i[9])),
            nota: int.parse((i[8] == '' ? '0' : i[8]).toString()),
            volfat: int.parse((i[12] ?? i[11]) == '' ? '0' : (i[12] ?? i[11])),));


          await bd.insertPedido(teste[0]);
        }
      }

    }




  }

}