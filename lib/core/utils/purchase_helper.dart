import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:io';
import '../../consumable_store.dart';

const String _kConsumableId = 'com.cosmos_nepal.question01';

class PurchaseHelper {
  final bool kAutoConsume = true;
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
  final List<String> _kProductIds = <String>[
    _kConsumableId,
    'upgrade',
    'subscription'
  ];

  bool isAvailable = false;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];

  PurchaseHelper() {
    initStoreInfo();
    Stream purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      print('listening to updated purchase');
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
  }

  initStoreInfo() async {
    isAvailable = await _connection.isAvailable();
    ProductDetailsResponse productDetailResponse =
        await _connection.queryProductDetails(_kProductIds.toSet());
    _products = productDetailResponse.productDetails;
  }

  purchase() {
    if (_products.length > 0) {
      print("possible to purchase ${_products.length}");
      PurchaseParam purchaseParam = PurchaseParam(
          productDetails: _products[0],
          applicationUserName: null,
          sandboxTesting: true);
      if (_products[0].id == _kConsumableId) {
        _connection.buyConsumable(
            purchaseParam: purchaseParam,
            autoConsume: kAutoConsume || Platform.isIOS);
      } else {
        _connection.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } else {
      print('No possible to purchase');
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
//        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
//          handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!kAutoConsume && purchaseDetails.productID == _kConsumableId) {
            await InAppPurchaseConnection.instance
                .consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchaseConnection.instance
              .completePurchase(purchaseDetails);
        }
      }
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify a purchase purchase details before delivering the product.
    if (purchaseDetails.productID == _kConsumableId) {
      await ConsumableStore.save(purchaseDetails.purchaseID);
//      List<String> consumables = await ConsumableStore.load();
//      setState(() {
//        _purchasePending = false;
//        _consumables = consumables;
//      });
    } else {
//      setState(() {
//        _purchases.add(purchaseDetails);
//        _purchasePending = false;
//      });
    }
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }
}
