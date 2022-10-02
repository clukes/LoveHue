import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/colors.dart';

/// Rounded [OutlinedButton] with [blueColor].
class StyledButton extends StatelessWidget {
  const StyledButton({Key? key, required this.child, required this.onPressed})
      : super(key: key);
  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          backgroundColor: blueColor,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4))),
        ),
        onPressed: onPressed,
        child: child,
      );
}

/// Circle shaped [Container] that blurs the backdrop behind it, and contains [child].
///
/// Useful for blurring behind a [FloatingActionButton].
class BlurredCircle extends StatelessWidget {
  /// Widget to place in the container.
  final Widget? child;

  const BlurredCircle({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
        child: child,
      ),
    );
  }
}
