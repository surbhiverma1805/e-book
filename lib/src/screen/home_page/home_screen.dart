import 'package:ebook/bloc/app_bloc/app_bloc.dart';
import 'package:ebook/model/album_list_resp.dart';
import 'package:ebook/model/all_album.dart';
import 'package:ebook/src/screen/details_view.dart';
import 'package:ebook/src/screen/home_page/home_view.dart';
import 'package:ebook/src/screen/home_page/new_bloc/home_screen_bloc.dart';
import 'package:ebook/src/utils/app_assets.dart';
import 'package:ebook/src/utils/extension/space.dart';
import 'package:ebook/src/utils/extension/text_style_decoration.dart';
import 'package:ebook/src/widgets/app_images.dart';
import 'package:ebook/src/widgets/custom_txtfield.dart';
import 'package:ebook/utility/constants.dart';
import 'package:ebook/utility/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppBloc appBloc = AppBloc(AppInitState());
  HomeScreenBloc homeScreenBloc = HomeScreenBloc(HomeScreenInitialState());

  List<AllAlbum>? allAlbumList = [];
  List<AlbumData>? albumData = [];

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      bloc: appBloc,
      listener: (context, state) {
        if (state is InternetLostState) {
          Utility.showSnackBar("No Internet");
        }
      },
      builder: (context, state) {
        if (state is InternetLostState) {
          return homeScreenView(false);
        } else {
          return homeScreenView(true);
        }
      },
    );
  }

  Widget homeScreenView(bool? isInternetAvail) {
    return Scaffold(
      //backgroundColor: Color(0xE636363A),
      backgroundColor: const Color(0xFF212122),

      /// for divider
      //backgroundColor: Color(0xFF262A2A),
      appBar: AppBar(
        elevation: 6,
        //backgroundColor: Color(0xFF212122),
        backgroundColor: Colors.black54,
        title: Container(
          margin: EdgeInsets.only(left: 5.w),
          child: Text(
            Constants.projectName,
            style: const TextStyle().bold.copyWith(
                  fontSize: 22.sp,
                  color: Colors.white,
                ),
          ),
        ),
      ),
      floatingActionButton: floatingActionBtn(),
      body: BlocConsumer(
        bloc: homeScreenBloc..add(HomeScreenInitialEvent(isInternetAvail)),
        listener: (context, state) {
          if (state is HomeScreenLoadingState) {
            Utility.showCustomDialog(context, text: "Please Wait...");
          }
          if (state is HomeScreenLoadedState) {
            Navigator.pop(Utility.dialogContext ?? context);
          }
        },
        builder: (context, state) {
          if (state is HomeScreenErrorState) {
            return Center(
              child: Text(state.errorMessage),
            );
          }
          if (state is HomeScreenLoadedState) {
            allAlbumList = state.allAlbumList;
            albumData = state.albumData;
            if (allAlbumList?.isEmpty ?? true) {
              return Center(
                child: Text(
                  "You don't have any album",
                  style: const TextStyle().medium.copyWith(
                        color: Colors.white,
                        fontSize: 18.sp,
                      ),
                ),
              );
            }
            return SafeArea(
              child: Column(
                children: [
                  15.toSpace(),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 40.h,
                        crossAxisSpacing: 0,
                      ),
                      itemCount: allAlbumList!.length % 2 == 1
                          ? allAlbumList!.length + 1
                          : allAlbumList!.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            dividerWidget(context),
                            allAlbumList!.length % 2 == 1 &&
                                    allAlbumList!.length == index
                                ? const SizedBox.shrink()
                                : Positioned(
                                    bottom: 18.h,
                                    child: InkWell(
                                      onTap: () {
                                        homeScreenBloc.add(DetailViewEvent(
                                            galleryImageList:
                                                albumData?[index].galleryImages,
                                            frontImage:
                                                allAlbumList?[index].imageName,
                                            albumName: allAlbumList?[index]
                                                .albumName));
                                        /*BlocProvider.of<HomeBloc>(context).add(
                                    GoToPdfViewEvent(
                                      galleryImageList:
                                      state.albumData?[index].galleryImages,
                                      // pin: pinController.text.trim(),
                                      frontImage:
                                      state.allAlbumList?[index].imageName,
                                      albumName:
                                      state.allAlbumList?[index].albumName,
                                    ),
                                  );*/
                                      },
                                      child: itemWidget(
                                        image: state.allAlbumList?[index]
                                                .imageName ??
                                            "",
                                      ),
                                    ),
                                  )
                          ],
                        );
                      },
                    ),
                  ),
                  15.toSpace(),
                ],
              ),
            );
          }
          return const Text("");
        },
      ),
    );
  }

  Widget floatingActionBtn() {
    return InkWell(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const DetailsView())),
      child: Container(
        padding: EdgeInsets.all(6.h),
        margin: EdgeInsets.only(
          right: 10.h,
          bottom: 10.h,
        ),
        decoration: BoxDecoration(
          color: Colors.red.shade900,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 45.sp,
        ),
      ),
    );
  }

  Widget dividerWidget(BuildContext context) {
    const double fillPercent = 50; // fills 56.23% for container from bottom
    const double fillStop = (100 - fillPercent) / 100;
    final List<double> stops = [0.0, fillStop, fillStop, 1.0];
    return Container(
      height: 25.h,
      width: MediaQuery.of(context).size.width,
      // color: const Color(0xFF212122),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: const [
            Color(0xFF222626),
            Color(0xFF222626),
            Color(0xFF393B3B),
            Color(0xFF393B3B)
          ],
          stops: stops,
          end: Alignment.bottomCenter,
          begin: Alignment.topCenter,
        ),
      ),
    );
  }

  Widget itemWidget({required String image}) {
    return Container(
      width: 130.h,
      height: 150.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF212122),
        // borderRadius: BorderRadius.
        // circular(10.r),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(5.r),
          bottomRight: Radius.circular(4.r),
          topLeft: Radius.circular(2.r),
        ),
        /*   border: Border(
                right: BorderSide(color: Colors.red),

              )*/
      ),
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(right: 8.w), // ***
            decoration: BoxDecoration(
              color: const Color(0xFF212122),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(5.r),
                bottomRight: Radius.circular(4.r),
                topLeft: Radius.circular(2.r),
              ),
              // borderRadius: BorderRadius.circular(8.r),
              boxShadow: const [
                BoxShadow(
                    color: Colors.white,
                    blurRadius: 3,
                    spreadRadius: 3,
                    offset: Offset(3.5, 3.5))
              ],
            ),
            child: AppLocalFileImage(
              imageUrl: image,
              fit: BoxFit.cover,
              width: 150.h,
              height: 150.h,
              // radius: 20.r,
            ),
            /*  child: Image.asset(
              AppAssets.image1,
              width: 150.h,
              height: 150.h,
              fit: BoxFit.cover,
            ),*/
          ),
          Positioned(
            left: 8.w,
            child: Container(
              height: 150.h,
              width: 1.w,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.white38,
                      blurRadius: 1,
                      spreadRadius: 0,
                      offset: Offset(0, 1.5))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyWidget(BuildContext context) {
    return Column(
      children: [
        Text(
          "You don't have any album yet.",
          style: const TextStyle().semiBold.copyWith(
                color: Colors.white,
              ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: ElevatedButton(
            onPressed: () {
              addAlbum(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade900,
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 6.h,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                ),
                6.toSpace(vertically: false),
                Text(
                  "Add",
                  style: const TextStyle().semiBold.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  addAlbum(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Album:',
          style: const TextStyle().medium.copyWith(
                color: Colors.black,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                Expanded(child: CustomTextField()),
                Text('-'),
                Expanded(child: CustomTextField()),
              ],
            ),
            10.toSpace(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => HomeView()));
              },
              icon: Icon(
                Icons.download,
                color: Colors.white,
                size: 30.sp,
              ),
              label: Text(
                'GET',
                style: const TextStyle().medium.copyWith(
                      color: Colors.white,
                    ),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.h,
                    vertical: 8.h,
                  )),
            )
          ],
        ),
      ),
    );
  }

  ///demo code
  oldCode() {
    return Column(
      children: [
        50.toSpace(),
        SizedBox(
          height: 150.h,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              dividerWidget(context),
              Positioned(
                bottom: 18.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 150.h,
                      height: 150.h,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: const Color(0xFF212122),
                        // borderRadius: BorderRadius.
                        // circular(10.r),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(5.r),
                          bottomRight: Radius.circular(4.r),
                          topLeft: Radius.circular(2.r),
                        ),
                        /*   border: Border(
                  right: BorderSide(color: Colors.red),

                )*/
                      ),
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 8.w),
                            // ***
                            decoration: BoxDecoration(
                              color: const Color(0xFF212122),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(5.r),
                                bottomRight: Radius.circular(4.r),
                                topLeft: Radius.circular(2.r),
                              ),
                              // borderRadius: BorderRadius.circular(8.r),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.white,
                                    blurRadius: 4,
                                    spreadRadius: 4,
                                    offset: Offset(3.5, 3.5))
                              ],
                            ),
                            child: Image.asset(
                              AppAssets.image1,
                              width: 150.h,
                              height: 150.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            left: 8.w,
                            child: Container(
                              height: 150.h,
                              width: 1.w,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.white38,
                                      blurRadius: 1,
                                      spreadRadius: 0,
                                      offset: Offset(0, 1.5))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    20.toSpace(),
                    Stack(
                      children: [
                        Container(
                          height: 100.h,
                          width: 80.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(6.r),
                                bottomLeft: Radius.circular(6.r)),
                          ),
                        ),
                        Positioned(
                          right: 3,
                          child: Stack(
                            children: [
                              Container(
                                height: 100.h,
                                width: 80.h,
                                decoration: BoxDecoration(
                                    // color: Colors.lightGreen,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(6.r),
                                        bottomLeft: Radius.circular(6.r)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF000000).withAlpha(60),
                                        blurRadius: 6.0,
                                        spreadRadius: 0.0,
                                        offset: const Offset(
                                          0.0,
                                          3.0,
                                        ),
                                      ),
                                    ]),
                                child: Image.asset(AppAssets.image1,
                                    fit: BoxFit.cover),
                              ),
                              Positioned(
                                left: 8.w,
                                child: Container(
                                  height: 100.h,
                                  width: 1.h,
                                  color: Colors.white24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100.h,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              dividerWidget(context),
              Positioned(
                bottom: 18.h,
                child: Stack(
                  children: [
                    Container(
                      height: 100.h,
                      width: 80.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6.r),
                            bottomLeft: Radius.circular(6.r)),
                      ),
                    ),
                    Positioned(
                      right: 3,
                      child: Stack(
                        children: [
                          Container(
                            height: 100.h,
                            width: 80.h,
                            decoration: BoxDecoration(
                                // color: Colors.lightGreen,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6.r),
                                    bottomLeft: Radius.circular(6.r)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF000000).withAlpha(60),
                                    blurRadius: 6.0,
                                    spreadRadius: 0.0,
                                    offset: const Offset(
                                      0.0,
                                      3.0,
                                    ),
                                  ),
                                ]),
                            child: Image.asset(AppAssets.image1,
                                fit: BoxFit.cover),
                          ),
                          Positioned(
                            left: 8.w,
                            child: Container(
                              height: 100.h,
                              width: 1.h,
                              color: Colors.white24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        /* Container(
                height: 100.h,
                width: 80.h,
                decoration: BoxDecoration(
                  // color: Colors.lightGreen,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6.r),
                        bottomLeft: Radius.circular(6.r)
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: Offset(4.0, 0),
                      ),
                      BoxShadow(
                        color: Colors.white,
                        spreadRadius: 0,
                        blurRadius: 2,
                        offset: Offset(1.0, 0)
                      )
                     */ /* BoxShadow(
                       // color: Color(0xFF000000).withAlpha(60),
                        color: Color(0xFFFFFFFF).withAlpha(100),
                        blurRadius: 6.0,
                        spreadRadius: 2.0,
                        offset: Offset(
                          0.0,
                          0.0,
                        ),
                      ),*/ /*
                    ]
                ),
                child: Image.asset(AppAssets.image1,fit: BoxFit.cover),
              ),*/

/*
              Container(
                height: 80,width: 80,
                decoration:  BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: Colors.black,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      spreadRadius: 1,
                      blurRadius: 0,
                      offset: Offset(4,4), // changes position of shadow
                    ),

                  ],
                ),
                child:  Center(
                  child: Text("1-6 Months",style: TextStyle(color: Colors.white),),

                ),
              ),*/

        10.toSpace(),
        /* Container(
                width: 200,
                height: 200,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                   // borderRadius: BorderRadius.circular(10.r),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5.r),
                    bottomRight: Radius.circular(4.r),
                    topLeft: Radius.circular(2.r),
                  ),
               */ /*   border: Border(
                    right: BorderSide(color: Colors.red),

                  )*/ /*
                ),
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 8.r), // ***
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(5.r),
                          bottomRight: Radius.circular(4.r),
                          topLeft: Radius.circular(2.r),
                        ),
                        // borderRadius: BorderRadius.circular(8.r),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 4,
                            spreadRadius: 4,
                            offset: Offset(3.5, 3.5)
                          )
                        ],
                      ),
                      child: Image.asset(AppAssets.image1, width: 200,
                        height: 200, fit: BoxFit.cover,),
                    ),
                    Positioned(
                      left: 8.w,
                      child: Container(
                        height: 200.h,
                        width: 1.w,
                        decoration: BoxDecoration(
                          //color: Colors.white24,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.white38,
                                blurRadius: 1,
                                spreadRadius: 0,
                                offset: Offset(1.5, 1.5)
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),*/
        10.toSpace(),
        emptyWidget(context),
      ],
    );
  }
}
