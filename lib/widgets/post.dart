import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:eco_zone/data/post_image_data.dart';

class Post extends StatefulWidget {
  PostImageData data;
  Post(this.data);

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  // final String description =
  //     "is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum";

  bool readMore = false;
  bool largeDescription = false;
  // final String postPic =
  //     "https://firebasestorage.googleapis.com/v0/b/eco-zone.appspot.com/o/posts%2FHU3ff701ACYbELcIfcNG?alt=media&token=41eff015-3512-422d-8337-143be63b49fe";
  // final String proPic =
  //     "https://scontent.fcok7-1.fna.fbcdn.net/v/t1.0-9/83693811_1505971276225000_2147387801509822464_o.jpg?_nc_cat=107&ccb=2&_nc_sid=09cbfe&_nc_ohc=nXqOZmnm4-oAX-IvjVf&_nc_ht=scontent.fcok7-1.fna&oh=0322aab02690a9205e13b8a4d8723b3e&oe=60047865";
  Widget postUserName() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 15,
              child: Text(widget.data.username,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 13,
                  ))),
          Container(
              height: 15,
              child: Text(widget.data.created,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300))),
        ],
      ),
    );
  }

  Widget postTitle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child: Text(widget.data.title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget postImage(height, width) {
    return Image.network(widget.data.imageUrl,
        height: height * .3, width: width, fit: BoxFit.cover);
  }

  Widget postDescription() {
    largeDescription = widget.data.description.length >= 40;
    String desc;
    String end = readMore ? "Show Less" : "Read More";
    bool showButton = false;
    if (largeDescription && readMore) {
      desc = widget.data.description;
      showButton = true;
    } else if (largeDescription && !readMore) {
      desc = widget.data.description.substring(0, 38);
      showButton = true;
    } else {
      desc = widget.data.description;
      showButton = false;
    }
    var output;
    if (showButton)
      output = RichText(
          text: TextSpan(children: [
        TextSpan(text: desc + "end", style: TextStyle(color: Colors.black)),
        TextSpan(
            text: " " + end,
            style: TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                setState(() {
                  readMore = !readMore;
                });
              })
      ]));
    else
      output = RichText(
          text: TextSpan(text: desc, style: TextStyle(color: Colors.black)));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [Expanded(child: output)],
      ),
    );
  }

  Widget postRepond() {
    return Container(
      color: Color(0xFFF1F1F1),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.thumb_up),
            ),
            VerticalDivider(
              indent: 10,
              endIndent: 10,
              thickness: 1,
            ),
            IconButton(
              icon: Icon(Icons.message),
            ),
            VerticalDivider(
              indent: 10,
              endIndent: 10,
              thickness: 1,
            ),
            IconButton(
              icon: Icon(Icons.share),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("data = :" + widget.data.toString());
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return (Container(
        color: Color(0xFFF1F1F1),
        width: width,
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    widget.data.profileUrl,
                    height: 30,
                    width: 30,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                SizedBox(width: 10),
                postUserName()
              ],
            ),
            SizedBox(height: 15),
            postTitle(),
            SizedBox(height: 12),
            postImage(height, width),
            SizedBox(height: 12),
            postDescription(),
            SizedBox(height: 5),
            postRepond(),
            SizedBox(height: 3),
          ],
        )));
  }
}
