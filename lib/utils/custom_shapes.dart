import 'dart:math';

import 'package:flutter/material.dart';

class CustomRoundedSliderTrackShape extends RoundedRectSliderTrackShape with BaseSliderTrackShape {
  /// Create a slider track that draws two rectangles that combine with a rounded rectangle via their intersection.
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
    assert(context != null);
    assert(offset != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    assert(enableAnimation != null);
    assert(textDirection != null);
    assert(thumbCenter != null);
    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting  can be a no-op.
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    // Assign the track segment paints, which are leading: active and
    // trailing: inactive.
    final ColorTween activeTrackColorTween =
    ColorTween(begin: sliderTheme.disabledActiveTrackColor, end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween =
    ColorTween(begin: sliderTheme.disabledInactiveTrackColor, end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
    final Paint leftTrackPaint;
    final Paint rightTrackPaint;
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
      (textDirection == TextDirection.rtl) ? trackRect.top - (additionalActiveTrackHeight / 2) : trackRect.top,
      trackRect.right,
      (textDirection == TextDirection.rtl) ? trackRect.bottom + (additionalActiveTrackHeight / 2) : trackRect.bottom,
      topLeft: (textDirection == TextDirection.rtl) ? activeTrackRadius : trackRadius,
      bottomLeft: (textDirection == TextDirection.rtl) ? activeTrackRadius : trackRadius,
      topRight: (textDirection == TextDirection.rtl) ? activeTrackRadius : trackRadius,
      bottomRight: (textDirection == TextDirection.rtl) ? activeTrackRadius : trackRadius,
    );
    Rect leftRect = Rect.fromLTRB(
      trackRect.left,
      (textDirection == TextDirection.ltr) ? trackRect.top - (additionalActiveTrackHeight / 2) : trackRect.top,
      thumbCenter.dx,
      (textDirection == TextDirection.ltr) ? trackRect.bottom + (additionalActiveTrackHeight / 2) : trackRect.bottom,
    );
    Rect rightRect = Rect.fromLTRB(
      trackRect.right,
      (textDirection == TextDirection.ltr) ? trackRect.top - (additionalActiveTrackHeight / 2) : trackRect.top,
      thumbCenter.dx,
      (textDirection == TextDirection.ltr) ? trackRect.bottom + (additionalActiveTrackHeight / 2) : trackRect.bottom,
    );

    context.canvas.drawPath(
      Path.combine(
        PathOperation.intersect,
        Path()..addRect(leftRect),
        Path()..addRRect(trackRRect),
      ),
      leftTrackPaint,
    );

    context.canvas.drawPath(
      Path.combine(
        PathOperation.intersect,
        Path()..addRect(rightRect),
        Path()..addRRect(trackRRect),
      ),
      rightTrackPaint,
    );
  }

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    assert(isEnabled != null);
    assert(isDiscrete != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    final double trackHeight = sliderTheme.trackHeight!;
    assert(trackHeight >= 0);

    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackRight = trackLeft + parentBox.size.width;
    final double trackBottom = trackTop + trackHeight;
    // If the parentBox'size less than slider's size the trackRight will be less than trackLeft, so switch them.
    return Rect.fromLTRB(min(trackLeft, trackRight), trackTop, max(trackLeft, trackRight), trackBottom);
  }
}
