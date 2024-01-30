import 'dart:async';
import 'package:sqflite/sqflite.dart';

import '../Models/Pedido.dart';

const _dbVersion = 1;

///Class for Database
class Banco {
  ///Database init
  Banco();

  ///Function that init the database
  Future<void> init() async {
    final databasePath = await OpenDatabaseOptions()

    db = await da
  }

  Future<void> insertPedido(List<pedido> list) async {
    for (final price in list) {
      await db.insert('Pedido', {
        'Seq': price.Seq
      });
    }
  }



}