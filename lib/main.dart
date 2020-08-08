import 'dart:async';
import 'dart:io';

import 'package:astrologer/core/service/navigation_service.dart';
import 'package:astrologer/provider_setup.dart';
import 'package:astrologer/router.dart';
import 'package:astrologer/ui/shared/theme_stream.dart';
import 'package:astrologer/ui/shared/ui_helpers.dart';
import 'package:astrologer/ui/view/home_view.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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
            title: 'Cosmos',
            color: Colors.red,
            theme: snapshot.hasData && snapshot.data
                ? UIHelper.darkTheme
                : UIHelper.lightTheme,
            debugShowCheckedModeBanner: false,
//            home: widget.token == null ? LoginView() : HomeView(),
//            home: MyHomePage(
//              title: "Purchase test",
//            ),
            home: HomeView(),
            onGenerateRoute: (settings) => Router.generateRoute(settings),
            navigatorKey: navigatorKey,
//              initialRoute: RoutePaths.login, //commenting this cause it shows black screen initially
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String iapId = 'com.cosmos_nepal.question01';

  /// Is the API available on the device
  bool _available = true;

  /// The In App Purchase plugin
  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;

  /// Products for sale
  List<ProductDetails> _products = [];

  /// Past purchases
  List<PurchaseDetails> _purchases = [];

  /// Updates to purchases
  StreamSubscription _subscription;

  /// Consumable credits the user can buy
  int _credits = 0;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  /// Initialize data
  void _initialize() async {
    // Check availability of In App Purchases
    _available = await _iap.isAvailable();

    if (_available) {
      await _getProducts();
      await _getPastPurchases();

      // Verify and deliver a purchase with your own business logic
//      _verifyPurchase();

      _subscription = _iap.purchaseUpdatedStream.listen((data) => setState(() {
            print('NEW PURCHASE');
            _purchases.addAll(data);
            _verifyPurchase();
          }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_available ? 'Open for Business' : 'Not Available'),
      ),
      body: Center(
        child: Column(
          children: [
            for (var prod in _products)

              // UI if already purchased
              if (_hasPurchased(prod.id) != null)
                ...[]

              // UI if NOT purchased
              else
                ...[]
          ],
        ),
      ),
    );
  }

  /// Get all products available for sale
  Future<void> _getProducts() async {
    Set<String> ids = Set.from([iapId, 'test_a']);
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);

    setState(() {
      _products = response.productDetails;
    });
  }

  /// Gets past purchases
  Future<void> _getPastPurchases() async {
    QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();

    for (PurchaseDetails purchase in response.pastPurchases) {
      if (Platform.isIOS) {
        InAppPurchaseConnection.instance.completePurchase(purchase);
      }
    }

    setState(() {
      _purchases = response.pastPurchases;
    });
  }

  /// Returns purchase of specific product ID
  PurchaseDetails _hasPurchased(String productID) {
    return _purchases.firstWhere((purchase) => purchase.productID == productID,
        orElse: () => null);
  }

  /// Your own business logic to setup a consumable
  void _verifyPurchase() {
    PurchaseDetails purchase = _hasPurchased(iapId);

    // TODO serverside verification & record consumable in the database

    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      _credits = 10;
    }
  }

  /// Purchase a product
  void _buyProduct(ProductDetails prod) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    // _iap.buyNonConsumable(purchaseParam: purchaseParam);
    _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: false);
  }
  /// Spend credits and consume purchase when they run pit
  void _spendCredits(PurchaseDetails purchase) async {

    /// Decrement credits
    setState(() { _credits--; });

    /// TODO update the state of the consumable to a backend database

    // Mark consumed when credits run out
    if (_credits == 0) {
      var res = await _iap.consumePurchase(purchase);
      await _getPastPurchases();
    }

  }
}
