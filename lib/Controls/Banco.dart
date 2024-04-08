import 'dart:async';
import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:postgres/postgres.dart';

import '../Models/Contagem.dart';

class Banco{

  late Connection conn;

  Banco(){
    init();
  }

  init() async {
    conn = await Connection.open(Endpoint(
      host: 'localhost',
      database: 'Teste',
      username: 'BI',
      password: '123456',
      port: 5432,
    ),
    settings: const ConnectionSettings(sslMode: SslMode.disable));
  }

  insert(String cod,int pallet, a) async{
    conn = await Connection.open(Endpoint(
      host: 'localhost',
      database: 'Teste',
      username: 'BI',
      password: '123456',
      port: 5432,
    ),
        settings: const ConnectionSettings(sslMode: SslMode.disable));
    try {
      await conn.execute(
          'insert into "Teste"("Codigo","Pallet") values ($cod,$pallet);');
    }
    on Exception catch(e){
      return showCupertinoModalPopup(barrierDismissible:false,builder:(context){
        return CupertinoAlertDialog(
          title:Text(
              'Código Duplicado'),
          actions:<CupertinoDialogAction>[
            CupertinoDialogAction(
                isDefaultAction:
                true,
                onPressed:(){
                  Navigator.pop(context);
                },
                child: const Text('Voltar'))],);},context: a);
    }
  }
  
  Future<List<Contagem>> select(int cod) async{
    conn = await Connection.open(Endpoint(
      host: 'localhost',
      database: 'Teste',
      username: 'BI',
      password: '123456',
      port: 5432,
    ),
        settings: const ConnectionSettings(sslMode: SslMode.disable));
    List<Contagem> teste = [];
    late final Pedidos;
    try {
      Pedidos = await conn.execute('select * from "Teste" where "Pallet" = $cod;');
    }
    catch(e){

    }
    Pedidos!.forEach((element) {
      teste.add(Contagem('0${element[0]}',element[1] as int));
    });
    return teste;
  }

  update() async{
    await conn.execute('update Teste ');
  }
}