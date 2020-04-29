// To parse this JSON data, do
//
//     final getInstallationDetailsResponse = getInstallationDetailsResponseFromJson(jsonString);

import 'dart:convert';

GetInstallationDetailsResponse getInstallationDetailsResponseFromJson(String str) => GetInstallationDetailsResponse.fromJson(json.decode(str));

String getInstallationDetailsResponseToJson(GetInstallationDetailsResponse data) => json.encode(data.toJson());

class GetInstallationDetailsResponse {
  bool success;
  Message message;

  GetInstallationDetailsResponse({
    this.success,
    this.message,
  });

  factory GetInstallationDetailsResponse.fromJson(Map<String, dynamic> json) => GetInstallationDetailsResponse(
    success: json["success"],
    message: Message.fromJson(json["message"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message.toJson(),
  };
}

class Message {
  Map<String, int> details;
  List<dynamic> accessPoints;

  Message({
    this.details,
    this.accessPoints,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    details: Map.from(json["details"]).map((k, v) => MapEntry<String, int>(k, v)),
    accessPoints: List<dynamic>.from(json["access_points"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "details": Map.from(details).map((k, v) => MapEntry<String, dynamic>(k, v)),
    "access_points": List<dynamic>.from(accessPoints.map((x) => x)),
  };
}
