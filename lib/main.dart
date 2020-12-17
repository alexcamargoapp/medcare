import 'package:MedCare/Notifications/NotificationPlugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  notificationPlugin.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final appTitle = 'MedCare';
  static final navigatorKey = new GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [const Locale('pt', 'BR')],
      title: appTitle,
      navigatorKey: navigatorKey,
      home: Home(),
    );
  }
}
