import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_capstone/Controllers/HomeController.dart';
import 'package:vpn_capstone/appPreferences/appPreferences.dart';
import 'package:vpn_capstone/vpnCore/vpnCore.dart';
import 'package:vpn_capstone/vpnInfo/VpnInfo.dart';

class ServerLocationCard extends StatefulWidget {
  final VpnInfo vpnInfo;

  const ServerLocationCard({
    super.key,
    required this.vpnInfo,
  });

  @override
  _ServerLocationCardState createState() => _ServerLocationCardState();
}

class _ServerLocationCardState extends State<ServerLocationCard> {
  late HomeController _homeController;

  @override
  void initState() {
    super.initState();
    _homeController = Get.find<HomeController>();
  }

  Future<void> _connectToVpn() async {
    // Update selected VPN info
    _homeController.vpnInfo.value = widget.vpnInfo;
    AppPreferences.vpnInfo = widget.vpnInfo;

    // Return to home screen
    Get.back();

    // Handle connection state
    if (_homeController.vpnConnectionState.value == VpnCore.vpnConnected) {
      await VpnCore.stopVpn();
      Future.delayed(
          const Duration(seconds: 5),
              () => _homeController.connectVpn()
      );
    } else {
      _homeController.connectVpn();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: screenSize.height * .01),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: _connectToVpn,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            widget.vpnInfo.countryLongName,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: _buildUserCount(),
        ),
      ),
    );
  }

  Widget _buildUserCount() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.vpnInfo.vpnSessionNumber.toString(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          CupertinoIcons.person_2_alt,
          color: Colors.blueGrey,
        ),
      ],
    );
  }
}