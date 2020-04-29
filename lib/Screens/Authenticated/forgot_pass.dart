import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toast/toast.dart';

import 'login.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool isLoading = false;

  final emailController = TextEditingController();

  forgotPassword(String email) async {
    setState(() {
      isLoading = true;
    });

    Map data = {
      'email': email,
    };
    var response = await http.post(
        'https://fieldapp.m2mcybernetics.com/api/v1/forgot_password',
        body: data,
        headers: {'authkey': 'Bcju0SQW2RKR0vhLzGbjeQwqkJvBUyA4IkMDuNubQq5'});
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print(jsonResponse.toString());
      if (jsonResponse["success"].toString() == 'true') {
        Toast.show(jsonResponse["message"], context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => LoginPage()));
      } else {
        setState(() {
          isLoading = false;
        });
        Toast.show("Forgot password failed", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    } else {
      setState(() {
        isLoading = false;
      });
      Toast.show("Forgot password failed", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 80, 20, 10),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Image.asset(
                        "assets/images/shopping_basket.png",
                        width: 70,
                        height: 70,
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 200, 20, 20),
                        child: Text(
                          'Forgot Password',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 25,
                            //fontWeight: FontWeight.w400,
                            fontFamily: 'TofinoRegular',
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 5.0, top: 10.0, bottom: 0.0, right: 5.0),
                        child: new TextField(
                          controller: emailController,
                          style: new TextStyle(
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
                      Container(
                        margin: EdgeInsets.only(
                            left: 0.0, top: 80.0, bottom: 0.0, right: 5.0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              child: new GestureDetector(
                                onTap: () {
                                  forgotPassword(
                                      emailController.text.toString());
                                },
                                child: Container(
                                  width: 120,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: new BoxDecoration(
                                      color: Colors.deepOrange,
                                      borderRadius: BorderRadius.circular(3)),
                                  child: Text(
                                    isLoading ? 'Loading...' : 'Save',
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
