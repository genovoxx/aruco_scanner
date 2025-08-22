# ArUco Scanner - Flutter App mit opencv_dart

Eine Flutter-Demo-App für ArUco-Marker-Erkennung in Echtzeit mit `opencv_dart`.

## Funktionen

- ✅ **Kamera-Preview** in Echtzeit
- ✅ **ArUco-Marker-Erkennung** mit opencv_dart
- ✅ **Mehrere Dictionary-Typen** (DICT_4X4_50, DICT_5X5_100, etc.)
- ✅ **Performance-Einstellungen** (Schnell, Ausgewogen, Qualität)
- ✅ **Visuelles Overlay** mit Marker-IDs und Eckpunkten
- ✅ **FPS-Anzeige** und Live-Status
- ✅ **Settings-Panel** zur Laufzeit-Konfiguration
- 🚧 **Pose-Schätzung** (vorbereitet, benötigt Kalibrierung)

## Installation

### Voraussetzungen

- Flutter SDK (stable channel)
- Dart 3.x
- Android Studio / Xcode für mobile Entwicklung
- Mindestens 2GB freier Speicher für OpenCV-Build

### Abhängigkeiten installieren

```bash
flutter pub get
```

### OpenCV Build-Cache (optional)

Um den Build zu beschleunigen, kann ein Cache-Verzeichnis konfiguriert werden:

**Windows:**
```bash
set DARTCV_CACHE_DIR=%USERPROFILE%\.cache\dartcv
```

**macOS/Linux:**
```bash
export DARTCV_CACHE_DIR=$HOME/.cache/dartcv
```

## Build & Run

### Android

```bash
flutter run
```

**Mindestanforderungen:**
- minSdkVersion: 21
- Kamera-Berechtigung automatisch konfiguriert

### iOS

```bash
flutter run
```

**Konfiguration:**
- NSCameraUsageDescription automatisch konfiguriert
- iOS 11.0+ erforderlich

### Erste Builds

⚠️ **Wichtig:** Der erste Build kann 10-20 Minuten dauern, da OpenCV-Quellen (~100MB) heruntergeladen und kompiliert werden.

## Verwendung

### 1. App starten
- Kamera-Berechtigung gewähren
- Warten bis Kamera initialisiert ist

### 2. ArUco-Marker erkennen
- Marker vor die Kamera halten
- Erkannte Marker werden mit grünen Rahmen und IDs angezeigt
- Status-Bar zeigt Anzahl erkannter Marker

### 3. Einstellungen anpassen
- **Settings-Button** (⚙️) in der AppBar
- **Dictionary wechseln:** verschiedene ArUco-Typen testen
- **Performance:** Schnell/Ausgewogen/Qualität
- **FPS-Limit:** 10-60 FPS einstellen

### 4. Demo-Marker erstellen

Zum Testen können ArUco-Marker online generiert werden:

- [ArUco Marker Generator](https://chev.me/arucogen/)
- Dictionary: 4x4 (50, 100, 250)
- Marker ID: 0-49 für DICT_4X4_50
- Größe: min. 3x3 cm auf Papier

## Architektur

```
lib/
├── main.dart                 # App-Entry-Point
├── models/
│   ├── aruco_settings.dart   # Enums und Settings
│   └── marker_detection.dart # Marker-Datenmodell
├── features/
│   ├── camera/
│   │   └── camera_controller.dart  # Kamera-Management
│   ├── cv/
│   │   ├── cv_service.dart         # OpenCV ArUco-Service
│   │   └── image_converter_example.dart # Beispiel-Code
│   ├── overlay/
│   │   └── aruco_overlay.dart      # Visual Overlay
│   └── settings/
│       └── settings.dart           # Settings UI
```

## Technische Details

### OpenCV Integration

- **Paket:** `opencv_dart ^1.3.0`
- **Native Libs:** Automatischer lokaler Build
- **ArUco-Module:** Komplett verfügbar (contrib)
- **API:** Direkte FFI-Bindungen

### Performance-Optimierungen

- **FPS-Limiting:** Verhindert UI-Blockierung
- **Async-Processing:** Nutzt opencv_dart async APIs
- **Downscaling:** Reduziert Verarbeitungszeit
- **Graustufen:** Nur Y-Plane von YUV420

### Kamera-Pipeline

1. **CameraController** → `startImageStream()`
2. **CameraImage** (YUV420) → Y-Plane Extraktion
3. **cv.Mat** → ArUco-Erkennung
4. **Ergebnisse** → UI-Overlay Mapping
5. **Preview-Koordinaten** → Korrekte Darstellung

## Bekannte Limitierungen

### Demo-Implementation

Die aktuelle Version verwendet eine **Demo-Implementierung** für die Marker-Erkennung, da die exakte opencv_dart API für CameraImage-zu-Mat-Konvertierung projektspezifisch implementiert werden muss.

**Echte Implementierung benötigt:**
- YUV420 → cv.Mat Konvertierung
- Korrekte Speicher-Management
- Platform-spezifische Optimierungen

### Pose-Schätzung

- Benötigt Kamera-Kalibrierung (camera_matrix, dist_coeffs)
- Implementierung vorbereitet in `cv_service.dart`
- Kalibrierungs-Assets müssen hinzugefügt werden

## Erweitern der App

### Echte OpenCV-Integration

1. **YUV-Konvertierung implementieren:**
   ```dart
   cv.Mat yuvToMat(CameraImage image) {
     // Siehe image_converter_example.dart
   }
   ```

2. **Kalibrierung hinzufügen:**
   ```yaml
   # assets/calibration/camera_matrix.yaml
   camera_matrix: [[fx, 0, cx], [0, fy, cy], [0, 0, 1]]
   dist_coeffs: [k1, k2, p1, p2, k3]
   ```

3. **Pose-Rendering aktivieren:**
   ```dart
   _showPose = true; // in main.dart
   ```

### Weitere Features

- **Marker-Tracking:** ID-basierte Persistenz
- **Multi-Marker-Boards:** Komplexe Szenen
- **Augmented Reality:** 3D-Objekte über Marker
- **Kalibrierungs-Tool:** Automatische Kamera-Kalibrierung

## Troubleshooting

### Build-Probleme

**"OpenCV build failed":**
- Cache leeren: `flutter clean`
- Internetverbindung prüfen
- Mehr Speicher bereitstellen

**"Camera permission denied":**
- App-Berechtigungen in System-Einstellungen prüfen
- AndroidManifest.xml / Info.plist überprüfen

### Performance-Probleme

**Niedrige FPS:**
- Performance auf "Schnell" setzen
- Downscale-Faktor reduzieren (0.5 → 0.3)
- FPS-Limit erhöhen

**App-Crash:**
- Memory-Leaks durch fehlende dispose() Aufrufe
- OpenCV Mat-Objekte nicht freigegeben

## Lizenz

Dieses Projekt ist ein Beispiel/Demo und verwendet:
- Flutter (BSD-3-Clause)
- opencv_dart (BSD-3-Clause)
- camera plugin (BSD-3-Clause)

## Weiterführende Links

- [opencv_dart Documentation](https://pub.dev/packages/opencv_dart)
- [ArUco in OpenCV](https://docs.opencv.org/4.x/d5/dae/tutorial_aruco_detection.html)
- [Flutter Camera Plugin](https://pub.dev/packages/camera)
- [ArUco Marker Generator](https://chev.me/arucogen/)
