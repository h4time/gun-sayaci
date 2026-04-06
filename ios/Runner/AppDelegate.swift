import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    let iconChannel = FlutterMethodChannel(
      name: "com.gunsayaci/app_icon",
      binaryMessenger: controller.binaryMessenger
    )
    iconChannel.setMethodCallHandler { (call, result) in
      if call.method == "setAlternateIcon" {
        let iconName = call.arguments as? String
        if UIApplication.shared.supportsAlternateIcons {
          UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
              result(FlutterError(code: "ICON_ERROR",
                                  message: error.localizedDescription,
                                  details: nil))
            } else {
              result(nil)
            }
          }
        } else {
          result(FlutterError(code: "NOT_SUPPORTED",
                              message: "Alternate icons not supported",
                              details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
