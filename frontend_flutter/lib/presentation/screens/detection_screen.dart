// lib/presentation/screens/detection_screen.dart
// REPLACE SELURUH FILE INI

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/prediction_model.dart';
import '../providers/detection_provider.dart';
import '../widgets/bounding_box_painter.dart';
import '../widgets/detection_widgets.dart';

class DetectionScreen extends StatelessWidget {
  const DetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('Deteksi Melon'),
          ],
        ),
        actions: [
          Consumer<DetectionProvider>(
            builder: (context, provider, _) {
              if (!provider.hasImage) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Reset',
                onPressed: provider.reset,
              );
            },
          ),
        ],
      ),
      body: Consumer<DetectionProvider>(
        builder: (context, provider, _) {
          // STATE 1: belum ada gambar → tampilan awal
          if (!provider.hasImage) {
            return _EmptyState(isDark: isDark);
          }

          // STATE 2: sudah ada gambar → body deteksi
          return Stack(
            children: [
              _DetectionBody(provider: provider, isDark: isDark),
              if (provider.isLoading) const DetectionLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// EMPTY STATE — tampilan awal sebelum pilih gambar
// ─────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DetectionProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikon ilustrasi
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkCard
                    : AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.image_search_rounded,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Deteksi Buah Melon',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textDark : AppColors.textLight,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ambil foto dengan kamera atau\npilih dari galeri untuk memulai',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 40),

            // Tombol Kamera
            _BigSourceButton(
              icon: Icons.camera_alt_rounded,
              label: 'Buka Kamera',
              subtitle: 'Foto langsung dengan kamera',
              color: AppColors.primary,
              isDark: isDark,
              onTap: () => provider.pickFromCamera(),
            ),
            const SizedBox(height: 12),

            // Tombol Galeri
            _BigSourceButton(
              icon: Icons.photo_library_rounded,
              label: 'Pilih dari Galeri',
              subtitle: 'Gunakan foto yang sudah ada',
              color: const Color(0xFF2196F3),
              isDark: isDark,
              onTap: () => provider.pickFromGallery(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _BigSourceButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.12 : 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.35), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: color.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// DETECTION BODY — setelah gambar dipilih
// ─────────────────────────────────────────────────────────
class _DetectionBody extends StatelessWidget {
  final DetectionProvider provider;
  final bool isDark;

  const _DetectionBody({required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Preview gambar (mengisi sisa ruang)
        Expanded(
          child: _ImagePreview(provider: provider, isDark: isDark),
        ),

        // Panel hasil (muncul setelah Cek ditekan)
        if (provider.hasResult)
          _ResultPanel(provider: provider, isDark: isDark),

        // Banner error
        if (provider.errorMessage != null)
          _ErrorBanner(
            message: provider.errorMessage!,
            onDismiss: provider.clearError,
          ),

        // Action bar: Galeri | Kamera | Cek Melon
        _ActionBar(provider: provider, isDark: isDark),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// IMAGE PREVIEW + BOUNDING BOX OVERLAY
// ─────────────────────────────────────────────────────────
class _ImagePreview extends StatelessWidget {
  final DetectionProvider provider;
  final bool isDark;

  const _ImagePreview({required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final predictions = provider.result?.predictions ?? [];
    final hasResult = provider.hasResult;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasResult
              ? AppColors.boxStroke
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: hasResult ? 2 : 1,
        ),
        boxShadow: hasResult
            ? [
          BoxShadow(
            color: AppColors.boxStroke.withOpacity(0.18),
            blurRadius: 16,
            spreadRadius: 1,
          )
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Gambar
              Image.file(
                File(provider.selectedImage!.path),
                fit: BoxFit.contain,
              ),

              // Bounding box overlay (muncul setelah ada hasil)
              if (predictions.isNotEmpty && provider.imageSize != Size.zero)
                _BoundingBoxOverlay(
                  predictions: predictions,
                  originalSize: provider.imageSize,
                  containerSize: Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  ),
                ),

              // Badge jumlah deteksi di pojok kanan atas
              if (hasResult)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.boxStroke.withOpacity(0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.boxStroke, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          '${predictions.length} terdeteksi',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BoundingBoxOverlay extends StatelessWidget {
  final List<Prediction> predictions;
  final Size originalSize;
  final Size containerSize;

  const _BoundingBoxOverlay({
    required this.predictions,
    required this.originalSize,
    required this.containerSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageAspect = originalSize.width / originalSize.height;
    final containerAspect = containerSize.width / containerSize.height;

    Size displaySize;
    Offset offset;

    if (imageAspect > containerAspect) {
      final w = containerSize.width;
      final h = w / imageAspect;
      displaySize = Size(w, h);
      offset = Offset(0, (containerSize.height - h) / 2);
    } else {
      final h = containerSize.height;
      final w = h * imageAspect;
      displaySize = Size(w, h);
      offset = Offset((containerSize.width - w) / 2, 0);
    }

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      width: displaySize.width,
      height: displaySize.height,
      child: CustomPaint(
        painter: BoundingBoxPainter(
          predictions: predictions,
          originalImageSize: originalSize,
          displaySize: displaySize,
          isDarkMode: isDark,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// ACTION BAR — Galeri | Kamera | [Cek Melon]
// ─────────────────────────────────────────────────────────
class _ActionBar extends StatelessWidget {
  final DetectionProvider provider;
  final bool isDark;

  const _ActionBar({required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isLoading = provider.isLoading;
    final hasResult = provider.hasResult;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Tombol Galeri
            Expanded(
              flex: 2,
              child: _OutlineIconButton(
                icon: Icons.photo_library_rounded,
                label: 'Galeri',
                color: const Color(0xFF2196F3),
                isDark: isDark,
                onTap: isLoading ? null : () => provider.pickFromGallery(),
              ),
            ),
            const SizedBox(width: 8),

            // Tombol Kamera
            Expanded(
              flex: 2,
              child: _OutlineIconButton(
                icon: Icons.camera_alt_rounded,
                label: 'Kamera',
                color: AppColors.accentOrange,
                isDark: isDark,
                onTap: isLoading ? null : () => provider.pickFromCamera(),
              ),
            ),
            const SizedBox(width: 12),

            // Tombol Cek Melon (utama)
            Expanded(
              flex: 3,
              child: _CekButton(
                hasResult: hasResult,
                isLoading: isLoading,
                onTap: (hasResult || isLoading) ? null : provider.detect,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlineIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;

  const _OutlineIconButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: disabled
                ? color.withOpacity(0.04)
                : color.withOpacity(isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: disabled
                  ? color.withOpacity(0.15)
                  : color.withOpacity(0.4),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: disabled ? color.withOpacity(0.35) : color,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: disabled ? color.withOpacity(0.35) : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CekButton extends StatelessWidget {
  final bool hasResult;
  final bool isLoading;
  final VoidCallback? onTap;

  const _CekButton({
    required this.hasResult,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Widget content;

    if (isLoading) {
      bgColor = AppColors.primary.withOpacity(0.65);
      content = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
            strokeWidth: 2.5, color: Colors.white),
      );
    } else if (hasResult) {
      bgColor = AppColors.primaryDark;
      content = const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_rounded, color: Colors.white, size: 18),
          SizedBox(width: 6),
          Text(
            'Selesai',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      );
    } else {
      bgColor = AppColors.primary;
      content = const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.document_scanner_rounded,
              color: Colors.white, size: 18),
          SizedBox(width: 6),
          Text(
            'Cek Melon',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: onTap != null
              ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
              : null,
        ),
        child: Center(child: content),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// RESULT PANEL — list hasil deteksi
// ─────────────────────────────────────────────────────────
class _ResultPanel extends StatelessWidget {
  final DetectionProvider provider;
  final bool isDark;

  const _ResultPanel({required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final result = provider.result!;

    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.analytics_rounded,
                  color: AppColors.primary, size: 17),
              const SizedBox(width: 6),
              Text(
                'Hasil Deteksi',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${result.detectionCount} objek',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // List item deteksi
          if (result.hasDetections)
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: result.predictions.length,
                itemBuilder: (context, index) => DetectionResultCard(
                  prediction: result.predictions[index],
                  index: index,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  '⚠️  Tidak ada melon terdeteksi dalam gambar ini',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// ERROR BANNER
// ─────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close_rounded,
                color: AppColors.error, size: 18),
          ),
        ],
      ),
    );
  }
}