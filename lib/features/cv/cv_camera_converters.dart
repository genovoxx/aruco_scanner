// lib/cv_camera_converters.dart
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

/// Wandelt ein CameraImage in ein OpenCV Mat (Graustufen) um.
/// - Android (YUV_420_888): nutzt Y-Plane (1 Kanal, CV_8UC1)
/// - iOS (BGRA8888): wandelt BGRA -> GRAY
/// Optionale Orientierungskorrektur (0/90/180/270) und Spiegelung (Frontcam).
cv.Mat cameraImageToGrayMat(
  CameraImage image, {
  int rotationDegrees = 0,
  bool mirror = false,
}) {
  cv.Mat gray;

  if (image.format.group == ImageFormatGroup.yuv420) {
    // --- Android Pfad: Y aus YUV420 sauber entpacken (RowStride beachten) ---
    final yPlane = image.planes[0];
    final w = image.width;
    final h = image.height;
    final yStr = yPlane.bytesPerRow;

    // Falls RowStride == width und PixelStride == 1, können wir direkt nehmen.
    if (yStr == w) {
      gray = cv.Mat.fromList(h, w, cv.MatType.CV_8UC1, yPlane.bytes);
    } else {
      // Zeilenweise kopieren und dabei Stride ignorieren
      final packed = Uint8List(w * h);
      final src = yPlane.bytes;
      var dstOff = 0;
      for (var r = 0; r < h; r++) {
        final sOff = r * yStr;
        packed.setRange(dstOff, dstOff + w, src.sublist(sOff, sOff + w));
        dstOff += w;
      }
      gray = cv.Mat.fromList(h, w, cv.MatType.CV_8UC1, packed);
    }
  } else if (image.format.group == ImageFormatGroup.bgra8888) {
    // --- iOS Pfad: BGRA -> GRAY ---
    final w = image.width;
    final h = image.height;
    final plane = image.planes[0];
    final rowStride = plane.bytesPerRow;
    final expected = w * 4;

    Uint8List packed;
    if (rowStride == expected) {
      packed = plane.bytes; // bereits dicht gepackt
    } else {
      // jede Zeile komprimieren (RowStride -> w*4)
      packed = Uint8List(h * expected);
      var dst = 0;
      final src = plane.bytes;
      for (var r = 0; r < h; r++) {
        final s = r * rowStride;
        packed.setRange(dst, dst + expected, src.sublist(s, s + expected));
        dst += expected;
      }
    }

    final bgra = cv.Mat.fromList(h, w, cv.MatType.CV_8UC4, packed);
    final g = cv.cvtColor(bgra, cv.COLOR_BGRA2GRAY); // -> 1 Kanal
    bgra.dispose();
    gray = g;
  } else {
    throw UnsupportedError(
      'Nicht unterstütztes Kamerapixel-Format: ${image.format.group}',
    );
  }

  // Orientierung/Spiegelung anwenden
  final out = _applyOrientation(
    gray,
    rotationDegrees: rotationDegrees,
    mirror: mirror,
  );
  if (!identical(out, gray)) {
    gray.dispose();
  }
  return out;
}

