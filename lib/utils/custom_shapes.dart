import 'dart:math';

import 'package:flutter/material.dart';

/// Create a slider track that draws two rectangles that combine with a rounded rectangle via their intersection.
///
/// Fixes the issue where a rounded rectangle track without a thumb ends up with flat edges when full/empty.
class CustomRoundedSliderTrackShape extends RoundedRectSliderTrackShape with BaseSliderTrackShape {
  const CustomRoundedSliderTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    assert(sliderTheme.trackHeight != null);
    if (sliderTheme.trackHeight! <= 0) {
      // Don't need to paint if trackHeight is <= 0.
      return;
    }

    final ColorTween activeTrackColorTween =
        ColorTween(begin: sliderTheme.disabledActiveTrackColor, end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween =
        ColorTween(begin: sliderTheme.disabledInactiveTrackColor, end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation)!;

    final Paint leftTrackPaint;
    final Paint rightTrackPaint;
    // Switch the left and right depending on text direction.
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final Radius trackRadius = Radius.circular(trackRect.height / 2);
    final Radius activeTrackRadius = Radius.circular((trackRect.height + additionalActiveTrackHeight) / 2);

    // Uses a Rounded Rectangle that covers the whole track to combine with left and right rects via intersection.
    RRect trackRRect = RRect.fromLTRBAndCorners(
      trackRect.left,
      trackRect.top + (additionalActiveTrackHeight / 2),
      trackRect.right,
      trackRect.bottom + (additionalActiveTrackHeight / 2),
      topLeft: (textDirection == TextDirection.rtl) ? activeTrackRadius : trackRadius,
      bottomLeft: (textDirection == TextDirection.rtl) ? activeTrackRadius : trackRadius,
      topRight: (textDirection == TextDirection.rtl) ? activeTrackRadius : trackRadius,
      bottomRight: (textDirection == TextDirection.rtl) ? activeTrackRadius : trackRadius,
    );

    RRect leftRect = RRect.fromLTRBAndCorners(
      trackRect.left,
      (textDirection == TextDirection.ltr) ? trackRect.top - (additionalActiveTrackHeight / 2) : trackRect.top,
      thumbCenter.dx,
      (textDirection == TextDirection.ltr) ? trackRect.bottom + (additionalActiveTrackHeight / 2) : trackRect.bottom,
      topLeft: (textDirection == TextDirection.rtl) ? activeTrackRadius : trackRadius,
      bottomLeft: (textDirection == TextDirection.rtl) ? activeTrackRadius : trackRadius,
    );
    RRect rightRect = RRect.fromLTRBAndCorners(
      trackRect.right,
      (textDirection == TextDirection.ltr) ? trackRect.top - (additionalActiveTrackHeight / 2) : trackRect.top,
      thumbCenter.dx,
      (textDirection == TextDirection.ltr) ? trackRect.bottom + (additionalActiveTrackHeight / 2) : trackRect.bottom,
      topRight: (textDirection == TextDirection.rtl) ? activeTrackRadius : trackRadius,
      bottomRight: (textDirection == TextDirection.rtl) ? activeTrackRadius : trackRadius,
    );

    if (thumbCenter.dx >= trackRect.right - trackRadius.x || thumbCenter.dx <= trackRect.left + trackRadius.x) {
      // If we get near the end of the track,
      // we need to intersect the trackRRect with left and right to prevent flat edges.
      context.canvas.drawPath(
        Path.combine(
          PathOperation.intersect,
          Path()..addRRect(leftRect),
          Path()..addRRect(trackRRect),
        ),
        leftTrackPaint,
      );
      context.canvas.drawPath(
        Path.combine(
          PathOperation.intersect,
          Path()..addRRect(rightRect),
          Path()..addRRect(trackRRect),
        ),
        rightTrackPaint,
      );
    } else {
      context.canvas.drawRRect(leftRect, leftTrackPaint);
      context.canvas.drawRRect(rightRect, rightTrackPaint);
    }
  }

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    assert(trackHeight >= 0);

    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackRight = trackLeft + parentBox.size.width;
    final double trackBottom = trackTop + trackHeight;
    // If the parentBox's size is less than slider's size the trackRight will be less than trackLeft, so switch them.
    return Rect.fromLTRB(min(trackLeft, trackRight), trackTop, max(trackLeft, trackRight), trackBottom);
  }
}
