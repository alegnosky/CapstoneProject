import 'package:flutter/material.dart';
import 'package:vpn_capstone/main.dart';

class RoundWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final Widget roundWidget;

  const RoundWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.roundWidget,
  });

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    return SizedBox(
      width: screenSize.width * .46,
      child: Column(
        children: [
          roundWidget,
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          if (subTitle.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              subTitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}