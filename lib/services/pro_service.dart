import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class ProService extends ChangeNotifier {
  static final ProService _instance = ProService._internal();
  factory ProService() => _instance;
  ProService._internal();

  static const _entitlementId = 'Gün Sayacı Pro';

  bool _isPro = false;
  bool get isPro => _isPro;

  Future<void> init() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _checkPro(customerInfo);
    } catch (e) {
      // init error ignored
    }

    Purchases.addCustomerInfoUpdateListener((info) {
      _checkPro(info);
      notifyListeners();
    });
  }

  void _checkPro(CustomerInfo info) {
    final entitlement = info.entitlements.all[_entitlementId];
    _isPro = entitlement?.isActive == true;
  }

  Future<bool> purchase() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) throw Exception('No offerings available');

      final package =
          current.lifetime ?? current.availablePackages.first;
      await Purchases.purchase(PurchaseParams.package(package));
      return true;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return false;
      }
      rethrow;
    }
  }

  Future<bool> restore() async {
    try {
      final info = await Purchases.restorePurchases();
      _checkPro(info);
      notifyListeners();
      return _isPro;
    } on PlatformException {
      rethrow;
    }
  }
}
