// To parse this JSON data, do
//
//     final albumDetailResp = albumDetailRespFromJson(jsonString);

import 'dart:convert';

AlbumDetailResp albumDetailRespFromJson(String str) => AlbumDetailResp.fromJson(json.decode(str));

String albumDetailRespToJson(AlbumDetailResp data) => json.encode(data.toJson());

class AlbumDetailResp {
  final String? message;
  final String? success;
  final int? statusCode;
  final Detail? detail;

  AlbumDetailResp({
    this.message,
    this.success,
    this.statusCode,
    this.detail,
  });

  factory AlbumDetailResp.fromJson(Map<String, dynamic> json) => AlbumDetailResp(
    message: json["message"],
    success: json["success"],
    statusCode: json["statusCode"],
    detail: json["Detail"] == null ? null : Detail.fromJson(json["Detail"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "success": success,
    "statusCode": statusCode,
    "Detail": detail?.toJson(),
  };
}

class Detail {
  final String? studioId;
  final String? code;
  final String? name;
  final String? frontImage;
  final String? backImage;
  final List<String>? albumImage;
  final String? studioName;
  final String? studioImage;
  final String? studioContactNo;
  final String? studioAddress;
  final String? albumPdf;
  final String? albumAudio;

  Detail({
    this.studioId,
    this.code,
    this.name,
    this.frontImage,
    this.backImage,
    this.albumImage,
    this.studioName,
    this.studioImage,
    this.studioContactNo,
    this.studioAddress,
    this.albumPdf,
    this.albumAudio,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
    studioId: json["studio_id"],
    code: json["code"],
    name: json["name"],
    frontImage: json["front_image"],
    backImage: json["back_image"],
    albumImage: json["album_image"] == null ? [] : List<String>.from(json["album_image"]!.map((x) => x)),
    studioName: json["studio_name"],
    studioImage: json["studio_image"],
    studioContactNo: json["studio_contact_no"],
    studioAddress: json["studio_address"],
    albumPdf: json["album_pdf"],
    albumAudio: json["album_audio"],
  );

  Map<String, dynamic> toJson() => {
    "studio_id": studioId,
    "code": code,
    "name": name,
    "front_image": frontImage,
    "back_image": backImage,
    "album_image": albumImage == null ? [] : List<dynamic>.from(albumImage!.map((x) => x)),
    "studio_name": studioName,
    "studio_image": studioImage,
    "studio_contact_no": studioContactNo,
    "studio_address": studioAddress,
    "album_pdf": albumPdf,
    "album_audio": albumAudio,
  };
}
