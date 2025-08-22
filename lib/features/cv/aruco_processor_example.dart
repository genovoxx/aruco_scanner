// Beispiel: in deinem ImageStream-Callback
// (controller.startImageStream((CameraImage image) async { ... }))
import 'package:camera/camera.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'cv_camera_converters.dart';

class ArucoProcessor {
  late final cv.ArucoDictionary _dict;
  late final cv.ArucoDetector _detector;

  void initAruco() {
    _dict = cv.ArucoDictionary.predefined(
      cv.PredefinedDictionaryType.DICT_4X4_50,
    );
    final params = cv.ArucoDetectorParameters.empty();
    // ggf. Parameter tunen (minDistance, thresholds, ...)
    _detector = cv.ArucoDetector.create(_dict, params);
  }

  void dispose() {
    _detector.dispose();
    _dict.dispose();
  }

  void onCameraImage(
    CameraImage image, {
    required bool isFront,
    required int sensorRotation,
  }) {
    // Für Erkennung reicht Graustufe (schneller):
    final gray = cameraImageToGrayMat(
      image,
      rotationDegrees: sensorRotation,
      mirror: isFront,
    );

    final result = _detector.detectMarkers(gray);
    final ids = result.$2; // VecI32

    // Beispiel: Anzahl & evtl. IDs loggen
    final count = ids.length;
    // ids[i] per Index zugreifbar; toList() je nach Version verfügbar.
    print('Aruco markers: $count');

    gray.dispose();
  }
}
