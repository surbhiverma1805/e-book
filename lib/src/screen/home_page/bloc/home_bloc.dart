import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ebook/app_route/app_router.dart';
import 'package:ebook/model/album_list_resp.dart';
import 'package:ebook/model/all_album.dart';
import 'package:ebook/model/photobook.dart';
import 'package:ebook/repository/api_service/api.dart';
import 'package:ebook/repository/api_service/api_methods.dart';
import 'package:ebook/utility/constants.dart';
import 'package:ebook/utility/shared_pre.dart';
import 'package:ebook/utility/utility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  List<PhotoBook> ebookList = [
    PhotoBook(
      id: 0,
      title: 'Wedding Album 1',
      url:
          'https://upsc.gov.in/sites/default/files/Spl-Advt-No-51-2023-engl-250223.pdf',
      // image:
      //     'https://5.imimg.com/data5/SELLER/Default/2020/9/JQ/FO/RS/748292/photo-pad-500x500.jpg',
      image:
          'https://www.happywedding.app/blog/wp-content/uploads/2019/11/Make-your-wedding-album-wonderful-with-these-innovative-ideas.jpg',
    ),
    PhotoBook(
        id: 1,
        title: 'Wedding Album 2',
        url:
            'https://cdnbbsr.s3waas.gov.in/s37bc1ec1d9c3426357e69acd5bf320061/uploads/2023/03/2023030640.pdf',
        image:
            'https://alexandra.bridestory.com/image/upload/assets/1b730f52-8f8e-415e-b229-9af310eeb1ee-SJhIdFsb4.jpg'
        // image: 'https://fotoframe.in/wp-content/uploads/2020/09/3-570x335.png',
        ),
    PhotoBook(
        id: 2,
        title: 'Wedding Album 3',
        url: 'https://www.africau.edu/images/default/sample.pdf',
        image:
            'https://www.zookbinders.com/wp-content/uploads/2020/05/Wedding-Album-Design-2.jpg'

        // image:
        //     'https://www.weddingkathmandu.com/public/images/upload/product/pro-photo-books-albun-kathmandu.jpg',
        ),
    PhotoBook(
        id: 3,
        title: 'RAJK1995',
        url:
            'https://firebasestorage.googleapis.com/v0/b/sales-management-7f835.appspot.com/o/chats%2Fdocs%2FRAJK1995%20EAadhaar_xxxxxxxx0469_04122020202107_021396.pdf?alt=media&token=503e14e4-bb33-4807-95da-9eae247eb279',
        image: 'https://www.milkbooks.com/media/10510/josephpaul-cover.jpg'
        // image:
        //     'https://www.weddingkathmandu.com/public/images/upload/product/pro-photo-books-albun-kathmandu.jpg',
        ),
  ];

  HomeBloc() : super(HomeInitialState()) {
    on<HomeInitialEvent>(_onHomeInitialEvent);
    on<GoToPdfViewEvent>(_onPdfViewEvent);
  }

  HomeLoadedState get _lastState => state as HomeLoadedState;

  FutureOr<void> _onHomeInitialEvent(
      HomeInitialEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadedState(isLoading: true));
    var dir = await Utility.getSavedDir();
    List<AllAlbum> allAlbumList = [];
    File? imgFile;
    String? albumImageName, albumName;
    if (event.isInternetAvail == true &&
        await Utility.checkInternetConnectivity() == true) {
      var res = await Api.instance.getSliderData();
      if (res.status == 200) {
        if (!(await Utility.dirDownloadFileExists(dirName: "$dir/allAlbums"))) {
          await Directory("${await Utility.getSavedDir()}/allAlbums").create();
        }
        final File file = File("$dir/allAlbums/album.json");
        await file.writeAsString(jsonEncode(res));
        await SharedPre.setString(
            SharedPre.allAlbumResp, await file.readAsString());
      } else {
        emit(_lastState.copyWith(isLoading: false));
        Utility.showSnackBar("Something went wrong");
      }
    }
    String data = await SharedPre.allAlbumResp.getStringValue();

    if (data.isNotEmpty) {
      final albumResp = albumListRespFromJson(data);
      /*  albumResp.data?.forEach((data) async {
      final downloadedImage = await http.get(
        Uri.parse("${ApiMethods.imageBaseUrl}/${data.featureImg}"),
      );
      File imgFile = File(path.join("$dir/allAlbum/$downloadedImage.jpeg"));
      imgFile.writeAsBytes(downloadedImage.bodyBytes);
      final albumName = data.postTitle;
      allAlbumList!.add(AllAlbum(imageName: imgFile.path, albumName: albumName));
    });*/

      for (var i = 0; i < (albumResp.data?.length ?? 0); i++) {
        List? file;
        if (event.isInternetAvail == true &&
            await Utility.checkInternetConnectivity() == true) {
          final downloadedImage = await http.get(
            Uri.parse(
                "${ApiMethods.imageBaseUrl}/${albumResp.data?[i].featureImg}"),
          );
          imgFile = File(path.join("$dir/${Constants.allAlbums}",
              "${albumResp.data?[i].featureImg}.jpeg"));
          await imgFile.writeAsBytes(downloadedImage.bodyBytes);
          albumImageName = imgFile.path;
          albumName = albumResp.data?[i].postTitle;
          allAlbumList
              .add(AllAlbum(imageName: albumImageName, albumName: albumName));
        } else {
          file = Directory("$dir/${Constants.allAlbums}").listSync();
          if (file.length - 1 == albumResp.data?.length) {
            albumImageName = (await Utility.localFile(
                    "${Constants.allAlbums}/${albumResp.data?[i].featureImg}.jpeg"))
                .path;
            albumName = albumResp.data?[i].postTitle;
            allAlbumList
                .add(AllAlbum(imageName: albumImageName, albumName: albumName));
          }
        }
      }
      emit(_lastState.copyWith(
        isLoading: false,
        allAlbumList: allAlbumList,
        albumData: albumResp.data,
      ));
    } else {
      emit(_lastState.copyWith(
        isLoading: false,
      ));
    }
  }

  FutureOr<void> _onPdfViewEvent(
      GoToPdfViewEvent event, Emitter<HomeState> emit) async {
    var dirPath = "${await Utility.getSavedDir()}/${event.albumName}";

    if (await Utility.dirDownloadFileExists(dirName: dirPath) &&
        Directory(dirPath).listSync().length ==
            event.galleryImageList?.length) {
      print("if1 ${Directory(dirPath).listSync().length}");
      AppRoutes.router.pushNamed(AppRoutes.pdfView, extra: {
        'album_name': event.albumName,
        'gallery_image_list': event.galleryImageList,
        'list_len': Directory(dirPath).listSync().length % 2 != 0
            ? Directory(dirPath).listSync().length - 1
            : Directory(dirPath).listSync().length,
        'front_image': event.frontImage,
      });
    } else {
      print("else");
      if (await Utility.checkInternetConnectivity()) {
        print("if2");
        AppRoutes.router.pushNamed(AppRoutes.pdfView, extra: {
          'album_name': event.albumName,
          'gallery_image_list': event.galleryImageList,
          'list_len': (event.galleryImageList?.length ?? 0) % 2 != 0
              ? (event.galleryImageList?.length ?? 0) - 1
              : event.galleryImageList?.length,
          'front_image': event.frontImage,
        });
      } else {
        print("else2");
        emit(_lastState);
        Utility.showSnackBar(
            "Please connect to the internet to sync the album!");
      }
    }
  }
}
