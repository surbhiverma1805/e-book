import 'package:ebook/app_route/app_router.dart';
import 'package:ebook/bloc/app_bloc/app_bloc.dart';
import 'package:ebook/utility/constants.dart';
import 'package:ebook/utility/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  /*  SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);*/
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AppBloc()..add(AppInitEvent()),
        ),
      ],
      child: MaterialApp.router(
        routeInformationProvider: AppRoutes.router.routeInformationProvider,
        routeInformationParser: AppRoutes.router.routeInformationParser,
        routerDelegate: AppRoutes.router.routerDelegate,
        debugShowCheckedModeBanner: false,
        title: Constants.projectName,
        theme: ThemeData(
          primarySwatch: Colors.cyan,
        ),
        scaffoldMessengerKey: snackBarKey,
        //home: const BookView(),
        //home: HomeView(),
        //home: MyApps(),
      ),
    );
  }
}
