import 'dart:io';

import 'package:eco_zone/data/post_image_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class PostImageProvider with ChangeNotifier {
  void setPostImageData({
    @required File imageFile,
    @required String title,
    @required String description,
  }) {
    print("inside post image data" + title);
    PostImageData _data = PostImageData(
        imageFile: imageFile, title: title, description: description);
    print(_data.title);
  }

  Future<void> postImage({
    @required File imageFile,
    @required String title,
    @required String description,
  }) async {
    String uid = FirebaseAuth.instance.currentUser.uid;
    DocumentReference ref =
        await FirebaseFirestore.instance.collection("posts").add({
      "title": title,
      "description": description,
      "uid": uid,
      "created": FieldValue.serverTimestamp()
    });

    Reference storageRef =
        FirebaseStorage.instance.ref().child('posts/${ref.id}');
    try {
      await storageRef.putFile(imageFile);
    } on FirebaseException catch (e) {
      print(e);
    }

    print(description);
    print(imageFile);
  }
}
