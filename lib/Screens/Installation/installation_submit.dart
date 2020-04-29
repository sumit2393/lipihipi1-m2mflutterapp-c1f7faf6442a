import 'dart:convert';
import 'package:async/async.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/Screens/dashboard.dart';
import 'package:flutterapp/Utility/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:permission/permission.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class InstallationSubmitPage extends StatefulWidget {


  final String installationId;
  final String projectId;
  final String title;
  final String gpName;
  final String gpDistrictName;
  final String gpStateName;
  final String gpVillageName;
  final String gpBlockName;
  final String gpMobileNumber;

  InstallationSubmitPage(
      {Key key,
        @required this.installationId,
        @required this.projectId,
        @required this.title,
        @required this.gpName,
        @required this.gpDistrictName,
        @required this.gpStateName,
        @required this.gpVillageName,
        @required this.gpBlockName,
        @required this.gpMobileNumber})
      : super(key: key);

  @override
  _InstallationSubmitPageState createState() => _InstallationSubmitPageState(
      installationId: this.installationId,
      projectId: this.projectId,
      title: this.title,
      gpName: this.gpName,
      gpDistrictName: this.gpDistrictName,
      gpStateName: this.gpStateName,
      gpVillageName: this.gpVillageName,
      gpBlockName: this.gpBlockName,
      gpMobileNumber: gpMobileNumber);
}

class _InstallationSubmitPageState extends State<InstallationSubmitPage> {
  final String installationId;
  final String projectId;
  final String title;
  final String gpName;
  final String gpDistrictName;
  final String gpStateName;
  final String gpVillageName;
  final String gpBlockName;
  final String gpMobileNumber;

  _InstallationSubmitPageState(
      {Key key,
        @required this.installationId,
        @required this.projectId,
        @required this.title,
        @required this.gpName,
        @required this.gpDistrictName,
        @required this.gpStateName,
        @required this.gpVillageName,
        @required this.gpBlockName,
        @required this.gpMobileNumber});

  final TextEditingController _macIdController = TextEditingController();
  final TextEditingController _serialNo = TextEditingController();
  final TextEditingController _batteryBox = TextEditingController();

  bool checkimgupload_yes = false;
  bool checkshowImgupload_yes = false;
  bool check_edit_access_point = false;

  var parentContext;
  File _pickedImage;
  List<File> ImageList = List<File>();
  List<int> spinnerItemsId;
  bool isLoading = false;
  bool isToken = false;
  bool isDeclare = false;
  String apiToken = '';
  bool a1 = false;
  PermissionName permissionName = PermissionName.Internet;
  String message = '';


  List<String> _selectlist = [
    'Yes',
    'No',
  ];

  String pole_installed;
  String solor_panel_installed;
  String solor_battery_installed;
  String access_point_installed;
  String poe_cabel_connected;
  String ac_power_supply;
  String access_point_powered;
  String poe_cable_module_data_part;
  String switch_on_the_ont_power;
  String ont_power_light_is_stable;
  String pon_light_is_stable;
  String connent_through_mobile;
  String open_google_com;
  String name_and_number_correct;

