import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMapPin extends CustomPainter {
  final Color dotColor;
  final double pulse;

  CustomMapPin({
    required this.dotColor,
    this.pulse = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw outer pulse circle
    final pulseRadius = (20.0 * (1 + (pulse * 0.3)));
    final pulsePaint = Paint()
      ..color = dotColor.withOpacity(0.3 * (1 - pulse))
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(center, pulseRadius, pulsePaint);

    // Draw main dot
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8.0, dotPaint);

    // Draw inner dot
    final innerDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.0, innerDotPaint);
  }

  @override
  bool shouldRepaint(CustomMapPin oldDelegate) {
    return oldDelegate.pulse != pulse || oldDelegate.dotColor != dotColor;
  }

  Future<Uint8List> toBitmap() async {
    final RenderRepaintBoundary boundary = RenderRepaintBoundary();

    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);

    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }
}

Future<BitmapDescriptor> createCustomMarkerBitmap() async {
  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(pictureRecorder);
  final size = const Size(48, 48);

  CustomMapPin(
    dotColor: Colors.blue,
    pulse: 0.0,
  ).paint(canvas, size);

  final picture = pictureRecorder.endRecording();
  final image = await picture.toImage(
    size.width.toInt(),
    size.height.toInt(),
  );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
}
