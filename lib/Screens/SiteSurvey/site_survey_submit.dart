import 'dart:convert';
import 'package:async/async.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/Screens/dashboard.dart';
import 'package:flutterapp/Utility/constants.dart';
import 'package:flutterapp/Screens/SiteSurvey/site_survey_list.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:permission/permission.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class SiteSurveySubmitPage extends StatefulWidget {
  final String surveyId;
  final String projectId;
  final String title;
  final String gpName;
  final String gpDistrictName;
  final String gpStateName;
  final String gpVillageName;
  final String gpBlockName;
  final String gpMobileNumber;

  SiteSurveySubmitPage(
      {Key key,
        @required this.surveyId,
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
  _SiteSurveySubmitPageState createState() => _SiteSurveySubmitPageState(
      surveyId: this.surveyId,
      projectId: this.projectId,
      title: this.title,
      gpName: this.gpName,
      gpDistrictName: this.gpDistrictName,
      gpStateName: this.gpStateName,
      gpVillageName: this.gpVillageName,
      gpBlockName: this.gpBlockName,
      gpMobileNumber: gpMobileNumber);
}

class _SiteSurveySubmitPageState extends State<SiteSurveySubmitPage> {

  FocusNode myfocusnode;
  final String surveyId;
  final String projectId;
  final String title;
  final String gpName;
  final String gpDistrictName;
  final String gpStateName;
  final String gpVillageName;
  final String gpBlockName;
  final String gpMobileNumber;

  _SiteSurveySubmitPageState(
      {Key key,
        @required this.surveyId,
        @required this.projectId,
        @required this.title,
        @required this.gpName,
        @required this.gpDistrictName,
        @required this.gpStateName,
        @required this.gpVillageName,
        @required this.gpBlockName,
        @required this.gpMobileNumber});

  final TextEditingController _macIdController = TextEditingController();
  final TextEditingController _cable_req_length = TextEditingController();
  final TextEditingController _access_point_name = TextEditingController();
  final TextEditingController _access_point_name_edit = TextEditingController();

  bool checkimgupload_yes = false;
  bool checkshowImgupload_yes = false;
  bool check_edit_access_point = false;


  bool access_point_edit_check_from_list = true;
  var access_point_id_edit_value = '';


  List<String> _Gpfeasibility = [
    'No',
    'Yes',
  ]; // Option 2
  String _selectedGpfeasibility;

  List<String> reasonList; // Option 2
  List<int> spinnerItemsId;
  String _selectedReasonlist;

  List<String> _selectlist = [
    'Yes',
    'No',
  ]; // Option 2
  String _selectedOntAvailableList;
  String _selectedOntPowerStateList;
  String _selectedMakeModelList;
  String _selectedPoeStatusList;
  String _selectedAlarmStatusList;
  String _selectedSolarPanelAvailableList;
  String _selectedCcuAvailableList;
  String _selectedBatteryAvailableList;
  String _selectedPowerRunning;

  bool isLoading = false;
  bool isToken = false;
  bool isDeclare = false;
  String apiToken = '';
  bool a1 = false;
  PermissionName permissionName = PermissionName.Internet;
  String message = '';

  getTokenRoSf() async {
    SharedPreferences shaPref = await SharedPreferences.getInstance();
    apiToken = shaPref.get("token");
    setState(() {
      isToken = true;
      isDeclare = true;
    });
  }

  Geolocator geolocator = Geolocator();

  Position userLocation;

  bool isONTDetailsClicked;

  @override
  void initState() {
    // TODO: implement initState
    isONTDetailsClicked = true;

    super.initState();
    _getLocation().then((position) {
      userLocation = position;
      myfocusnode=FocusNode();
    });
  }
  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myfocusnode.dispose();

    super.dispose();
  }

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      print('location picked: '+currentLocation.toString());
    } catch (e) {
      currentLocation = null;
      print('location not picked: '+e.toString());
    }
    return currentLocation;
  }


  /* void _pickImage(context) async {
    showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select the image source'),
          actions: <Widget>[
            MaterialButton(
              child: Text('Camera'),
              onPressed: () => captureImage(ImageSource.camera, context),
            ),
            MaterialButton(
              child: Text('Gallery'),
              onPressed: () => captureImage(ImageSource.gallery, context),
            )
          ],
        ));
  }*/


  var parentContext;
  File _pickedImage;
  List<File> ImageList = List<File>();

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


  String imageNames= '';

  Future uploadMultipleImage(File images) async {
    setState(() {
      isLoading = true;
      checkimgupload_yes = true;
    });

    var stream = new http.ByteStream(DelegatingStream.typed(images.openRead()));

    var length = await images.length();

    SharedPreferences shaPref = await SharedPreferences.getInstance();
    var token = shaPref.get("token");

    Map<String, String> headers = {
      'authkey': 'Bcju0SQW2RKR0vhLzGbjeQwqkJvBUyA4IkMDuNubQq5'
    };
    var uri = Uri.parse(
        'https://fieldapp.m2mcybernetics.com/api/v1/imageUpload?token=$token');
    var request = new http.MultipartRequest("POST", uri);


    var multipartFileSign = http.MultipartFile('image_name', stream, length,
        filename: basename(images.path));

    // add file to multipart
    request.files.add(multipartFileSign);

    request.headers.addAll(headers);

    var jsonresponse = await request.send();

    var resultsapi = await jsonresponse.stream.bytesToString();
    var imgjasonresponse = jsonDecode(resultsapi);

    _stopAnimation();

    if (jsonresponse.statusCode == 200) {

      String surveyacessimage = imgjasonresponse["message"].toString();
      imageNames = imageNames+','+surveyacessimage;
      debugPrint("zzzzzzyyyyyyyy$imageNames");

      print("Image Uploaded");
    } else {
      print("Upload Failed");
    }
    imgjasonresponse.stream.transform(utf8.decoder).listen((value) {
      print("ddddd" + value);
    });
  }

  List<Message> list = List();

  double screenheight =  900;

  surveyAccessPointSubmit(
      String token,
      String survey_id,
      String Access_point,
      ) async {
    debugPrint(
        "wfawfawfawfawfawfawffawfa$imageNames");
    print("$imageNames   $Access_point  $survey_id    $token ");

    setState(
          () {
        isLoading = true;
        _getLocation().then((value) {
          setState(() {
            userLocation = value;
          });
        });

        print("Location:" +
            userLocation.latitude.toString() +
            " " +
            userLocation.longitude.toString());

      },
    );

    Map data = {
      'token': token,
      'survey_id': survey_id,
      'name': Access_point,
      'latitude': userLocation.latitude.toString(),
      'longitude':  userLocation.longitude.toString(),
      'servey_access_point_id': '',
      'images': imageNames,
    };
    var response = await http.post(
        'https://fieldapp.m2mcybernetics.com/api/v1/surveyAccessPointSubmit',
        body: data,
        headers: {'authkey': 'Bcju0SQW2RKR0vhLzGbjeQwqkJvBUyA4IkMDuNubQq5'});

    var jsonResponse = json.decode(response.body);

    debugPrint("bodybodybodybodybody"+response.body.toString());
    if (response.statusCode == 200) {

      debugPrint("jsonResponsejsonResponsejsonResponse"+jsonResponse.toString());
      list = parseData(json.decode(response.body));


      setState(() {
        ImageList.clear();
        _access_point_name.clear();
        imageNames= ' ';
        check_edit_access_point = true;
        double screen = 400;
        screenheight = screenheight + screen;
      });



      _stopAnimation();

      Toast.show("Access Point Submit successfully", parentContext,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);


      return list;


    } else {
      print("Access Point Faild");
      _stopAnimation();
    }
  }

  surveyAccessPointEdit(
      String token,
      String survey_id,
      String Access_point,
      String Access_point_id,
      ) async {

    print("$Access_point_id   $Access_point  $survey_id    $token ");

    setState(
          () {
        isLoading = true;
      },
    );

    Map data = {
      'token': token,
      'survey_id': survey_id,
      'name': Access_point,
      'latitude': userLocation.latitude.toString(),
      'longitude':  userLocation.longitude.toString(),
      'servey_access_point_id': Access_point_id,
      'images': imageNames,
    };
    var response = await http.post(
        'https://fieldapp.m2mcybernetics.com/api/v1/surveyAccessPointSubmit',
        body: data,
        headers: {'authkey': 'Bcju0SQW2RKR0vhLzGbjeQwqkJvBUyA4IkMDuNubQq5'});

    var jsonResponse = json.decode(response.body);

    debugPrint("bodybodybodybodybody"+response.body.toString());
    if (response.statusCode == 200) {

      debugPrint("jsonResponsejsonResponsejsonResponse"+jsonResponse.toString());
      list = parseData(json.decode(response.body));

      _access_point_name.clear();
      imageNames= ' ';
      access_point_edit_check_from_list = true;

      _stopAnimation();

      Toast.show("Access Point Edit successfully", parentContext,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return list;

    } else {
      print("Access Point Faild");
      _stopAnimation();
    }
  }

  List<Message> parseData(dataJson) {
    var list = dataJson['message'] as List;
    List<Message> dataList =
    list.map((message) => Message.fromJson(message)).toList();
    return dataList;
  }



  _remAccessPointImage(
      String token,
      String id,
      String survey_id,
      )async {

    debugPrint("xxxxxxxxxxxxxx$survey_id");
    print(" $id   $survey_id,   $token  ");

    setState(
          () {
        isLoading = true;
      },
    );

    final data = {
      'token': token,
      'id': id.toString(),
      'survey_id': survey_id.toString()
    };



    Uri uri = Uri.parse("https://fieldapp.m2mcybernetics.com/api/v1/remAccessPointImage");

    final newURI = uri.replace(queryParameters: data);

    var response = await http.get(newURI,
        headers: {'authkey': 'Bcju0SQW2RKR0vhLzGbjeQwqkJvBUyA4IkMDuNubQq5'});

    print("gggggggggggggggggggggggggggggg "+response.body.toString());

    setState(() {
      if (response.statusCode == 200) {

        _stopAnimation();

        var jsonResponse = json.decode(response.body);
        debugPrint("ssssiMGrssssiMGrssssiMGrssssiMGrssssiMGr" +jsonResponse.toString());

        Toast.show("Image Delete successfully", parentContext,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);



      } else {
        print("IMAGE DELETE  Faild");
        _stopAnimation();
      }
    });

  }



  surveysubmit_yes(
      String token,
      String project_id,
      String survey_id,
      String Gpfeasibility,
      String OntAvailableList,
      String OntPowerStateList,
      String MakeModelList,
      String MacIdController,
      String PoeStatusList,
      String AlarmStatusList,
      String PanelAvailableList,
      String CcuAvailableList,
      String BatteryAvailable,
      String PowerRunning,
      String Cable_req_length,
      ) async {
    setState(
          () {
        isLoading = true;
        debugPrint("xxxxxxxxxxxxdddddddddddxxxxxxxxxxx$survey_id");
      },
    );
    Map data = {
      'token': token,
      'project_id': project_id,
      'survey_id': survey_id,
      'feasibility': '1' ,
      'reason': '',
      'ont_available': OntAvailableList == 'Yes' ? '1' : '0',
      'ont_power_status': OntPowerStateList == 'Yes' ? '1' : '0',
      'ont_make_model': MakeModelList == 'Yes' ? '1' : '0',
      'ont_mac_id': MacIdController,
      'poe_status': PoeStatusList == 'Yes' ? '1' : '0',
      'alarm_status': AlarmStatusList == 'Yes' ? '1' : '0',
      'solar_panel_available': PanelAvailableList == 'Yes' ? '1' : '0',
      'ccu_available': CcuAvailableList == 'Yes' ? '1' : '0',
      'battery_available': BatteryAvailable == 'Yes' ? '1' : '0',
      'power_running': PowerRunning == 'Yes' ? '1' : '0',
      'cable_req_length': Cable_req_length,
      'images': '',
    };
    var response = await http.post(
        'https://fieldapp.m2mcybernetics.com/api/v1/surveyDetailSubmit',
        body: data,
        headers: {'authkey': 'Bcju0SQW2RKR0vhLzGbjeQwqkJvBUyA4IkMDuNubQq5'});
    debugPrint(response.body.toString());
    if (response.statusCode == 200) {
      checkshowImgupload_yes = true;


      _macIdController.clear();
      _cable_req_length.clear();

      _stopAnimation();
      Toast.show("Submit successfully", parentContext,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      var jsonResponse = json.decode(response.body);
      print(jsonResponse.toString());
    } else {
      print("Submit Faild");
      _stopAnimation();
    }
  }

  surveysubmit_no(
      String token,
      String project_id,
      String survey_id,
      String Gpfeasibility,
      String Reasonlist,
      ) async {
    setState(
          () {
        isLoading = true;
        print("Sultan$project_id $survey_id $Reasonlist");
      },
    );

    Map data = {
      'token': token,
      'project_id': project_id,
      'survey_id': survey_id,
      'feasibility': '0',
      'reason': Reasonlist,
      'ont_available': '',
      'ont_power_status': '',
      'ont_make_model': '',
      'ont_mac_id': '',
      'poe_status': '',
      'alarm_status': '',
      'solar_panel_available': '',
      'ccu_available': '',
      'cable_req_length': '',
      'battery_available': '',
      'power_running': '',
      'images': imageNames
    };
    var response = await http.post(
        'https://fieldapp.m2mcybernetics.com/api/v1/surveyDetailSubmit',
        body: data,
        headers: {'authkey': 'Bcju0SQW2RKR0vhLzGbjeQwqkJvBUyA4IkMDuNubQq5'});
    debugPrint(response.body.toString());
    if (response.statusCode == 200) {

      imageNames= ' ';
      ImageList.clear();

      Toast.show("Submit successfully", parentContext,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      var jsonResponse = json.decode(response.body);
      print("rrrrrr" + jsonResponse.toString());
      _stopAnimation();
      Navigator.of(parentContext).push(
        MaterialPageRoute(
            builder: (_) => SiteSurveyPage()),
      );
    } else {
      print("Submit Faild");
      _stopAnimation();
    }
  }



  @override
  Widget build(BuildContext context) {

    final screenSize = MediaQuery.of(context).size;
    parentContext = context;
    requestStoragePermissions();
    if (!isDeclare) {
      reasonList = [];
      spinnerItemsId = [];
      getTokenRoSf();
    }

    if (isToken) {
      getReasonsList();
    }

//    if (isLoading) {
//      return Container(
//          height: 100,
//          margin: EdgeInsets.only(top: 60),
//          decoration: BoxDecoration(color: Color(0x80787878)),
//          child: kLoadingWidget(context));
//    }


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
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SiteSurveyPage()),
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
        //physics: ScrollPhysics(),
        child: Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Container(
//                height: MediaQuery.of(context).size.height + screenheight/2,
                  decoration: BoxDecoration(color: Color(0xE5F4FD)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                                                  borderRadius:
                                                  new BorderRadius.all(
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 25, 15, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("GP Feasibility:",
                                style:
                                TextStyle(color: Colors.black54, fontSize: 16)),
                            Container(
                              height: 50,
                              width: 160,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border:
                                  Border.all(color: Colors.black54, width: .2)),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                        const EdgeInsets.fromLTRB(13, 0, 0, 0),
                                        child: DropdownButton<String>(
                                          hint: Text('Select'),
                                          isExpanded: true,
                                          value: _selectedGpfeasibility,
                                          icon: Icon(
                                            Icons.expand_more,
                                            size: 35,
                                          ),
                                          iconSize: 24,
                                          elevation: 16,
                                          style: TextStyle(
                                              color: Colors.black54, fontSize: 16),
                                          underline: Container(
                                            height: 0,
                                          ),
                                          onChanged: (String value) {
                                            setState(() {
                                              _selectedGpfeasibility = value;
                                              print(_selectedGpfeasibility);
                                            });
                                          },
                                          items: _Gpfeasibility.map((gp_faci) {
                                            return DropdownMenuItem<String>(
                                              value: gp_faci,
                                              child: Text(
                                                gp_faci,
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
                      _selectedGpfeasibility == null ? Container() : Container(),
                      _selectedGpfeasibility == 'No'
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 20, left: 15, right: 15),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  height: 50,
                                  width:
                                  MediaQuery.of(context).size.width - 30,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: Colors.black54, width: .2)),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0, 0, 10, 0),
                                    child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding:
                                            const EdgeInsets.fromLTRB(
                                                13, 0, 0, 0),
                                            child: DropdownButton<String>(
                                              hint: Text(
                                                  'Please Select Reason'),
                                              isExpanded: true,
                                              value: _selectedReasonlist,
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
                                                  _selectedReasonlist = value;
                                                  print(_selectedReasonlist);
                                                });
                                              },
                                              items: reasonList.map((r_list) {
                                                return DropdownMenuItem<
                                                    String>(
                                                  value: r_list,
                                                  child: Text(
                                                    r_list,
                                                    textAlign:
                                                    TextAlign.center,
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding:
                                const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                child: Text(
                                  "Uploaded Images",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 16),
                                ),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.fromLTRB(15, 5, 15, 15),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    GestureDetector(
                                      //onTap: () => {_pickCameraImage(parentContext)},
                                      onTap: () {
                                        captureImage(ImageSource.camera,
                                            parentContext);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(5),
                                            color: Colors.blue),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              27, 15, 27, 15),
                                          child: Text(
                                            "Take Picture",
                                            style: TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        captureImage(ImageSource.gallery,
                                            parentContext);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(5),
                                            color: Colors.blue),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              27, 15, 27, 15),
                                          child: Text(
                                            "Browse File to upload",
                                            style: TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10, 10, 10, 0),
                                  child: Container(
                                    height: 120,
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 0,
                                          left: 5,
                                          right: 5,
                                          bottom: 0),
                                      child: GridView.count(
                                        crossAxisCount: 3,
                                        children: List.generate(
                                            ImageList.length, (index) {
                                          File file = ImageList[index];
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
                                                const EdgeInsets.only(
                                                    top: 10),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      ImageList.removeAt(
                                                          index);
                                                      print(
                                                          "iiisdfgggggggggggggggggggggg");
                                                    });
                                                  },
                                                  child: Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                        color:
                                                        Colors.black54),
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                        }),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 0.0,
                                top: 10.0,
                                bottom: 20.0,
                                right: 5.0),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.center,
                                  child: new GestureDetector(
                                    onTap: () {
                                      if (_selectedReasonlist == null) {
                                        Toast.show(
                                            "Please Select Reason", context,
                                            duration: Toast.LENGTH_SHORT,
                                            gravity: Toast.BOTTOM);
                                      } else {
                                        surveysubmit_no(
                                          apiToken.toString(),
                                          widget.projectId.toString(),
                                          widget.surveyId.toString(),
                                          _selectedGpfeasibility.toString(),
                                          _selectedReasonlist.toString(),
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
                      )
                          : Container(),
                      _selectedGpfeasibility == 'Yes'
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                          onTap: (){
                            setState(() {
                              isONTDetailsClicked = !isONTDetailsClicked;
                            });
                          },
                            child: Container(
                              padding: const EdgeInsets.only(
                                  top: 10 ,bottom: 10, left: 15, right: 15),
                              width: MediaQuery.of(context).size.width,
                              height: 60,
                              alignment: Alignment.centerLeft,
                              color: Colors.blueGrey[600],
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("ONT Details",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                  Icon(!isONTDetailsClicked? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, color: Colors.white,),
                                ],
                              ),
                            ),
                          ),

                          Visibility(
                          visible: isONTDetailsClicked? true :false,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only( top:10,
                                      bottom: 10, left: 15, right: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("ONT Available:",
                                          style: TextStyle(
                                              color: Colors.black54, fontSize: 16)),
                                      Container(
                                        height: 50,
                                        width: 160,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.black54, width: .2)),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 0),
                                          child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.fromLTRB(
                                                      13, 0, 0, 0),
                                                  child: DropdownButton<String>(
                                                    hint: Text('Select'),
                                                    isExpanded: true,
                                                    value:
                                                    _selectedOntAvailableList,
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
                                                        _selectedOntAvailableList =
                                                            value;
                                                        print(
                                                            _selectedOntAvailableList);
                                                      });
                                                    },
                                                    items:
                                                    _selectlist.map((s_list) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: s_list,
                                                        child: Text(
                                                          s_list,
                                                          textAlign:
                                                          TextAlign.center,
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
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("ONT Power Status:",
                                          style: TextStyle(
                                              color: Colors.black54, fontSize: 16)),
                                      Container(
                                        height: 50,
                                        width: 160,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.black54, width: .2)),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 0),
                                          child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.fromLTRB(
                                                      13, 0, 0, 0),
                                                  child: DropdownButton<String>(
                                                    hint: Text('Select'),
                                                    isExpanded: true,
                                                    value:
                                                    _selectedOntPowerStateList,
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
                                                        _selectedOntPowerStateList =
                                                            value;
                                                        print(
                                                            _selectedOntPowerStateList);
                                                      });
                                                    },
                                                    items:
                                                    _selectlist.map((s_list) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: s_list,
                                                        child: Text(
                                                          s_list,
                                                          textAlign:
                                                          TextAlign.center,
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
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("ONT Make & Model:",
                                          style: TextStyle(
                                              color: Colors.black54, fontSize: 16)),
                                      Container(
                                        height: 50,
                                        width: 160,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.black54, width: .2)),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 0),
                                          child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.fromLTRB(
                                                      13, 0, 0, 0),
                                                  child: DropdownButton<String>(
                                                    hint: Text('Select'),
                                                    isExpanded: true,
                                                    value: _selectedMakeModelList,
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
                                                        _selectedMakeModelList =
                                                            value;
                                                        print(
                                                            _selectedMakeModelList);
                                                      });
                                                    },
                                                    items:
                                                    _selectlist.map((s_list) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: s_list,
                                                        child: Text(
                                                          s_list,
                                                          textAlign:
                                                          TextAlign.center,
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
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("ONT Make ID:",
                                          style: TextStyle(
                                              color: Colors.black54, fontSize: 16)),
                                      Container(
                                        height: 50,
                                        width: 160,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.black54, width: .2)),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 0),
                                          child: TextFormField(
                                            controller: _macIdController,

                                            focusNode: myfocusnode,
                                            onFieldSubmitted: (term){
                                              myfocusnode.unfocus();
                                            },
                                            autofocus: false,
                                            decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.fromLTRB(
                                                  15.0, 10.0, 15.0, 10.0),
                                              hintText: 'Enter Mac id',

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

                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 10, left: 15, right: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("POE Status:",
                                          style: TextStyle(
                                              color: Colors.black54, fontSize: 16)),
                                      Container(
                                        height: 50,
                                        width: 160,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.black54, width: .2)),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 0),
                                          child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.fromLTRB(
                                                      13, 0, 0, 0),
                                                  child: DropdownButton<String>(
                                                    hint: Text('Select'),
                                                    isExpanded: true,
                                                    value: _selectedPoeStatusList,
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
                                                        _selectedPoeStatusList =
                                                            value;
                                                        print(
                                                            _selectedPoeStatusList);
                                                      });
                                                    },
                                                    items:
                                                    _selectlist.map((s_list) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: s_list,
                                                        child: Text(
                                                          s_list,
                                                          textAlign:
                                                          TextAlign.center,
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
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Alarm Status:",
                                          style: TextStyle(
                                              color: Colors.black54, fontSize: 16)),
                                      Container(
                                        height: 50,
                                        width: 160,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.black54, width: .2)),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 0),
                                          child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.fromLTRB(
                                                      13, 0, 0, 0),
                                                  child: DropdownButton<String>(
                                                    hint: Text('Select'),
                                                    isExpanded: true,
                                                    value: _selectedAlarmStatusList,
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
                                                        _selectedAlarmStatusList =
                                                            value;
                                                        print(
                                                            _selectedAlarmStatusList);
                                                      });
                                                    },
                                                    items:
                                                    _selectlist.map((s_list) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: s_list,
                                                        child: Text(
                                                          s_list,
                                                          textAlign:
                                                          TextAlign.center,
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
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Power Running:",
                                          style: TextStyle(
                                              color: Colors.black54, fontSize: 16)),
                                      Container(
                                        height: 50,
                                        width: 160,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.black54, width: .2)),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 0),
                                          child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.fromLTRB(
                                                      13, 0, 0, 0),
                                                  child: DropdownButton<String>(
                                                    hint: Text('Select'),
                                                    isExpanded: true,
                                                    value: _selectedPowerRunning,
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
                                                        _selectedPowerRunning =
                                                            value;
                                                        print(
                                                            _selectedPowerRunning);
                                                      });
                                                    },
                                                    items:
                                                    _selectlist.map((s_list) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: s_list,
                                                        child: Text(
                                                          s_list,
                                                          textAlign:
                                                          TextAlign.center,
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
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Solar Panel Available:",
                                          style: TextStyle(
                                              color: Colors.black54, fontSize: 16)),
                                      Container(
                                        height: 50,
                                        width: 160,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.black54, width: .2)),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 0),
                                          child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.fromLTRB(
                                                      13, 0, 0, 0),
                                                  child: DropdownButton<String>(
                                                    hint: Text('Select'),
                                                    isExpanded: true,
                                                    value:
                                                    _selectedSolarPanelAvailableList,
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
                                                        _selectedSolarPanelAvailableList =
                                                            value;
                                                        print(
                                                            _selectedSolarPanelAvailableList);
                                                      });
                                                    },
                                                    items:
                                                    _selectlist.map((s_list) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: s_list,
                                                        child: Text(
                                                          s_list,
                                                          textAlign:
                                                          TextAlign.center,
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
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("CCU Available:",
                                          style: TextStyle(
                                              color: Colors.black54, fontSize: 16)),
                                      Container(
                                        height: 50,
                                        width: 160,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.black54, width: .2)),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 0),
                                          child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.fromLTRB(
                                                      13, 0, 0, 0),
                                                  child: DropdownButton<String>(
                                                    hint: Text('Select'),
                                                    isExpanded: true,
                                                    value:
                                                    _selectedCcuAvailableList,
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
                                                        _selectedCcuAvailableList =
                                                            value;
                                                        print(
                                                            _selectedCcuAvailableList);
                                                      });
                                                    },
                                                    items:
                                                    _selectlist.map((s_list) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: s_list,
                                                        child: Text(
                                                          s_list,
                                                          textAlign:
                                                          TextAlign.center,
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
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Battery Available:",
                                          style: TextStyle(
                                              color: Colors.black54, fontSize: 16)),
                                      Container(
                                        height: 50,
                                        width: 160,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.black54, width: .2)),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 0),
                                          child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.fromLTRB(
                                                      13, 0, 0, 0),
                                                  child: DropdownButton<String>(
                                                    hint: Text('Select'),
                                                    isExpanded: true,
                                                    value:
                                                    _selectedBatteryAvailableList,
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
                                                        _selectedBatteryAvailableList =
                                                            value;
                                                        print(
                                                            _selectedBatteryAvailableList);
                                                      });
                                                    },
                                                    items:
                                                    _selectlist.map((s_list) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: s_list,
                                                        child: Text(
                                                          s_list,
                                                          textAlign:
                                                          TextAlign.center,
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
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("ONT LAN Cable \nRequired Length(M):",
                                          style: TextStyle(
                                              color: Colors.black54, fontSize: 16)),
                                      Container(
                                        height: 50,
                                        width: 160,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.black54, width: .2)),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 0),
                                          child: TextFormField(
                                            controller: _cable_req_length,
                                            decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.fromLTRB(
                                                  15.0, 10.0, 15.0, 10.0),
                                              hintText: 'Such as 12, 13, 15',
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
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 0.0, top: 20.0, bottom: 20, right: 5.0),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.center,
                                        child: new GestureDetector(
                                          onTap: () {
                                            if (_selectedOntAvailableList == null) {
                                              Toast.show(
                                                  "Please Select ONT Available",
                                                  context,
                                                  duration: Toast.LENGTH_SHORT,
                                                  gravity: Toast.BOTTOM);
                                            } else if (_selectedOntPowerStateList ==
                                                null) {
                                              Toast.show(
                                                  "Please Select ONT Power Status",
                                                  context,
                                                  duration: Toast.LENGTH_SHORT,
                                                  gravity: Toast.BOTTOM);
                                            } else if (_selectedMakeModelList ==
                                                null) {
                                              Toast.show(
                                                  "Please Select ONT Make & Model",
                                                  context,
                                                  duration: Toast.LENGTH_SHORT,
                                                  gravity: Toast.BOTTOM);
                                            } else if (_macIdController.text
                                                .toString() ==
                                                "") {
                                              Toast.show(
                                                  "Please Fill Mac ID", context,
                                                  duration: Toast.LENGTH_SHORT,
                                                  gravity: Toast.BOTTOM);
                                            } else if (_selectedPoeStatusList ==
                                                null) {
                                              Toast.show("Please Select Poe Status",
                                                  context,
                                                  duration: Toast.LENGTH_SHORT,
                                                  gravity: Toast.BOTTOM);
                                            } else if (_selectedAlarmStatusList ==
                                                null) {
                                              Toast.show(
                                                  "Please Select Alarm Status",
                                                  context,
                                                  duration: Toast.LENGTH_SHORT,
                                                  gravity: Toast.BOTTOM);
                                            } else if (_selectedSolarPanelAvailableList ==
                                                null) {
                                              Toast.show(
                                                  "Please Select Solar Panel Available",
                                                  context,
                                                  duration: Toast.LENGTH_SHORT,
                                                  gravity: Toast.BOTTOM);
                                            } else if (_selectedCcuAvailableList ==
                                                null) {
                                              Toast.show(
                                                  "Please Select CCU Available",
                                                  context,
                                                  duration: Toast.LENGTH_SHORT,
                                                  gravity: Toast.BOTTOM);
                                            } else if (_cable_req_length.text
                                                .toString() ==
                                                "") {
                                              Toast.show(
                                                  "Please Fill Cable Req Length",
                                                  context,
                                                  duration: Toast.LENGTH_SHORT,
                                                  gravity: Toast.BOTTOM);
                                            } else if (_selectedPowerRunning ==
                                                null) {
                                              Toast.show(
                                                  "Please Select Power Running",
                                                  context,
                                                  duration: Toast.LENGTH_SHORT,
                                                  gravity: Toast.BOTTOM);
                                            } else if (_selectedBatteryAvailableList ==
                                                null) {
                                              Toast.show(
                                                  "Please Select Battery Available",
                                                  context,
                                                  duration: Toast.LENGTH_SHORT,
                                                  gravity: Toast.BOTTOM);
                                            } else {
                                              surveysubmit_yes(
                                                apiToken.toString(),
                                                widget.projectId.toString(),
                                                widget.surveyId.toString(),
                                                _selectedGpfeasibility.toString(),
                                                _selectedOntAvailableList
                                                    .toString(),
                                                _selectedOntPowerStateList
                                                    .toString(),
                                                _selectedMakeModelList.toString(),
                                                _macIdController.text.toString(),
                                                _selectedPoeStatusList.toString(),
                                                _selectedAlarmStatusList.toString(),
                                                _selectedSolarPanelAvailableList
                                                    .toString(),
                                                _selectedCcuAvailableList
                                                    .toString(),
                                                _selectedPowerRunning.toString(),
                                                _selectedBatteryAvailableList
                                                    .toString(),
                                                _cable_req_length.text.toString(),
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
                          ),
                        ],
                      )
                          : Container(),
                    ],
                  ),
                ),

                checkshowImgupload_yes == true
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          left: 0.0, top: 10, bottom: 0.0, right: 0),
                      child: Container(
                        alignment: Alignment.center,
                        child: new GestureDetector(
                          onTap: () {
                            /*Navigator.of(context).pushReplacement(MaterialPageRoute(
                                      builder: (context) => DashboardPage(),
                                    ));*/
                          },
                          child: Container(
                            width: screenSize.width,
                            height: 50,
                            alignment: Alignment.centerLeft,
                            decoration: new BoxDecoration(
                                color: Colors.black.withOpacity(.7),
                                borderRadius: BorderRadius.circular(0)),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Text(
                                '  ADD  -  ACCESS  POINTS',
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
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 20),
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
                            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: TextFormField(
                              controller: _access_point_name,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(
                                    15.0, 10.0, 15.0, 10.0),
                                hintText: 'Enter AP Name or ID',
                                //labelText: 'Email',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.black54),
                              ),
                              style: TextStyle(color: Colors.black54),
                              keyboardType: TextInputType.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 20, 15, 5),
                      child: Text(
                        "Uploaded Images",
                        style:
                        TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            //onTap: () => {_pickCameraImage(parentContext)},
                            onTap: () {
                              captureImage(
                                  ImageSource.camera, parentContext);
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
                            onTap: () {
                              captureImage(
                                  ImageSource.gallery, parentContext);
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
                          height: 110,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 0, left: 5, right: 5, bottom: 0),
                            child: GridView.count(
                              crossAxisCount: 3,
                              children:
                              List.generate(ImageList.length, (index) {
                                File file = ImageList[index];
                                return Column(
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(8.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(8.0),
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
                                        onTap: () {
                                          setState(() {
                                            ImageList.removeAt(index);
                                            print("IMg Delete");
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
                        )),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        margin: EdgeInsets.only(
                            left: 0.0, top: 20.0, bottom: 20.0, right: 5.0),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              child: new GestureDetector(
                                onTap: () {
                                  if (_access_point_name.text.toString() ==
                                      "") {
                                    Toast.show(
                                        "Please Fill Access Point", context,
                                        duration: Toast.LENGTH_SHORT,
                                        gravity: Toast.BOTTOM);
                                  } else if (checkimgupload_yes != true) {
                                    Toast.show("Please Take Picture", context,
                                        duration: Toast.LENGTH_SHORT,
                                        gravity: Toast.BOTTOM);
                                  } else {
                                    if(access_point_edit_check_from_list == true){
                                      _getLocation().then((value) {
                                        setState(() {
                                          userLocation = value;
                                        });
                                      });
                                      surveyAccessPointSubmit(
                                        apiToken.toString(),
                                        widget.surveyId.toString(),
                                        _access_point_name.text.toString(),
                                      );
                                    }else{
                                      surveyAccessPointEdit(
                                          apiToken.toString(),
                                          widget.surveyId.toString(),
                                          _access_point_name.text.toString(),
                                          access_point_id_edit_value.toString()
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  width: 120,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: new BoxDecoration(
                                      color:  access_point_edit_check_from_list == true ? Colors.deepOrange :
                                      Colors.black
                                          .withOpacity(.7),
                                      borderRadius: BorderRadius.circular(3)),
                                  child: Text(
                                    access_point_edit_check_from_list == true ? 'Add AP' : "Edit AP",
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
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 10,
                        height: 1,
                        child: TextField(
                          controller: _access_point_name_edit,
                          decoration: const InputDecoration.collapsed(
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.white, fontSize: 1),
                          ),
                          style: TextStyle(color: Colors.white, fontSize: 1),
                        ),
                      ),
                    ),

                  ],
                )
                    : Container(width: 10, height: 10,),

                check_edit_access_point == true
                    ? ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        shrinkWrap: true,
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
                                                  list[index0]
                                                      .name
                                                      .toString() ??
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
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          "Latitude:  ",
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                        Text(list[index0].latitude.toString() ?? "",
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          "Longitude:  ",
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                        Text(list[index0].longitude.toString() ?? "",
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(10, 20, 10, 0),
                                  child: Container(
                                    height:150,
                                    child:
                                    GridView.builder(
                                        itemCount: list[index0].surveyAccessPointImages.length,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                                        itemBuilder: (context, index1) {
                                          return Column(
                                            children: <Widget>[
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  child: Image.network(
                                                    list[index0].surveyAccessPointImages[index1].image ,
                                                    fit: BoxFit.cover,
                                                    height: 80,
                                                    width: 100,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(top: 10),
                                                child: GestureDetector(
                                                  onTap: (){
                                                    _remAccessPointImage(
                                                      apiToken.toString(),
                                                      list[index0].surveyAccessPointImages[index1].id.toString(),
                                                      list[index0].surveyAccessPointImages[index1].surveyId.toString(),
                                                    );
                                                    surveyAccessPointEdit(
                                                      apiToken.toString(),
                                                      list[index0].surveyId.toString(),
                                                      list[index0].name.toString(),
                                                      list[index0].id.toString(),
                                                    );
                                                  },
                                                  child: Container(
                                                    child: Text(
                                                      "Delete",
                                                      style: TextStyle(
                                                          color: Colors.black54),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                        }
                                    ),
                                  )
                              ),
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
                                          setState(() {
                                            _access_point_name.text = list[index0].name.toString();
                                            _access_point_name_edit.text = list[index0].name.toString();
                                            access_point_id_edit_value = list[index0].id.toString();
                                            access_point_edit_check_from_list = false;
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
                        })
                    : Container(width: 10, height: 10,),

              ],
            ),
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

  getReasonsList() async {
    setState(() {
      isLoading = true;
    });
    isToken = false;
    var response = await http.get(
        'https://fieldapp.m2mcybernetics.com/api/v1/getReasons?token=$apiToken',
        headers: {'authkey': 'Bcju0SQW2RKR0vhLzGbjeQwqkJvBUyA4IkMDuNubQq5'});
    if (response.statusCode == 200) {
      try {
        var jsonResponse = json.decode(response.body);
        print(jsonResponse.toString());
        if (jsonResponse["success"] == true) {
          ReasonList otpVerificationData =
          ReasonList.fromSurveyListJson(jsonResponse);
          if (otpVerificationData.status == true) {
            /*Toast.show("Reason List success", context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);*/
            List<String> typeItemList = [];
            if (otpVerificationData.messageList.length > 0) {
              typeItemList.add('Please Select Reason');
              spinnerItemsId.add(0);
              for (var reasonItem in otpVerificationData.messageList) {
                typeItemList.add(reasonItem.name);
                spinnerItemsId.add(reasonItem.id);
              }
            }
            setState(() {
              reasonList = typeItemList;
            });
          } else {
            /*  Toast.show('You have no data', context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);*/
          }
        } else {
          /* Toast.show("Survey failed", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);*/
        }
        _stopAnimation();
      } catch (e) {
        _stopAnimation();
        print(e);
      }
    } else {
      _stopAnimation();
      debugPrint("Survey failed");
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

setTokenRoSf(String surveyimg) async {
  SharedPreferences shaPref = await SharedPreferences.getInstance();
  shaPref.setString("surveyimg", surveyimg);
}


class Message {
  int id;
  int surveyId;
  int userId;
  String name;
  String latitude;
  String longitude;
  List<SurveyAccessPointImages> surveyAccessPointImages;

  Message(
      {this.id,
        this.surveyId,
        this.userId,
        this.name,
        this.latitude,
        this.longitude,
        this.surveyAccessPointImages});

  Message.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    surveyId = json['survey_id'];
    userId = json['user_id'];
    name = json['name'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    if (json['survey_access_point_images'] != null) {
      surveyAccessPointImages = new List<SurveyAccessPointImages>();
      json['survey_access_point_images'].forEach((v) {
        surveyAccessPointImages.add(new SurveyAccessPointImages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['survey_id'] = this.surveyId;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    if (this.surveyAccessPointImages != null) {
      data['survey_access_point_images'] =
          this.surveyAccessPointImages.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SurveyAccessPointImages {
  int id;
  int surveyId;
  int userId;
  int surveyAccessPointId;
  String imageName;
  String image;

  SurveyAccessPointImages(
      {this.id,
        this.surveyId,
        this.userId,
        this.surveyAccessPointId,
        this.imageName,
        this.image});

  SurveyAccessPointImages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    surveyId = json['survey_id'];
    userId = json['user_id'];
    surveyAccessPointId = json['survey_access_point_id'];
    imageName = json['image_name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['survey_id'] = this.surveyId;
    data['user_id'] = this.userId;
    data['survey_access_point_id'] = this.surveyAccessPointId;
    data['image_name'] = this.imageName;
    data['image'] = this.image;
    return data;
  }
}

