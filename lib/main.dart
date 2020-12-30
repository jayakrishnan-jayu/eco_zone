import 'package:eco_zone/screens/error_page.dart';
import 'package:eco_zone/screens/home_page.dart';
import 'package:eco_zone/screens/loading_page.dart';
import 'package:eco_zone/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Eco Zone",
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.blue,
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
              button: TextStyle(color: Colors.white),
              headline6: TextStyle(
                  fontFamily: "OpenSans",
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
      ),
      home: _getLandingPage(),
    );
  }

  Widget _getLandingPage() {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorPage(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.done) {
          // return HomePage();
          return StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, authSnapshot) {
              print(authSnapshot.connectionState);
              if (authSnapshot.connectionState == ConnectionState.active) {
                User user = authSnapshot.data;
                if (user == null) return LoginScreen();
                print(user.uid);
                return HomePage();
              } else if (authSnapshot.hasError)
                return ErrorPage(authSnapshot.error.toString());
              return LoadingPage();
            },
          );
        }

        return LoadingPage();
      },
    );
  }
}
