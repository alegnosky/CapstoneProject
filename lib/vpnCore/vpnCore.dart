import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:vpn_capstone/vpnInfo/VpnConfig.dart';
import 'package:vpn_capstone/vpnInfo/connectionStatus.dart';

class VpnCore {
  static final String eventChannelVpnStage = "vpnStage";
  static final String eventChannelVpnStatus = "vpnStatus";
  static final String methodChannelVpnControl = "vpnControl";

  static Stream<String> vpnStageSnapshot() =>
      EventChannel(eventChannelVpnStage).receiveBroadcastStream().cast();
  static Stream<connectionStatus?> connectionStatusSnapshot() => EventChannel(
          eventChannelVpnStatus)
      .receiveBroadcastStream()
      .map((eventStatus) => connectionStatus.fromJson(jsonDecode(eventStatus)))
      .cast();

  static Future<void> startVpn(VpnConfig vpnConfig) {
    return MethodChannel(methodChannelVpnControl).invokeMethod(
      "start",
      {
        "config": vpnConfig.config,
        "country": vpnConfig.countryName,
        "username": vpnConfig.username,
        "password": vpnConfig.password
      },
    );
  }

  static Future<void> stopVpn() {
    return MethodChannel(methodChannelVpnControl).invokeMethod("stop");
  }

  static Future<void> killSwitch() {
    return MethodChannel(methodChannelVpnControl).invokeMethod("kill_switch");
  }

  static Future<void> refreshStage() {
    return MethodChannel(methodChannelVpnControl).invokeMethod("refresh");
  }

  static Future<String?> getStage() {
    return MethodChannel(methodChannelVpnControl).invokeMethod("stage");
  }

  static Future<bool> isConnected() {
    return getStage()
        .then((valueStage) => valueStage!.toLowerCase() == "connected");
  }

  static const String vpnConnected = "connected";
  static const String vpnDisconnected = "disconnected";
  static const String vpnWaitConnection = "wait_connection";
  static const String vpnAuthenticating = "authenticating";
  static const String vpnReconnect = "reconnect";
  static const String vpnNotConnected = "no_connection";
  static const String vpnConnecting = "connecting";
  static const String vpnPreparing = "prepare";
  static const String vpnDenied = "denied";
}
