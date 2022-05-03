import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rssi_collector/model/Collector.dart';
import 'package:rssi_collector/model/CollectorTile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'RSSI Collector'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<CollectorTile> items = [];
  String title = "";
  String personId = "";

  Future<void> permissionRequest() async {
    if (await Permission.camera.request().isGranted) {
      debugPrint('camera');
    }

    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
    ].request();
  }

  Future<String> get _localPath async {
    final directory = (await getApplicationDocumentsDirectory()).path + '/rssi_data';
    return directory;
  }

  void createDir() async {
    final path = await _localPath;
    if(!Directory(path).existsSync()) {
      Directory(path).create(recursive: true);
    }
  }

  void createFile(String title) async {
    final path = await _localPath;
    File('$path/$title.json').createSync();
  }

  Future<void> get _loadData async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final path = await _localPath;
    String readTitle = "";
    String readPersonId = "";
    try {
      print(Directory(path).listSync());
      setState(() {
        for (var file in Directory(path).listSync()) {
          readTitle = file.path
              .split("/")
              .last
              .replaceAll(".json", "");
          readPersonId = prefs.getString(readTitle)!;
          items.add(CollectorTile(Collector(readTitle, readPersonId)));
        }
      });
    } catch (e) {
      print(e);
    }
  }

  _addData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(title, personId);
  }

  @override
  void initState() {
    super.initState();
    permissionRequest();
    createDir();
    _loadData;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return items[index];
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Add data"),
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                    const Expanded(child: Text("Input title")),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          title = value;
                        },
                      ),
                    ),
                    const Expanded(child: SizedBox(height: 10)),
                    const Expanded(child: Text("Input person id")),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          personId = value;
                        },
                      ),
                    ),
                  ]),
                  actions: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            items.add(CollectorTile(Collector(title, personId)));
                            createFile(title);
                            _addData();
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text("Add"))
                  ],
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
