import 'dart:io';
import 'package:flutter/services.dart';

/// Lightweight wrapper around iOS setAlternateIconName via MethodChannel.
/// No third-party package needed — just one platform call.
class AppIconService {
  static const _channel = MethodChannel('com.gunsayaci/app_icon');

  /// Change the iOS home screen icon.
  /// Pass `null` to revert to the primary (default) icon.
  /// Returns `true` on success, `false` if not supported or failed.
  static Future<bool> setAlternateIcon(String? iconName) async {
    if (!Platform.isIOS) return false;
    try {
      await _channel.invokeMethod('setAlternateIcon', iconName);
      return true;
    } on PlatformException {
      return false;
    }
  }
}
