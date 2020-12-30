import 'dart:io';

import 'package:eco_zone/providers/post_image_provider.dart';
import 'package:eco_zone/services/auth.dart';
import 'package:eco_zone/services/picture.dart';
import 'package:eco_zone/widgets/clipper_art.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _imageNotSelected = false;
  bool _authStatusMessage = false;
  String _statusMessage;
  Auth _appAuth = Auth();

  String _username;
  String _email;
  String _password;
  File _imageFile;

  Widget _title() {
    return Text(
      "Eco Zone",
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: Color(0xffe46b10),
      ),
    );
  }

  Widget _customModalBottomSheet() {
    print("options selected");
    return SafeArea(
      child: Container(
        child: new Wrap(
          children: <Widget>[
            new ListTile(
                leading: new Icon(Icons.photo_library),
                title: new Text('Photo Library'),
                onTap: () async {
                  Navigator.of(context).pop();
                  File imageFile = await Picture.getImage(ImageFrom.gallery);
                  if (imageFile != null)
                    setState(() {
                      _imageFile = imageFile;
                      print("image file is set");
                      print(_imageFile.path);

                      _imageNotSelected = false;
                    });

                  //   Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (_) => PostImage(imageFile),
                  //   ));
                }),
            new ListTile(
              leading: new Icon(Icons.photo_camera),
              title: new Text('Camera'),
              onTap: () async {
                Navigator.of(context).pop();
                File imageFile = await Picture.getImage(ImageFrom.gallery);
                if (imageFile != null)
                  setState(() {
                    _imageFile = imageFile;
                    _imageNotSelected = false;
                  });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _profilePicture() {
    print("Profile picture widget created");
    String src =
        "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&dpr=3&h=750&w=1260";
    return GestureDetector(
      onTap: () => showModalBottomSheet(
          context: context, builder: (context) => _customModalBottomSheet()),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(120.0),
          child: _imageFile != null
              ? Image.file(
                  _imageFile,
                  height: 100.0,
                  width: 100.0,
                  fit: BoxFit.fitWidth,
                )
              : Image.asset(
                  "assets/images/placeholder.png",
                  height: 100,
                  width: 100,
                )),
    );
  }

  Widget _entryField(
      String title, TextInputType textInputType, Function validate,
      {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            validator: (value) => validate(value),
            obscureText: isPassword,
            keyboardType: textInputType,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
            ),
          )
        ],
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: [
        _entryField("Email", TextInputType.emailAddress, emailValidator),
        _entryField("Password", TextInputType.text, passwordValidator,
            isPassword: true),
      ],
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        print("is image null " + (_imageFile == null ? "1" : "0"));
        if (_imageFile == null && !_isLogin)
          setState(() {
            _imageNotSelected = true;
          });
        else if (_formKey.currentState.validate()) {
          setState(() {
            _isLoading = true;
            print("is loading is set to true");
          });
          print(
              "validated with username: $_username, email: $_email, password $_email");
          AuthResultStatus status;
          if (_isLogin)
            status = await _appAuth.login(_email, _password);
          else
            status = await _appAuth.registerUser(
                _username, _email, _password, _imageFile);

          if (status != AuthResultStatus.successful)
            setState(() {
              _authStatusMessage = true;
              print(status);
              _statusMessage =
                  AuthExceptionHandler.generateExceptionMessage(status);
            });
          setState(() {
            _isLoading = false;
            print("is loading is set to false");
          });
        }
      },
      child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2,
              )
            ],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xfffbb448), Color(0xfff7892b)]),
          ),
          child: Text(
            _isLogin ? "Login" : "Signup",
            style: TextStyle(fontSize: 20, color: Colors.white),
          )),
    );
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Divider(
              thickness: 1,
            ),
          ))
        ],
      ),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        setState(() {
          _isLogin = !_isLogin;
        });
      },
      child: Container(
        alignment: Alignment.bottomCenter,
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLogin ? "Don't have an account ?" : "Already have an account",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 10),
            Text(
              _isLogin ? "Register" : "Login",
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginWidget(double height, double width) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: height * .2),
              _title(),
              if (!_isLogin) SizedBox(height: 30),
              if (!_isLogin) _profilePicture(),
              if (_imageNotSelected)
                Text(
                  "Image is required",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 20),
              if (!_isLogin)
                _entryField(
                  "Username",
                  TextInputType.text,
                  usernameValidator,
                ),
              if (!_isLogin) SizedBox(height: 10),
              _emailPasswordWidget(),
              SizedBox(height: 20),
              if (_authStatusMessage)
                Text(
                  _statusMessage,
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              if (_authStatusMessage) SizedBox(height: 20),
              _submitButton(),
              SizedBox(height: 20),
              _divider(),
              _createAccountLabel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget loadingWidget() {
    return Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  String emailValidator(String value) {
    if (RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value)) {
      _email = value;
      return null;
    }
    return "Invalid Email";
  }

  String passwordValidator(String value) {
    if (value.length >= 6) {
      _password = value;
      return null;
    }
    return "Password length must be atleast 6 characters";
  }

  String usernameValidator(String value) {
    if (value.length >= 4) {
      _username = value;
      return null;
    }
    return "Username must be atleast 4 characters";
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        child: Stack(
          children: [
            Positioned(
              top: -height * .15,
              right: -width * .4,
              child: ClipperArt(),
            ),
            _isLoading ? loadingWidget() : _loginWidget(height, width)
          ],
        ),
      ),
    );
  }
}
