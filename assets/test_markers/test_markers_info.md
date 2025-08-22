# Test-Marker für ArUco Scanner

## Verfügbare Test-Marker

Die folgenden ArUco-Marker sind für Tests vorbereitet:

### 4x4_50 Dictionary (Standard)
- **test_marker_id_0.png** - ID: 0 (Basis-Test)
- **test_marker_id_1.png** - ID: 1 (Mehrfach-Erkennung)
- **test_marker_id_23.png** - ID: 23 (Beliebte Test-ID)
- **test_marker_id_42.png** - ID: 42 (Universelle Test-ID)

### Marker-Spezifikationen
- **Format**: PNG, 300x300 Pixel
- **Quiet Zone**: 1 Modul-Breite rundum
- **Dictionary**: DICT_4X4_50 (Standard)
- **Druckgröße**: Minimum 5x5 cm für optimale Erkennung

## Test-Szenarien

### Basis-Tests
1. **Einzelner Marker**: test_marker_id_0.png
2. **Mehrere Marker**: IDs 0, 1, 23 gleichzeitig
3. **Bewegung**: Marker bewegen, rotieren, neigen
4. **Abstand**: 10cm bis 2m testen

### Erweiterte Tests
1. **Verschiedene Beleuchtung**:
   - Helles Tageslicht
   - Innenbeleuchtung
   - Schwache Beleuchtung (Grenzen testen)

2. **Verschiedene Winkel**:
   - Frontal (0°)
   - Geneigt (15°, 30°, 45°)
   - Seitlich (bis 60°)

3. **Verschiedene Größen**:
   - Klein: 3x3 cm
   - Standard: 5x5 cm
   - Groß: 10x10 cm

## Marker generieren

### Online-Generator
Besuchen Sie: https://chev.me/arucogen/
- Dictionary: 4x4 (50 Marker)
- Marker ID: 0-49
- Marker Size: 300px
- Include White Border: Yes

### Python-Script (Optional)
```python
import cv2
import numpy as np

# ArUco Dictionary laden
aruco_dict = cv2.aruco.getPredefinedDictionary(cv2.aruco.DICT_4X4_50)

# Marker generieren
marker_id = 0
marker_size = 300  # Pixel
marker_img = cv2.aruco.generateImageMarker(aruco_dict, marker_id, marker_size)

# Speichern
cv2.imwrite(f'test_marker_id_{marker_id}.png', marker_img)
```

## Drucktipps

### Optimale Druckqualität
- **Auflösung**: 300 DPI minimum
- **Papier**: Weißes, mattes Papier
- **Drucker**: Laser-Drucker bevorzugt (schärfere Kanten)
- **Größe**: 5x5 cm oder größer für beste Erkennung

### Laminierung (empfohlen)
- Schützt vor Abnutzung
- Reduziert Reflexionen
- Glatte Oberfläche für bessere Erkennung

## Fehlerbehebung

### Marker wird nicht erkannt
1. **Dictionary prüfen**: Ist der Marker für 4x4_50 generiert?
2. **Qualität prüfen**: Sind die Kanten scharf und klar?
3. **Beleuchtung**: Ist der Marker gleichmäßig ausgeleuchtet?
4. **Abstand**: Ist der Marker groß genug für den Aufnahmeabstand?

### Falsche ID erkannt
1. **Verschmutzung**: Marker reinigen
2. **Beschädigung**: Neuen Marker drucken
3. **Reflexionen**: Beleuchtung anpassen
4. **Bewegungsunschärfe**: Ruhiger halten

## Test-Protokoll

### Erfolgreiche Tests dokumentieren
- [ ] Marker ID 0: Erkannt bei 30cm Abstand
- [ ] Marker ID 1: Erkannt bei verschiedenen Winkeln
- [ ] Marker ID 23: Erkannt bei schwacher Beleuchtung
- [ ] Marker ID 42: Erkannt bei Bewegung
- [ ] Multi-Marker: 2-3 Marker gleichzeitig erkannt

### Performance-Messung
- FPS bei verschiedenen Einstellungen
- Erkennungsrate bei verschiedenen Bedingungen
- CPU/Memory-Verbrauch monitoren

---

**Viel Erfolg beim Testen der ArUco-Erkennung!**
