import 'dart:async';
import 'package:camera/camera.dart';
import '../cv/cv_service.dart';
import '../../models/marker_detection.dart';
import '../../models/aruco_settings.dart';

/// Controller für die Kamera und ArUco-Erkennung
class ArucoScannerCameraController {
  static ArucoScannerCameraController? _instance;
  static ArucoScannerCameraController get instance =>
      _instance ??= ArucoScannerCameraController._();

  ArucoScannerCameraController._();

  CameraController? _controller;
  StreamController<List<MarkerDetection>>? _detectionStreamController;
  Timer? _processingTimer;

  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isDisposed = false;

  final CvService _cvService = CvService();

  // Performance-Tracking - Entfernt da nicht mehr benötigt für Shot-basierte Erkennung

  /// Stream für erkannte Marker
  Stream<List<MarkerDetection>> get detectionStream =>
      _detectionStreamController?.stream ?? const Stream.empty();

  /// FPS nicht mehr relevant für Shot-basierte Erkennung
  double get currentFps => 0.0;

  /// Ist die Kamera initialisiert?
  bool get isInitialized =>
      _isInitialized && _controller?.value.isInitialized == true;

  /// Kamera-Controller (für Preview)
  CameraController? get controller => _controller;

  /// Initialisiert die Kamera
  Future<bool> initialize({
    CameraResolution resolution = CameraResolution.medium,
    ArucoDictionary dictionary = ArucoDictionary.dict4x4_50,
    PerformanceSettings? settings,
  }) async {
    if (_isDisposed) return false;

    try {
      // Verfügbare Kameras abrufen
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print('Keine Kamera verfügbar');
        return false;
      }

      // Hauptkamera auswählen (normalerweise die erste)
      final camera = cameras.first;

      // Kamera-Controller erstellen
      final preset = _getResolutionPreset(resolution);
      _controller = CameraController(
        camera,
        preset,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      // Kamera initialisieren
      await _controller!.initialize();

      // CV Service initialisieren
      final cvInitialized = await _cvService.init(
        dictionary: dictionary,
        settings: settings,
      );

      if (!cvInitialized) {
        print('CV Service konnte nicht initialisiert werden');
        return false;
      }

      // Stream für Erkennungen erstellen
      _detectionStreamController =
          StreamController<List<MarkerDetection>>.broadcast();

      _isInitialized = true;

      return true;
    } catch (e) {
      print('Fehler bei der Kamera-Initialisierung: $e');
      return false;
    }
  }

  /// Konvertiert CameraResolution zu ResolutionPreset
  ResolutionPreset _getResolutionPreset(CameraResolution resolution) {
    switch (resolution) {
      case CameraResolution.low:
        return ResolutionPreset.low;
      case CameraResolution.medium:
        return ResolutionPreset.medium;
      case CameraResolution.high:
        return ResolutionPreset.high;
      case CameraResolution.veryHigh:
        return ResolutionPreset.veryHigh;
    }
  }

  /// Nimmt ein Foto auf und erkennt ArUco-Marker
  Future<List<MarkerDetection>> captureAndDetectMarkers() async {
    if (!_isInitialized || _controller == null || _isProcessing) {
      return [];
    }

    _isProcessing = true;

    try {
      // Foto aufnehmen
      final XFile imageFile = await _controller!.takePicture();

      // Bild als Bytes laden
      final imageBytes = await imageFile.readAsBytes();

      // ArUco-Marker im aufgenommenen Bild erkennen
      final detections = await _cvService.detectMarkersFromImageBytes(
        imageBytes,
      );

      // Erkennungen an Stream weiterleiten
      if (!_isDisposed) {
        _detectionStreamController?.add(detections);
      }

      return detections;
    } catch (e) {
      print('Fehler bei der Bildaufnahme: $e');
      return [];
    } finally {
      _isProcessing = false;
    }
  }

  /// Ändert das ArUco-Dictionary
  Future<bool> changeDictionary(ArucoDictionary dictionary) async {
    if (!_isInitialized) return false;

    return await _cvService.changeDictionary(dictionary);
  }

  /// Ändert die Performance-Einstellungen
  void updatePerformanceSettings(PerformanceSettings settings) {
    _cvService.updatePerformanceSettings(settings);
  }

  /// Aktuelle Einstellungen abrufen
  ArucoDictionary get currentDictionary => _cvService.currentDictionary;
  PerformanceSettings get performanceSettings => _cvService.performanceSettings;

  /// Stoppt die Bildverarbeitung temporär (nicht mehr nötig)
  void pauseProcessing() {
    // Kein kontinuierlicher Stream mehr
  }

  /// Startet die Bildverarbeitung wieder (nicht mehr nötig)
  void resumeProcessing() {
    // Kein kontinuierlicher Stream mehr
  }

  /// Beendet den Controller sauber
  Future<void> dispose() async {
    _isDisposed = true;

    _processingTimer?.cancel();
    _processingTimer = null;

    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }

    await _detectionStreamController?.close();
    _detectionStreamController = null;

    _cvService.dispose();

    _isInitialized = false;
  }
}
