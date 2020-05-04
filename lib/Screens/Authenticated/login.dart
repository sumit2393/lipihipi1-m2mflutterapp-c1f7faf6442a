import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterapp/Screens/Authenticated/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;

import '../dashboard.dart';
import 'forgot_pass.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  login(String email, String password) async {
    setState(() {
      isLoading = true;
    });

    Map data = {
      'email': email,
      'password': password,
    };
    var response = await http.post(
        'https://fieldapp.m2mcybernetics.com/api/v1/login',
        body: data,
        headers: {'authkey': 'Bcju0SQW2RKR0vhLzGbjeQwqkJvBUyA4IkMDuNubQq5'});
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print(jsonResponse.toString());
      if (jsonResponse["success"].toString() == 'true') {
        Toast.show("Login Success", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        setTokenRoSf(jsonResponse["token"].toString());
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => DashboardPage()));
      } else {
        setState(() {
          isLoading = false;
        });
        Toast.show("Login Failed", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    } else {
      setState(() {
        isLoading = false;
      });
      debugPrint("Login faild");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.fill,
                    child: Image.asset(
                        "assets/images/m_to_m.png",
                      width: MediaQuery.of(context).size.width,
                      ),
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 25,
                            //fontWeight: FontWeight.w400,
                            fontFamily: 'TofinoRegular',
                          ),
                        ),
                      ),
                     Padding(
                       padding: const EdgeInsets.only(left:15.0,right: 15),
                       child: Column(
                         children: <Widget>[
                           Container(
                             margin: EdgeInsets.only(
                                 left: 5.0, top: 10.0, bottom: 0.0, right: 5.0),
                             child: TextField(
                               controller: emailController,
                               style: TextStyle(
                                 fontFamily: 'Poppins',
                                 color: Color(0xff6a6a6a),
                                 fontSize: 16,
                                 fontWeight: FontWeight.w400,
                                 fontStyle: FontStyle.normal,
                               ),
                               keyboardType: TextInputType.emailAddress,
                               decoration: InputDecoration(
                                 prefixIcon: Icon(
                                   Icons.person_outline,
                                   color: Colors.blueAccent,
                                 ),
                                 enabledBorder: new OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(4.0),
                                   borderSide: BorderSide(
                                       color: Color(0xff64748b), width: 0.2),
                                 ),
                                 border: new OutlineInputBorder(),
                                 filled: true,
                                 fillColor: Colors.white,
                                 labelText: 'Username',
                                 hintStyle: const TextStyle(
                                   fontFamily: 'Poppins',
                                   color: Color(0xff6a6a6a),
                                   fontSize: 16,
                                   fontWeight: FontWeight.w400,
                                   fontStyle: FontStyle.normal,
                                 ),
                               ),
                             ),
                           ),
                           SizedBox(height: 10,),
                           Container(
                             margin: EdgeInsets.only(
                                 left: 5.0, top: 10.0, bottom: 0.0, right: 5.0),
                             child: new TextField(
                               controller: passwordController,
                               style: new TextStyle(
                                 fontFamily: 'Poppins',
                                 color: Color(0xff6a6a6a),
                                 fontSize: 16,
                                 fontWeight: FontWeight.w400,
                                 fontStyle: FontStyle.normal,
                               ),
                               obscureText: true,
                               decoration: InputDecoration(
                                 prefixIcon: Padding(
                                   padding: const EdgeInsets.only(left: 15),
                                   child: Text(
                                     "...",
                                     style: TextStyle(
                                         color: Colors.blueAccent, fontSize: 30),
                                   ),
                                 ),
                                 enabledBorder: new OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(4.0),
                                   borderSide: BorderSide(
                                       color: Color(0xff64748b), width: 0.2),
                                 ),
                                 border: new OutlineInputBorder(),
                                 filled: true,
                                 fillColor: Colors.white,
                                 labelText: 'Password',
                                 hintStyle: const TextStyle(
                                   fontFamily: 'Poppins',
                                   color: Color(0xff6a6a6a),
                                   fontSize: 16,
                                   fontWeight: FontWeight.w400,
                                   fontStyle: FontStyle.normal,
                                 ),
                               ),
                             ),
                           ),
                           SizedBox(height: 15,),
                           Padding(
                             padding: const EdgeInsets.only(right: 7, top: 10),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: <Widget>[
                                 GestureDetector(
                                   onTap:(){
                                     Navigator.of(context).pushReplacement(
                                         MaterialPageRoute(builder: (_) => ForgotPassword()));
                                   },
                                   child: Text(
                                     'Forgot Password?',
                                     style: TextStyle(
                                       color: Colors.black54,
                                       fontSize: 17,
                                       //fontWeight: FontWeight.w400,
                                       fontFamily: 'TofinoRegular',
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                           ),
                         ],
                       ),
                     ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 0.0, top: 30.0, bottom: 0.0, right: 5.0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              child: new GestureDetector(
                                onTap: () {
                                  String emailPattern =
                                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                  RegExp emailRegExp = RegExp(emailPattern);

                                  if (emailController.text.toString() == null ||
                                      passwordController.text.toString() ==
                                          null) {
                                  } else if (!emailRegExp.hasMatch(
                                      emailController.text.toString())) {
                                    print("2");
                                  } else {
                                    login(emailController.text.toString(),
                                        passwordController.text.toString());
                                  }
                                },
                                child: Container(
                                  width: 120,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: new BoxDecoration(
                                      color: Colors.deepOrange,
                                      borderRadius: BorderRadius.circular(3)),
                                  child: Text(
                                    isLoading ? 'Loading...' : 'Login',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

setTokenRoSf(String loginToken) async {
  SharedPreferences shaPref = await SharedPreferences.getInstance();
  shaPref.setString("token", loginToken);
  shaPref.setBool("logincheck", true);
}
