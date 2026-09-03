import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Picks a profile photo from the gallery and returns it as a base64 string.
///
/// The image is resized/compressed by the picker so the resulting base64 stays
/// small enough to store in a Firestore document.
///
/// Returns `null` if the user cancels the selection.
Future<String?> pickProfilePhotoBase64({ImagePicker? picker}) async {
  final imagePicker = picker ?? ImagePicker();
  final XFile? file = await imagePicker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 512,
    maxHeight: 512,
    imageQuality: 70,
  );

  if (file == null) return null;

  final Uint8List bytes = await file.readAsBytes();
  return base64Encode(bytes);
}
