import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_capstone/appPreferences/appPreferences.dart';
import 'package:vpn_capstone/vpnCore/vpnCore.dart';
import 'package:vpn_capstone/vpnInfo/VpnConfig.dart';
import 'package:vpn_capstone/vpnInfo/VpnInfo.dart';

class HomeController extends GetxController {
  final Rx<VpnInfo> vpnInfo = AppPreferences.vpnInfo.obs;

  final vpnConnectionState = VpnCore.vpnDisconnected.obs;

  void connectVpn() async {
    if (vpnInfo.value.base64OpenVPNConfigurationData.isEmpty) {
      Get.snackbar("Location", "Select a location");
      return;
    }
    if (vpnConnectionState.value == VpnCore.vpnDisconnected) {
      final configData =
          Base64Decoder().convert(vpnInfo.value.base64OpenVPNConfigurationData);
      final configuration = Utf8Decoder().convert(configData);
      final vpnConfiguration = VpnConfig(
          username: "vpn",
          password: "vpn",
          countryName: vpnInfo.value.countryLongName,
          config: configuration);
      await VpnCore.startVpn(vpnConfiguration);
    } else {
      await VpnCore.stopVpn();
    }
  }

  Color get getButtonColor {
    if (vpnConnectionState.value case VpnCore.vpnDisconnected) {
      return Colors.blueGrey;
    } else if (vpnConnectionState.value case VpnCore.vpnConnected) {
      return Colors.blueGrey;
    } else {
      return Colors.white70;
    }
  }

  String get getButtonText {
    if (vpnConnectionState.value case VpnCore.vpnDisconnected) {
      return "Connect";
    } else if (vpnConnectionState.value case VpnCore.vpnConnected) {
      return "Disconnect";
    } else {
      return "Connecting";
    }
  }
}
