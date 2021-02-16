/// LogData
class LogData {
  /// name
  String name;

  /// room
  String room;

  /// timestamp
  String timestamp;

  /// LogData
  LogData({this.name, this.room, this.timestamp});

  /// fromJSON
  factory LogData.fromJSON(Map<String, dynamic> json) {
    return LogData(
        // name: json['name'] as String,
        // room: json['room'] as String,
        // timestamp: json['timestamp'] as String
        name: "$json['name']",
        room: "$json['room]",
        timestamp: "$json['timestamp]");
  }

  /// toJson
  Map toJson() => {'name': name, 'room': room, 'timestamp': timestamp};

  @override
  String toString() =>
      'LogData: {name: $name, room: $room, timestamp: $timestamp}';
}
