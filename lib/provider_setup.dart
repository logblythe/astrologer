import 'package:astrologer/core/service/api.dart';
import 'package:astrologer/core/service/db_provider.dart';
import 'package:astrologer/core/service/home_service.dart';
import 'package:astrologer/core/service/navigation_service.dart';
import 'package:astrologer/core/service/profile_service.dart';
import 'package:astrologer/core/service/settings_service.dart';
import 'package:astrologer/core/service/user_service.dart';
import 'package:astrologer/core/utils/local_notification_helper.dart';
import 'package:astrologer/core/utils/purchase_helper.dart';
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
  Provider.value(value: NavigationService()),
  Provider.value(value: PurchaseHelper()),
];

List<SingleChildCloneableWidget> dependentServices = [
  ProxyProvider3<Api, DbProvider, SharedPrefHelper, UserService>(
    builder: (context, api, dbProvider, sharedPrefH, userService) =>
        UserService(
            api: api, dbProvider: dbProvider, sharedPrefHelper: sharedPrefH),
  ),
  ProxyProvider3<Api, DbProvider, SharedPrefHelper, ProfileService>(
    builder: (context, api, dbProvider, prefHelper, profileService) =>
        ProfileService(api: api, db: dbProvider, prefHelper: prefHelper),
  ),
  ProxyProvider5<Api, DbProvider, SharedPrefHelper, LocalNotificationHelper,
      PurchaseHelper, HomeService>(
    builder: (context, api, dbProvider, sharedPrefH, localNotificationH,
            purchaseHelper, homeService) =>
        HomeService(
            api: api,
            db: dbProvider,
            sharedPrefHelper: sharedPrefH,
            localNotificationHelper: localNotificationH,
            purchaseHelper: purchaseHelper),
  ),
  ProxyProvider2<SharedPrefHelper, DbProvider, SettingsService>(
    builder: (context, sharedPrefHelper, dbProvider, homeService) =>
        SettingsService(
      dbProvider: dbProvider,
      sharedPrefHelper: sharedPrefHelper,
    ),
  ),
];

List<SingleChildCloneableWidget> uiConsumableProviders = [
  StreamProvider<int>(
    initialData: 0,
    builder: (context) =>
        Provider.of<HomeService>(context, listen: false).freeCountStream,
    updateShouldNotify: (_, __) => true,
  ),
  StreamProvider<String>(
    builder: (context) =>
        Provider.of<ProfileService>(context, listen: false).profilePic,
    updateShouldNotify: (_, __) => true,
  ),
  /*
  StreamProvider<UtilityModel>(
    builder: (context) =>
    Provider.of<AdsService>(context, listen: false).utilityStream,
    updateShouldNotify: (_, __) => true,
  )*/
];
