import 'package:flutter/material.dart';
import 'package:vpn_capstone/main.dart';
import 'package:vpn_capstone/vpnInfo/networkInfo.dart';

class IPCard extends StatelessWidget {
  final NetworkIP networkInfo;

  const IPCard({
    super.key,
    required this.networkInfo,
  });

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: screenSize.height * .01),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        leading: Icon(
          networkInfo.iconData.icon,
          size: networkInfo.iconData.size ?? 24,
          color: Colors.blueGrey,
        ),
        title: Text(
          networkInfo.title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          networkInfo.subTitle,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}