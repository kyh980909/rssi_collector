class Rssi {
  final String rp;
  final String building_id;
  final String floor_id;
  final String person_id;
  final String space_id;
  final String timestamp;
  final Map<String, int> rssi;

  Rssi(this.rp, this.building_id, this.floor_id, this.person_id, this.timestamp, this.space_id, this.rssi);

  Rssi.fromJson(Map<String, dynamic> json)
      : rp = json['rp'],
        building_id = json['building_id'],
        floor_id = json['floor_id'],
        person_id = json['person_id'],
        timestamp = json['timestamp'],
        space_id = json['space_id'],
        rssi = json['rssi'];

  Map<String, dynamic> toJson() => {
    'rp':rp,
    'building_id': building_id,
    'floor_id': floor_id,
    'person_id': person_id,
    'timestamp': timestamp,
    'space_id': space_id,
    'rssi': rssi
  };
}

class RssiData {
  final int id;
  final String device;
  final Rssi rssi;

  RssiData(this.id, this.device, this.rssi);

  RssiData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        device = json['device'],
        rssi = json['data'];

  Map<String, dynamic> toJson() => {'id': id, 'device': device, 'data': rssi};
}
