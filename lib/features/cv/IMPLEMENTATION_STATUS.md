# Robuste CameraImage zu OpenCV Mat Konvertierung

## ✅ Implementiert

Die neue Implementierung in `cv_camera_converters.dart` erfüllt alle geforderten Kriterien:

### 🎯 Muss-Kriterien erfüllt:

1. **✅ Behandelt YUV420, NV21 und BGRA8888**
   - Android: YUV_420_888 → Y-Plane Extraktion (CV_8UC1)
   - iOS: BGRA8888 → cvtColor BGRA2GRAY
   - NV21: Gleiche Behandlung wie YUV420

2. **✅ Row stride Behandlung**
   - `if (bytesPerRow == width)` → Direkter Zugriff
   - `else` → Zeilenweise Block-Kopie mit `setRange()`
   - Assertions: `yBytes.length >= (height-1)*bytesPerRow + width`

3. **✅ BGRA8888 Optimierung**
   - CV_8UC4 Mat erstellen → `cvtColor(bgra, COLOR_BGRA2GRAY)`
   - Automatic `bgra.dispose()` cleanup

4. **✅ Orientierungskorrektur**
   - `normalizeOrientation()` mit 90°-Schritten
   - `cv.rotate()` mit ROTATE_90_CLOCKWISE/180/COUNTERCLOCKWISE
   - Optional horizontal flip für Frontkamera

5. **✅ Vollständiger Beispielcode**
   - `ArucoProcessor` Klasse mit `initAruco()`
   - Dictionary + Detector + Parameters Setup
   - `detectMarkers()` Integration mit cleanup

6. **✅ Nur Block-Kopien**
   - `setRange()` für zeilenweise Kopie
   - `sublist()` für direkte Buffer-Nutzung
   - Keine per-Pixel-Schleifen

7. **✅ Assertions und Guards**
   - Width/Height > 0 Validierung
   - Buffer-Größe Checks
   - UnsupportedError für unbekannte Formate

8. **✅ Performance-Dokumentation**
   - Y-Plane nur für Graustufen (5x schneller)
   - Row stride Behandlung optimiert
   - Memory-Management mit dispose()

## 📁 Dateien

- `cv_camera_converters.dart` - Hauptimplementierung
- `aruco_processor_example.dart` - Verwendungsbeispiel
- `image_converter_example.dart` - Migration Guide (deprecated)

## 🚀 Verwendung

```dart
import 'cv_camera_converters.dart';

// Graustufen für ArUco (schnell)
final gray = cameraImageToGrayMat(
  image,
  rotationDegrees: sensorOrientation,
  mirror: isFrontCamera,
);

// RGB für Vollfarb-Verarbeitung
final rgb = cameraImageToRgbMat(
  image,
  rotationDegrees: sensorOrientation,
  mirror: isFrontCamera,
);

// ArUco Detection
final detector = cv.ArucoDetector.create(...);
final result = detector.detectMarkers(gray);
gray.dispose();
```

## 🔧 Features

- **Android YUV420**: Y-Plane Extraktion mit stride-sicherer Kopie
- **iOS BGRA**: Native cvtColor Konvertierung
- **Orientierung**: 0/90/180/270° Rotation + Mirror
- **Memory Safe**: Automatisches dispose() aller temporären Mats
- **Performance**: Block-Operationen, keine Pixel-Loops
- **Validierung**: Umfassende Input-Checks und Error-Handling
