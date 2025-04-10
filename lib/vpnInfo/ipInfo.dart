class IPInfo {
  late final String countryName;
  late final String cityName;
  late final String query;

  IPInfo(
      {required this.countryName,
      required this.cityName,
      required this.query,
      });

  IPInfo.fromJson(Map<String, dynamic> jsonData) {
    countryName = jsonData['country'] ?? '';
    cityName = jsonData['city'] ?? '';
    query = jsonData['query'] ?? 'Unavailable';
  }
}
