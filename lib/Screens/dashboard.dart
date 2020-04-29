import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/Screens/SiteSurvey/site_survey_list.dart';
import 'package:flutterapp/Utility/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:toast/toast.dart';

import '../check.dart';
import 'Authenticated/login.dart';
import 'Installation/installation_list.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  bool isLoading = false;

  List listData = ['Site Survey', 'Installations', 'M2M Audit', 'CSCAT'];
  List pagelist = [ SiteSurveyPage(), InstallationPage(), ' ', ' '];
  List pendList ;

  logoutAPI() async {
    setState(() {
      isLoading = true;
    });
      SharedPreferences shaPref = await SharedPreferences.getInstance();
      var apiToken = shaPref.get("token");
    var response = await http.get(
        'https://fieldapp.m2mcybernetics.com/api/v1/logout?token=$apiToken',
        headers: {'authkey': 'Bcju0SQW2RKR0vhLzGbjeQwqkJvBUyA4IkMDuNubQq5'});
    if (response.statusCode == 200) {

      SharedPreferences preferences = await SharedPreferences.getInstance();
      for (String key in preferences.getKeys()) {
        if (key == "token" || key == "logincheck") {
          preferences.remove(key);
        }
      }
      preferences.clear();
      var jsonResponse = json.decode(response.body);
      print(jsonResponse.toString());
      if (jsonResponse["success"].toString() == 'true') {
        Toast.show("Logout Success", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else {
        Toast.show("Logout failed", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        _stopAnimation();
      }
    } else {
      debugPrint("Logout failed");
      _stopAnimation();
    }
  }

  dashboard_data()async{

    setState(() {
      isLoading = true;
    });

    SharedPreferences shaPref = await SharedPreferences.getInstance();
    var Token = shaPref.get("token");
    var response = await http.get(
        'https://fieldapp.m2mcybernetics.com/api/v1/dashboard?token=$Token',
        headers: {'authkey': 'Bcju0SQW2RKR0vhLzGbjeQwqkJvBUyA4IkMDuNubQq5'}
        );
    debugPrint(response.body.toString());
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print(jsonResponse.toString());
      print(jsonResponse['message']['pending_survery'].toString(),);
      pendList = [
        jsonResponse['message']['pending_survery'].toString(),
        jsonResponse['message']['pending_installation'].toString(),
        '', ''
      ];

      _stopAnimation();

    } else {
      print("Dashboard Faild");
      _stopAnimation();
    }
  }

  Future<Null> _stopAnimation() async {
    try {
      setState(
            () {
          isLoading = false;
        },
      );
    } on TickerCanceled {}
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dashboard_data();
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
          height: 100,
          margin: EdgeInsets.only(top: 60),
          decoration: BoxDecoration(color: Color(0x80787878)),
          child: kLoadingWidget(context));
    }
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'Dashboard',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
              ),
            ),
          ),
          backgroundColor: Colors.black,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => ListenPage()),
                );
              },
            )
          ],
        ),
        drawer: Drawer(
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      Colors.black,
                      Colors.deepOrange,
                    ],
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 80.0, left: 15.0, bottom: 20.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: ListTile(
                            title: Text('Dashboard',
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                )),
                            onTap: () {
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => DashboardPage()),
                                );
                            },
                            trailing: Icon(Icons.keyboard_arrow_right,
                                size: 20, color: Colors.white),
                          ),
                        ),
                        Divider(
                          height: 1.0,
                          thickness: 0.5,
                          indent: 0.0,
                          endIndent: 0.0,
                          color: Colors.white,
                        ),
                        Container(
                          child: ListTile(
                            title: Text('Profile',
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                )),
                            onTap: () {
                              /*Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => MyProfileScreenPage()),
                                );*/
                            },
                            trailing: Icon(Icons.keyboard_arrow_right,
                                size: 20, color: Colors.white),
                          ),
                        ),
                        Divider(
                          height: 1.0,
                          thickness: 0.5,
                          indent: 0.0,
                          endIndent: 0.0,
                          color: Colors.white,
                        ),
                        Container(
                          child: ListTile(
                            title: Text('Site Survey',
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                )),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => SiteSurveyPage()),
                              );
                            },
                            trailing: Icon(Icons.keyboard_arrow_right,
                                size: 20, color: Colors.white),
                          ),
                        ),
                        Divider(
                          height: 1.0,
                          thickness: 0.5,
                          indent: 0.0,
                          endIndent: 0.0,
                          color: Colors.white,
                        ),
                        Container(
                          child: ListTile(
                            title: Text('Installations',
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                )),
                            onTap: () {
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => InstallationPage()),
                                );
                            },
                            trailing: Icon(Icons.keyboard_arrow_right,
                                size: 20, color: Colors.white),
                          ),
                        ),
                        Divider(
                          height: 1.0,
                          thickness: 0.5,
                          indent: 0.0,
                          endIndent: 0.0,
                          color: Colors.white,
                        ),
                        Container(
                          child: ListTile(
                            title: Text('M2M Audit',
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                )),
                            onTap: () => {},
                            trailing: Icon(Icons.keyboard_arrow_right,
                                size: 20, color: Colors.white),
                          ),
                        ),
                        Divider(
                          height: 1.0,
                          thickness: 0.5,
                          indent: 0.0,
                          endIndent: 0.0,
                          color: Colors.white,
                        ),
                        Container(
                          child: ListTile(
                            title: Text('CSC AT',
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                )),
                            onTap: () => {
                              /*Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CallRecordingScreenPage(),
                                  ),
                                ),*/
                            },
                            trailing: Icon(Icons.keyboard_arrow_right,
                                size: 20, color: Colors.white),
                          ),
                        ),
                        Divider(
                          height: 1.0,
                          thickness: 0.5,
                          indent: 0.0,
                          endIndent: 0.0,
                          color: Colors.white,
                        ),
                        Container(
                          child: ListTile(
                            title: Text('Logout',
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                )),
                            onTap: () => logoutAPI(),
                            trailing: Icon(Icons.keyboard_arrow_right,
                                size: 20, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(color: Color(0xE5F4FD)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            "Lorem ipsum dolor sit amet, consetetur",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                        Text(
                          "Sadipscing eliter, sed diam nonumy eirmod",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: ListView.builder(
                        itemCount: listData.length,
                        itemBuilder: (context, index) {
                          return Column(children: [
                            Row(
                              key: ValueKey('1'),
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                       MaterialPageRoute(
                                         builder: (_) => pagelist[index],
                                       ),
                                     );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Colors.black54
                                                  .withOpacity(0.4),
                                              width: 0.2),
                                          borderRadius: new BorderRadius.all(
                                              Radius.circular(10.0))),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                              child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 50, 0, 50),
                                            child: Column(
                                              children: <Widget>[
                                                Text(
                                                  pendList[index],
                                                  style: TextStyle(
                                                    fontSize: 30,
                                                    color: Colors.deepOrange
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 0),
                                                  child: Text(
                                                    "Pending",
                                                    style: TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 14),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 90, 0, 0),
                                              child: Column(
                                                children: <Widget>[
                                                  Text(
                                                    listData[index],
                                                    style: TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 18),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            right: 30,
                                                            left: 30,
                                                            bottom: 0),
                                                    child: Divider(
                                                      color: Colors.deepOrange,
                                                      height: 1,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 25.0),
                          ]);
                        }),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
