import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  Future<File?> cropImage(XFile? imagePick) async {
    if (imagePick != null) {
      final croppedFile = await ImageCropper().cropImage(
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        maxHeight: 128,
        maxWidth: 128,
        sourcePath: imagePick.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 30,
        cropStyle: CropStyle.circle,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepPurple,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              hideBottomControls: true),
          IOSUiSettings(
            title: 'Cropper',
            aspectRatioLockEnabled: true,
          ),
        ],
      );
      if (croppedFile != null) {
        //convert croppedFile to XFile
        File? file = File(croppedFile.path);
        return file;
      }
    }
    return null;
  }

  Future<XFile?> getImageFromFiles() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return pickedFile;
    }
    return null;
  }

  Future<XFile?> takePhoto() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return pickedFile;
    }
    return null;
  }
}
