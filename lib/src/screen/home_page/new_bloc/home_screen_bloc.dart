import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ebook/app_route/app_router.dart';
import 'package:ebook/model/album_detail_resp.dart';
import 'package:ebook/model/album_list.dart';
import 'package:ebook/model/album_list_resp.dart';
import 'package:ebook/model/all_album.dart';
import 'package:ebook/repository/api_service/api.dart';
import 'package:ebook/utility/constants.dart';
import 'package:ebook/utility/shared_pre.dart';
import 'package:ebook/utility/utility.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

part 'home_screen_event.dart';

part 'home_screen_state.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  HomeScreenBloc(initialState) : super(initialState) {
    on(eventHandler);
  }

  FutureOr<void> eventHandler(
      HomeScreenEvent event, Emitter<HomeScreenState> emit) async {
    var dir = await Utility.getSavedDir();

    void init() async {
      emit(HomeScreenLoadingState());
      //emit(HomeScreenLoadedState());
    }

    if (event is HomeScreenInitialEvent) {
      emit(HomeScreenLoadingState());
      var dataResp =
          AlbumList.fromJson(await SharedPre.getObj(SharedPre.albumImageList));
      final finalAlbList = dataResp.albumList;

      List<AlbumListElement> list = [];
      if (finalAlbList != null) {
        for (var alb in finalAlbList) {
          print("init event : ${alb.folderPath}");
          if (await Utility.dirDownloadFileExists(dirName: alb.folderPath)) {
            print("init 2 : ${alb.frontImage} ?? ${alb.detail?.frontImage}");
            list.add(alb);
          }
        }
      }
      //print("data ${dataResp.albumList?.first.detail?.albumImage}");
      emit(HomeScreenLoadedState(albumList: AlbumList(albumList: list)));
/*      List<AllAlbum> allAlbumList = [];
      File? imgFile;
      String? albumImageName, albumName;
      int? albumListLen;
      emit(HomeScreenLoadingState());
      if (event.isInternetAvail == true &&
          await Utility.checkInternetConnectivity() == true) {
        var res = await Api.instance.getAlbumList();
        if (res.status == 200) {
          albumListLen = res.data?.length;
          if (!(await Utility.dirDownloadFileExists(
              dirName: "$dir/allAlbums"))) {
            await Directory("$dir/allAlbums").create();
          }
          final File file = File("$dir/allAlbums/album.json");
          await file.writeAsString(jsonEncode(res));
          await SharedPre.setString(
              SharedPre.allAlbumResp, await file.readAsString());
        } else {
          emit(HomeScreenErrorState(res.message ?? "Something went wrong"));
        }
      }

      /// this code will always run except if dir not exist or for first time
      if (await Utility.dirDownloadFileExists(
          dirName: "$dir/${Constants.allAlbums}")) {
        String data = await SharedPre.allAlbumResp.getStringValue();
        if (data.isNotEmpty) {
          final albumResp = albumListRespFromJson(data);
          for (var i = 0; i < (albumResp.data?.length ?? 0); i++) {
            List? file;
            if (albumListLen !=
                Directory("$dir/${Constants.allAlbums}").listSync().length -
                    1) {
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
                allAlbumList.add(
                    AllAlbum(imageName: albumImageName, albumName: albumName));
              } else {
                ///this is the repetitive code
                file = Directory("$dir/${Constants.allAlbums}").listSync();
                if (file.length - 1 == albumResp.data?.length) {
                  albumImageName = (await Utility.localFile(
                          "${Constants.allAlbums}/${albumResp.data?[i].featureImg}.jpeg"))
                      .path;
                  albumName = albumResp.data?[i].postTitle;
                  allAlbumList.add(AllAlbum(
                      imageName: albumImageName, albumName: albumName));
                }
              }
            } else {
              ///this is the repetitive code
              file = Directory("$dir/${Constants.allAlbums}").listSync();
              if (file.length - 1 == albumResp.data?.length) {
                albumImageName = (await Utility.localFile(
                        "${Constants.allAlbums}/${albumResp.data?[i].featureImg}.jpeg"))
                    .path;
                albumName = albumResp.data?[i].postTitle;
                allAlbumList.add(
                    AllAlbum(imageName: albumImageName, albumName: albumName));
              }
            }
          }
          emit(HomeScreenLoadedState(
            allAlbumList: allAlbumList,
            albumData: albumResp.data,
          ));
        } else {
          emit(HomeScreenErrorState("You don't have any album"));
        }
      } else {
        emit(HomeScreenErrorState(
            "Please connect to internet to load the album from server."));
      }*/
    }

    if (event is DetailViewEvent) {
      var dirPath = "$dir/${event.albumName}";
      List<String>? imageList = [];
      if (await Utility.dirDownloadFileExists(dirName: dirPath) &&
          Directory(dirPath).listSync().length ==
              event.galleryImageList?.length) {
        imageList = await Utility.getDownloaded(
            imgList: event.galleryImageList, postTitle: event.albumName);

        /// navigate to detail page
        AppRoutes.router.pushNamed(AppRoutes.pdfView, extra: {
          'album_name': event.albumName,
          'gallery_image_list': event.galleryImageList,
          'list_len': Directory(dirPath).listSync().length % 2 != 0
              ? Directory(dirPath).listSync().length - 1
              : Directory(dirPath).listSync().length,
          'front_image': event.frontImage,
        });
      } else {
        if (await Utility.checkInternetConnectivity()) {
          if (!(await Utility.dirDownloadFileExists(dirName: dirPath))) {
            await Directory(dirPath).create();
            print("directory");
          }

          /// to download if images are not downloaded
          event.galleryImageList?.forEach(
            (image) async {
              await Utility.saveDownloadedImageToLocal(
                fileName: image.imageName,
                albumName: event.albumName,
              );
            },
          );

          imageList = await Utility.getDownloaded(
              imgList: event.galleryImageList, postTitle: event.albumName);

          /// navigate to detail page
          AppRoutes.router.pushNamed(AppRoutes.pdfView, extra: {
            'album_name': event.albumName,
            'gallery_image_list': event.galleryImageList,
            'list_len': (imageList?.length ?? 0) % 2 != 0
                ? (imageList?.length ?? 0) - 1
                : imageList?.length,
            'front_image': event.frontImage,
          });
        } else {
          Utility.showSnackBar("No Internet");
        }
      }
      /* if (await Utility.dirDownloadFileExists(dirName: dirPath) &&
          Directory(dirPath).listSync().length ==
              event.galleryImageList?.length) {
        AppRoutes.router.pushNamed(AppRoutes.pdfView, extra: {
          'album_name': event.albumName,
          'gallery_image_list': event.galleryImageList,
          'list_len': Directory(dirPath).listSync().length % 2 != 0
              ? Directory(dirPath).listSync().length - 1
              : Directory(dirPath).listSync().length,
          'front_image': event.frontImage,
        });
      } else {
        if (await Utility.checkInternetConnectivity()) {
          AppRoutes.router.pushNamed(AppRoutes.pdfView, extra: {
            'album_name': event.albumName,
            'gallery_image_list': event.galleryImageList,
            'list_len': (event.galleryImageList?.length ?? 0) % 2 != 0
                ? (event.galleryImageList?.length ?? 0) - 1
                : event.galleryImageList?.length,
            'front_image': event.frontImage,
          });
        } else {
          emit(HomeScreenErrorState(
              "Please connect to the internet to load the album from server!"));
        }
      }*/
    }

    if (event is AddAlbumEvent) {
      if (await Utility.checkInternetConnectivity()) {
        emit(HomeScreenLoadingState());
        bool isAvail;
        List<String> albumImageList = [];
        // albumImageList = await SharedPre.getStringList(SharedPre.albumImageList);
        var res = await Api.instance.getAlbumDetail(albumCode: event.albumCode);
        debugPrint("what the res is : ${res.detail?.name}");
        if (res.statusCode == 200) {
          final detail = res.detail;
          debugPrint("what the detail is : ${detail?.name}");

          debugPrint("dir name : $dir");
          /// check if allAlbums dir exist or not and if not then create
          if (!(await Utility.dirDownloadFileExists(
              dirName: "$dir/${Constants.allAlbums}"))) {
            await Directory("$dir/${Constants.allAlbums}").create();
          }

          /// check if allAlbums sub dir exist or not and if not then create
          if (!(await Utility.dirDownloadFileExists(
              dirName: "$dir/${Constants.allAlbums}/${detail?.name}"))) {
            isAvail = true;
            await Directory("$dir/${Constants.allAlbums}/${detail?.name}")
                .create();
          }

          /// download front image
          if (!(await Utility.dirDownloadFileExists(
              dirName:
                  "$dir/${Constants.allAlbums}/${detail?.name}/${detail?.frontImage?.split('/').last}"))) {}
          final frontImage = await downloadImage(
            image: detail?.frontImage,
            dir: dir,
            albumName: detail?.name,
          );

          /// download back image
          final backImage = await downloadImage(
            image: detail?.backImage,
            dir: dir,
            albumName: detail?.name,
          );

          /// download studio image
          final studioImage = await downloadImage(
            image: detail?.studioImage,
            dir: dir,
            albumName: detail?.name,
          );

          File? audioFile;
          /// Download and save audio in local dir from network
          if (detail?.albumAudio?.isNotEmpty ?? false) {
            audioFile = await downloadImage(
              image: detail?.albumAudio,
              dir: dir,
              albumName: detail?.name,
            );
          }

          final File file = File(
              "$dir/allAlbums/${res.detail?.name}/${res.detail?.name}.json");
          await file.writeAsString(jsonEncode(res.detail));

          List<AlbumListElement> list = [];

          var dataResp = AlbumList.fromJson(
              await SharedPre.getObj(SharedPre.albumImageList));

          print("pref data : $dataResp");
          if (dataResp.albumList != null) {
            list = [...?dataResp.albumList];
          }

          list.add(AlbumListElement(
            frontImage: frontImage.path,
            backImage: backImage.path,
            studioImage: studioImage.path,
            audioPath: audioFile?.path,
            folderPath: "$dir/allAlbums/${res.detail?.name}",
            detail: res.detail,
          ));
          AlbumList l = AlbumList(albumList: list);
          final File newFile = File(
              "$dir/allAlbums/${res.detail?.name}/${res.detail?.name}.json");
          await newFile.writeAsString(jsonEncode(l));
          //albumImageList.add(frontImage.path);

          /*
          /// download studio image
          final studioImage = await downloadImage(
            image: detail?.studioImage,
            dir: dir,
            albumName: detail?.name,
          );*/

          /* double downloadProgress = 0;
          int contentLength = 0;
          detail?.albumImage?.forEach((element) async{
            final request = Request('GET', Uri.parse(element));
            final response = await Client().send(request);
            contentLength += response.contentLength!;
            // final img = await http.get(
            //   Uri.parse(image!),
            // );
            /// check if allAlbums sub dir exist or not and if not then create
            if (!(await Utility.dirDownloadFileExists(
                dirName: "$dir/${Constants.allAlbums}/${detail.name}/albumImages"))) {
              await Directory("$dir/${Constants.allAlbums}/${detail.name}/albumImages")
                  .create();
            }
            var file = File(path.join(
                "$dir/${Constants.allAlbums}/${detail.name}/albumImages", element.split("/").last));
            await file.writeAsBytes(request.bodyBytes);
            //await file.writeAsBytes(img.bodyBytes);
            final bytes = <int>[];
            response.stream.listen((streamedBytes) {
              bytes.addAll(streamedBytes);
              downloadProgress += bytes.length / contentLength;
              print("%% $downloadProgress");
              emit(ShowDownloading(downloadProgress));
              //Utility.showDownloadProgressIndicator(downloadProgress);
            },
              onDone: () async {
                downloadProgress = 1;
              },
              cancelOnError: true,
            );
          });*/
          //if (!(await Utility.dirDownloadFileExists(fileName: "$dir/allAlbums/${res.detail?.name}.json"))) {
          SharedPre.setObj(SharedPre.albumImageList, l);

          // }
          // final File file = File("$dir/allAlbums");
          // await file.writeAsString(jsonEncode(jsonList));
          // await SharedPre.setString(
          //     SharedPre.allAlbumResp, await file.readAsString());

          print("len : ${detail?.albumImage?.length}");
          add(HomeScreenInitialEvent(
            albumDetail: detail,
          ));
        } else {
          emit(HomeScreenErrorState("No Record Found!!!"));
        }
        // emit(HomeScreenLoadedState(
        //     albumDetail: res.detail, list: albumImageList));
      } else {
        emit(HomeScreenErrorState(
            "No Internet\nPlease connect to internet to download the album"));
      }
    }
  }

  /// download image
  Future<File> downloadImage({
    String? image,
    String? dir,
    String? albumName,
  }) async {
    double downloadProgress = 0;

    /*   final request = Request('GET', Uri.parse(image!));
    final response = await Client().send(request);
    final contentLength = response.contentLength;*/
    final img = await http.get(
      Uri.parse(image!),
    );
    var file = File(path.join(
        "$dir/${Constants.allAlbums}/$albumName", image.split("/").last));
    //await file.writeAsBytes(request.bodyBytes);
    await file.writeAsBytes(img.bodyBytes);
    final bytes = <int>[];
    // response.stream.listen((streamedBytes) {
    //   bytes.addAll(streamedBytes);
    //   downloadProgress = bytes.length / contentLength!;
    // },
    // onDone: () async {
    //   downloadProgress = 1;
    // },
    //   cancelOnError: true,
    // );
    return file;
  }
}
