import 'package:flutter/material.dart';

class UserInfoBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? bgColor;

  const UserInfoBox(
      {super.key,
      required this.label,
      required this.value,
      this.bgColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 8, right: 8),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
