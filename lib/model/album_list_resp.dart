// To parse this JSON data, do
//
//     final albumListResp = albumListRespFromJson(jsonString);

import 'dart:convert';

AlbumListResp albumListRespFromJson(String str) =>
    AlbumListResp.fromJson(json.decode(str));

String albumListRespToJson(AlbumListResp data) => json.encode(data.toJson());

class AlbumListResp {
  AlbumListResp({
     this.status,
     this.data,
     this.message,
  });

  int? status;
  List<AlbumData>? data;
  String? message;

  factory AlbumListResp.fromJson(Map<String, dynamic> json) => AlbumListResp(
        status: json["status"],
        data: json["data"] == null
            ? null
            : List<AlbumData>.from(json["data"].map((x) => AlbumData.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data == null
            ? null
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
      };
}

class AlbumData {
  AlbumData({
    required this.id,
    this.postAuthor,
    required this.postContent,
    required this.postTitle,
    this.postExcerpt,
    this.postName,
    this.guid,
    this.menuOrder,
    required this.postType,
    required this.featureImg,
    this.featureImgDesktop,
    required this.status,
    required this.imgGalleryPic,
    required this.createdAt,
    required this.updatedAt,
    required this.galleryImages,
  });

  int? id;
  String? postAuthor;
  String? postContent;
  String? postTitle;
  String? postExcerpt;
  String? postName;
  String? guid;
  String? menuOrder;
  PostType? postType;
  String? featureImg;
  String? featureImgDesktop;
  bool? status;
  ImgGalleryPic? imgGalleryPic;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<GalleryImage>? galleryImages;

  factory AlbumData.fromJson(Map<String, dynamic> json) => AlbumData(
        id: json["id"],
        postAuthor: json["post_author"],
        postContent: json["post_content"],
        postTitle: json["post_title"],
        postExcerpt: json["post_excerpt"],
        postName: json["post_name"],
        guid: json["guid"],
        menuOrder: json["menu_order"],
        postType: postTypeValues.map[json["post_type"]]!,
        featureImg: json["feature_img"],
        featureImgDesktop: json["feature_img_desktop"],
        status: json["status"],
        imgGalleryPic: imgGalleryPicValues.map[json["img_gallery_pic"]]!,
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        galleryImages: List<GalleryImage>.from(
            json["galleryimages"].map((x) => GalleryImage.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "post_author": postAuthor,
        "post_content": postContent,
        "post_title": postTitle,
        "post_excerpt": postExcerpt,
        "post_name": postName,
        "guid": guid,
        "menu_order": menuOrder,
        "post_type": postTypeValues.reverse[postType],
        "feature_img": featureImg,
        "feature_img_desktop": featureImgDesktop,
        "status": status,
        "img_gallery_pic": imgGalleryPicValues.reverse[imgGalleryPic],
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "galleryimages":
            List<dynamic>.from(galleryImages!.map((x) => x.toJson())),
      };
}

class GalleryImage {
  GalleryImage({
     this.imageName,
     this.galleryId,
     this.id,
  });

  String? imageName;
  int? galleryId;
  int? id;

  factory GalleryImage.fromJson(Map<String, dynamic> json) => GalleryImage(
        imageName: json["image_name"],
        galleryId: json["gallery_id"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "image_name": imageName,
        "gallery_id": galleryId,
        "id": id,
      };
}

enum ImgGalleryPic { OBJECT_OBJECT, IMG_GALLERY_PIC_OBJECT_OBJECT }

final imgGalleryPicValues = EnumValues({
  "\"[object Object]\"": ImgGalleryPic.IMG_GALLERY_PIC_OBJECT_OBJECT,
  "[object Object]": ImgGalleryPic.OBJECT_OBJECT
});

enum PostType { FREE_CONTENT }

final postTypeValues = EnumValues({"free_content": PostType.FREE_CONTENT});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
