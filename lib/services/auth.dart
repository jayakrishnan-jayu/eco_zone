import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_zone/providers/post_image_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

enum AuthResultStatus {
  successful,
  emailAlreadyExists,
  wrongPassword,
  invalidEmail,
  userNotFound,
  userDisabled,
  operationNotAllowed,
  tooManyRequests,
  undefined,
}

class AuthExceptionHandler {
  static handleException(e) {
    print(e.code);
    var status;
    switch (e.code) {
      case "invalid-email":
        status = AuthResultStatus.invalidEmail;
        break;
      case "ERROR_WRONG_PASSWORD":
      case "wrong-password":
        status = AuthResultStatus.wrongPassword;
        break;
      case "ERROR_USER_NOT_FOUND":
      case "user-not-found":
        status = AuthResultStatus.userNotFound;
        break;
      case "ERROR_USER_DISABLED":
        status = AuthResultStatus.userDisabled;
        break;
      case "ERROR_TOO_MANY_REQUESTS":
        status = AuthResultStatus.tooManyRequests;
        break;
      case "operation-not-allowed":
        status = AuthResultStatus.operationNotAllowed;
        break;
      case "email-already-exists":
        status = AuthResultStatus.emailAlreadyExists;
        break;
      default:
        status = AuthResultStatus.undefined;
    }
    return status;
  }

  static generateExceptionMessage(exceptionCode) {
    String errorMessage;
    switch (exceptionCode) {
      case AuthResultStatus.invalidEmail:
        errorMessage = "Your email address appears to be malformed.";
        break;
      case AuthResultStatus.wrongPassword:
        errorMessage = "Your password is wrong.";
        break;
      case AuthResultStatus.userNotFound:
        errorMessage = "User with this email doesn't exist.";
        break;
      case AuthResultStatus.userDisabled:
        errorMessage = "User with this email has been disabled.";
        break;
      case AuthResultStatus.tooManyRequests:
        errorMessage = "Too many requests. Try again later.";
        break;
      case AuthResultStatus.operationNotAllowed:
        errorMessage = "Signing in with Email and Password is not enabled.";
        break;
      case AuthResultStatus.emailAlreadyExists:
        errorMessage =
            "The email has already been registered. Please login or reset your password.";
        break;
      default:
        errorMessage = "An undefined Error happened.";
    }

    return errorMessage;
  }
}

class Auth {
  final _auth = FirebaseAuth.instance;
  AuthResultStatus _status;

  AuthResultStatus get authResultStatus {
    return _status;
  }

  Future<AuthResultStatus> registerUser(
      String username, String email, String password, File imageFile) async {
    try {
      User user = (await _auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;

      if (user != null) {
        _status = AuthResultStatus.successful;
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .set({"username": username, "email": email});
        Reference storageRef =
            FirebaseStorage.instance.ref().child('users/${user.uid}');
        try {
          await storageRef.putFile(imageFile);
        } on FirebaseException catch (e) {
          print(e);
        }
      } else
        _status = AuthResultStatus.undefined;
      return _status;
    } on FirebaseAuthException catch (e) {
      print("Exception @registerUser: $e");
      _status = AuthExceptionHandler.handleException(e);
      return _status;
    } catch (e) {
      _status = AuthResultStatus.undefined;
      return _status;
    }
  }

  Future<AuthResultStatus> login(String email, String password) async {
    try {
      print("Logging in...");
      User user = (await _auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      if (user != null)
        _status = AuthResultStatus.successful;
      else
        _status = AuthResultStatus.undefined;

      print("Done logging in..");
      return _status;
    } on FirebaseAuthException catch (e) {
      print("Exception @login: $e");
      print(e);
      _status = AuthExceptionHandler.handleException(e);
      print("returning $_status");
      return _status;
    } catch (e) {
      _status = AuthResultStatus.undefined;
      return _status;
    }
  }
}
