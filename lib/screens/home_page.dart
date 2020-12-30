import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_zone/data/post_image_data.dart';
import 'package:eco_zone/screens/post_image.dart';
import 'package:eco_zone/services/picture.dart';
import 'package:eco_zone/widgets/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavIndex = 0;
  bool _isLoading = false;
  final limit = 5;
  List<PostImageData> postDataList = [];
  @override
  void initState() {
    // fetchPosts();

    final fbm = FirebaseMessaging();
    fbm.requestNotificationPermissions();
    fbm.configure(
      // onBackgroundMessage: (message) {
      //   print("On background message");
      //   print(message);
      //   return;
      // },
      onLaunch: (message) {
        print("On launch message");
        print(message);
        return;
      },
      onMessage: (message) {
        // while running on foreground
        print("On message message");
        print(message);
        return;
      },
      onResume: (message) {
        // while app is minimized
        print("On resume message");
        print(message);
        return;
      },
    );
    // fbm.getToken(); // Used to retrieve a token that is unique to every app that can be used to send message from server.
    // fbm.subscribeToTopic("test"); // Subscribes to topic "test" which can be used to send notification based on topic.
    super.initState();
  }

  Widget _customModalBottomSheet() {
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
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => PostImage(imageFile),
                    ));
                }),
            new ListTile(
              leading: new Icon(Icons.photo_camera),
              title: new Text('Camera'),
              onTap: () async {
                Navigator.of(context).pop();
                File imageFile = await Picture.getImage(ImageFrom.gallery);
                if (imageFile != null)
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => PostImage(imageFile),
                  ));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<PostImageData> getPost(QueryDocumentSnapshot element) async {
    print(element.id);
    print("get post called");
    var foo = element.data();
    String imageUrl;
    String profileUrl;
    var retry = false;
    var count = 1;
    do {
      try {
        imageUrl = await FirebaseStorage.instance
            .ref("posts")
            .child(element.id)
            .getDownloadURL();

        profileUrl = await FirebaseStorage.instance
            .ref("users")
            .child(foo["uid"])
            .getDownloadURL();
        retry = false;
      } catch (e) {
        print(e);
        retry = count <= limit ? true : false;
      }
    } while (retry);

    var name = (await FirebaseFirestore.instance
        .collection("users")
        .doc(foo["uid"])
        .get())["username"];

    print("profile url: " + profileUrl);
    // postDataList.add(
    var date = DateTime.parse(foo["created"].toDate().toString());

    print(date);
    PostImageData data = PostImageData(
        uid: foo["uid"],
        description: foo["description"],
        profileUrl: profileUrl,
        username: name,
        created: date.toLocal().toString(),
        imageUrl: imageUrl,
        title: foo["title"]);
    print("The data is ${data.created}");
    return data;
    // ):
    // FirebaseFirestore.instance
    //     .collection("users")
    //     .doc(uid)
    //     .get()
    //     .then((value) => print(value));
    // Reference ref = FirebaseStorage.instance.ref().child("posts/$uid");
    // String url = (await ref.getDownloadURL()).toString();
    // );
  }

  void fetchPosts() async {
    // setState(() {
    //   _isLoading = true;
    //   print("Started fetching data");
    // });

    FirebaseFirestore.instance
        .collection("posts")
        .orderBy("created", descending: false)
        .snapshots()
        .listen((result) {
      result.docs.forEach((element) async {
        var foo = element.data();
        print(element.id);
        var imageUrl = await FirebaseStorage.instance
            .ref("posts")
            .child(element.id)
            .getDownloadURL();
        var profileUrl = await FirebaseStorage.instance
            .ref("users")
            .child(foo["uid"])
            .getDownloadURL();
        print(profileUrl);
        postDataList.add(PostImageData(
            uid: foo["uid"],
            description: foo["description"],
            profileUrl: profileUrl,
            created: foo["created"],
            imageUrl: imageUrl,
            title: foo["title"]));
        // FirebaseFirestore.instance
        //     .collection("users")
        //     .doc(uid)
        //     .get()
        //     .then((value) => print(value));
        // Reference ref = FirebaseStorage.instance.ref().child("posts/$uid");
        // String url = (await ref.getDownloadURL()).toString();
      });

      // setState(() {
      //   print("Done fetching posts");
      //   postDataList = postDataList;
      //   _isLoading = false;
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Fetching");

    print("Done fetching");
    return Scaffold(
      appBar: AppBar(
        title: Text("Eco Zone"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                FirebaseAuth.instance.signOut();
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (BuildContext bc) {
                return _customModalBottomSheet();
              });
          // showDialog(
          //   context: context,
          //   builder: (context) => AlertDialog(
          //     title: Text("Title"),
          //     content: Text("Content"),
          //     actions: [Icon(Icons.add)],
          //   ),
          // );
        },
        //params
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: [
          Icons.access_alarm,
          Icons.account_circle,
          Icons.picture_as_pdf,
          Icons.camera
        ],
        activeColor: Colors.orange,
        splashColor: Colors.orange,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.defaultEdge,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        //other params
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("posts")
                      .orderBy("created", descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData ||
                        snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return ListView.separated(
                        itemCount: snapshot.data.docs.length,
                        separatorBuilder: (context, index) => SizedBox(
                              height: 10,
                            ),
                        itemBuilder: (context, index) {
                          return FutureBuilder(
                            future: getPost(snapshot.data.docs[index]),
                            builder: (context, futureSnapshot) {
                              print("Had data");
                              print(futureSnapshot.hasData);
                              print(futureSnapshot.connectionState);
                              if (futureSnapshot.connectionState ==
                                  ConnectionState.done) {
                                print("Future snapshot " +
                                    futureSnapshot.data.toString());
                                return Post(futureSnapshot.data);
                              }
                              print("inside loading:");
                              print(futureSnapshot.connectionState);
                              print(futureSnapshot.hasData);
                              print(futureSnapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !futureSnapshot.hasData);
                              return Center(
                                child: Text("Loading"),
                              );
                            },
                          );
                        });
                  }),
            ),
    );
  }
}
