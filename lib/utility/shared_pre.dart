import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPre {
  static const allAlbumResp = "all_album_resp";
  static const albumImageList = "album_image_list";

  static Future<bool> setString(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  static Future<bool> setBool(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, value);
  }

  static Future<bool> setInt(String key, int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(key, value);
  }

  ///Save list of strings
  static Future<bool> setStringList(String key, List<String> value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(key, value);
  }

  static Future<String> getStringValue(String key,
      {String defaultValue = ""}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? defaultValue;
  }

  static getBoolValue(String key, {bool defaultValue = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  static getIntValue(String key, {int defaultValue = -1}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? defaultValue;
  }

  static getStringList(String key,
      {List<String> defaultValue = const []}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? defaultValue;
  }

  static Future<bool> clearAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

  /// call this method like this
  ///AlbumListResp data=AlbumListResp.fromJson(albumListResp.data.tojson())
  /// sp.setObj("",data);
  static setObj(String key, var json) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = jsonEncode(json);
    return prefs.setString(key, user);
  }

  /// call this method like this
  ///var data= sp.getObj("key);
  ///AlbumListResp albumListResp= AlbumListResp.fromjson(data);
  static Future<Map<String, dynamic>> getObj(String key) async {
    Map<String, dynamic> json = {};
    if (key.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String str = prefs.getString(key) ?? "";
      if (str.isNotEmpty) {
        json = jsonDecode(str);
      }
      json;
    }
    return json; // get data by calling from json method in model class
  }
}

extension Share on String {
  Future<String> getStringValue({String defaultValue = ''}) {
    return SharedPre.getStringValue(this, defaultValue: defaultValue);
  }
}
