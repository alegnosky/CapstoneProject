import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_capstone/Controllers/HomeController.dart';
import 'package:vpn_capstone/Screens/PasswordManagementScreen.dart';
import 'package:vpn_capstone/Screens/serverList.dart';
import 'package:vpn_capstone/Widgets/ipCard.dart';
import 'package:vpn_capstone/appPreferences/appPreferences.dart';
import 'package:vpn_capstone/main.dart';
import 'package:vpn_capstone/vpnCore/vpnCore.dart';
import 'package:vpn_capstone/vpnInfo/ipInfo.dart';
import 'package:vpn_capstone/vpnAPI/vpnAPI.dart';
import 'package:vpn_capstone/vpnInfo/networkInfo.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _homeController = Get.put(HomeController());
  final _ipInfo = IPInfo.fromJson({}).obs;

  @override
  Widget build(BuildContext context) {
    VpnCore.vpnStageSnapshot().listen((event) {
      _homeController.vpnConnectionState.value = event;

      if (event == VpnCore.vpnConnected || event == VpnCore.vpnNotConnected) {
        Future.delayed(Duration(seconds: 5), () {
          VpnApi.getIp(ipInformation: _ipInfo);
        });
      }
    });

    VpnApi.getIp(ipInformation: _ipInfo);

    screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: _buildAppBar(),
      bottomNavigationBar: _buildBottomNavigation(context),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blueGrey,
      title: const Text("Android Security Suite"),
      leading: IconButton(
        onPressed: () => Get.to(() => PasswordManagementScreen()),
        icon: const Icon(Icons.password),
      ),
      actions: [
        IconButton(
          onPressed: _toggleTheme,
          icon: const Icon(Icons.brightness_2_sharp),
        ),
      ],
    );
  }

  void _toggleTheme() {
    Get.changeThemeMode(
        AppPreferences.darkMode ? ThemeMode.light : ThemeMode.dark);
    AppPreferences.darkMode = !AppPreferences.darkMode;
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return SafeArea(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: () => Get.to(() => ServerList()),
          child: Container(
            color: Colors.blueGrey,
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * .04),
            height: 60,
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.flag_circle,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 12),
                const Text(
                  "Server Selection",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildVpnSection(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Divider(thickness: 1),
          ),
          _buildNetworkSection(),
        ],
      ),
    );
  }

  Widget _buildVpnSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              "VPN Connection",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildVpnButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildVpnButton() {
    return Obx(() => Semantics(
          button: true,
          child: InkWell(
            onTap: _homeController.connectVpn,
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: screenSize.height * .16,
              height: screenSize.height * .16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _homeController.getButtonColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.power_settings_new,
                    size: 30,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _homeController.getButtonText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildNetworkSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              "Network Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Obx(() => Column(
                children: [
                  _buildNetworkInfoCard(
                    title: "IP Address",
                    subtitle: _ipInfo.value.query,
                    icon: Icons.my_location,
                  ),
                  _buildNetworkInfoCard(
                    title: "City",
                    subtitle: _ipInfo.value.cityName,
                    icon: Icons.location_city,
                  ),
                  _buildNetworkInfoCard(
                    title: "Country",
                    subtitle: _ipInfo.value.countryName,
                    icon: Icons.flag,
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildNetworkInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Obx(() => IPCard(
          networkInfo: NetworkIP(
            title: title,
            subTitle: _homeController.vpnConnectionState.value ==
                    VpnCore.vpnConnecting
                ? "Updating"
                : subtitle,
            iconData: Icon(icon),
          ),
        ));
  }
}
