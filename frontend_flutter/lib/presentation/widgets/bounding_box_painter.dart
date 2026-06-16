import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/prediction_model.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<Prediction> predictions;
  final Size originalImageSize;
  final Size displaySize;
  final bool isDarkMode;

  const BoundingBoxPainter({
    required this.predictions,
    required this.originalImageSize,
    required this.displaySize,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (originalImageSize.isEmpty || predictions.isEmpty) return;

    final scaleX = displaySize.width / originalImageSize.width;
    final scaleY = displaySize.height / originalImageSize.height;

    for (final prediction in predictions) {
      _drawBox(canvas, prediction, scaleX, scaleY);
    }
  }

  void _drawBox(
      Canvas canvas,
      Prediction prediction,
      double scaleX,
      double scaleY,
      ) {
    final box = prediction.box;

    final rect = Rect.fromLTRB(
      box.x1 * scaleX,
      box.y1 * scaleY,
      box.x2 * scaleX,
      box.y2 * scaleY,
    );

    // Confidence-based color intensity
    final alpha = (0.5 + prediction.confidence * 0.5).clamp(0.0, 1.0);
    final strokeColor = AppColors.boxStroke.withOpacity(alpha);
    final fillColor = AppColors.boxFill.withOpacity(alpha * 0.3);

    // Fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    // Stroke
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppConstants.boxStrokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Corner accent paint
    final cornerPaint = Paint()
      ..color = AppColors.boxStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppConstants.boxStrokeWidth * 2
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      fillPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      strokePaint,
    );

    // Draw corner accents
    _drawCornerAccents(canvas, rect, cornerPaint);

    // Draw label
    _drawLabel(canvas, prediction, rect);
  }

  void _drawCornerAccents(Canvas canvas, Rect rect, Paint paint) {
    const cornerLen = 12.0;

    final corners = [
      // Top-left
      [
        Offset(rect.left, rect.top + cornerLen),
        Offset(rect.left, rect.top),
        Offset(rect.left + cornerLen, rect.top),
      ],
      // Top-right
      [
        Offset(rect.right - cornerLen, rect.top),
        Offset(rect.right, rect.top),
        Offset(rect.right, rect.top + cornerLen),
      ],
      // Bottom-left
      [
        Offset(rect.left, rect.bottom - cornerLen),
        Offset(rect.left, rect.bottom),
        Offset(rect.left + cornerLen, rect.bottom),
      ],
      // Bottom-right
      [
        Offset(rect.right - cornerLen, rect.bottom),
        Offset(rect.right, rect.bottom),
        Offset(rect.right, rect.bottom - cornerLen),
      ],
    ];

    for (final corner in corners) {
      final path = Path()
        ..moveTo(corner[0].dx, corner[0].dy)
        ..lineTo(corner[1].dx, corner[1].dy)
        ..lineTo(corner[2].dx, corner[2].dy);
      canvas.drawPath(path, paint);
    }
  }

  void _drawLabel(Canvas canvas, Prediction prediction, Rect rect) {
    final label = AppConstants.translateLabel(prediction.label);
    final confidence = prediction.confidencePercent;
    final text = '$label $confidence';

    const fontSize = AppConstants.labelFontSize;
    const padding = AppConstants.labelPadding;

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final bgWidth = textPainter.width + padding * 3;
    final bgHeight = textPainter.height + padding * 2;

    double labelX = rect.left;
    double labelY = rect.top - bgHeight;

    if (labelY < 0) labelY = rect.top + 2;
    if (labelX + bgWidth > displaySize.width) {
      labelX = displaySize.width - bgWidth;
    }

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(labelX, labelY, bgWidth, bgHeight),
      const Radius.circular(6),
    );

    final bgPaint = Paint()
      ..color = AppColors.labelBg
      ..style = PaintingStyle.fill;

    canvas.drawRRect(bgRect, bgPaint);

    textPainter.paint(
      canvas,
      Offset(labelX + padding * 1.5, labelY + padding),
    );
  }

  @override
  bool shouldRepaint(BoundingBoxPainter oldDelegate) {
    return oldDelegate.predictions != predictions ||
        oldDelegate.originalImageSize != originalImageSize ||
        oldDelegate.displaySize != displaySize;
  }
}

class DetectionImageView extends StatefulWidget {
  final String imagePath;
  final List<Prediction> predictions;
  final Size originalImageSize;

  const DetectionImageView({
    super.key,
    required this.imagePath,
    required this.predictions,
    required this.originalImageSize,
  });

  @override
  State<DetectionImageView> createState() => _DetectionImageViewState();
}

class _DetectionImageViewState extends State<DetectionImageView> {
  Size _displaySize = Size.zero;
  Offset _imageOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;

        if (widget.originalImageSize != Size.zero) {
          final imageAspect =
              widget.originalImageSize.width / widget.originalImageSize.height;
          final containerAspect = maxWidth / maxHeight;

          if (imageAspect > containerAspect) {
            _displaySize = Size(maxWidth, maxWidth / imageAspect);
            _imageOffset = Offset(0, (maxHeight - _displaySize.height) / 2);
          } else {
            _displaySize = Size(maxHeight * imageAspect, maxHeight);
            _imageOffset = Offset((maxWidth - _displaySize.width) / 2, 0);
          }
        }

        return Stack(
          children: [
            Center(
              child: Image.file(
                key: ValueKey(widget.imagePath),
                File(widget.imagePath),
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            if (widget.predictions.isNotEmpty && _displaySize != Size.zero)
              Positioned(
                left: _imageOffset.dx,
                top: _imageOffset.dy,
                width: _displaySize.width,
                height: _displaySize.height,
                child: CustomPaint(
                  painter: BoundingBoxPainter(
                    predictions: widget.predictions,
                    originalImageSize: widget.originalImageSize,
                    displaySize: _displaySize,
                    isDarkMode: isDark,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}


