import 'dart:convert';
import 'dart:io';
import 'package:rssi_collector/model/Rssi.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wifi_hunter/wifi_hunter.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';

class RssiCollect extends StatefulWidget {
  final String title;
  final String personId;

  const RssiCollect({Key? key, required this.title, required this.personId}) : super(key: key);

  @override
  State<RssiCollect> createState() => _RssiCollectState();
}

class _RssiCollectState extends State<RssiCollect> {

  WiFiHunterResult wiFiHunterResult = WiFiHunterResult();
  Color huntButtonColor = Colors.lightBlue;
  String scanStatus = "WiFi Scan";
  int rssiIndex = 0;
  late AndroidDeviceInfo info;
  String device = '';

  final _buildingList = ['1', '2', '3', '4', '5'];
  String _selectedBuilding = '1';

  final _floorList = ['1', '2', '3', '4', '5', '6', '7'];
  String _selectedFloor = '1';

  String? _space_id;
  String? _rp;
  List<dynamic> rssiDataList = [];

  bool isSwitched = false;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/rssi_data/${widget.title}.json');
  }

  Future<void> huntWiFis() async {
    while (isSwitched) {
      setState(() => huntButtonColor = Colors.red);

      Map<String, int> rssi = {};
      try {
        wiFiHunterResult = (await WiFiHunter.huntWiFiNetworks)!;

        for (var data in wiFiHunterResult.results) {
          rssi[data.BSSID] = data.level;
        }
      } on PlatformException catch (exception) {
        debugPrint(exception.toString());
      }

      if (!mounted) return;

      Rssi rssiData = Rssi(
          _rp!,
          _selectedBuilding,
          _selectedFloor,
          widget.personId,
          DateTime.now().toString(),
          _space_id!,
          rssi);
      RssiData metaData =
      RssiData(rssiIndex, info.androidId.toString(), rssiData);

      setState(() {
        rssiIndex++;
      });
      rssiDataList.add(metaData);
      sleep(const Duration(seconds: 1));
    }
    createFile(rssiDataList);
    setState(() => huntButtonColor = Colors.lightBlue);
  }

  void createFile(List<dynamic> rssiData) async {
    File file = await _localFile;
    file.createSync();
    file.writeAsStringSync(jsonEncode(rssiData));
    print(jsonEncode(rssiData));
  }

  void loadFile() async {
    File file = await _localFile;
    String rssiData = await file.readAsString();
    setState(() {
      final jsonRssiData = jsonDecode(rssiData);
      rssiDataList = jsonRssiData;
      rssiIndex = jsonRssiData.last["id"];
    });
  }


  Future<void> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      info = await deviceInfo.androidInfo;
    }
  }

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
    loadFile();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("Building ID : "),
                  DropdownButton(
                      value: _selectedBuilding,
                      items: _buildingList.map((value) {
                        return DropdownMenuItem(
                            value: value, child: Text(value));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBuilding = value.toString();
                        });
                      }),
                  const Text("Floor ID : "),
                  DropdownButton(
                      value: _selectedFloor,
                      items: _floorList.map((value) {
                        return DropdownMenuItem(
                            value: value, child: Text(value));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFloor = value.toString();
                        });
                      })
                ],
              ),
              TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter(RegExp('[0-9]'), allow: true)
                ],
                decoration: const InputDecoration(
                    labelText: 'Space ID', hintText: '방 호수 입력'),
                onChanged: (value) {
                  _space_id = value;
                },
              ),
              TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter(RegExp('[0-9]'), allow: true)
                ],
                decoration: const InputDecoration(
                    labelText: 'Reference Point',
                    hintText: 'Reference Point 입력'),
                onChanged: (value) {
                  _rp = value;
                },
              ),
              Center(
                child: Switch(
                  value: isSwitched,
                  onChanged: (bool value) {
                    if (_rp != null && _rp != '' && _space_id != null &&
                        _space_id != '') {
                      setState(() {
                        isSwitched = value;
                        isSwitched == true
                            ? scanStatus = "WiFi Scanning"
                            : scanStatus = "WiFi Scan";
                      });
                      huntWiFis();
                    }
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.0),
                    color: huntButtonColor,
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black,
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                          offset: Offset(2.0, 2.0))
                    ]),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    rssiIndex.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.0),
                    color: huntButtonColor,
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black,
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                          offset: Offset(2.0, 2.0))
                    ]),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    scanStatus,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              wiFiHunterResult.results.isNotEmpty
                  ? Container(
                margin: const EdgeInsets.only(
                    bottom: 20.0, left: 30.0, right: 30.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                        wiFiHunterResult.results.length,
                            (index) =>
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10.0),
                              child: ListTile(
                                  leading: Text(wiFiHunterResult
                                      .results[index].level
                                      .toString() +
                                      ' dbm'),
                                  title: Text(wiFiHunterResult
                                      .results[index].SSID),
                                  subtitle: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('BSSID : ' +
                                            wiFiHunterResult
                                                .results[index].BSSID),
                                      ])),
                            ))),
              )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
