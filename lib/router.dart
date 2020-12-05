import 'package:astrologer/ui/view/home_view.dart';
import 'package:astrologer/ui/shared/route_paths.dart';
import 'package:astrologer/ui/widgets/profile_dialog.dart';
import 'package:flutter/material.dart';

class Router {
  static Route<dynamic> generateRoute(
      RouteSettings settings) {
    switch (settings.name) {
      case RoutePaths.home:
        return MaterialPageRoute(
            builder: (_) => HomeView());
      case RoutePaths.profile:
        return MaterialPageRoute(
            builder: (_) => ProfileDialog());
      case RoutePaths.example:
//        return MaterialPageRoute(builder: (_) => DashboardView2());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
