import 'package:flutter/material.dart';

import '../dashboard.dart';



class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15,80,20,10),
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
                        padding: const EdgeInsets.fromLTRB(20,200,20,20),
                        child: Text(
                          'Register',
                          style: TextStyle(color: Colors.black54,
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
                          style: new TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xff6a6a6a),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                          ),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person_outline,color: Colors.blueAccent,),

                            enabledBorder: new OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.0),
                              borderSide: BorderSide(color: Color(0xff64748b), width: 0.2),
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
                            left: 5.0, top: 10.0, bottom: 0.0, right: 5.0),
                        child: new TextField(
                          style: new TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xff6a6a6a),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                          ),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Text("...",
                                style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 30
                                ),
                              ),
                            ),
                            enabledBorder: new OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.0),
                              borderSide: BorderSide(color: Color(0xff64748b), width: 0.2),
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
                      Container(
                        margin: EdgeInsets.only(
                            left: 0.0, top: 30.0, bottom: 0.0, right: 5.0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              child: new GestureDetector(
                                onTap: (){
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                                    builder: (context) => DashboardPage(),
                                  ));
                                },
                                child: Container(
                                  width: 120,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: new BoxDecoration(
                                      color: Colors.deepOrange,
                                      borderRadius: BorderRadius.circular(3)),
                                  child: Text(
                                    'Save',
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
