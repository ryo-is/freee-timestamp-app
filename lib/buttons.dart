import 'package:flutter/material.dart';

class EnableButton extends StatelessWidget {
  final String text;
  final GestureTapCallback onPressed;
  const EnableButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: SizedBox(
          width: 180,
          height: 60,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(elevation: 0),
            child: Text(
              text,
              style: const TextStyle(fontSize: 18),
            ),
          )),
    );
  }
}

class DisableButton extends StatelessWidget {
  final String text;
  const DisableButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: SizedBox(
          width: 180,
          height: 60,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(elevation: 0),
            child: Text(
              text,
              style: const TextStyle(fontSize: 18),
            ),
          )),
    );
  }
}
