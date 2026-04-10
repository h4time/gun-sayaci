import 'package:flutter/foundation.dart';

class ProService extends ChangeNotifier {
  static final ProService _instance = ProService._internal();
  factory ProService() => _instance;
  ProService._internal();

  bool _isPro = false;

  bool get isPro => _isPro;

  /// Şimdilik manuel toggle — sonra RevenueCat bağlanacak
  void setPro(bool value) {
    _isPro = value;
    notifyListeners();
  }

  /// Pro özellik kontrolü
  bool canAccess(String feature) {
    return _isPro;
  }
}
