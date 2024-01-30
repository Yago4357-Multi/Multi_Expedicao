import 'package:flutter/material.dart';
import 'package:romaneio_teste/Models/Romaneio.dart';

class RomaneioTela extends StatefulWidget {
  const RomaneioTela({super.key});

  @override
  State<RomaneioTela> createState() => _RomaneioTelaState();
}

class _RomaneioTelaState extends State<RomaneioTela> {
  int selectIndex = -1;

  List<romaneio> testeRomaneio = [
    romaneio(1, '03.040.543/0001-20', 'BRUNO MICHEL FAVERO', 'CAPINZAL',
        700003909, 391274, 378.77, 1, 1, 1, 'Não', 0, 'OK', '2º Faturamento'),
    romaneio(
        2,
        '04.778.028/0001-05',
        'M & R COMERCIO FARMA LTDA',
        'LEOBERTO LEAL',
        740000566,
        391275,
        545.48,
        1,
        1,
        1,
        'Não',
        0,
        'OK',
        '2º Faturamento')
  ];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Theme.of(context).canvasColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.popAndPushNamed(context, '/Romaneio');
                  },
                  child: const Text('Romaneio')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.popAndPushNamed(context, '/Conformidade');
                  },
                  child: const Text('Não Conformidade')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {}, child: const Text('Contagem')),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          "Romaneio",
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
                                        )),
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
                          testeRomaneio.removeAt(selectIndex);
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
          width: 2000,
          decoration: BoxDecoration(
              border: Border.all(
                  color: const Color.fromRGBO(0, 70, 0, 100), width: 5),
              borderRadius: const BorderRadius.all(Radius.circular(40))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
                child: Text('Romaneio',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    showCheckboxColumn: false,
                      headingTextStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      dataTextStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.black
                      ),
                      columns: const <DataColumn>[
                        DataColumn(label: Text('Seq')),
                        DataColumn(label: Text('CNPJ')),
                        DataColumn(label: Text('Cliente')),
                        DataColumn(label: Text('Cidade')),
                        DataColumn(label: Text('Nº Pedido')),
                        DataColumn(label: Text('Nº NF')),
                        DataColumn(label: Text('Valor')),
                        DataColumn(label: Text('Vol. Rom.')),
                        DataColumn(label: Text('Vol. Exp.')),
                        DataColumn(label: Text('Contagem')),
                        DataColumn(label: Text('Duplicidade')),
                        DataColumn(label: Text('Cxs. Faltantes')),
                        DataColumn(label: Text('OK')),
                        DataColumn(label: Text('Observação')),
                      ],
                      rows: List<DataRow>.generate(
                          testeRomaneio.length,
                          (index) => DataRow(
                                  selected: index == selectIndex,
                                  onSelectChanged: (val) {
                                    setState(() {
                                      if (index == selectIndex) {
                                        selectIndex = -1;
                                      } else {
                                        selectIndex = index;
                                      }
                                    });
                                  },
                                  cells: <DataCell>[
                                    DataCell(
                                        Text('${testeRomaneio[index].Seq}')),
                                    DataCell(Text(testeRomaneio[index].CNPJ)),
                                    DataCell(
                                        Text(testeRomaneio[index].Cliente)),
                                    DataCell(Text(testeRomaneio[index].Cidade)),
                                    DataCell(
                                        Text('${testeRomaneio[index].NPed}')),
                                    DataCell(
                                        Text('${testeRomaneio[index].NF}')),
                                    DataCell(
                                        Text('${testeRomaneio[index].Valor}')),
                                    DataCell(Text(
                                        '${testeRomaneio[index].Vol_Rom}')),
                                    DataCell(Text(
                                        '${testeRomaneio[index].Vol_Exp}')),
                                    DataCell(Text(
                                        '${testeRomaneio[index].Contagem}')),
                                    DataCell(
                                        Text(testeRomaneio[index].Duplicada)),
                                    DataCell(Text(
                                        '${testeRomaneio[index].Cxs_Faltam}')),
                                    DataCell(Text(testeRomaneio[index].Ok)),
                                    DataCell(Text(testeRomaneio[index].Obs)),
                                  ]),
                          growable: true)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
