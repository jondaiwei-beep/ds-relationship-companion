import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Where a proof photo comes from.
enum ProofSource { camera, gallery }

/// Picks one photo and returns it as a JPEG no larger than 1600 px on its
/// long side. Null when the person backed out of the system picker.
///
/// Compression is done by the platform picker itself (`maxWidth`/`maxHeight`/
/// `imageQuality` re-encode as JPEG on both Android and iOS), so no image
/// library ships with the app.
abstract class ProofPicker {
  Future<Uint8List?> pick(ProofSource source);
}

class ImagePickerProofPicker implements ProofPicker {
  ImagePickerProofPicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const maxSide = 1600.0;
  static const quality = 85;

  @override
  Future<Uint8List?> pick(ProofSource source) async {
    final file = await _picker.pickImage(
      source: switch (source) {
        ProofSource.camera => ImageSource.camera,
        ProofSource.gallery => ImageSource.gallery,
      },
      maxWidth: maxSide,
      maxHeight: maxSide,
      imageQuality: quality,
      requestFullMetadata: false,
    );
    if (file == null) return null;
    return file.readAsBytes();
  }
}

final proofPickerProvider = Provider<ProofPicker>((_) => ImagePickerProofPicker());
