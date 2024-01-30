import 'package:flutter/material.dart';
import '../Models/Pedido.dart';

class NConformidade extends StatefulWidget {

  const NConformidade({super.key});

  @override
  State<NConformidade> createState() => _NConformidadeState();
}

class _NConformidadeState extends State<NConformidade> {

  int selectIndex = -1;

  List<pedido> teste = [
    pedido(1, 1, 1, 1, 1, 'Teste', '123', 'Teste'),
    pedido(2, 2, 2, 2, 2, 'Teste2', '123', 'Teste2'),
    pedido(3, 3, 3, 3, 3, 'Teste3', '123', 'Teste3'),
    pedido(4, 4, 4, 4, 4, 'Teste4', '123', 'Teste4')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Theme.of(context).canvasColor,
        child: Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(onPressed: (){
                      Navigator.popAndPushNamed(context, '/Romaneio');
                    }, child: const Text('Romaneio')),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(onPressed: (){
                      Navigator.popAndPushNamed(context, '/Conformidade');
                    }, child: const Text('Não Conformidade')),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(onPressed: (){
                      Navigator.pushNamed(context, '/Contagem');
                    }, child: const Text('Contagem')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          "Não Conformidade",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
                width: 80,
                height: 60,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius:
                    BorderRadius.horizontal(left: Radius.circular(20)),
                    color: Colors.lightGreenAccent,
                  ),
                  child: IconButton(
                      onPressed: () {
                        if (selectIndex != -1) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const SimpleDialog(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: SizedBox(
                                        width: 800,
                                        height: 400,
                                        child: Center(
                                          child: Text('Dados ficam aqui!!!'),
                                        )
                                    ),
                                  )
                                ],
                              );
                            },
                          );
                        }
                      },
                      icon: const Icon(Icons.edit)),
                )),
            SizedBox(
                width: 80,
                height: 60,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius:
                    BorderRadius.horizontal(right: Radius.circular(20)),
                    color: Colors.red,
                  ),
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          teste.removeAt(selectIndex);
                        });
                      },
                      icon: const Icon(Icons.delete_forever)),
                )),
          ],
        ),
      ),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          height: 800,
          width: 1200,
          decoration: BoxDecoration(
              border: Border.all(
                  color: const Color.fromRGBO(0, 70, 0, 100), width: 5),
              borderRadius: const BorderRadius.all(Radius.circular(40))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
                child: Text('Não Conformidade',
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
              ),
              Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        showCheckboxColumn: false,
                          headingTextStyle: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                          dataTextStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                          columns: const <DataColumn>[
                            DataColumn(label: Text('Seq')),
                            DataColumn(label: Text('Vol_Rom')),
                            DataColumn(label: Text('Vol_Exp')),
                            DataColumn(label: Text('Cont')),
                            DataColumn(label: Text('Caixa')),
                            DataColumn(label: Text('Origem')),
                            DataColumn(label: Text('Pedido')),
                            DataColumn(label: Text('Obs')),
                          ],
                          rows: List<DataRow>.generate(
                              teste.length,
                                  (index) => DataRow(
                                  selected: index == selectIndex,
                                  onSelectChanged: (val) {
                                    setState(() {
                                      if (index == selectIndex){
                                        selectIndex = -1;
                                      }
                                      else{
                                        selectIndex = index;
                                      }
                                    });
                                  },
                                  cells: <DataCell>[
                                    DataCell(Text('${teste[index].Seq}')),
                                    DataCell(Text('${teste[index].Vol_Rom}')),
                                    DataCell(Text('${teste[index].Vol_Exp}')),
                                    DataCell(Text('${teste[index].Cont}')),
                                    DataCell(Text('${teste[index].Caixa}')),
                                    DataCell(Text(teste[index].Origem)),
                                    DataCell(Text(teste[index].Pedido)),
                                    DataCell(Text(teste[index].Obs))
                                  ]),
                              growable: true)),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
