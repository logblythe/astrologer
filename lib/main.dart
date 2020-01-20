import 'package:astrologer/core/service/navigation_service.dart';
import 'package:astrologer/provider_setup.dart';
import 'package:astrologer/router.dart';
import 'package:astrologer/ui/shared/theme_stream.dart';
import 'package:astrologer/ui/shared/ui_helpers.dart';
import 'package:astrologer/ui/view/home_view.dart';
import 'package:astrologer/ui/view/login_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/utils/shared_pref_helper.dart';

Future<void> main() async {
//  debugPaintSizeEnabled=true;
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences sharedPref = await SharedPreferences.getInstance();
  final String token = sharedPref.getString(KEY_TOKEN);
  final bool darkModeEnabled = sharedPref.getBool(KEY_DARK_MODE_ENABLED);
  runApp(MyApp(token, darkModeEnabled));
}

class MyApp extends StatefulWidget {
  MyApp(this.token, this.darkModeEnabled);

  final String token;
  final bool darkModeEnabled;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: theme.themeStream,
      initialData: widget.darkModeEnabled,
      builder: (context, snapshot) {
        return MultiProvider(
          providers: providers,
          child: MaterialApp(
            title: 'Astrologer',
            theme: snapshot.hasData && snapshot.data
                ? UIHelper.darkTheme
                : UIHelper.lightTheme,
            debugShowCheckedModeBanner: false,
            home: widget.token == null ? LoginView() : HomeView(),
//              home: HomeView(),
            onGenerateRoute: (settings) => Router.generateRoute(settings),
//              navigatorKey: navigatorKey,
//              initialRoute: RoutePaths.login, //commenting this cause it shows black screen initially
          ),
        );
      },
    );
  }
}
