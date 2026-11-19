import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'receipt_parser.dart';

enum ScanFailure { cancelled, noText, error }

class ScanResult {
  const ScanResult({this.guess, this.failure});
  final ReceiptGuess? guess;
  final ScanFailure? failure;
}

/// Takes a photo with the phone's camera app and reads it with Google ML Kit
/// text recognition, which runs fully ON THE DEVICE: the photo never leaves
/// the phone and is deleted right after reading.
///
/// Limitation: ML Kit's on-device recognizer supports Latin script (not
/// Bangla letters). Most receipts print prices in Latin digits, so totals
/// work. Bangla-only receipts may need manual entry (see docs/12).
class ReceiptScanner {
  final _picker = ImagePicker();

  Future<ScanResult> scan() async {
    XFile? photo;
    try {
      // The system camera app takes the photo, so Bolo needs no CAMERA permission.
      photo = await _picker.pickImage(source: ImageSource.camera, maxWidth: 2000, imageQuality: 85);
      if (photo == null) return const ScanResult(failure: ScanFailure.cancelled);

      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      try {
        final text = await recognizer.processImage(InputImage.fromFilePath(photo.path));
        if (text.text.trim().isEmpty) return const ScanResult(failure: ScanFailure.noText);
        return ScanResult(guess: parseReceipt(text.text));
      } finally {
        await recognizer.close();
      }
    } catch (e) {
      debugPrint('Receipt scan failed: $e');
      return const ScanResult(failure: ScanFailure.error);
    } finally {
      // Privacy: delete the photo as soon as we're done.
      if (photo != null) {
        try {
          await File(photo.path).delete();
        } catch (_) {}
      }
    }
  }
}
