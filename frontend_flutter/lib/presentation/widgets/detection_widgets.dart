// lib/presentation/widgets/detection_widgets.dart
// REPLACE SELURUH FILE INI

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/prediction_model.dart';

// ─────────────────────────────────────────────────────────
// CARD SATU ITEM HASIL DETEKSI
// ─────────────────────────────────────────────────────────
class DetectionResultCard extends StatelessWidget {
  final Prediction prediction;
  final int index;

  const DetectionResultCard({
    super.key,
    required this.prediction,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = AppConstants.translateLabel(prediction.label);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBackground.withOpacity(0.5)
            : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          // Nomor urut
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.boxStroke.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border:
              Border.all(color: AppColors.boxStroke.withOpacity(0.4)),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.boxStroke,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Label & raw key
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color:
                    isDark ? AppColors.textDark : AppColors.textLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  prediction.label,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Indikator confidence
          _ConfidenceIndicator(confidence: prediction.confidence),
        ],
      ),
    );
  }
}

class _ConfidenceIndicator extends StatelessWidget {
  final double confidence;
  const _ConfidenceIndicator({required this.confidence});

  Color get _color {
    if (confidence >= 0.8) return AppColors.primary;
    if (confidence >= 0.6) return AppColors.accent;
    return AppColors.accentOrange;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: confidence,
            backgroundColor: _color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(_color),
            strokeWidth: 3.5,
          ),
          Text(
            '${(confidence * 100).round()}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// LOADING OVERLAY — tampil saat menunggu respons server
// ─────────────────────────────────────────────────────────
class DetectionLoadingOverlay extends StatelessWidget {
  const DetectionLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Colors.black.withOpacity(0.45),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 52,
                height: 52,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Mendeteksi Melon...',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Harap tunggu sebentar',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}