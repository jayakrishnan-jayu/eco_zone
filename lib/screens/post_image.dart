import 'dart:io';

import 'package:eco_zone/providers/post_image_provider.dart';
import 'package:eco_zone/widgets/clipper_art.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostImage extends StatefulWidget {
  final File _imageFile;
  PostImage(this._imageFile);
  @override
  _PostImageState createState() => _PostImageState();
}

class _PostImageState extends State<PostImage> {
  final _formKey = GlobalKey<FormState>();
  String _title;
  String _description;
  bool _isLoading = false;

  Widget _image(width, height) {
    return Center(
      child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              offset: Offset(2, 4),
              blurRadius: 5,
              spreadRadius: 2,
            )
          ]),
          width: width * .8,
          height: height * .2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.0),
            child: Image.file(widget._imageFile),
          )),
    );
  }

  String titleValidator(String value) {
    if (value.length >= 6) {
      _title = value;
      return null;
    }
    return "Title must be atleast 4 characters";
  }

  String descValidator(String value) {
    if (value.length >= 6) {
      print("value while validatinog" + value);
      _description = value;
      print(_title);
      return null;
    }
    return "Description must be atleast 6 characters";
  }

  Widget _entryField(
      String title, TextInputType textInputType, Function validate) {
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
            keyboardType: textInputType,
            minLines: 1,
            maxLines: 5,
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

  Widget _postButton(BuildContext ctx) {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState.validate()) {
          print("From post button method");
          print(_title);
          print(_description);
          setState(() {
            _isLoading = true;
          });
          await Provider.of<PostImageProvider>(ctx, listen: false).postImage(
              imageFile: widget._imageFile,
              title: _title,
              description: _description);

          setState(() {
            _isLoading = false;
          });

          Navigator.of(context).pop();
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
            "Post",
            style: TextStyle(fontSize: 20, color: Colors.white),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        child: ChangeNotifierProvider<PostImageProvider>(
          create: (context) => PostImageProvider(),
          builder: (ctx, child) {
            return Stack(
              children: [
                Positioned(
                  top: -height * .15,
                  right: -width * .6,
                  child: ClipperArt(),
                ),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                        child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: height * .2),
                                _image(width, height),
                                SizedBox(height: 50),
                                _entryField("Title", TextInputType.text,
                                    titleValidator),
                                SizedBox(height: 50),
                                _entryField("Description",
                                    TextInputType.multiline, descValidator),
                                SizedBox(height: 50),
                                _postButton(ctx),
                              ],
                            )))),
                if (_isLoading) Center(child: CircularProgressIndicator()),
              ],
            );
          },
        ),
      ),
    );
  }
}