/// Wandelt ein CameraImage in ein OpenCV Mat (RGB, 3 Kanäle) um.
/// Android: YUV420 -> NV21-Buffer bauen -> COLOR_YUV2RGB_NV21
/// iOS: BGRA -> RGB
cv.Mat cameraImageToRgbMat(
  CameraImage image, {
  int rotationDegrees = 0,
  bool mirror = false,
}) {
  cv.Mat rgb;

  if (image.format.group == ImageFormatGroup.yuv420) {
    final w = image.width;
    final h = image.height;

    // --- Y packen ---
    final yPlane = image.planes[0];
    final yStride = yPlane.bytesPerRow;
    final yPacked = Uint8List(w * h);
    var yDst = 0;
    for (var r = 0; r < h; r++) {
      final s = r * yStride;
      yPacked.setRange(yDst, yDst + w, yPlane.bytes.sublist(s, s + w));
      yDst += w;
    }

    // --- UV interleaved als NV21 (VU) packen ---
    // In Camera (Android) sind plane[1]=U(Cb), plane[2]=V(Cr) getrennt (4:2:0, half-res)
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];
    final uvW = w ~/ 2;
    final uvH = h ~/ 2;

    final uStride = uPlane.bytesPerRow;
    final vStride = vPlane.bytesPerRow;

    final uPixStride = uPlane.bytesPerPixel ?? 1; // oft 2
    final vPixStride = vPlane.bytesPerPixel ?? 1;

    // NV21 hat pro UV-Zeile w Bytes (VU VU VU ...), in Summe h/2 Zeilen
    final uvPacked = Uint8List(w * uvH);
    for (var r = 0; r < uvH; r++) {
      final uBase = r * uStride;
      final vBase = r * vStride;
      var uvColOff = r * w; // Ziel-Offset in der Interleave-Zeile
      for (var c = 0; c < uvW; c++) {
        final u = uPlane.bytes[uBase + c * uPixStride];
        final v = vPlane.bytes[vBase + c * vPixStride];
        // NV21 = V dann U
        uvPacked[uvColOff] = v;
        uvPacked[uvColOff + 1] = u;
        uvColOff += 2;
      }
    }

    // --- Full NV21 Puffer: Y gefolgt von interleaved VU ---
    final yuv = Uint8List(yPacked.length + uvPacked.length)
      ..setAll(0, yPacked)
      ..setAll(yPacked.length, uvPacked);

    // OpenCV erwartet (h + h/2) x w mit 1 Kanal für NV21
    final yuvMat = cv.Mat.fromList(h + uvH, w, cv.MatType.CV_8UC1, yuv);
    final r = cv.cvtColor(yuvMat, cv.COLOR_YUV2RGB_NV21); // -> 3 Kanäle (RGB)
    yuvMat.dispose();
    rgb = r;
  } else if (image.format.group == ImageFormatGroup.bgra8888) {
    final w = image.width;
    final h = image.height;
    final plane = image.planes[0];
    final rowStride = plane.bytesPerRow;
    final expected = w * 4;

    Uint8List packed;
    if (rowStride == expected) {
      packed = plane.bytes;
    } else {
      packed = Uint8List(h * expected);
      var dst = 0;
      final src = plane.bytes;
      for (var r = 0; r < h; r++) {
        final s = r * rowStride;
        packed.setRange(dst, dst + expected, src.sublist(s, s + expected));
        dst += expected;
      }
    }

    final bgra = cv.Mat.fromList(h, w, cv.MatType.CV_8UC4, packed);
    final r = cv.cvtColor(bgra, cv.COLOR_BGRA2RGB);
    bgra.dispose();
    rgb = r;
  } else {
    throw UnsupportedError(
      'Nicht unterstütztes Kamerapixel-Format: ${image.format.group}',
    );
  }

  final out = _applyOrientation(
    rgb,
    rotationDegrees: rotationDegrees,
    mirror: mirror,
  );
  if (!identical(out, rgb)) {
    rgb.dispose();
  }
  return out;
}

/// Orientierung & Spiegelung anwenden (in-place sicher maskiert).
cv.Mat _applyOrientation(
  cv.Mat src, {
  required int rotationDegrees,
  required bool mirror,
}) {
  cv.Mat rotated = src;
  switch (rotationDegrees % 360) {
    case 90:
      rotated = cv.rotate(src, cv.ROTATE_90_CLOCKWISE);
      break;
    case 180:
      rotated = cv.rotate(src, cv.ROTATE_180);
      break;
    case 270:
      rotated = cv.rotate(src, cv.ROTATE_90_COUNTERCLOCKWISE);
      break;
    default:
      rotated = src;
  }
  if (mirror) {
    final flipped = cv.flip(rotated, 1); // horizontal spiegeln
    if (!identical(rotated, src)) rotated.dispose();
    rotated = flipped;
  }
  return rotated;
}
