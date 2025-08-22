import 'package:camera/camera.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

/// DEPRECATED: Diese Implementierung wurde durch cv_camera_converters.dart ersetzt.
///
/// Verwende stattdessen:
/// - cameraImageToGrayMat() für Graustufen-Konvertierung
/// - cameraImageToRgbMat() für RGB-Konvertierung
/// - Beide mit row stride Behandlung und Orientierungskorrektur
///
/// Siehe: cv_camera_converters.dart und aruco_processor_example.dart
class ImageConverter {
  /// DEPRECATED: Verwende cameraImageToGrayMat() aus cv_camera_converters.dart
  @deprecated
  static cv.Mat? cameraImageToGrayMat(CameraImage image) {
    // Robuste Implementierung in cv_camera_converters.dart verfügbar
    throw UnimplementedError(
      'Diese Methode ist deprecated. Verwende cameraImageToGrayMat() aus cv_camera_converters.dart',
    );
  }

  /// Demonstriert die Verwendung der opencv_dart ArUco API
  static Future<void> demonstrateArucoAPI() async {
    try {
      // Dictionary erstellen
      final dictionary = cv.ArucoDictionary.predefined(
        cv.PredefinedDictionaryType.DICT_4X4_50,
      );

      // Detector-Parameter
      final params = cv.ArucoDetectorParameters.empty();

      // Detector erstellen
      final detector = cv.ArucoDetector.create(dictionary, params);

      print('ArUco Detector erfolgreich erstellt');

      // Cleanup
      detector.dispose();
      params.dispose();
      dictionary.dispose();
    } catch (e) {
      print('Fehler bei ArUco API Demo: $e');
    }
  }

  /// Erstellt ein Demo-Mat für Testzwecke
  static cv.Mat? createDemoMat() {
    try {
      // Erstelle ein 640x480 Graustufen-Bild
      final mat = cv.Mat.zeros(480, 640, cv.MatType.CV_8UC1);

      print('Demo Mat erstellt: ${mat.rows}x${mat.cols}');
      return mat;
    } catch (e) {
      print('Fehler beim Erstellen des Demo Mat: $e');
      return null;
    }
  }
}

/// MIGRATION GUIDE:
/// 
/// Alte Verwendung:
/// ```dart
/// final mat = ImageConverter.yPlaneToMat(image);
/// ```
/// 
/// Neue Verwendung:
/// ```dart
/// import 'cv_camera_converters.dart';
/// 
/// final mat = cameraImageToGrayMat(
///   image,
///   rotationDegrees: sensorOrientation,
///   mirror: isFrontCamera,
/// );
/// ```
/// 
/// Features der neuen Implementierung:
/// - ✅ Row stride Behandlung für YUV420 und BGRA8888
/// - ✅ Block-Kopien ohne per-Pixel-Schleifen
/// - ✅ Orientierungskorrektur (0/90/180/270°)
/// - ✅ Frontkamera-Spiegelung
/// - ✅ Assertions für Input-Validierung
/// - ✅ Sauberes Memory Management (dispose)
/// - ✅ Unterstützung für NV21, YUV420, BGRA8888
/// - ✅ RGB-Konvertierung via NV21-Buffer
