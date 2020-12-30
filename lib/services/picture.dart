import 'dart:io';
import 'package:flutter/material.dart';
import 'package:eco_zone/errors/image_error.dart';
import 'package:image_picker/image_picker.dart';

enum ImageFrom { gallery, camera }

class Picture {
  static Future<File> _imageFromCamera() async {
    final PickedFile pickedFile = await ImagePicker.platform
        .pickImage(source: ImageSource.camera, imageQuality: 50);

    if (pickedFile == null) throw ImageError("No Image selected");

    return File(pickedFile.path);
  }

  static Future<File> _imageFromGallery() async {
    PickedFile pickedFile = await ImagePicker.platform
        .pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile == null) throw ImageError("No Image selected");

    return File(pickedFile.path);
  }

  // static Future<void> showImage(BuildContext ctx,
  //     {File imageFile, String error = ""}) {
  //   return showDialog<void>(
  //     context: ctx,
  //     builder: (context) {
  //       if (imageFile == null) {
  //         return Dialog(
  //           child: Container(
  //             child: Text(error),
  //           ),
  //         );
  //       } else {
  //         return CircleAvatar(
  //           radius: 55,
  //           backgroundColor: Colors.grey,
  //           child: Image.file(
  //             imageFile,
  //             height: 100,
  //             width: 100,
  //           ),
  //         );
  //       }
  //     },
  //   );
  // }

  static Future<File> getImage(ImageFrom imageFrom) async {
    File imageFile;

    try {
      imageFile = await (imageFrom == ImageFrom.camera
          ? _imageFromCamera()
          : _imageFromGallery());
    } on ImageError catch (e) {
      return null;
    }
    return imageFile;
  }
}
