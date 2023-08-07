import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ApiClient {
  static final ApiClient _apiClient = ApiClient._internal();

  factory ApiClient() {
    return _apiClient;
  }

  ApiClient._internal();

  //get method
  Future<String> getMethod(
      {required String url,
      Map<String, String>? header,
      Map<String, String>? requestPrams,}) async {
    try {
      log(url);
      if (header != null) {
        log(header.toString());
      }
      /*// Uri.parse(url).replace(queryParameters: requestPrams),*/
      final response = await http.get(
        Uri.parse(url),
        headers: header,
      );
      log(response.body);
      return response.body;
    } catch (e) {
      log("______ getMethode error ${e.toString()}");
      return '';
    }
  }

  //post method
  Future<String> postMethod(
      {required String url,
      Map<String, dynamic>? body,
      Map<String, String>? header}) async {
    try {
      log(url);
      if (header != null) {
        log(header.toString());
      }
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(body),
        headers: header,
      );
      log(response.body);
      return response.body;
    } catch (e) {
      log("______ post Method error ${e.toString()}");
      return '';
    }
  }
}
