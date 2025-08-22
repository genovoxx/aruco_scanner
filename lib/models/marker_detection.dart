import 'package:flutter/material.dart';

/// Repräsentiert ein erkanntes ArUco-Marker mit seinen Eigenschaften
class MarkerDetection {
  final int id;
  final List<Offset> corners; // 4 Eckpunkte im Preview-Koordinatensystem
  final List<double>? rvec; // Rotationsvektor (optional für Pose)
  final List<double>? tvec; // Translationsvektor (optional für Pose)
  final double confidence; // Erkennungsqualität (0.0 - 1.0)

  const MarkerDetection({
    required this.id,
    required this.corners,
    this.rvec,
    this.tvec,
    this.confidence = 1.0,
  });

  /// Erstellt eine Kopie mit geänderten Werten
  MarkerDetection copyWith({
    int? id,
    List<Offset>? corners,
    List<double>? rvec,
    List<double>? tvec,
    double? confidence,
  }) {
    return MarkerDetection(
      id: id ?? this.id,
      corners: corners ?? this.corners,
      rvec: rvec ?? this.rvec,
      tvec: tvec ?? this.tvec,
      confidence: confidence ?? this.confidence,
    );
  }

  /// Konvertiert zu Map für JSON-Serialisierung
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'corners': corners.map((offset) => [offset.dx, offset.dy]).toList(),
      'rvec': rvec,
      'tvec': tvec,
      'confidence': confidence,
    };
  }

  /// Erstellt MarkerDetection aus Map
  factory MarkerDetection.fromMap(Map<String, dynamic> map) {
    final cornersData = map['corners'] as List<dynamic>;
    final corners = cornersData
        .map((corner) => Offset(corner[0] as double, corner[1] as double))
        .toList();

    return MarkerDetection(
      id: map['id'] as int,
      corners: corners,
      rvec: map['rvec'] != null ? List<double>.from(map['rvec']) : null,
      tvec: map['tvec'] != null ? List<double>.from(map['tvec']) : null,
      confidence: map['confidence'] as double? ?? 1.0,
    );
  }

  /// Berechnet den Mittelpunkt des Markers
  Offset get center {
    if (corners.isEmpty) return Offset.zero;

    double x = 0;
    double y = 0;
    for (final corner in corners) {
      x += corner.dx;
      y += corner.dy;
    }
    return Offset(x / corners.length, y / corners.length);
  }

  /// Berechnet die durchschnittliche Größe des Markers
  double get averageSize {
    if (corners.length < 4) return 0;

    double totalDistance = 0;
    for (int i = 0; i < corners.length; i++) {
      final nextIndex = (i + 1) % corners.length;
      final distance = (corners[i] - corners[nextIndex]).distance;
      totalDistance += distance;
    }
    return totalDistance / corners.length;
  }

  /// Prüft ob Pose-Daten verfügbar sind
  bool get hasPose => rvec != null && tvec != null;

  @override
  String toString() {
    return 'MarkerDetection(id: $id, corners: $corners, hasPose: $hasPose, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MarkerDetection &&
        other.id == id &&
        other.corners.length == corners.length &&
        other.confidence == confidence;
  }

  @override
  int get hashCode {
    return id.hashCode ^ corners.length.hashCode ^ confidence.hashCode;
  }
}
