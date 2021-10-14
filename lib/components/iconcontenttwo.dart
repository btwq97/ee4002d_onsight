import 'package:flutter/material.dart';

//use for widgets WITHOUT icon

class IconContentTwo extends StatelessWidget {

  IconContentTwo ({this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget> [
        SizedBox(
          height: 10.0,
        ),
        Text(
          label!,
          style: TextStyle(
            fontSize: 50.0,
            color: Color(0xFFFFFF00),
          ),
        ),
      ],
    );
  }
}