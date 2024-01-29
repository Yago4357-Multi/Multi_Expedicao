import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade900),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectIndex = -1;
  @override
  Widget build(BuildContext context) {

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          "MULTILIST",
          style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
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
                      onPressed: () {}, icon: const Icon(Icons.edit)),
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
                      onPressed: () {}, icon: const Icon(Icons.delete_forever)),
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
                child: Text('Romaneio',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              Expanded(
                  child: DataTable(
                      headingTextStyle: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                      dataTextStyle: const TextStyle(
                        fontSize: 12,
                      ),
                      columns: const <DataColumn>[
                        DataColumn(label: Text('Column2')),
                        DataColumn(label: Text('Column2')),
                        DataColumn(label: Text('Column3')),
                        DataColumn(label: Text('Column4')),
                        DataColumn(label: Text('Column5')),
                        DataColumn(label: Text('Column6')),
                      ],
                      rows: List<DataRow>.generate(
                        4,
                        (index) => const DataRow(
                            cells: <DataCell>[
                              DataCell(Text('2')),
                              DataCell(Text('4')),
                              DataCell(Text('4')),
                              DataCell(Text('4')),
                              DataCell(Text('4')),
                              DataCell(Text('4'))
                            ]),
                      ))),
            ],
          ),
        ),
      ),
    );
  }
}
