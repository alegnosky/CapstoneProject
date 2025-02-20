class connectionStatus {
  String? byteIn;
  String? byteOut;
  String? durationTime;
  String? lastPacketReceived;

  connectionStatus({
    this.byteIn,
    this.byteOut,
    this.durationTime,
    this.lastPacketReceived,
  });
  factory connectionStatus.fromJson(Map<String, dynamic> jsonData) =>
      connectionStatus(
          byteIn: jsonData['byte_in'],
          byteOut: jsonData['byte_out'],
          durationTime: jsonData['duration'],
          lastPacketReceived: jsonData['last_packet_receive']);
  Map<String, dynamic> toJson() => {
        'byte_in': byteIn,
        'byte_out': byteOut,
        'duration': durationTime,
        'last_packet_receive': lastPacketReceived
      };
}
