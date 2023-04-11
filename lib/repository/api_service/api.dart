import 'package:ebook/model/album_list_resp.dart';
import 'package:ebook/repository/api_service/api_client.dart';
import 'package:ebook/repository/api_service/api_methods.dart';

class Api {
  static final Api instance = Api._internal();
  final _apiClient = ApiClient();
  final _apiMethod = ApiMethods();

  Api._internal();

  Future<AlbumListResp> getSliderData() async {
    try {
      String resp = await _apiClient.postMethod(url: _apiMethod.albumImages);
      if (resp.isEmpty) {
        return AlbumListResp();
      } else {
        return albumListRespFromJson(resp);
      }
    } catch (e) {
      return AlbumListResp(message: e.toString());
    }
  }
}
