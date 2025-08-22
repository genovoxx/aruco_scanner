import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../../models/marker_detection.dart';
import '../../models/aruco_settings.dart';

/// Service für OpenCV ArUco-Erkennung mit opencv_dart
class CvService {
  bool _isInitialized = false;
  ArucoDictionary _currentDictionary = ArucoDictionary.dict4x4_50;
  PerformanceSettings _performanceSettings = PerformanceSettings.balanced;

  // OpenCV Objekte
  cv.ArucoDictionary? _dictionary;
  cv.ArucoDetectorParameters? _detectorParams;
  cv.ArucoDetector? _detector;

  // Performance-Tracking - entfernt da nicht mehr für kontinuierliche Verarbeitung gebraucht

  /// Ist der Service initialisiert?
  bool get isInitialized => _isInitialized;

  /// Aktuelles Dictionary
  ArucoDictionary get currentDictionary => _currentDictionary;

  /// Aktuelle Performance-Einstellungen
  PerformanceSettings get performanceSettings => _performanceSettings;

  /// Initialisiert den CV Service
  Future<bool> init({
    ArucoDictionary dictionary = ArucoDictionary.dict4x4_50,
    PerformanceSettings? settings,
  }) async {
    try {
      _currentDictionary = dictionary;
      _performanceSettings = settings ?? PerformanceSettings.balanced;

      // ArUco Dictionary erstellen
      _dictionary = cv.ArucoDictionary.predefined(
        _currentDictionary.predefinedType,
      );

      // Detector Parameter erstellen (Standard-Parameter)
      _detectorParams = cv.ArucoDetectorParameters.empty();

      // ArUco Detector erstellen
      _detector = cv.ArucoDetector.create(_dictionary!, _detectorParams!);

      _isInitialized = true;
      print(
        'CV Service erfolgreich initialisiert mit Dictionary: ${dictionary.displayName}',
      );
      return true;
    } catch (e) {
      print('Fehler bei CV Service Initialisierung: $e');
      return false;
    }
  }

  /// Erkennt ArUco-Marker in einem aufgenommenen Bild (aus Bytes)
  Future<List<MarkerDetection>> detectMarkersFromImageBytes(
    Uint8List imageBytes,
  ) async {
    if (!_isInitialized || _detector == null) return [];

    try {
      // JPEG/PNG-Bytes in OpenCV Mat laden
      final mat = cv.imdecode(imageBytes, cv.IMREAD_COLOR);
      if (mat.isEmpty) {
        print('Konnte Bild nicht laden');
        return [];
      }

      // Zu Graustufen konvertieren für ArUco-Erkennung
      final grayMat = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);

      // ArUco-Marker erkennen
      final result = _detector!.detectMarkers(grayMat);
      final corners = result.$1; // VecVecPoint2f
      final ids = result.$2; // VecI32

      final detections = <MarkerDetection>[];

      // Erkennungen verarbeiten
      if (ids.isNotEmpty) {
        for (int i = 0; i < ids.length; i++) {
          final markerId = ids[i];
          final markerCorners = corners[i];

          // Ecken aus OpenCV in Flutter-Koordinaten konvertieren
          final cornerPoints = <Offset>[];
          for (int j = 0; j < markerCorners.length; j++) {
            final point = markerCorners[j];
            cornerPoints.add(Offset(point.x, point.y));
          }

          if (cornerPoints.length == 4) {
            detections.add(
              MarkerDetection(
                id: markerId,
                corners: cornerPoints,
                confidence:
                    1.0, // opencv_dart gibt derzeit keine Konfidenz zurück
              ),
            );
          }
        }
      }

      // Speicher freigeben
      mat.dispose();
      grayMat.dispose();

      print(
        'ArUco-Erkennung abgeschlossen: ${detections.length} Marker gefunden',
      );
      return detections;
    } catch (e) {
      print('Fehler bei ArUco-Erkennung aus Bytes: $e');
      return [];
    }
  }

  /// Ändert das ArUco-Dictionary
  Future<bool> changeDictionary(ArucoDictionary dictionary) async {
    if (!_isInitialized) return false;

    try {
      _currentDictionary = dictionary;

      // Neues Dictionary und Detector erstellen
      _dictionary?.dispose();
      _detector?.dispose();

      _dictionary = cv.ArucoDictionary.predefined(dictionary.predefinedType);
      _detector = cv.ArucoDetector.create(_dictionary!, _detectorParams!);

      print('Dictionary geändert zu: ${dictionary.displayName}');
      return true;
    } catch (e) {
      print('Fehler beim Dictionary-Wechsel: $e');
      return false;
    }
  }

  /// Aktualisiert Performance-Einstellungen
  void updatePerformanceSettings(PerformanceSettings settings) {
    _performanceSettings = settings;
    print('Performance-Einstellungen aktualisiert: ${settings.displayName}');
  }

  /// Beendet den Service
  void dispose() {
    _isInitialized = false;

    _dictionary?.dispose();
    _detectorParams?.dispose();
    _detector?.dispose();

    _dictionary = null;
    _detectorParams = null;
    _detector = null;

    print('CV Service wurde beendet');
  }
}
