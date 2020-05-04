import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/Screens/Installation/installation_edit.dart';
import 'package:flutterapp/Screens/dashboard.dart';
import 'package:flutterapp/Screens/SiteSurvey/site_survey_submit.dart';
import 'package:flutterapp/Utility/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'installation_submit.dart';

class InstallationPage extends StatefulWidget {
  @override
  _InstallationPageState createState() => _InstallationPageState();
}

class _InstallationPageState extends State<InstallationPage> {

  bool btn1 = true;
  bool btn2 = false;

  int pedding_count;
  int completed_count;

  bool isLoading = false;
  bool isToken = false;
  bool isDeclare = false;
  String apiToken = '';
  List<SurveyListItem> pendingLiveData;
  List<SurveyListItem> completedLiveData;
  //List<SurveyListItem> notFeasibilityLiveData;

  getTokenRoSf() async {
    SharedPreferences shaPref = await SharedPreferences.getInstance();
    apiToken = shaPref.get("token");
    print('apiToken: '+apiToken);
    setState(() {
      isToken = true;
      isDeclare = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isDeclare) {
      pendingLiveData = [];
      completedLiveData = [];
      getTokenRoSf();
    }

    if (isToken) {
      listOfSurvey();
    }

    if (isLoading) {
      return Container(
          height: 100,
          margin: EdgeInsets.only(top: 60),
          decoration: BoxDecoration(color: Color(0x80787878)),
          child: kLoadingWidget(context));
    }
    pedding_count = pendingLiveData.length;
    completed_count = completedLiveData.length;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Installation',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => DashboardPage()),
              );
            }),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onPressed: null,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(219, 246, 255, 10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 15, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  height: 50.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Icon(
                          Icons.search,
                          color: Colors.blue,
                        ),
                      ),
                      Flexible(
                        child: TextFormField(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(0.0),
                            hintText: 'Search by name, mobile',
                            hintStyle: TextStyle(
                              color: Colors.blue,
                              fontSize: 15.0,
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 50,
                color: Colors.white,
                child: Center(
                  child: Text("Lorem ipsum dolor sit amet, consetetur"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 20, left: 5, right: 5),
                child: Container(
                  height: 40,
                  color: Color.fromRGBO(219, 246, 255, 10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            RaisedButton(
                              child: new Text('Pending'),
                              textColor: Colors.black,
                              elevation: 0,
                              color: btn1
                                  ? Colors.white
                                  : Color.fromRGBO(219, 246, 255, 10),
                              onPressed: () {
                                setState(() {
                                  btn1 = true;
                                  btn2 = false;
                                });
                              },
                            ),
                             Padding(
                              padding: const EdgeInsets.fromLTRB(72,0,0,0),
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                    color:btn1
                                        ? Color.fromRGBO(219, 246, 255, 10)
                                        : Colors.white,
                                  shape: BoxShape.circle
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text("$pedding_count",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            RaisedButton(
                              child: new Text('Completed'),
                              textColor: Colors.black,
                              elevation: 0,
                              color: btn2
                                  ? Colors.white
                                  : Color.fromRGBO(219, 246, 255, 10),
                              onPressed: () {
                                setState(() {
                                  btn1 = false;
                                  btn2 = true;
                                });
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(85,0,0,0),
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                    color:btn2
                                        ? Color.fromRGBO(219, 246, 255, 10)
                                        : Colors.white,
                                    shape: BoxShape.circle
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text("$completed_count",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(

                            color: Color.fromRGBO(219, 246, 255, 10),


                        ),
                      ),
                      /*Icon(Icons.search, color: Colors.deepOrange,)*/
                    ],
                  ),
                ),
              ),
              btn1
                  ? Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.0, right: 15.0),
                      child: ListView.builder(
                        itemCount: pendingLiveData.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Row(
                                key: ValueKey('1'),
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                InstallationSubmitPage(
                                                  installationId: pendingLiveData[index].id.toString(),
                                                  projectId: pendingLiveData[index].userId.toString(),
                                                  title: pendingLiveData[
                                                  index]
                                                      .gramPanchayatName,
                                                  gpName: pendingLiveData[
                                                  index]
                                                      .gramPanchayatName,
                                                  gpDistrictName:
                                                  pendingLiveData[
                                                  index]
                                                      .districtName,
                                                  gpStateName:
                                                  pendingLiveData[
                                                  index]
                                                      .stateName,
                                                  gpBlockName:
                                                  pendingLiveData[
                                                  index]
                                                      .blockName,
                                                  gpVillageName:
                                                  pendingLiveData[
                                                  index]
                                                      .vleName,
                                                  gpMobileNumber:
                                                  pendingLiveData[
                                                  index]
                                                      .vleMobile,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        alignment:
                                        Alignment.centerLeft,
                                        decoration:
                                        new BoxDecoration(
                                          color: Color(0xffffffff),
                                          borderRadius:
                                          BorderRadius.circular(
                                              5),
                                        ),
                                        child: Padding(
                                          padding:
                                          EdgeInsets.all(10.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: <Widget>[
                                                  Container(
                                                    alignment: Alignment
                                                        .centerLeft,
                                                    child: Text(
                                                      pendingLiveData[
                                                      index]
                                                          .gramPanchayatName,
                                                      style:
                                                      TextStyle(
                                                        fontFamily:
                                                        'Overpass',
                                                        color: Color(
                                                            0xff131721),
                                                        fontSize:
                                                        16,
                                                        fontWeight:
                                                        FontWeight
                                                            .w400,
                                                        fontStyle:
                                                        FontStyle
                                                            .normal,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: 4.0),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: <Widget>[
                                                  Container(
                                                    alignment: Alignment
                                                        .centerLeft,
                                                    child: Text(
                                                      pendingLiveData[
                                                      index]
                                                          .distStateName,
                                                      style:
                                                      TextStyle(
                                                        fontFamily:
                                                        'Overpass',
                                                        color: Colors
                                                            .black54,
                                                        fontSize:
                                                        13,
                                                        fontWeight:
                                                        FontWeight
                                                            .w400,
                                                        fontStyle:
                                                        FontStyle
                                                            .normal,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.0),
                            ],
                          );
                        },
                      ),
                    ),
                  )
                  : Container(),
              btn2
                  ? Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.0, right: 15.0),
                      child: ListView.builder(
                        itemCount: completedLiveData.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Row(
                                key: ValueKey('1'),
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                InstallationEditPage(
                                                  installationId: completedLiveData[index].id.toString(),
                                                  projectId: completedLiveData[index].userId.toString(),
                                                  title: completedLiveData[index].gramPanchayatName,
                                                  gpName: completedLiveData[index].gramPanchayatName,
                                                  gpDistrictName: completedLiveData[index].districtName,
                                                  gpStateName: completedLiveData[index].stateName,
                                                  gpBlockName: completedLiveData[index].blockName,
                                                  gpVillageName: completedLiveData[index].vleName,
                                                  gpMobileNumber: completedLiveData[index].vleMobile,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        alignment:
                                        Alignment.centerLeft,
                                        decoration:
                                        new BoxDecoration(
                                          color: Color(0xffffffff),
                                          borderRadius:
                                          BorderRadius.circular(
                                              5),
                                        ),
                                        child: Padding(
                                          padding:
                                          EdgeInsets.all(10.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: <Widget>[
                                                  Container(
                                                    alignment: Alignment
                                                        .centerLeft,
                                                    child: Text(
                                                      completedLiveData[
                                                      index]
                                                          .gramPanchayatName,
                                                      style:
                                                      TextStyle(
                                                        fontFamily:
                                                        'Overpass',
                                                        color: Color(
                                                            0xff131721),
                                                        fontSize:
                                                        16,
                                                        fontWeight:
                                                        FontWeight
                                                            .w400,
                                                        fontStyle:
                                                        FontStyle
                                                            .normal,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: 4.0),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: <Widget>[
                                                  Container(
                                                    alignment: Alignment
                                                        .centerLeft,
                                                    child: Text(
                                                      completedLiveData[
                                                      index]
                                                          .distStateName,
                                                      style:
                                                      TextStyle(
                                                        fontFamily:
                                                        'Overpass',
                                                        color: Colors
                                                            .black54,
                                                        fontSize:
                                                        13,
                                                        fontWeight:
                                                        FontWeight
                                                            .w400,
                                                        fontStyle:
                                                        FontStyle
                                                            .normal,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.0),
                            ],
                          );
                        },
                      ),
                    ),
                  )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  listOfSurvey() async {
    setState(() {
      isLoading = true;
    });
    isToken = false;
    var response = await http.get(
        'https://fieldapp.m2mcybernetics.com/api/v1/listOfInstallation?token=$apiToken',
        headers: {'authkey': 'Bcju0SQW2RKR0vhLzGbjeQwqkJvBUyA4IkMDuNubQq5'});
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print(jsonResponse.toString());
      try {
        if (jsonResponse["success"] == true) {
          SurveyListData otpVerificationData = SurveyListData.fromSurveyListJson(jsonResponse);
          if (otpVerificationData.status == true) {
            Toast.show("Installation Success", context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

            setState(() {
              pendingLiveData = otpVerificationData.message.pendingData;
              completedLiveData = otpVerificationData.message.completedData;
              //notFeasibilityLiveData = otpVerificationData.message.notFeasibilityData;
            });
          } else {
            Toast.show('You have no data', context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          }
        } else {
          Toast.show("Installation failed", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
        _stopAnimation();
      } catch (e) {
        _stopAnimation();
        print(e);
      }
    } else {
      _stopAnimation();
      debugPrint("Installation failed");
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
}

class SurveyListData {
  bool status;
  Message message;

  SurveyListData.fromSurveyListJson(Map<String, dynamic> json) {
    try {
      status = json['success'];
      message = Message.fromSurveyListJson(json['message']);
    } catch (e) {
      status = json['error'];
      print(e.toString());
    }
  }
}

class SurveyListItem {
  int id;
  int userId;
  String stateName;
  String districtName;
  String blockName;
  String vleName;
  String vleMobile;
  String gramPanchayatName;
  String gpName;
  String vleEmail;
  String vleAlternateMobile;
  String vleNewName;
  String vleNewMobile;
  String dmName;
  String dmMobile;
  String dmEmail;
  String distStateName;

  SurveyListItem.fromUserDataJson(Map<String, dynamic> json) {
    try {
      id = json['installation_id'];
      userId = json['project_id'];
      stateName = json['state_name'];
      districtName = json['district_name'];
      String gpBlockName = json['gram_panchayat_name'];
      String gpDistrictName = json['district_name'];
      String gpStateName = json['state_name'];
      distStateName = 'Dist: $gpDistrictName, $gpStateName';
      blockName = json['block_name'];
      gramPanchayatName = 'GP $gpBlockName';
      gpName = '$gpBlockName';
      vleName = json['vle_name'];
      vleMobile = json['vle_mobile'];
      vleEmail = json['vle_email'];
      vleAlternateMobile = json['vle_alternate_mobile'];
      vleNewName = json['vle_new_name'];
      vleNewMobile = json['vle_new_mobile'];
      dmName = json['dm_name'];
      dmMobile = json['dm_mobile'];
      dmEmail = json['dm_email'];
    } catch (e) {
      print(e.toString());
    }
  }
}

class Message {
  List<SurveyListItem> pendingData;
  List<SurveyListItem> completedData;
  //List<SurveyListItem> notFeasibilityData;

  Message.fromSurveyListJson(Map<String, dynamic> json) {
    try {
      pendingData = [];
      completedData = [];
      //notFeasibilityData = [];
      if (json['pending'].length > 0) {
        for (var listItem in json['pending']) {
          SurveyListItem data = SurveyListItem.fromUserDataJson(listItem);
          pendingData.add(data);
        }
      }
      if (json['completed'].length > 0) {
        for (var listItem in json['completed']) {
          SurveyListItem data = SurveyListItem.fromUserDataJson(listItem);
          completedData.add(data);
        }
      }
     /* if (json['not_feasibility'].length > 0) {
        for (var listItem in json['not_feasibility']) {
          SurveyListItem data = SurveyListItem.fromUserDataJson(listItem);
          notFeasibilityData.add(data);
        }
      }*/
    } catch (e) {
      print(e.toString());
    }
  }
}
