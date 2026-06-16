// lib/presentation/providers/detection_provider.dart
// REPLACE SELURUH FILE INI

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/prediction_model.dart';
import '../../data/services/detection_service.dart';

class DetectionProvider extends ChangeNotifier {
  final DetectionService _service = DetectionService();
  final ImagePicker _picker = ImagePicker();

  DetectionStatus _status = DetectionStatus.idle;
  File? _selectedImage;
  PredictionResponse? _result;
  String? _errorMessage;
  Size _imageSize = Size.zero;

  // ── Getters ──
  DetectionStatus get status => _status;
  File? get selectedImage => _selectedImage;
  PredictionResponse? get result => _result;
  String? get errorMessage => _errorMessage;
  Size get imageSize => _imageSize;

  bool get isLoading => _status == DetectionStatus.loading;
  bool get hasImage => _selectedImage != null;

  /// true hanya jika sudah ada hasil deteksi dari server
  bool get hasResult => _result != null;

  /// true jika gambar sudah dipilih tapi belum dicek
  bool get readyToDetect =>
      hasImage && !hasResult && _status != DetectionStatus.loading;

  // ── Pilih Gambar ──
  Future<void> pickFromGallery() async {
    await _pickImage(ImageSource.gallery);
  }

  Future<void> pickFromCamera() async {
    await _pickImage(ImageSource.camera);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      _status = DetectionStatus.picking;
      notifyListeners();

      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (picked == null) {
        // User batal pilih → kembalikan state sebelumnya
        _status = hasImage ? DetectionStatus.idle : DetectionStatus.idle;
        notifyListeners();
        return;
      }

      // Gambar baru dipilih → reset hasil sebelumnya
      _selectedImage = File(picked.path);
      _result = null;
      _errorMessage = null;
      _imageSize = Size.zero;

      // Baca dimensi asli gambar untuk scaling bounding box
      final decoded = await decodeImageFromList(
        await _selectedImage!.readAsBytes(),
      );
      _imageSize = Size(
        decoded.width.toDouble(),
        decoded.height.toDouble(),
      );

      _status = DetectionStatus.idle;
      notifyListeners();
    } catch (e) {
      _status = DetectionStatus.error;
      _errorMessage = 'Gagal memilih gambar: $e';
      notifyListeners();
    }
  }

  // ── Deteksi (dipanggil saat tombol "Cek Melon" ditekan) ──
  Future<void> detect() async {
    // Guard: hanya boleh jalan jika ada gambar dan belum ada hasil
    if (_selectedImage == null) return;
    if (_status == DetectionStatus.loading) return;
    if (_result != null) return; // sudah ada hasil, tidak perlu request ulang

    try {
      _status = DetectionStatus.loading;
      _errorMessage = null;
      notifyListeners();

      _result = await _service.predict(_selectedImage!);
      _status = DetectionStatus.success;
    } on ApiException catch (e) {
      _status = DetectionStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = DetectionStatus.error;
      _errorMessage = 'Terjadi kesalahan tidak terduga: $e';
    } finally {
      notifyListeners();
    }
  }

  // ── Reset ke kondisi awal ──
  void reset() {
    _status = DetectionStatus.idle;
    _selectedImage = null;
    _result = null;
    _errorMessage = null;
    _imageSize = Size.zero;
    notifyListeners();
  }

  // ── Tutup banner error tanpa reset gambar ──
  void clearError() {
    _errorMessage = null;
    if (_status == DetectionStatus.error) {
      _status = DetectionStatus.idle;
    }
    notifyListeners();
  }
}