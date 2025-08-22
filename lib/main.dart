import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'features/camera/camera_controller.dart';
import 'features/overlay/aruco_overlay.dart';
import 'features/settings/settings.dart';
import 'models/marker_detection.dart';
import 'models/aruco_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArUco Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const ArucoScannerPage(),
    );
  }
}

class ArucoScannerPage extends StatefulWidget {
  const ArucoScannerPage({super.key});

  @override
  State<ArucoScannerPage> createState() => _ArucoScannerPageState();
}

class _ArucoScannerPageState extends State<ArucoScannerPage>
    with WidgetsBindingObserver {
  final ArucoScannerCameraController _cameraController =
      ArucoScannerCameraController.instance;

  List<MarkerDetection> _detectedMarkers = [];
  String? _errorMessage;
  bool _isInitializing = true;
  bool _showSettings = false;
  bool _showPose = false;
  bool _isCapturing = false; // Für Shot-Status

  // Einstellungen
  ArucoDictionary _currentDictionary = ArucoDictionary.dict4x4_50;
  PerformanceSettings _performanceSettings = PerformanceSettings.balanced;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Kein kontinuierlicher Stream mehr - keine App Lifecycle-Behandlung nötig
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final success = await _cameraController.initialize(
        resolution: CameraResolution.medium,
        dictionary: _currentDictionary,
        settings: _performanceSettings,
      );

      if (!success) {
        setState(() {
          _errorMessage = 'Kamera konnte nicht initialisiert werden';
          _isInitializing = false;
        });
        return;
      }

      // Detection Stream abhören (für zuletzt erkannte Marker)
      _cameraController.detectionStream.listen(
        (detections) {
          if (mounted) {
            setState(() {
              _detectedMarkers = detections;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _errorMessage = 'Fehler bei der Marker-Erkennung: $error';
            });
          }
        },
      );

      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Initialisierungsfehler: $e';
        _isInitializing = false;
      });
    }
  }

  /// Nimmt ein Foto auf und erkennt ArUco-Marker
  Future<void> _captureAndDetect() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
      _errorMessage = null;
    });

    try {
      final detections = await _cameraController.captureAndDetectMarkers();

      // Erfolgreiche Erkennung anzeigen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${detections.length} ArUco-Marker erkannt'),
            backgroundColor: detections.isNotEmpty
                ? Colors.green
                : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Fehler bei der Aufnahme: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  void _onDictionaryChanged(ArucoDictionary dictionary) async {
    _currentDictionary = dictionary;
    final success = await _cameraController.changeDictionary(dictionary);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler beim Ändern des Dictionaries')),
      );
    }
  }

  void _onPerformanceChanged(PerformanceSettings settings) {
    setState(() {
      _performanceSettings = settings;
      _showPose = settings.enablePoseEstimation;
    });
    _cameraController.updatePerformanceSettings(settings);
  }

  /// Löscht die zuletzt erkannten Marker
  void _clearDetections() {
    setState(() {
      _detectedMarkers = [];
    });
  }

  void _onShowPoseChanged(bool showPose) {
    setState(() {
      _showPose = showPose;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ArUco Scanner'),
        backgroundColor: Colors.black87,
        actions: [
          // Settings Button
          IconButton(
            icon: Icon(
              _showSettings ? Icons.settings : Icons.settings_outlined,
              color: _showSettings ? Colors.blue[300] : Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showSettings = !_showSettings;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Kamera-Preview (ganz unten)
          Positioned.fill(child: _buildCameraPreview()),

          // ArUco-Overlay (über der Kamera, aber unter den Controls)
          if (_cameraController.isInitialized && _detectedMarkers.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 180, // Freiraum für Button und Status-Bar
              child: IgnorePointer(
                // Verhindert Touch-Events auf dem Overlay
                child: ArucoOverlay(
                  detections: _detectedMarkers,
                  showIds: true,
                  showCorners: true,
                  showPose: _showPose,
                  markerColor: Colors.green,
                  strokeWidth: 2.0,
                ),
              ),
            ),

          // Status-Info unten (über dem Overlay)
          Positioned(bottom: 0, left: 0, right: 0, child: _buildStatusBar()),

          // Aufnahme- und Clear-Buttons (ganz oben, damit sie klickbar bleiben)
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Clear Button (nur anzeigen wenn Marker erkannt)
                if (_detectedMarkers.isNotEmpty)
                  FloatingActionButton(
                    onPressed: _clearDetections,
                    backgroundColor: Colors.red,
                    heroTag: "clear_button",
                    child: const Icon(Icons.clear, color: Colors.white),
                  ),

                // Scan Button
                FloatingActionButton.extended(
                  onPressed: _cameraController.isInitialized && !_isCapturing
                      ? _captureAndDetect
                      : null,
                  backgroundColor: _isCapturing ? Colors.grey : Colors.blue,
                  heroTag: "scan_button",
                  icon: _isCapturing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.camera_alt, color: Colors.white),
                  label: Text(
                    _isCapturing ? 'Erkenne...' : 'ArUco scannen',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Settings Panel (ganz oben)
          if (_showSettings)
            Positioned(
              top: 20,
              right: 20,
              child: SettingsPanel(
                currentDictionary: _currentDictionary,
                performanceSettings: _performanceSettings,
                showPose: _showPose,
                onDictionaryChanged: _onDictionaryChanged,
                onPerformanceChanged: _onPerformanceChanged,
                onShowPoseChanged: _onShowPoseChanged,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_errorMessage != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeCamera,
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isInitializing || !_cameraController.isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Kamera wird initialisiert...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    final controller = _cameraController.controller;
    if (controller == null) {
      return const Center(
        child: Text(
          'Kamera nicht verfügbar',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return CameraPreview(controller);
  }

  Widget _buildStatusBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Marker-Zähler
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: _detectedMarkers.isNotEmpty
                        ? Colors.green
                        : Colors.white54,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _detectedMarkers.isNotEmpty
                        ? '${_detectedMarkers.length} Marker (letzte Erkennung)'
                        : 'Drücke "ArUco scannen" für Erkennung',
                    style: TextStyle(
                      color: _detectedMarkers.isNotEmpty
                          ? Colors.green
                          : Colors.white54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Dictionary-Info
            if (_detectedMarkers.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Dictionary: ${_currentDictionary.displayName}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],

            // Marker-IDs anzeigen
            if (_detectedMarkers.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _detectedMarkers.map((detection) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ID: ${detection.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
