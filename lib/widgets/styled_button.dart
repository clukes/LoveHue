import 'package:flutter/material.dart';
import 'package:relationship_bars/utils/colors.dart';

class StyledButton extends StatelessWidget {
  const StyledButton({Key? key, required this.child, required this.onPressed}) : super(key: key);
  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        style: OutlinedButton.styleFrom(
            primary: primaryColor,
            backgroundColor: blueColor,
            // side: const BorderSide(color: Colors.deepPurple),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)))),
        onPressed: onPressed,
        child: child,
      );
}
