import 'package:astrologer/provider_setup.dart';
import 'package:astrologer/router.dart';
import 'package:astrologer/ui/shared/theme_stream.dart';
import 'package:astrologer/ui/view/home_view.dart';
import 'package:astrologer/ui/view/login_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:square_in_app_payments/in_app_payments.dart';

import 'core/utils/shared_pref_helper.dart';

Future<void> main() async {
  final ThemeStream theme = ThemeStream();
  final SharedPreferences sharedPref = await SharedPreferences.getInstance();
  final String token = sharedPref.getString(KEY_TOKEN);
  runApp(MyApp(theme, token));
}

class MyApp extends StatefulWidget {
  MyApp(this.theme, this.token);

  final ThemeStream theme;
  final String token;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> _initSquarePayment() async {
    await InAppPayments.setSquareApplicationId('sandbox-sq0idb-8xaFjsiY867G9HsOT-Ojtg');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: widget.theme.getStream,
        initialData: false,
        builder: (context, snapshot) {
          return MultiProvider(
            providers: providers,
            child: MaterialApp(
              title: 'Astrologer',
              themeMode: snapshot.hasData && snapshot.data
                  ? ThemeMode.dark
                  : ThemeMode.light,
              theme: snapshot.hasData && snapshot.data
                  ? ThemeData.dark()
                  : ThemeData.light(),
              debugShowCheckedModeBanner: false,
              home: /*widget.token == null ? LoginView() :*/ HomeView(),
              onGenerateRoute: (settings) =>
                  Router.generateRoute(settings, widget.theme),
//              initialRoute: RoutePaths.login, //commenting this cause it shows black screen initially
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _initSquarePayment();
  }
}
