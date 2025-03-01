import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vpn_capstone/vpnInfo/VpnInfo.dart';

class AppPreferences {
  static late Box dataBox;
  static final ValueNotifier<bool> darkModeNotifier = ValueNotifier(false);

  static Future<void> initHive() async {
    await Hive.initFlutter();
    dataBox = await Hive.openBox("data");
    darkModeNotifier.value = dataBox.get("darkMode") ?? false;
  }

  static bool get darkMode => darkModeNotifier.value;

  static set darkMode(bool value) {
    dataBox.put("darkMode", value);
    darkModeNotifier.value = value;
  }

  static VpnInfo get vpnInfo =>
      VpnInfo.fromJson(jsonDecode(dataBox.get("vpn") ?? '{}'));

  static set vpnInfo(VpnInfo value) =>
      dataBox.put("vpn", jsonEncode(value));

  static List<VpnInfo> get vpnList {
    List<VpnInfo> tempList = [];
    final vpnData = jsonDecode(dataBox.get("vpnList") ?? '[]');
    for (var data in vpnData) {
      tempList.add(VpnInfo.fromJson(data));
    }
    return tempList;
  }

  static set vpnList(List<VpnInfo> valueList) =>
      dataBox.put("vpnList", jsonEncode(valueList));
}