  Position _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }



  getTokenRoSf() async {
    SharedPreferences shaPref = await SharedPreferences.getInstance();
    apiToken = shaPref.get("token");
    setState(() {
      isToken = true;
      isDeclare = true;
    });
  }

  Future<void> captureImage(ImageSource imageSource, context) async {
    try {
      final imageFile = await ImagePicker.pickImage(source: imageSource);
      ImageList.add(imageFile);
      setState(() {
        _pickedImage = imageFile;
        uploadMultipleImage(_pickedImage);
      });
    } catch (e) {
      print(e);
    }
  }

  String imageNames = '';

  Future uploadMultipleImage(File images) async {
    setState(() {
      isLoading = true;
      checkimgupload_yes = true;
    });

    var stream = new http.ByteStream(DelegatingStream.typed(images.openRead()));

    var length = await images.length();

    SharedPreferences shaPref = await SharedPreferences.getInstance();
    var token = shaPref.get("token");

    Map<String, String> headers = {'authkey': 'Bcju0SQW2RKR0vhLzGbjeQwqkJvBUyA4IkMDuNubQq5'};
    var uri = Uri.parse('https://fieldapp.m2mcybernetics.com/api/v1/imageUpload?token=$token');
    var request = new http.MultipartRequest("POST", uri);

    var multipartFileSign =  http.MultipartFile('image_name', stream, length, filename: basename(images.path));

    // add file to multipart
    request.files.add(multipartFileSign);

    request.headers.addAll(headers);

    var response = await request.send();

    var resultsapi = await response.stream.bytesToString();
    var jsonresponse = jsonDecode(resultsapi);
    debugPrint("response"+jsonresponse.toString());

    _stopAnimation();

    if (response.statusCode == 200) {


      debugPrint("responfffffdddddd"+jsonresponse["message"].toString());

      String surveyacessimage = jsonresponse["message"].toString();
      imageNames = imageNames + ',' + surveyacessimage;
      debugPrint("zzzzzzyyyyyyyy$imageNames");

      print("Image Uploaded");
    }

    else {
      print("Upload Failed");
    }
    response.stream.transform(utf8.decoder).listen((value) {
      print("ddddd"+value);
    }
    );

  }

  _getCurrentLocation() {
    final Geolocator geoLocator = Geolocator()..forceAndroidLocationManager;

    geoLocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }

  List<Message> list = List();

  double screenheight = 1300;

  installationAccessPointSubmit(
      String token,
      String instalid,
      String macId,
      String serialNo,
      String batteryBox
      ) async{


    debugPrint("wfawfawfawfawfawfawffawfa$imageNames");
    print("   $instalid  $batteryBox    $token ");


    setState(
          () {
        //isLoading = true;
      },
    );

    double lat;
    double lng;

    if (_currentPosition != null) {
      lat = _currentPosition.latitude;
      lng = _currentPosition.longitude;
    } else {
      _getCurrentLocation();
    }

    print(lat);
    print(lng);


    Map data = {
      'token': token,
      'installation_id': instalid,
      'survey_id': '',
      'survey_access_point_id': '',
      'installation_access_point_id': '',
      'mac_id' : macId,
      'serial_no' : serialNo,
      'battery_box' : batteryBox,
      'latitude': "$lat",
      'longitude': "$lng",
      'images': imageNames,
    };
    var response = await http.post(
        'https://fieldapp.m2mcybernetics.com/api/v1/installationAccessPointSubmit',
        body: data,
        headers: {'authkey': 'Bcju0SQW2RKR0vhLzGbjeQwqkJvBUyA4IkMDuNubQq5'});

    var jsonResponse = json.decode(response.body);
    debugPrint("sssssssssrrrrrrrrr"+jsonResponse.toString());

    if (response.statusCode == 200) {

      _batteryBox.clear();
      _serialNo.clear();
      _macIdController.clear();
      ImageList.clear();
      imageNames = ' ';
      double screen = 700;
      screenheight = screenheight + screen;
      list = parseData(json.decode(response.body));
      check_edit_access_point = true;
      _stopAnimation();

      Toast.show("Access Point Submit successfully", parentContext,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

    } else {
      print("Access Point Faild");
      _stopAnimation();
    }

  }


  _edit_installationAccessPoint(
      String token,
      String instal_id,
      String survey_ap_id,
      String installation_ap_id,
      String mac_id,
      String serial_No,
      String battery_Box,
      String latitude,
      String longitude,
      ) async {
    debugPrint("yyyyyyyyyyyyyyyyy    $instal_id    $survey_ap_id   $installation_ap_id,   $token");
    //id: 27, installation_id: 14, survey_access_point_id: null, mac_id: app22, serial_no: 77, battery_box: tgh, latitude: null, longitude: null, installation_access_point_images: [{id: 39, installation_id: 14, user_id: 29, installation_access_point_id: 27,
    setState(
          () {
        //isLoading = true;
      },
    );

    final data = {
      'token': token,
      'installation_id': instal_id,
      'survey_id': '',
      'survey_access_point_id': '',
      'installation_access_point_id': installation_ap_id,
      'mac_id' : mac_id,
      'serial_no' : serial_No,
      'battery_box' : battery_Box,
      'latitude': latitude,
      'longitude': longitude,
      'images': '',
    };

    var response = await http.post(
        'https://fieldapp.m2mcybernetics.com/api/v1/installationAccessPointSubmit',
        body: data,
        headers: {'authkey': 'Bcju0SQW2RKR0vhLzGbjeQwqkJvBUyA4IkMDuNubQq5'});

    debugPrint("installationAccessPointEdit");
    //var jsonResponse = json.decode(response.body.toString());
    debugPrint(response.body.toString());


    if (response.statusCode == 200) {
      _stopAnimation();

      list = parseData(json.decode(response.body));

      Toast.show("Installation AccessPoint Edit SuccesFully", parentContext,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    } else {
      print("Installation AccessPoint Edit Failed");
      _stopAnimation();
    }
  }

  List<Message> parseData(dataJson) {
    var list = dataJson['message'] as List;
    List<Message> dataList =
    list.map((message) => Message.fromJson(message)).toList();
    return dataList;
  }

  _rem_installation_AccessPointImage(
      String token,
      String installation_id,
      String id,
      ) async {
    print("xxxxxxxxxxxxxx    $installation_id,     $id,   $token  ");

    setState(
          () {
        //isLoading = true;
      },
    );

    final data = {
      'token': token,
      'installation_id': installation_id.toString(),
      'id': id.toString()
    };

    Uri uri = Uri.parse(
        "https://fieldapp.m2mcybernetics.com/api/v1/remInstallationAccessPointImage");

    final newURI = uri.replace(queryParameters: data);

    var response = await http.get(newURI,
        headers: {'authkey': 'Bcju0SQW2RKR0vhLzGbjeQwqkJvBUyA4IkMDuNubQq5'});

    print("gggggggggggggggggggggggggggggg"+ response.body.toString());

    setState(() {
      if (response.statusCode == 200) {
        _stopAnimation();

        Toast.show("Image Delete successfully", parentContext,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      } else {
        print("IMAGE DELETE Faild");
        _stopAnimation();
      }
    });
  }

  installationsubmit(
      String token,
      String project_id,
      String install_id,

      String pole_installed,
      String solor_panel_installed,
      String solor_battery_installed,
      String access_point_installed,
      String poe_cabel_connected,
      String ac_power_supply,
      String access_point_powered,
      String poe_cable_module_data_part,
      String switch_on_the_ont_power,
      String ont_power_light_is_stable,
      String pon_light_is_stable,
      String connent_through_mobile,
      String open_google_com,
      String name_and_number_correct,

      ) async {
    setState(
          () {
        isLoading = true;
      },
    );
    Map data = {
      'token': token,
      'installation_id': install_id,
      'project_id': project_id,
      'survey_id': install_id,
      'pole_installed':  pole_installed == 'Yes' ? '1' : '0',
      'solor_panel_installed': solor_panel_installed == 'Yes' ? '1' : '0',
      'solor_battery_installed': solor_battery_installed == 'Yes' ? '1' : '0',
      'access_point_installed': access_point_installed == 'Yes' ? '1' : '0',
      'poe_cabel_connected': poe_cabel_connected == 'Yes' ? '1' : '0',
      'ac_power_supply': ac_power_supply == 'Yes' ? '1' : '0',
      'access_point_powered': access_point_powered == 'Yes' ? '1' : '0',
      'poe_cable_module_data_part': poe_cable_module_data_part == 'Yes' ? '1' : '0',
      'switch_on_the_ont_power': switch_on_the_ont_power == 'Yes' ? '1' : '0',
      'ont_power_light_is_stable': ont_power_light_is_stable == 'Yes' ? '1' : '0',
      'pon_light_is_stable': pon_light_is_stable == 'Yes' ? '1' : '0',
      'connent_through_mobile': connent_through_mobile == 'Yes' ? '1' : '0',
      'open_google_com': open_google_com == 'Yes' ? '1' : '0',
      'name_and_number_correct': name_and_number_correct == 'Yes' ? '1' : '0',
    };
    var response = await http.post(
        'https://fieldapp.m2mcybernetics.com/api/v1/installationDetailSubmit',
        body: data,
        headers: {'authkey': 'Bcju0SQW2RKR0vhLzGbjeQwqkJvBUyA4IkMDuNubQq5'}
        );
    debugPrint(response.body.toString());
    if (response.statusCode == 200) {

      checkshowImgupload_yes = true;

      var jsonResponse = json.decode(response.body);
      print("sssssoooooooooooooooooooooooooooooooooooooooo"+jsonResponse.toString());

      Toast.show("Installation Submit successfully", parentContext,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      _stopAnimation();
    } else {
      print("Installation Faild");
      _stopAnimation();
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    parentContext = context;
    requestStoragePermissions();
    if (!isDeclare) {
      spinnerItemsId = [];
      getTokenRoSf();
    }

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
            '$title',
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
            icon: Icon(Icons.arrow_back_ios),
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
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height + screenheight,
          decoration: BoxDecoration(color: Color(0xE5F4FD)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: screenSize.width * 0.90,
                    height: 185,
                    margin: EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
                    //padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.7),
                        borderRadius:
                        new BorderRadius.all(Radius.circular(10.0))),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 15, bottom: 15),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "State: $gpStateName",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 7, bottom: 7),
                                          child: Text(
                                            "District: $gpDistrictName",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    )),
                                Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "GP: $gpName",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 7, bottom: 7),
                                          child: Text(
                                            "Block: $gpBlockName",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          MySeparator(color: Colors.white.withOpacity(.4)),
                          Padding(
                            padding: const EdgeInsets.only(top: 15, bottom: 0),
                            child: Row(
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Vle: $gpVillageName",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            top: 12, bottom: 10),
                                        child: Container(
                                          height: 34,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              //border: Border.all(color: Colors.black54.withOpacity(0.4), width: 0.2),
                                              borderRadius: new BorderRadius.all(
                                                  Radius.circular(20.0))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InkWell(
                                              onTap: () {
                                                _launchCaller(gpMobileNumber);
                                              },
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.phone_in_talk,
                                                    color: Colors.blue,
                                                  ),
                                                  Text(
                                                      "    CALL | +91 $gpMobileNumber")
                                                ],
                                              ),
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 0.0, top: 10, bottom: 0.0, right: 0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: screenSize.width,
                          height: 50,
                          alignment: Alignment.centerLeft,
                          decoration: new BoxDecoration(
                              color: Colors.black.withOpacity(.7),
                              borderRadius:
                              BorderRadius.circular(0)),
                          child: Padding(
                            padding:
                            const EdgeInsets.only(left: 15),
                            child: Text(
                              '  GENERAL DETAILS',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, left: 15, right: 15, top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Pole Installed on the \nLocation(s):",
                            style: TextStyle(
                                color: Colors.black54, fontSize: 15)),
                        Container(
                          height: 50,
                          width: 140,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.black54, width: .2)),
                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        13, 0, 0, 0),
                                    child: DropdownButton<String>(
                                      hint: Text('Select'),
                                      isExpanded: true,
                                      value: pole_installed,
                                      icon: Icon(
                                        Icons.expand_more,
                                        size: 35,
                                      ),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16),
                                      underline: Container(
                                        height: 0,
                                      ),
                                      onChanged: (String value) {
                                        setState(() {
                                          pole_installed =
                                              value;
                                          print(
                                              pole_installed);
                                        });
                                      },
                                      items: _selectlist.map((s_list) {
                                        return DropdownMenuItem<String>(
                                          value: s_list,
                                          child: Text(
                                            s_list,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Solar Panel Installed on the \nLocation(s):",
                            style: TextStyle(
                                color: Colors.black54, fontSize: 15)),
                        Container(
                          height: 50,
                          width: 140,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.black54, width: .2)),
                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        13, 0, 0, 0),
                                    child: DropdownButton<String>(
                                      hint: Text('Select'),
                                      isExpanded: true,
                                      value: solor_panel_installed,
                                      icon: Icon(
                                        Icons.expand_more,
                                        size: 35,
                                      ),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16),
                                      underline: Container(
                                        height: 0,
                                      ),
                                      onChanged: (String value) {
                                        setState(() {
                                          solor_panel_installed =
                                              value;
                                          print(
                                              solor_panel_installed);
                                        });
                                      },
                                      items: _selectlist.map((s_list) {
                                        return DropdownMenuItem<String>(
                                          value: s_list,
                                          child: Text(
                                            s_list,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Solar Battery Connected \nPanel with the Panel:",
                            style: TextStyle(
                                color: Colors.black54, fontSize: 15)),
                        Container(
                          height: 50,
                          width: 140,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.black54, width: .2)),
                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        13, 0, 0, 0),
                                    child: DropdownButton<String>(
                                      hint: Text('Select'),
                                      isExpanded: true,
                                      value: solor_battery_installed,
                                      icon: Icon(
                                        Icons.expand_more,
                                        size: 35,
                                      ),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16),
                                      underline: Container(
                                        height: 0,
                                      ),
                                      onChanged: (String value) {
                                        setState(() {
                                          solor_battery_installed =
                                              value;
                                          print(
                                              solor_battery_installed);
                                        });
                                      },
                                      items: _selectlist.map((s_list) {
                                        return DropdownMenuItem<String>(
                                          value: s_list,
                                          child: Text(
                                            s_list,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Access Point Installed on \nthe Pole/lLocation(s):",
                            style: TextStyle(
                                color: Colors.black54, fontSize: 15)),
                        Container(
                          height: 50,
                          width: 140,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.black54, width: .2)),
                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        13, 0, 0, 0),
                                    child: DropdownButton<String>(
                                      hint: Text('Select'),
                                      isExpanded: true,
                                      value: access_point_installed,
                                      icon: Icon(
                                        Icons.expand_more,
                                        size: 35,
                                      ),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16),
                                      underline: Container(
                                        height: 0,
                                      ),
                                      onChanged: (String value) {
                                        setState(() {
                                          access_point_installed =
                                              value;
                                          print(
                                              access_point_installed);
                                        });
                                      },
                                      items: _selectlist.map((s_list) {
                                        return DropdownMenuItem<String>(
                                          value: s_list,
                                          child: Text(
                                            s_list,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("POE Cable Module \nConnected With the AP:",
                            style: TextStyle(
                                color: Colors.black54, fontSize: 15)),
                        Container(
                          height: 50,
                          width: 140,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.black54, width: .2)),
                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        13, 0, 0, 0),
                                    child: DropdownButton<String>(
                                      hint: Text('Select'),
                                      isExpanded: true,
                                      value: poe_cabel_connected,
                                      icon: Icon(
                                        Icons.expand_more,
                                        size: 35,
                                      ),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16),
                                      underline: Container(
                                        height: 0,
                                      ),
                                      onChanged: (String value) {
                                        setState(() {
                                          poe_cabel_connected =
                                              value;
                                          print(
                                              poe_cabel_connected);
                                        });
                                      },
                                      items: _selectlist.map((s_list) {
                                        return DropdownMenuItem<String>(
                                          value: s_list,
                                          child: Text(
                                            s_list,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("AC Power Supply Provided \nto the equipment:",
                            style: TextStyle(
                                color: Colors.black54, fontSize: 15)),
                        Container(
                          height: 50,
                          width: 140,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.black54, width: .2)),
                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        13, 0, 0, 0),
                                    child: DropdownButton<String>(
                                      hint: Text('Select'),
                                      isExpanded: true,
                                      value: ac_power_supply,
                                      icon: Icon(
                                        Icons.expand_more,
                                        size: 35,
                                      ),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16),
                                      underline: Container(
                                        height: 0,
                                      ),
                                      onChanged: (String value) {
                                        setState(() {
                                          ac_power_supply =
                                              value;
                                          print(
                                              ac_power_supply);
                                        });
                                      },
                                      items: _selectlist.map((s_list) {
                                        return DropdownMenuItem<String>(
                                          value: s_list,
                                          child: Text(
                                            s_list,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("AP Powered Connected \nwith Battery or POE \npower port:",
                            style: TextStyle(
                                color: Colors.black54, fontSize: 15)),
                        Container(
                          height: 50,
                          width: 140,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.black54, width: .2)),
                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        13, 0, 0, 0),
                                    child: DropdownButton<String>(
                                      hint: Text('Select'),
                                      isExpanded: true,
                                      value: access_point_powered,
                                      icon: Icon(
                                        Icons.expand_more,
                                        size: 35,
                                      ),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16),
                                      underline: Container(
                                        height: 0,
                                      ),
                                      onChanged: (String value) {
                                        setState(() {
                                          access_point_powered =
                                              value;
                                          print(
                                              access_point_powered);
                                        });
                                      },
                                      items: _selectlist.map((s_list) {
                                        return DropdownMenuItem<String>(
                                          value: s_list,
                                          child: Text(
                                            s_list,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("POE Cable Module Data \nPort AP cable connected \nwith ONT:",
                            style: TextStyle(
                                color: Colors.black54, fontSize: 15)),
                        Container(
                          height: 50,
                          width: 140,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.black54, width: .2)),
                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        13, 0, 0, 0),
                                    child: DropdownButton<String>(
                                      hint: Text('Select'),
                                      isExpanded: true,
                                      value: poe_cable_module_data_part,
                                      icon: Icon(
                                        Icons.expand_more,
                                        size: 35,
                                      ),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16),
                                      underline: Container(
                                        height: 0,
                                      ),
                                      onChanged: (String value) {
                                        setState(() {
                                          poe_cable_module_data_part =
                                              value;
                                          print(
                                              poe_cable_module_data_part);
                                        });
                                      },
                                      items: _selectlist.map((s_list) {
                                        return DropdownMenuItem<String>(
                                          value: s_list,
                                          child: Text(
                                            s_list,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Switch on the ONT power \nsupply:",
                            style: TextStyle(
                                color: Colors.black54, fontSize: 15)),
                        Container(
                          height: 50,
                          width: 140,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.black54, width: .2)),
                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        13, 0, 0, 0),
                                    child: DropdownButton<String>(
                                      hint: Text('Select'),
                                      isExpanded: true,
                                      value: switch_on_the_ont_power,
                                      icon: Icon(
                                        Icons.expand_more,
                                        size: 35,
                                      ),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16),
                                      underline: Container(
                                        height: 0,
                                      ),
                                      onChanged: (String value) {
                                        setState(() {
                                          switch_on_the_ont_power =
                                              value;
                                          print(
                                              switch_on_the_ont_power);
                                        });
                                      },
                                      items: _selectlist.map((s_list) {
                                        return DropdownMenuItem<String>(
                                          value: s_list,
                                          child: Text(
                                            s_list,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("ONT Power light is stable \n(green) or Off:",
                            style: TextStyle(
                                color: Colors.black54, fontSize: 15)),
                        Container(
                          height: 50,
                          width: 140,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.black54, width: .2)),
                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        13, 0, 0, 0),
                                    child: DropdownButton<String>(
                                      hint: Text('Select'),
                                      isExpanded: true,
                                      value: ont_power_light_is_stable,
                                      icon: Icon(
                                        Icons.expand_more,
                                        size: 35,
                                      ),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16),
                                      underline: Container(
                                        height: 0,
                                      ),
                                      onChanged: (String value) {
                                        setState(() {
                                          ont_power_light_is_stable =
                                              value;
                                          print(
                                              ont_power_light_is_stable);
                                        });
                                      },
                                      items: _selectlist.map((s_list) {
                                        return DropdownMenuItem<String>(
                                          value: s_list,
                                          child: Text(
                                            s_list,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("PON light is stable or\nblinking (green) or Off:",
                            style: TextStyle(
                                color: Colors.black54, fontSize: 15)),
                        Container(
                          height: 50,
                          width: 140,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.black54, width: .2)),
                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        13, 0, 0, 0),
                                    child: DropdownButton<String>(
                                      hint: Text('Select'),
                                      isExpanded: true,
                                      value: pon_light_is_stable,
                                      icon: Icon(
                                        Icons.expand_more,
                                        size: 35,
                                      ),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16),
                                      underline: Container(
                                        height: 0,
                                      ),
                                      onChanged: (String value) {
                                        setState(() {
                                          pon_light_is_stable =
                                              value;
                                          print(
                                              pon_light_is_stable);
                                        });
                                      },
                                      items: _selectlist.map((s_list) {
                                        return DropdownMenuItem<String>(
                                          value: s_list,
                                          child: Text(
                                            s_list,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("You Are able to connect\nthrough mobile WIFI with\nSSID name WIFI Choupal:",
                            style: TextStyle(
                                color: Colors.black54, fontSize: 15)),
                        Container(
                          height: 50,
                          width: 140,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.black54, width: .2)),
                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        13, 0, 0, 0),
                                    child: DropdownButton<String>(
                                      hint: Text('Select'),
                                      isExpanded: true,
                                      value: connent_through_mobile,
                                      icon: Icon(
                                        Icons.expand_more,
                                        size: 35,
                                      ),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16),
                                      underline: Container(
                                        height: 0,
                                      ),
                                      onChanged: (String value) {
                                        setState(() {
                                          connent_through_mobile =
                                              value;
                                          print(
                                              connent_through_mobile);
                                        });
                                      },
                                      items: _selectlist.map((s_list) {
                                        return DropdownMenuItem<String>(
                                          value: s_list,
                                          child: Text(
                                            s_list,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Open Google.com, are you \ngetting CSC Landing page:",
                            style: TextStyle(
                                color: Colors.black54, fontSize: 15)),
                        Container(
                          height: 50,
                          width: 140,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.black54, width: .2)),
                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        13, 0, 0, 0),
                                    child: DropdownButton<String>(
                                      hint: Text('Select'),
                                      isExpanded: true,
                                      value: open_google_com,
                                      icon: Icon(
                                        Icons.expand_more,
                                        size: 35,
                                      ),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16),
                                      underline: Container(
                                        height: 0,
                                      ),
                                      onChanged: (String value) {
                                        setState(() {
                                          open_google_com =
                                              value;
                                          print(
                                              open_google_com);
                                        });
                                      },
                                      items: _selectlist.map((s_list) {
                                        return DropdownMenuItem<String>(
                                          value: s_list,
                                          child: Text(
                                            s_list,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Your Name and Number\nare correct on CSC \nLanding page:",
                            style: TextStyle(
                                color: Colors.black54, fontSize: 15)),
                        Container(
                          height: 50,
                          width: 140,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.black54, width: .2)),
                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        13, 0, 0, 0),
                                    child: DropdownButton<String>(
                                      hint: Text('Select'),
                                      isExpanded: true,
                                      value: name_and_number_correct,
                                      icon: Icon(
                                        Icons.expand_more,
                                        size: 35,
                                      ),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16),
                                      underline: Container(
                                        height: 0,
                                      ),
                                      onChanged: (String value) {
                                        setState(() {
                                          name_and_number_correct =
                                              value;
                                          print(
                                              name_and_number_correct);
                                        });
                                      },
                                      items: _selectlist.map((s_list) {
                                        return DropdownMenuItem<String>(
                                          value: s_list,
                                          child: Text(
                                            s_list,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 0.0, top: 20.0, bottom: 20.0, right: 5.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          child: new GestureDetector(
                            onTap: () {
                              if(pole_installed == null ){
                                Toast.show("Select Pole Installed on the Location(s)", context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                              }else if(solor_panel_installed == null ){
                                Toast.show("Solar Panel Installed on the Location(s)", context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                              }else if(solor_battery_installed == null ){
                                Toast.show("Select Solar Battery Connected Panel", context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                              }else if(access_point_installed == null ){
                                Toast.show("Select Access Point Installed on the Location(s)", context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                              }else if(poe_cabel_connected == null ){
                                Toast.show("Select POE Cable Module", context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                              }else if(ac_power_supply == null ){
                                Toast.show("Select AC Power Supply Provided", context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                              }else if(access_point_powered == null ){
                                Toast.show("Select Access Point Powered Connected With Battery", context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                              }else if(poe_cable_module_data_part == null ){
                                Toast.show("Select POE Cable Module Data Port", context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                              } else if(switch_on_the_ont_power == null ){
                                Toast.show("Select Switch on the ONT power Supply", context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                              }else if(ont_power_light_is_stable == null ){
                                Toast.show("Select ONT Power Light Is Stable", context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                              }else if(pon_light_is_stable == null ){
                                Toast.show("Select  PON Light Is Stable or blinking", context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                              }else if(connent_through_mobile == null){
                                Toast.show("Select You Are able to connect through mobile WIFI", context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                              }else if(open_google_com == null ){
                                Toast.show("Select Open Google.com, are You Getting CSC", context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                              }else if(name_and_number_correct == null ){
                                Toast.show("Select Your Name and Number are correct on CSC", context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                              } else{
                                installationsubmit(
                                  apiToken.toString(),
                                  widget.projectId.toString(),
                                  widget.installationId.toString(),

                                  pole_installed.toString(),
                                  solor_panel_installed.toString(),
                                  solor_battery_installed.toString(),
                                  access_point_installed.toString(),
                                  poe_cabel_connected.toString(),
                                  ac_power_supply.toString(),
                                  access_point_powered.toString(),
                                  poe_cable_module_data_part.toString(),
                                  switch_on_the_ont_power.toString(),
                                  ont_power_light_is_stable.toString(),
                                  pon_light_is_stable.toString(),
                                  connent_through_mobile.toString(),
                                  open_google_com.toString(),
                                  name_and_number_correct.toString(),

                                );
                              }
                            },
                            child: Container(
                              width: 120,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: new BoxDecoration(
                                  color: Colors.deepOrange,
                                  borderRadius:
                                  BorderRadius.circular(3)),
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
                  ),
                ],
              ),

              check_edit_access_point == true
                  ? Expanded(
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, index0) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                                left: 0.0,
                                top: 10,
                                bottom: 0.0,
                                right: 0),
                            child: Container(
                              alignment: Alignment.center,
                              child: new GestureDetector(
                                child: Container(
                                  width: screenSize.width,
                                  height: 50,
                                  alignment: Alignment.centerLeft,
                                  decoration: new BoxDecoration(
                                      color: Colors.black.withOpacity(.7),
                                      borderRadius:
                                      BorderRadius.circular(0)),
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.only(left: 15),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          "AP  -  " +
                                              list[index0].id.toString() ??
                                              "",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, top: 15),
                                  child: Text(
                                    "Lat and Long:",
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, top: 15),
                                  child: Text(
                                    " \nLat and Long:",
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, top: 15),
                                  child: Text(
                                    "",
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  10, 20, 10, 0),
                              child: Container(
                                height: 150,
                                child: GridView.builder(
                                    itemCount: list[index0].installationAccessPointImages.length,
                                    gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3),
                                    itemBuilder: (context, index1) {
                                      return Column(
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  8.0),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  8.0),
                                              child: Image.network(
                                                list[index0]
                                                    .installationAccessPointImages[index1].image,
                                                fit: BoxFit.cover,
                                                height: 80,
                                                width: 100,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(
                                                top: 10),
                                            child: GestureDetector(
                                              onTap: () {

                                                _rem_installation_AccessPointImage(
                                                  apiToken.toString(),
                                                  list[index0].installationAccessPointImages[index1].installationId.toString(),
                                                  list[index0].installationAccessPointImages[index1].id.toString(),
                                                );

                                                _edit_installationAccessPoint(
                                                  apiToken.toString(),
                                                  list[index0].installationId.toString(),
                                                  list[index0].surveyAccessPointId.toString(),
                                                  list[index0].id.toString(),
                                                  list[index0].macId.toString(),
                                                  list[index0].serialNo.toString(),
                                                  list[index0].batteryBox.toString(),
                                                  list[index0].latitude.toString(),
                                                  list[index0].longitude.toString(),
                                                );
                                              },
                                              child: Container(
                                                child: Text(
                                                  "Delete",
                                                  style: TextStyle(
                                                      color:
                                                      Colors.black54),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      );
                                    }),
                              )),
                          Container(
                            margin: EdgeInsets.only(
                                left: 0.0,
                                top: 20.0,
                                bottom: 20.0,
                                right: 5.0),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.center,
                                  child: new GestureDetector(
                                    onTap: () {
                                      /* surveyAccessPointEdit(
                                                apiToken.toString(),
                                                list[index0].surveyId.toString(),
                                                list[index0].name.toString(),
                                                list[index0].id.toString(),
                                            );*/
                                      setState(() {
                                        //_access_point_name.text = list[index0].name.toString();
                                      });
                                    },
                                    child: Container(
                                      width: 120,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: new BoxDecoration(
                                          color: Colors.black
                                              .withOpacity(.7),
                                          borderRadius:
                                          BorderRadius.circular(3)),
                                      child: Text(
                                        'Edit',
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
                          ),
                        ],
                      );
                    }),
              )
                  : Container(),


              checkshowImgupload_yes == true ?Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                        left: 0.0, top: 10, bottom: 0.0, right: 0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          child: new GestureDetector(
                            onTap: () {

                            },
                            child: Container(
                              width: screenSize.width,
                              height: 50,
                              alignment: Alignment.centerLeft,
                              decoration: new BoxDecoration(
                                  color: Colors.black.withOpacity(.7),
                                  borderRadius:
                                  BorderRadius.circular(0)),
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 15),
                                child: Text(
                                  '  ACCESS  POINTS NAME OR ID',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 15),
                    child: Text("AP MAC ID",  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                    ),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, top: 5),
                    child: Center(
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.93,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: Colors.black54, width: .2)),
                        child: Padding(
                          padding:
                          const EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: TextFormField(
                            controller: _macIdController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(
                                  15.0, 10.0, 15.0, 10.0),
                              hintText: 'Such as 12,13,14',
                              //labelText: 'Email',
                              border: InputBorder.none,
                              hintStyle:
                              TextStyle(color: Colors.black54),
                            ),
                            style: TextStyle(color: Colors.black54),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 15),
                    child: Text("AP Serial No",  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                    ),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, top: 5),
                    child: Center(
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.93,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: Colors.black54, width: .2)),
                        child: Padding(
                          padding:
                          const EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: TextFormField(
                            controller: _serialNo,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(
                                  15.0, 10.0, 15.0, 10.0),
                              hintText: 'Such as 12,13,14',
                              //labelText: 'Email',
                              border: InputBorder.none,
                              hintStyle:
                              TextStyle(color: Colors.black54),
                            ),
                            style: TextStyle(color: Colors.black54),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 15),
                    child: Text("Battery Box for API",  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                    ),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, top: 5),
                    child: Center(
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.93,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: Colors.black54, width: .2)),
                        child: Padding(
                          padding:
                          const EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: TextFormField(
                            controller: _batteryBox,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(
                                  15.0, 10.0, 15.0, 10.0),
                              hintText: 'Serial No',
                              //labelText: 'Email',
                              border: InputBorder.none,
                              hintStyle:
                              TextStyle(color: Colors.black54),
                            ),
                            style: TextStyle(color: Colors.black54),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding:
                    const EdgeInsets.fromLTRB(15, 20, 15, 5),
                    child: Text(
                      "Uploaded Images",
                      style: TextStyle(
                          color: Colors.black54, fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          //onTap: () => {_pickCameraImage(parentContext)},
                          onTap: () {
                            captureImage(ImageSource.camera, parentContext);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.blue),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  27, 15, 27, 15),
                              child: Text(
                                "Take Picture",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            captureImage(ImageSource.gallery, parentContext);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.blue),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  27, 15, 27, 15),
                              child: Text(
                                "Browse File to upload",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Container(
                        height: 120,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 0,left: 5,right: 5,bottom: 0),
                          child: GridView.count(
                            crossAxisCount: 3,
                            children: List.generate(ImageList.length, (index) {
                              File file = ImageList[index];
                              return Column(
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.file(
                                        file,
                                        fit: BoxFit.cover,
                                        height: 75,
                                        width: 100,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets.only(top: 10),
                                    child: GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          ImageList.removeAt(index);
                                          print("iiisdfgggggggggggggggggggggg");
                                        });
                                      },
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(
                                            color: Colors.black54),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            }),
                          ),
                        ),
                      )
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 0.0, top: 20.0, bottom: 20.0, right: 5.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          child: new GestureDetector(
                            onTap: () {
                              if(_macIdController.text.toString() == ""){
                                Toast.show("Please Fill Mac ID ", context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

                              }else if(_serialNo.text.toString() == ""){
                                Toast.show("Please Fill AP Serial No.", context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                              }else if(_batteryBox.text.toString() == ""){
                                Toast.show("Please Fill Battery Box", context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                              }else if(checkimgupload_yes != true ){
                                Toast.show("Please Take Picture", context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                              }
                              else{
                                installationAccessPointSubmit(
                                  apiToken.toString(),
                                  widget.installationId.toString(),
                                  _macIdController.text.toString(),
                                  _serialNo.text.toString(),
                                  _batteryBox.text.toString(),
                                );
                              }
                            },
                            child: Container(
                              width: 120,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: new BoxDecoration(
                                  color: Colors.deepOrange,
                                  borderRadius:
                                  BorderRadius.circular(3)),
                              child: Text(
                                'Submit',
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
                  ),
                ],
              ): Container(),
            ],
          ),
        ),
      ),
    );
  }

  requestStoragePermissions() async {
    List<PermissionName> permissionNames = [];
    if (a1) permissionNames.add(PermissionName.Storage);
    message = '';
    var permissions = await Permission.requestPermissions(permissionNames);
    permissions.forEach((permission) {
      message +=
      '${permission.permissionName}: ${permission.permissionStatus}\n';
    });
    setState(() {});
  }

  _launchCaller(String customerMobileNumber) async {
    String mobileNumber = 'tel:$customerMobileNumber';

    if (await canLaunch(mobileNumber)) {
      await launch(mobileNumber);
    } else {
      throw 'Could not launch $mobileNumber';
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

class MySeparator extends StatelessWidget {
  final double height;
  final Color color;

  const MySeparator({this.height = 2, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = 6.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}

class ReasonList {
  bool status;
  List<MessageData> messageList;

  ReasonList.fromSurveyListJson(Map<String, dynamic> json) {
    try {
      status = json['success'];
      messageList = [];
      if (json['message'].length > 0) {
        for (var listItem in json['message']) {
          MessageData message = MessageData.fromSurveyListJson(listItem);
          messageList.add(message);
        }
      }
    } catch (e) {
      status = json['error'];
      print(e.toString());
    }
  }
}

class MessageData {
  int id;
  String name;

  MessageData.fromSurveyListJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      name = json['name'];
    } catch (e) {
      print(e.toString());
    }
  }

}

class Message {
  int id;
  int installationId;
  int surveyAccessPointId;
  String macId;
  String serialNo;
  String batteryBox;
  String latitude;
  String longitude;
  List<InstallationAccessPointImages> installationAccessPointImages;

  Message(
      {this.id,
        this.installationId,
        this.surveyAccessPointId,
        this.macId,
        this.serialNo,
        this.batteryBox,
        this.latitude,
        this.longitude,
        this.installationAccessPointImages});

  Message.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    installationId = json['installation_id'];
    surveyAccessPointId = json['survey_access_point_id'];
    macId = json['mac_id'];
    serialNo = json['serial_no'];
    batteryBox = json['battery_box'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    if (json['installation_access_point_images'] != null) {
      installationAccessPointImages = new List<InstallationAccessPointImages>();
      json['installation_access_point_images'].forEach((v) {
        installationAccessPointImages
            .add(new InstallationAccessPointImages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['installation_id'] = this.installationId;
    data['survey_access_point_id'] = this.surveyAccessPointId;
    data['mac_id'] = this.macId;
    data['serial_no'] = this.serialNo;
    data['battery_box'] = this.batteryBox;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    if (this.installationAccessPointImages != null) {
      data['installation_access_point_images'] =
          this.installationAccessPointImages.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class InstallationAccessPointImages {
  int id;
  int installationId;
  int userId;
  int installationAccessPointId;
  String imageName;
  String image;

  InstallationAccessPointImages(
      {this.id,
        this.installationId,
        this.userId,
        this.installationAccessPointId,
        this.imageName,
        this.image});

  InstallationAccessPointImages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    installationId = json['installation_id'];
    userId = json['user_id'];
    installationAccessPointId = json['installation_access_point_id'];
    imageName = json['image_name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['installation_id'] = this.installationId;
    data['user_id'] = this.userId;
    data['installation_access_point_id'] = this.installationAccessPointId;
    data['image_name'] = this.imageName;
    data['image'] = this.image;
    return data;
  }
}

