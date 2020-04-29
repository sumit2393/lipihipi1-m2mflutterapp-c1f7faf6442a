// To parse this JSON data, do
//
//     final getSurveyDetailsResponse = getSurveyDetailsResponseFromJson(jsonString);

import 'dart:convert';

GetSurveyDetailsResponse getSurveyDetailsResponseFromJson(String str) => GetSurveyDetailsResponse.fromJson(json.decode(str));

String getSurveyDetailsResponseToJson(GetSurveyDetailsResponse data) => json.encode(data.toJson());

class GetSurveyDetailsResponse {
  bool success;
  Message message;

  GetSurveyDetailsResponse({
    this.success,
    this.message,
  });

  factory GetSurveyDetailsResponse.fromJson(Map<String, dynamic> json) => GetSurveyDetailsResponse(
    success: json["success"],
    message: Message.fromJson(json["message"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message.toJson(),
  };
}

class Message {
  Details details;
  List<AccessPoint> accessPoints;

  Message({
    this.details,
    this.accessPoints,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    details: Details.fromJson(json["details"]),
    accessPoints: List<AccessPoint>.from(json["access_points"].map((x) => AccessPoint.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "details": details.toJson(),
    "access_points": List<dynamic>.from(accessPoints.map((x) => x.toJson())),
  };
}

class AccessPoint {
  int id;
  int surveyId;
  int userId;
  String name;
  String latitude;
  String longitude;
  List<SurveyAccessPointImage> surveyAccessPointImages;

  AccessPoint({
    this.id,
    this.surveyId,
    this.userId,
    this.name,
    this.latitude,
    this.longitude,
    this.surveyAccessPointImages,
  });

  factory AccessPoint.fromJson(Map<String, dynamic> json) => AccessPoint(
    id: json["id"],
    surveyId: json["survey_id"],
    userId: json["user_id"],
    name: json["name"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    surveyAccessPointImages: List<SurveyAccessPointImage>.from(json["survey_access_point_images"].map((x) => SurveyAccessPointImage.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "survey_id": surveyId,
    "user_id": userId,
    "name": name,
    "latitude": latitude,
    "longitude": longitude,
    "survey_access_point_images": List<dynamic>.from(surveyAccessPointImages.map((x) => x.toJson())),
  };
}

class SurveyAccessPointImage {
  int id;
  int surveyId;
  int userId;
  int surveyAccessPointId;
  String imageName;
  String image;

  SurveyAccessPointImage({
    this.id,
    this.surveyId,
    this.userId,
    this.surveyAccessPointId,
    this.imageName,
    this.image,
  });

  factory SurveyAccessPointImage.fromJson(Map<String, dynamic> json) => SurveyAccessPointImage(
    id: json["id"],
    surveyId: json["survey_id"],
    userId: json["user_id"],
    surveyAccessPointId: json["survey_access_point_id"],
    imageName: json["image_name"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "survey_id": surveyId,
    "user_id": userId,
    "survey_access_point_id": surveyAccessPointId,
    "image_name": imageName,
    "image": image,
  };
}

class Details {
  int id;
  int userId;
  int projectId;
  int feasibility;
  dynamic reason;
  int ontAvailable;
  int ontPowerStatus;
  int ontMakeModel;
  String ontMacId;
  int poeStatus;
  int alarmStatus;
  int powerRunning;
  int solarPanelAvailable;
  int ccuAvailable;
  int batteryAvailable;
  String cableReqLength;
  List<SurveyImage> surveyImages;

  Details({
    this.id,
    this.userId,
    this.projectId,
    this.feasibility,
    this.reason,
    this.ontAvailable,
    this.ontPowerStatus,
    this.ontMakeModel,
    this.ontMacId,
    this.poeStatus,
    this.alarmStatus,
    this.powerRunning,
    this.solarPanelAvailable,
    this.ccuAvailable,
    this.batteryAvailable,
    this.cableReqLength,
    this.surveyImages,
  });

  factory Details.fromJson(Map<String, dynamic> json) => Details(
    id: json["id"],
    userId: json["user_id"],
    projectId: json["project_id"],
    feasibility: json["feasibility"],
    reason: json["reason"],
    ontAvailable: json["ont_available"],
    ontPowerStatus: json["ont_power_status"],
    ontMakeModel: json["ont_make_model"],
    ontMacId: json["ont_mac_id"],
    poeStatus: json["poe_status"],
    alarmStatus: json["alarm_status"],
    powerRunning: json["power_running"],
    solarPanelAvailable: json["solar_panel_available"],
    ccuAvailable: json["ccu_available"],
    batteryAvailable: json["battery_available"],
    cableReqLength: json["cable_req_length"],
    surveyImages: List<SurveyImage>.from(json["survey_images"].map((x) => SurveyImage.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "project_id": projectId,
    "feasibility": feasibility,
    "reason": reason,
    "ont_available": ontAvailable,
    "ont_power_status": ontPowerStatus,
    "ont_make_model": ontMakeModel,
    "ont_mac_id": ontMacId,
    "poe_status": poeStatus,
    "alarm_status": alarmStatus,
    "power_running": powerRunning,
    "solar_panel_available": solarPanelAvailable,
    "ccu_available": ccuAvailable,
    "battery_available": batteryAvailable,
    "cable_req_length": cableReqLength,
    "survey_images": List<dynamic>.from(surveyImages.map((x) => x.toJson())),
  };
}

class SurveyImage {
  int id;
  int surveyId;
  String imageName;
  String image;

  SurveyImage({
    this.id,
    this.surveyId,
    this.imageName,
    this.image,
  });

  factory SurveyImage.fromJson(Map<String, dynamic> json) => SurveyImage(
    id: json["id"],
    surveyId: json["survey_id"],
    imageName: json["image_name"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "survey_id": surveyId,
    "image_name": imageName,
    "image": image,
  };
}
