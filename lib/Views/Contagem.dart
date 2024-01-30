import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Models/Contagem.dart';

class ContagemTela extends StatefulWidget {
  const ContagemTela({super.key});

  @override
  State<ContagemTela> createState() => _ContagemTelaState();
}

class _ContagemTelaState extends State<ContagemTela> {
  int Palete = 1;
  final TextEditingController teste = TextEditingController();
  List<Contagem> teste2 = [Contagem('075977950001060700003909999001001', 1)];
  int i = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        centerTitle: true,
        title: const Text('Contagem'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.characters.length == 33) {
                      teste.clear();
                      return null;
                    } else {
                      teste.clear();
                      return 'Código errado';
                    }
                  },
                  canRequestFocus: true,
                  autofocus: true,
                  controller: teste,
                  onFieldSubmitted: (value) {
                    if (value.length == 33) {
                      setState(() {
                        i = teste2.length;
                        teste2.add(Contagem(value, Palete));
                      });
                    }
                  },
                  decoration: const InputDecoration(hintText: 'Código'),
                ),
              ),
            ),
            Container(
              alignment: AlignmentDirectional.centerStart,
              padding: const EdgeInsets.all(10),
              child: DefaultTextStyle(
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Table(
                    children: [
                      TableRow(children: [
                        Text('Código: \n${teste2[i].Codigo}'),
                      ]),
                      TableRow(children: [
                        Text('Pedido: \n${teste2[i].Ped}'),
                      ]),
                      TableRow(children: [
                        Text('Caixa: \n${teste2[i].Cx}'),
                      ]),
                      TableRow(children: [
                        Text('Volume: \n${teste2[i].Vol}'),
                      ]),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              Palete++;
            });
          },
          child: Text('{$Palete}')),
    );
  }
}
