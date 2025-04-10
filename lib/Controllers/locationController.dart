import 'package:get/get.dart';
import 'package:vpn_capstone/appPreferences/appPreferences.dart';
import 'package:vpn_capstone/vpnAPI/vpnAPI.dart';
import 'package:vpn_capstone/vpnInfo/VpnInfo.dart';

class LocationController extends GetxController {
  List<VpnInfo> vpnServers = AppPreferences.vpnList;
  final RxBool isLoadingServers = false.obs;
  Future<void> retrieveInformation() async {
    isLoadingServers.value = true;
    vpnServers.clear();
    vpnServers = await VpnApi.getVpnServers();
    isLoadingServers.value = false;
  }
}
