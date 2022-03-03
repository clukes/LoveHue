import 'package:flutter/material.dart';

/// Heading text with padding and default fontSize.
class Header extends StatelessWidget {
  const Header({Key? key, required this.heading}) : super(key: key);
  final String heading;
  final double fontSize = 20;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          heading,
          style: TextStyle(fontSize: fontSize),
        ),
      );
}
