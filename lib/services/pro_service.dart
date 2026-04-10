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
    debugPrint('ProService init başladı');
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      debugPrint('CustomerInfo: ${customerInfo.entitlements.all}');
      _checkPro(customerInfo);
    } catch (e) {
      debugPrint('ProService init error: $e');
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
    debugPrint('Purchase başladı');
    try {
      final offerings = await Purchases.getOfferings();
      debugPrint('Offerings: ${offerings.current}');
      final current = offerings.current;
      if (current == null) throw Exception('No offerings available');

      debugPrint('Packages: ${current.availablePackages}');
      final package =
          current.lifetime ?? current.availablePackages.first;
      debugPrint('Selected package: $package');
      await Purchases.purchase(PurchaseParams.package(package));
      return true;
    } on PlatformException catch (e) {
      debugPrint('Purchase error: $e');
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
    } on PlatformException catch (e) {
      debugPrint('Restore error: $e');
      rethrow;
    }
  }
}
