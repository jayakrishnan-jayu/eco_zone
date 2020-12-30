import 'dart:io';
import 'package:flutter/material.dart';

class PostImageData {
  final File imageFile;
  final String imageUrl;
  final String username;
  final String profileUrl;
  final String created;
  final String title;
  final String description;
  final String uid;

  PostImageData({
    this.imageFile,
    this.title,
    this.username,
    this.imageUrl,
    this.profileUrl,
    this.created,
    this.description,
    this.uid,
  });
}
