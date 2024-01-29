import 'dart:async';
import 'package:sqflite/sqflite.dart';

import '../Models/Pedido.dart';

const _dbVersion = 1;

///Class for Database
class Banco {
  ///Database init
  Banco();

  ///Variable for database
  late Database db;

  ///Function that init the database
  Future<void> init() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/database2.db';

    db = await openDatabase(path, version: _dbVersion,
        onCreate: (database, version) async {
          await database.execute('''CREATE TABLE Romaneio(
          Seq INTEGER NOT NULL
          PRIMARY KEY(ID AUTOINCREMENT));''');
        });
  }

  Future<void> insertPedido(List<pedido> list) async {
    for (final price in list) {
      await db.insert('Pedido', {
        'Seq': price.Seq
      });
    }
  }



}