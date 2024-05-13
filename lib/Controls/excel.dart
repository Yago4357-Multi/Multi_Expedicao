import 'dart:io';

import 'package:excel/excel.dart';

import '../Models/pedido.dart';
import 'banco.dart';

class ExcelClass {

  List<Pedido> pedExcel = [];
  List<Pedido> banco = [];
  Banco bd = Banco();

  pickFile() async {

    banco = await bd.selectAllPedidos();

    var file = 'A:/COLABORADORES/VICTOR/ROMANEIOS/MAIO/13.05.2024/ROMANEIO 01.xlsx';
    var bytes = File(file).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {


        var teste = banco.where((element) =>
        element.ped == int.parse(row[5]!.value.toString())).toList();

        if (teste.isNotEmpty) {

          teste[0].valor = double.parse(row[7]!.value.toString());
          teste[0].cnpj = row[1]!.value.toString();
          teste[0].situacao = row[9]!.value.toString();
          teste[0].nota = int.parse(row[6]!.value.toString());
           await bd.updatePedido(teste[0]);

        }else{
          teste.add(Pedido(int.parse(row[5]!.value.toString()), '0', 0, int.parse(row[8]!.value.toString()), 'Errado', situacao: row[9]!.value.toString(), cidade: row[3]!.value.toString(), cnpj: row[1]!.value.toString(), valor: double.parse(row[7]!.value.toString()), nota: int.parse(row[6]!.value.toString()), volfat: int.parse(row[8]!.value.toString()), ));
          await bd.insertPedido(teste[0]);
        }
      }
    }




  }

}