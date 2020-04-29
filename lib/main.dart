import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/Authenticated/login.dart';
import 'Screens/dashboard.dart';

void main() => runApp( Main() );

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}



class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {



  Future getTokenRoSf() async {

    SharedPreferences shaPref = await SharedPreferences.getInstance();
    bool login ;

    login = shaPref.get("logincheck");

    print("ffffffffffffffffffffffffffffffffffff$login");

    if (login == true) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => DashboardPage(),
      ));
    }
    else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => LoginPage(),
      ));
    }
  }


@override
  void initState() {
    // TODO: implement initState
    super.initState();
    new Timer(new Duration(milliseconds: 0), () async {
      getTokenRoSf();
    });
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        body: Text(" "),
      );

  }
}




/*
MaterialApp(
    home: (checkUserAndNavigate(context) == true) ? DashboardPage(): LoginPage(),
);

Future checkUserAndNavigate(BuildContext context) async {
  bool status;
  print("Checking user stateyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy");
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String userdata = preferences.getString("token");
  print("Checking user stateddddddddddddddddddd"+userdata);

  if (userdata == null) {
    status = false;
  } else {
    status = true;
  }
  print("rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr"+userdata);
  return status;
}*/
