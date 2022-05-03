import 'package:flutter/material.dart';
import 'package:rssi_collector/model/Collector.dart';
import 'package:rssi_collector/rssi_collect.dart';

class CollectorTile extends StatelessWidget {
  CollectorTile(this._collector);

  final Collector _collector;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: Text(_collector.title),
      subtitle: Text(_collector.personId),
      onTap: () {
        Navigator.push(
          context,MaterialPageRoute(builder: (context) => RssiCollect(title: _collector.title, personId: _collector.personId,))
        );
      },
    );
  }
}
