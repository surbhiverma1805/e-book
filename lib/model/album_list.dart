// To parse this JSON data, do
//
//     final albumList = albumListFromJson(jsonString);

import 'dart:convert';

import 'package:ebook/model/album_detail_resp.dart';

AlbumList albumListFromJson(String str) => AlbumList.fromJson(json.decode(str));

String albumListToJson(AlbumList data) => json.encode(data.toJson());
class AlbumList {
  final List<AlbumListElement>? albumList;

  AlbumList({
    this.albumList,
  });

  factory AlbumList.fromJson(Map<String, dynamic> json) => AlbumList(
    albumList: json["album_list"] == null ? [] : List<AlbumListElement>.from(json["album_list"]!.map((x) => AlbumListElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "album_list": albumList == null ? [] : List<dynamic>.from(albumList!.map((x) => x.toJson())),
  };
}

class AlbumListElement {
  final String? frontImage;
  final String? backImage;
  final String? studioImage;
  final String? audioPath;
  final String? folderPath;
  final Detail? detail;

  AlbumListElement({
    this.frontImage,
    this.backImage,
    this.studioImage,
    this.audioPath,
    this.folderPath,
    this.detail,
  });

  factory AlbumListElement.fromJson(Map<String, dynamic> json) => AlbumListElement(
    frontImage: json["front_image"],
    backImage: json["back_image"],
    studioImage: json["studio_image"],
    audioPath: json["audio_path"],
    folderPath: json["folder_path"],
    detail: json["Detail"] == null ? null : Detail.fromJson(json["Detail"]),
  );

  Map<String, dynamic> toJson() => {
    "front_image": frontImage,
    "back_image": backImage,
    "studio_image": studioImage,
    "audio_path": audioPath,
    "folder_path": folderPath,
    "Detail": detail?.toJson(),
  };
}

/*class Detail {
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
}*/
