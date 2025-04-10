class VpnInfo {
  late final String hostname;
  late final String ip;
  late final String ping;
  late final String countryLongName;
  late final String countryShortName;
  late final String vpnSessionNumber;
  late final String base64OpenVPNConfigurationData;

  VpnInfo({
    required this.hostname,
    required this.ip,
    required this.ping,
    required this.countryLongName,
    required this.countryShortName,
    required this.vpnSessionNumber,
    required this.base64OpenVPNConfigurationData,
  });

  VpnInfo.fromJson(Map<String, dynamic> jsonData) {
    hostname = jsonData['HostName'] ?? '';
    ip = jsonData['IP'] ?? '';
    ping = jsonData['Ping']?.toString() ?? '';
    countryLongName = jsonData['CountryLong'] ?? '';
    countryShortName = jsonData['CountryShort'] ?? '';
    vpnSessionNumber = jsonData['NumVpnSessions']?.toString() ?? '';
    base64OpenVPNConfigurationData =
        jsonData['OpenVPN_ConfigData_Base64'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final jsonData = <String, dynamic>{};
    jsonData['HostName'] = hostname;
    jsonData['IP'] = ip;
    jsonData['Ping'] = ping;
    jsonData['CountryLong'] = countryLongName;
    jsonData['CountryShort'] = countryShortName;
    jsonData['NumVpnSessions'] = vpnSessionNumber;
    jsonData['OpenVPN_ConfigData_Base64'] = base64OpenVPNConfigurationData;
    return jsonData;
  }
}
