import 'dart:math' as dart_math;
import 'package:flutter/material.dart';
import '../../models/marker_detection.dart';

/// CustomPainter für die Darstellung von ArUco-Markern über der Kamera-Preview
class ArucoOverlayPainter extends CustomPainter {
  final List<MarkerDetection> detections;
  final bool showIds;
  final bool showCorners;
  final bool showPose;
  final Color markerColor;
  final Color idColor;
  final Color poseColor;
  final double strokeWidth;

  ArucoOverlayPainter({
    required this.detections,
    this.showIds = true,
    this.showCorners = true,
    this.showPose = false,
    this.markerColor = Colors.green,
    this.idColor = Colors.white,
    this.poseColor = Colors.red,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final detection in detections) {
      _drawMarker(canvas, size, detection);
    }
  }

  void _drawMarker(Canvas canvas, Size size, MarkerDetection detection) {
    if (detection.corners.length < 4) return;

    // Marker-Rahmen zeichnen
    if (showCorners) {
      _drawMarkerBounds(canvas, detection);
    }

    // Marker-ID zeichnen
    if (showIds) {
      _drawMarkerId(canvas, detection);
    }

    // Pose-Achsen zeichnen (falls verfügbar)
    if (showPose && detection.hasPose) {
      _drawPoseAxes(canvas, detection);
    }
  }

  void _drawMarkerBounds(Canvas canvas, MarkerDetection detection) {
    final paint = Paint()
      ..color = markerColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final corners = detection.corners;

    // Polygon der Marker-Ecken zeichnen
    path.moveTo(corners[0].dx, corners[0].dy);
    for (int i = 1; i < corners.length; i++) {
      path.lineTo(corners[i].dx, corners[i].dy);
    }
    path.close();

    canvas.drawPath(path, paint);

    // Ecken als kleine Kreise markieren
    final cornerPaint = Paint()
      ..color = markerColor
      ..style = PaintingStyle.fill;

    for (final corner in corners) {
      canvas.drawCircle(corner, 3.0, cornerPaint);
    }
  }

  void _drawMarkerId(Canvas canvas, MarkerDetection detection) {
    final center = detection.center;
    
    // Hintergrund für bessere Lesbarkeit
    final backgroundPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    final textSpan = TextSpan(
      text: 'ID: ${detection.id}',
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Hintergrund-Rechteck
    final bgRect = Rect.fromCenter(
      center: center,
      width: textPainter.width + 8,
      height: textPainter.height + 4,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      backgroundPaint,
    );

    // Text
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawPoseAxes(Canvas canvas, MarkerDetection detection) {
    if (!detection.hasPose) return;

    final center = detection.center;
    final axisLength = detection.averageSize * 0.3;

    // X-Achse (rot)
    _drawAxis(canvas, center, axisLength, 0, Colors.red);
    
    // Y-Achse (grün) 
    _drawAxis(canvas, center, axisLength, 90, Colors.green);
    
    // Z-Achse würde aus der Ebene herausragen, daher als Punkt dargestellt
    final zPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.0, zPaint);
  }

  void _drawAxis(Canvas canvas, Offset center, double length, double angleDegrees, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth + 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final angleRadians = angleDegrees * (3.14159 / 180);
    final endPoint = Offset(
      center.dx + length * cos(angleRadians),
      center.dy + length * sin(angleRadians),
    );

    canvas.drawLine(center, endPoint, paint);

    // Pfeilspitze
    final arrowLength = length * 0.2;
    final arrowAngle = 30 * (3.14159 / 180);
    
    final arrow1 = Offset(
      endPoint.dx - arrowLength * cos(angleRadians - arrowAngle),
      endPoint.dy - arrowLength * sin(angleRadians - arrowAngle),
    );
    
    final arrow2 = Offset(
      endPoint.dx - arrowLength * cos(angleRadians + arrowAngle),
      endPoint.dy - arrowLength * sin(angleRadians + arrowAngle),
    );

    canvas.drawLine(endPoint, arrow1, paint);
    canvas.drawLine(endPoint, arrow2, paint);
  }

  @override
  bool shouldRepaint(ArucoOverlayPainter oldDelegate) {
    return detections != oldDelegate.detections ||
           showIds != oldDelegate.showIds ||
           showCorners != oldDelegate.showCorners ||
           showPose != oldDelegate.showPose ||
           markerColor != oldDelegate.markerColor ||
           strokeWidth != oldDelegate.strokeWidth;
  }
}

/// Widget für das ArUco-Overlay über der Kamera-Preview
class ArucoOverlay extends StatelessWidget {
  final List<MarkerDetection> detections;
  final bool showIds;
  final bool showCorners;
  final bool showPose;
  final Color markerColor;
  final Color idColor;
  final Color poseColor;
  final double strokeWidth;

  const ArucoOverlay({
    super.key,
    required this.detections,
    this.showIds = true,
    this.showCorners = true,
    this.showPose = false,
    this.markerColor = Colors.green,
    this.idColor = Colors.white,
    this.poseColor = Colors.red,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ArucoOverlayPainter(
        detections: detections,
        showIds: showIds,
        showCorners: showCorners,
        showPose: showPose,
        markerColor: markerColor,
        idColor: idColor,
        poseColor: poseColor,
        strokeWidth: strokeWidth,
      ),
      child: Container(), // Transparent overlay
    );
  }
}

// Hilfsfunktionen für Trigonometrie
double cos(double radians) => dart_math.cos(radians);
double sin(double radians) => dart_math.sin(radians);
