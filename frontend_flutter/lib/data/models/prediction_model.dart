import 'package:flutter/material.dart';

class BoundingBox {
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  const BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  factory BoundingBox.fromList(List<dynamic> list) {
    return BoundingBox(
      x1: (list[0] as num).toDouble(),
      y1: (list[1] as num).toDouble(),
      x2: (list[2] as num).toDouble(),
      y2: (list[3] as num).toDouble(),
    );
  }

  double get width => x2 - x1;
  double get height => y2 - y1;

  Rect toRect() => Rect.fromLTWH(x1, y1, width, height);

  @override
  String toString() =>
      'BoundingBox(x1: $x1, y1: $y1, x2: $x2, y2: $y2)';
}

class Prediction {
  final BoundingBox box;
  final double confidence;
  final String label;

  const Prediction({
    required this.box,
    required this.confidence,
    required this.label,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      box: BoundingBox.fromList(json['box'] as List<dynamic>),
      confidence: (json['confidence'] as num).toDouble(),
      label: json['label'] as String,
    );
  }

  String get confidencePercent =>
      '${(confidence * 100).toStringAsFixed(1)}%';

  @override
  String toString() =>
      'Prediction(label: $label, confidence: $confidence, box: $box)';
}

class PredictionResponse {
  final String filename;
  final List<Prediction> predictions;

  const PredictionResponse({
    required this.filename,
    required this.predictions,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      filename: json['filename'] as String,
      predictions: (json['prediction'] as List<dynamic>)
          .map((e) => Prediction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get hasDetections => predictions.isNotEmpty;
  int get detectionCount => predictions.length;
}

enum DetectionStatus {
  idle,
  picking,
  loading,
  success,
  error,
}
