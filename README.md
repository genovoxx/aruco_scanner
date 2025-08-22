# ArUco Scanner - Flutter App mit opencv_dart

Eine Flutter-App für ArUco-Marker-Erkennung durch manuelle Bildaufnahme mit `opencv_dart`.

## Funktionen

- ✅ **Kamera-Preview** in Echtzeit
- ✅ **Shot-basierte ArUco-Marker-Erkennung** mit opencv_dart
- ✅ **Manuelle Bildaufnahme** - Erkennung nur bei Button-Druck
- ✅ **Mehrere Dictionary-Typen** (DICT_4X4_50, DICT_5X5_100, etc.)
- ✅ **Performance-Einstellungen** (Schnell, Ausgewogen, Qualität)
- ✅ **Visuelles Overlay** mit Marker-IDs und Eckpunkten
- ✅ **Clear-Funktion** zum Löschen alter Erkennungen
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
- minSdk: 24 (Android 7.0+) - erforderlich für opencv_dart
- compileSdk: 36 - für aktuelle Camera-Plugins
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
- **"ArUco scannen"-Button** drücken um ein Foto aufzunehmen
- Marker vor die Kamera halten und Button drücken
- Erkannte Marker werden mit grünen Rahmen und IDs angezeigt
- Status-Bar zeigt Anzahl erkannter Marker der letzten Aufnahme

### 3. Weitere Aufnahmen
- **Roten Clear-Button** drücken um alte Erkennungen zu löschen
- **"ArUco scannen"** erneut drücken für neue Erkennung
- Buttons sind immer über dem Overlay sichtbar und klickbar

### 4. Einstellungen anpassen
- **Settings-Button** (⚙️) in der AppBar
- **Dictionary wechseln:** verschiedene ArUco-Typen testen
- **Performance:** Schnell/Ausgewogen/Qualität

### 5. Demo-Marker erstellen

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

- **Shot-basierte Verarbeitung:** Vermeidet kontinuierliche CPU-Last
- **JPEG/PNG-Dekodierung:** Nutzt opencv_dart `imdecode()` für aufgenommene Bilder
- **Graustufen-Konvertierung:** Nur für ArUco-Erkennung
- **Speicher-Management:** Automatisches `dispose()` von OpenCV-Objekten

### Kamera-Pipeline (Shot-basiert)

1. **CameraController** → `takePicture()` bei Button-Druck
2. **XFile** → Bild als Bytes laden
3. **cv.imdecode()** → JPEG/PNG zu cv.Mat
4. **cv.cvtColor()** → Graustufen-Konvertierung
5. **cv.ArucoDetector.detectMarkers()** → Marker-Erkennung
6. **Koordinaten-Mapping** → UI-Overlay
7. **Mat.dispose()** → Speicher freigeben

## Bekannte Limitierungen

### Shot-basierte Erkennung

Die App verwendet jetzt eine **Shot-basierte Implementierung** anstatt kontinuierlicher Echtzeit-Erkennung:

**Vorteile:**
- ✅ Deutlich weniger CPU-Last und Akku-Verbrauch
- ✅ Stabile Marker-Anzeige ohne Flackern
- ✅ Präzise Erkennung durch scharfe Standbilder
- ✅ Keine komplexe YUV420-zu-Mat-Konvertierung nötig

**Einschränkungen:**
- ❌ Keine Echtzeit-Verfolgung von Markern
- ❌ Manuelle Auslösung für jede Erkennung erforderlich

### UI-Interaktion

- **Overlay-Positionierung:** ArUco-Overlay ist mit `IgnorePointer` versehen
- **Button-Priorität:** Scan- und Clear-Buttons sind immer oberste Stack-Ebene
- **Touch-Events:** Werden korrekt an Buttons weitergeleitet

### Pose-Schätzung

- Benötigt Kamera-Kalibrierung (camera_matrix, dist_coeffs)
- Implementierung vorbereitet in `cv_service.dart`
- Kalibrierungs-Assets müssen hinzugefügt werden

## Erweitern der App

### Rückwechsel zu Echtzeit-Erkennung

Falls kontinuierliche Erkennung gewünscht ist:

1. **CameraImage-Stream implementieren:**
   ```dart
   _controller.startImageStream(_processImage);
   ```

2. **YUV420-zu-Mat-Konvertierung:**
   ```dart
   cv.Mat cameraImageToMat(CameraImage image) {
     // Siehe cv_camera_converters.dart Beispiele
   }
   ```

3. **FPS-Limiting hinzufügen:**
   ```dart
   Timer.periodic(Duration(milliseconds: 100), (timer) {
     // Verarbeitung alle 100ms
   });
   ```

### Shot-Verbesserungen

- **Burst-Modus:** Mehrere Bilder schnell hintereinander
- **Autofokus:** Vor Aufnahme fokussieren
- **Belichtungsoptimierung:** Für bessere Marker-Erkennung
- **Vorschau-Feedback:** Marker-Hinweise vor Aufnahme

### Weitere Features

- **Marker-Historie:** Alle erkannten Marker speichern
- **Batch-Verarbeitung:** Mehrere Bilder aus Galerie
- **Export-Funktion:** Erkennungen als JSON/CSV
- **Augmented Reality:** 3D-Objekte über Marker (mit Echtzeit-Modus)

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

**App zu langsam:**
- Performance auf "Schnell" setzen
- Kleinere ArUco-Marker verwenden (weniger Verarbeitungszeit)
- Bessere Beleuchtung für schärfere Bilder

**Button nicht klickbar:**
- ArUco-Overlay ist mit `IgnorePointer` versehen
- Stack-Reihenfolge prüfen (Buttons müssen oberste Ebene sein)
- UI-Refresh durch Settings-Toggle testen

**Marker nicht erkannt:**
- Marker gerade und gut beleuchtet halten
- Richtiges Dictionary wählen (4x4 für IDs 0-49)
- Marker-Größe: mindestens 3x3 cm
- Scharfes Foto durch ruhige Hand

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
