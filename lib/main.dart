import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport_app/common/color_extension.dart';
import 'package:transport_app/common/dbhelpers.dart';
import 'package:transport_app/common/my_http_override.dart';
import 'package:transport_app/common/socket_manager.dart';
import 'package:transport_app/cubit/login/login_cubit.dart';
import 'package:transport_app/view/login/splash_view.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'common/appLocalizations .dart';
import 'common/globs.dart';
import 'common/service_call.dart';
import 'cubit/geolocation/geolocation_bloc.dart';
import 'cubit/map_requests/map_requests_cubit.dart';
import 'firebase/local_notification_service.dart';

SharedPreferences? prefs;

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

void main() async{
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  DBHelper.shared().db;

  prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  LocalNotificationService.initialize();

  if(Globs.udValueBool(Globs.userLogin)){
    ServiceCall.userObj = Globs.udValue(Globs.userPayload) as Map? ?? {};
    ServiceCall.userType = ServiceCall.userObj["user_type"] as int? ?? 1;
  }

  SocketManager.shared.initSocket();

  requestStoragePermission();

  final String? locale = await getSavedLocale();
  runApp(MyApp(locale: locale ?? 'en'));

  configLoading();
  ServiceCall.getStaticDateApi();
}

void requestStoragePermission() async{

  final permissionStatus =await Permission.photos.status;

  if(permissionStatus.isDenied){
    await Permission.photos.request();

    if(permissionStatus.isDenied){
      //await openAppSettings();
    }
  }else if(permissionStatus.isPermanentlyDenied){
    await Permission.photos.request();

    if(permissionStatus.isDenied){
      //await openAppSettings();
    }
  }

}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 5.0
    ..progressColor = TColor.primaryText
    ..backgroundColor = TColor.primary
    ..indicatorColor = Colors.white
    ..textColor = TColor.primaryText
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatefulWidget {

  final String locale;

  const MyApp({super.key, required this.locale});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Locale _locale = Locale('en');

  @override
  void initState() {
    super.initState();
    _locale = Locale(widget.locale); // Set the locale to saved or default language
  }

  void _changeLanguage(String languageCode) async {
    setState(() {
      _locale = Locale(languageCode);
    });
    await saveLocale(languageCode); // Save selected language
  }

  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context)=>LoginCubit()),
          BlocProvider(create: (context)=>MapRequestsCubit()),
          BlocProvider(create: (context)=>GeolocationBloc()),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          locale: _locale,
          supportedLocales: [
            Locale('en', ''),
            Locale('es', ''),
          ],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppLocalizationsDelegate(),
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            // Check if the current locale is supported
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: "NunitoSans",
            scaffoldBackgroundColor: TColor.bg,
            appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.transparent
            ),
            colorScheme: ColorScheme.fromSeed(seedColor: TColor.primary),
            useMaterial3: false,
          ),
          home: SplashView(changeLanguage: _changeLanguage),
          builder: EasyLoading.init(),
          navigatorObservers: [routeObserver],
        )
    );
  }
}

Future<String?> getSavedLocale() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('locale');
}

Future<void> saveLocale(String locale) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('locale', locale);
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    var localizations = AppLocalizations(locale.languageCode);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
