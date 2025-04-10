import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_capstone/appPreferences/appPreferences.dart';
import 'package:vpn_capstone/vpnInfo/VpnInfo.dart';
import 'package:http/http.dart' as http;
import 'package:vpn_capstone/vpnInfo/ipInfo.dart';

class VpnApi {
  static Future<List<VpnInfo>> getVpnServers() async {
    final List<VpnInfo> vpnServerList = [];
    try {
      final apiResponse =
          await http.get(Uri.parse("http://www.vpngate.net/api/iphone"));
      final csvString = apiResponse.body.split("#")[1].replaceAll("*", "");
      List<List<dynamic>> listData =
          const CsvToListConverter().convert(csvString);
      final header = listData[0];
      for (int count = 1; count < listData.length - 1; count++) {
        Map<String, dynamic> jsonData = {};
        for (int counter = 0; counter < header.length; counter++) {
          jsonData
              .addAll({header[counter].toString(): listData[count][counter]});
        }
        vpnServerList.add(VpnInfo.fromJson(jsonData));
      }
    } catch (errorMsg) {
      Get.snackbar("Error", errorMsg.toString(),
          colorText: Colors.white, backgroundColor: Colors.red.withOpacity(.8));
    }
    vpnServerList.shuffle();
    if (vpnServerList.isNotEmpty) AppPreferences.vpnList = vpnServerList;
    return vpnServerList;
  }

  static Future<void> getIp({required Rx<IPInfo> ipInformation}) async {
    try {
      final apiResponse = await http.get(Uri.parse('http://ip-api.com/json/'));
      final apiData = jsonDecode(apiResponse.body);
      ipInformation.value = IPInfo.fromJson(apiData);
    } catch (errorMsg) {
      Get.snackbar("Error", errorMsg.toString(),
          colorText: Colors.black12, backgroundColor: Colors.red.withOpacity(.8));
    }
  }
}
