# ArUco Marker Generator Links

## Online-Generatoren (empfohlen)

### 1. ChEv ArUco Generator (Haupt-Empfehlung)
**URL**: https://chev.me/arucogen/
**Vorteile**:
- Benutzerfreundliche Oberfläche
- Alle gängigen Dictionaries verfügbar
- Direkt downloadbare PNG-Dateien
- Konfigurierbare Marker-Größe
- Automatische Quiet Zone

**Einstellungen für dieses Projekt**:
- Dictionary: 4x4 (50 markers)
- Marker ID: 0, 1, 23, 42 (für Tests)
- Marker Size: 300px
- Include White Border: Yes (wichtig!)

### 2. OpenCV Tutorial Generator
**URL**: https://docs.opencv.org/4.x/d5/dae/tutorial_aruco_detection.html
**Vorteile**:
- Offizielle OpenCV-Dokumentation
- Code-Beispiele inklusive
- Verschiedene Dictionary-Erklärungen

### 3. GitHub ArUco Tools
**URL**: https://github.com/SmartRoboticSystems/aruco_markers_generator
**Vorteile**:
- Batch-Generierung möglich
- Python-Script zum lokalen Erstellen
- Anpassbare Parameter

## Lokale Generierung (für Entwickler)

### Python-Script
```python
import cv2
import numpy as np
import os

# Dictionary definieren
aruco_dict = cv2.aruco.getPredefinedDictionary(cv2.aruco.DICT_4X4_50)

# Test-Marker-IDs
test_ids = [0, 1, 23, 42]
marker_size = 300  # Pixel

# Output-Ordner erstellen
os.makedirs('generated_markers', exist_ok=True)

# Marker generieren
for marker_id in test_ids:
    # Marker-Bild erstellen
    marker_img = cv2.aruco.generateImageMarker(aruco_dict, marker_id, marker_size)
    
    # Dateiname
    filename = f'generated_markers/test_marker_id_{marker_id}.png'
    
    # Speichern
    cv2.imwrite(filename, marker_img)
    print(f'Marker ID {marker_id} gespeichert: {filename}')

print("Alle Test-Marker erfolgreich generiert!")
```

### C++ Version (für native Entwicklung)
```cpp
#include <opencv2/opencv.hpp>
#include <opencv2/aruco.hpp>

int main() {
    // Dictionary laden
    cv::aruco::Dictionary dictionary = cv::aruco::getPredefinedDictionary(cv::aruco::DICT_4X4_50);
    
    // Marker generieren
    std::vector<int> test_ids = {0, 1, 23, 42};
    int marker_size = 300;
    
    for (int id : test_ids) {
        cv::Mat marker_img;
        cv::aruco::generateImageMarker(dictionary, id, marker_size, marker_img, 1);
        
        std::string filename = "test_marker_id_" + std::to_string(id) + ".png";
        cv::imwrite(filename, marker_img);
    }
    
    return 0;
}
```

## Dictionary-Übersicht

### Für Einsteiger
- **DICT_4X4_50**: 4x4 Bit, 50 eindeutige Marker
- **DICT_4X4_100**: 4x4 Bit, 100 eindeutige Marker
- **DICT_4X4_250**: 4x4 Bit, 250 eindeutige Marker

### Für Fortgeschrittene
- **DICT_5X5_50**: 5x5 Bit, höhere Genauigkeit
- **DICT_6X6_250**: 6x6 Bit, beste Genauigkeit
- **DICT_7X7_50**: 7x7 Bit, maximum Fehlerkorrektur

### Für spezielle Anwendungen
- **DICT_ARUCO_ORIGINAL**: Original ArUco Dictionary
- **DICT_APRILTAG_16h5**: AprilTag-kompatibel
- **DICT_APRILTAG_25h9**: AprilTag mit höherer Redundanz

## Schnell-Links für Tests

### Sofort verwendbare Marker (4x4_50):
1. **ID 0**: https://chev.me/arucogen/?id=0&dict=4x4_50&size=300
2. **ID 1**: https://chev.me/arucogen/?id=1&dict=4x4_50&size=300
3. **ID 23**: https://chev.me/arucogen/?id=23&dict=4x4_50&size=300
4. **ID 42**: https://chev.me/arucogen/?id=42&dict=4x4_50&size=300

*(Hinweis: URLs funktionieren möglicherweise nicht direkt - besuchen Sie die Hauptseite und konfigurieren Sie manuell)*

## Mobile Apps

### Android
- **ArUco Marker Generator** (Play Store)
- **OpenCV Manager** (für Tests)

### iOS  
- **ArUco Detector** (App Store)
- **Computer Vision Tools** (für Generierung)

## Druckvorlagen

### PDF-Template erstellen
```python
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4
import cv2

def create_marker_pdf(marker_ids, output_file):
    c = canvas.Canvas(output_file, pagesize=A4)
    width, height = A4
    
    # Dictionary laden
    aruco_dict = cv2.aruco.getPredefinedDictionary(cv2.aruco.DICT_4X4_50)
    
    # Marker pro Seite
    markers_per_row = 2
    marker_size = 200  # points (ca. 7cm bei 72 DPI)
    margin = 50
    
    for i, marker_id in enumerate(marker_ids):
        # Position berechnen
        row = i // markers_per_row
        col = i % markers_per_row
        
        x = margin + col * (marker_size + margin)
        y = height - margin - (row + 1) * (marker_size + margin)
        
        # Marker-Bild generieren
        marker_img = cv2.aruco.generateImageMarker(aruco_dict, marker_id, 200)
        
        # Als temporäre Datei speichern und in PDF einbetten
        temp_file = f"temp_marker_{marker_id}.png"
        cv2.imwrite(temp_file, marker_img)
        
        # In PDF einbetten
        c.drawImage(temp_file, x, y, marker_size, marker_size)
        
        # ID als Text hinzufügen
        c.drawString(x, y - 20, f"ID: {marker_id}")
        
        # Temp-Datei löschen
        os.remove(temp_file)
    
    c.save()

# Verwendung
create_marker_pdf([0, 1, 23, 42], "test_markers.pdf")
```

---

**Mit diesen Tools können Sie sofort loslegen!**
