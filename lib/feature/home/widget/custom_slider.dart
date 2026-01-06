import 'package:flutter/material.dart';

class SquareSliderThumbShape extends SliderComponentShape {
  final double thumbSize;
  final double borderRadius;
  final double? thumbWidth;

  const SquareSliderThumbShape({
    this.thumbSize = 16.0,
    this.borderRadius = 2.0,
    this.thumbWidth,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbSize, thumbSize);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.white
      ..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: thumbWidth ?? thumbSize,
        height: thumbSize,
      ),
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(rect, paint);
  }
}
