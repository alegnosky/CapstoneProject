import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_capstone/Controllers/locationController.dart';
import 'package:vpn_capstone/Widgets/serverCard.dart';

class ServerList extends StatelessWidget {
  ServerList({super.key});

  final _locationController = LocationController();

  @override
  Widget build(BuildContext context) {
    if (_locationController.vpnServers.isEmpty) {
      _locationController.retrieveInformation();
    }

    return Obx(() => Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    ));
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blueGrey,
      title: Text(
        "VPN Servers (${_locationController.vpnServers.length})",
      ),
      actions: [
        IconButton(
          onPressed: _locationController.retrieveInformation,
          icon: const Icon(Icons.refresh),
        )
      ],
    );
  }

  Widget _buildBody() {
    if (_locationController.isLoadingServers.value) {
      return _buildLoadingUI();
    } else if (_locationController.vpnServers.isEmpty) {
      return _buildEmptyUI();
    } else {
      return _buildServerList();
    }
  }

  Widget _buildLoadingUI() {
    return const SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
          ),
          SizedBox(height: 8),
          Text(
            "Gathering VPN Servers",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black45,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyUI() {
    return const Center(
      child: Text(
        "No Servers Found",
        style: TextStyle(
          fontSize: 16,
          color: Colors.black45,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildServerList() {
    return ListView.builder(
      itemCount: _locationController.vpnServers.length,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(3),
      itemBuilder: (context, index) {
        return ServerLocationCard(
          vpnInfo: _locationController.vpnServers[index],
        );
      },
    );
  }
}