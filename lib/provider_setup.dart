import 'package:astrologer/core/service/api.dart';
import 'package:astrologer/core/service/db_provider.dart';
import 'package:astrologer/core/service/home_service.dart';
import 'package:astrologer/core/service/profile_service.dart';
import 'package:astrologer/core/service/user_service.dart';
import 'package:astrologer/core/utils/local_notification_helper.dart';
import 'package:astrologer/core/utils/shared_pref_helper.dart';
import 'package:provider/provider.dart';

List<SingleChildCloneableWidget> providers = [
  ...independentServices,
  ...dependentServices,
  ...uiConsumableProviders
];

List<SingleChildCloneableWidget> independentServices = [
  Provider.value(value: Api()),
  Provider.value(value: SharedPrefHelper()),
  Provider.value(value: DbProvider()),
  Provider.value(value: LocalNotificationHelper()),
];

List<SingleChildCloneableWidget> dependentServices = [
  ProxyProvider2<Api, DbProvider, UserService>(
    builder: (context, api, dbProvider, userService) =>
        UserService(api: api, dbProvider: dbProvider),
  ),
  ProxyProvider2<Api, DbProvider, ProfileService>(
    builder: (context, api, dbProvider, profileService) =>
        ProfileService(api: api, db: dbProvider),
  ),
  ProxyProvider2<Api, DbProvider, HomeService>(
    builder: (context, api, dbProvider, homeService) =>
        HomeService(api: api, db: dbProvider),
  ),
];

List<SingleChildCloneableWidget> uiConsumableProviders = [
  /*StreamProvider<UserModel>(
    builder: (context) =>
    Provider.of<UserService>(context, listen: false).userStream,
    updateShouldNotify: (_, __) => true,
  ),
  StreamProvider<UtilityModel>(
    builder: (context) =>
    Provider.of<AdsService>(context, listen: false).utilityStream,
    updateShouldNotify: (_, __) => true,
  )*/
];
