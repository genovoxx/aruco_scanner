import 'package:opencv_dart/opencv_dart.dart' as cv;

/// Verfügbare ArUco Dictionary Typen
enum ArucoDictionary {
  dict4x4_50(cv.PredefinedDictionaryType.DICT_4X4_50, 'DICT_4X4_50'),
  dict4x4_100(cv.PredefinedDictionaryType.DICT_4X4_100, 'DICT_4X4_100'),
  dict4x4_250(cv.PredefinedDictionaryType.DICT_4X4_250, 'DICT_4X4_250'),
  dict5x5_50(cv.PredefinedDictionaryType.DICT_5X5_50, 'DICT_5X5_50'),
  dict5x5_100(cv.PredefinedDictionaryType.DICT_5X5_100, 'DICT_5X5_100'),
  dict5x5_250(cv.PredefinedDictionaryType.DICT_5X5_250, 'DICT_5X5_250'),
  dict6x6_50(cv.PredefinedDictionaryType.DICT_6X6_50, 'DICT_6X6_50'),
  dict6x6_100(cv.PredefinedDictionaryType.DICT_6X6_100, 'DICT_6X6_100'),
  dict6x6_250(cv.PredefinedDictionaryType.DICT_6X6_250, 'DICT_6X6_250'),
  dict7x7_50(cv.PredefinedDictionaryType.DICT_7X7_50, 'DICT_7X7_50'),
  dict7x7_100(cv.PredefinedDictionaryType.DICT_7X7_100, 'DICT_7X7_100'),
  dict7x7_250(cv.PredefinedDictionaryType.DICT_7X7_250, 'DICT_7X7_250'),
  dictAruco(
    cv.PredefinedDictionaryType.DICT_ARUCO_ORIGINAL,
    'DICT_ARUCO_ORIGINAL',
  );

  const ArucoDictionary(this.predefinedType, this.name);

  final cv.PredefinedDictionaryType predefinedType;
  final String name;

  /// Für UI-Anzeige
  String get displayName {
    switch (this) {
      case ArucoDictionary.dict4x4_50:
        return '4x4 (50 Marker)';
      case ArucoDictionary.dict4x4_100:
        return '4x4 (100 Marker)';
      case ArucoDictionary.dict4x4_250:
        return '4x4 (250 Marker)';
      case ArucoDictionary.dict5x5_50:
        return '5x5 (50 Marker)';
      case ArucoDictionary.dict5x5_100:
        return '5x5 (100 Marker)';
      case ArucoDictionary.dict5x5_250:
        return '5x5 (250 Marker)';
      case ArucoDictionary.dict6x6_50:
        return '6x6 (50 Marker)';
      case ArucoDictionary.dict6x6_100:
        return '6x6 (100 Marker)';
      case ArucoDictionary.dict6x6_250:
        return '6x6 (250 Marker)';
      case ArucoDictionary.dict7x7_50:
        return '7x7 (50 Marker)';
      case ArucoDictionary.dict7x7_100:
        return '7x7 (100 Marker)';
      case ArucoDictionary.dict7x7_250:
        return '7x7 (250 Marker)';
      case ArucoDictionary.dictAruco:
        return 'ARUCO Original';
    }
  }

  /// Standard Dictionary für neue Benutzer
  static const ArucoDictionary defaultDictionary = ArucoDictionary.dict4x4_50;
}

/// Kameraauflösungs-Einstellungen
enum CameraResolution {
  low('Niedrig (480p)'),
  medium('Mittel (720p)'),
  high('Hoch (1080p)'),
  veryHigh('Sehr hoch (4K)');

  const CameraResolution(this.displayName);

  final String displayName;

  static const CameraResolution defaultResolution = CameraResolution.medium;
}

/// Performance-Einstellungen für die Bildverarbeitung
class PerformanceSettings {
  final double downscaleFactor; // 0.1 - 1.0
  final int maxFps; // 1 - 60
  final bool useAsyncProcessing;
  final bool enablePoseEstimation;

  const PerformanceSettings({
    this.downscaleFactor = 0.5,
    this.maxFps = 30,
    this.useAsyncProcessing = true,
    this.enablePoseEstimation = false,
  });

  PerformanceSettings copyWith({
    double? downscaleFactor,
    int? maxFps,
    bool? useAsyncProcessing,
    bool? enablePoseEstimation,
  }) {
    return PerformanceSettings(
      downscaleFactor: downscaleFactor ?? this.downscaleFactor,
      maxFps: maxFps ?? this.maxFps,
      useAsyncProcessing: useAsyncProcessing ?? this.useAsyncProcessing,
      enablePoseEstimation: enablePoseEstimation ?? this.enablePoseEstimation,
    );
  }

  /// Standard-Performance-Profile
  static const PerformanceSettings fast = PerformanceSettings(
    downscaleFactor: 0.5,
    maxFps: 30,
    useAsyncProcessing: true,
    enablePoseEstimation: false,
  );

  static const PerformanceSettings balanced = PerformanceSettings(
    downscaleFactor: 0.75,
    maxFps: 25,
    useAsyncProcessing: true,
    enablePoseEstimation: true,
  );

  static const PerformanceSettings quality = PerformanceSettings(
    downscaleFactor: 1.0,
    maxFps: 20,
    useAsyncProcessing: true,
    enablePoseEstimation: true,
  );

  String get displayName {
    if (this == fast) return 'Schnell';
    if (this == balanced) return 'Ausgewogen';
    if (this == quality) return 'Qualität';
    return 'Benutzerdefiniert';
  }
}
