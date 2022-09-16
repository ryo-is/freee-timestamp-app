import 'package:flutter/material.dart';

class EnableButton extends StatelessWidget {
  final String text;
  final GestureTapCallback onPressed;
  final Color color;
  const EnableButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: SizedBox(
          width: 180,
          height: 60,
          child: ElevatedButton(
            onPressed: onPressed,
            style:
                ElevatedButton.styleFrom(elevation: 0, backgroundColor: color),
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

class OutlinedButtonContainer extends StatelessWidget {
  final String text;
  final GestureTapCallback onPressed;
  final Color color;
  const OutlinedButtonContainer(
      {super.key,
      required this.text,
      required this.onPressed,
      this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: SizedBox(
          width: 180,
          height: 60,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
                elevation: 0, side: BorderSide(color: color)),
            child: Text(
              text,
              style: TextStyle(fontSize: 18, color: color),
            ),
          )),
    );
  }
}
