import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    guard let windowScene = scene as? UIWindowScene,
          let controller = windowScene.windows.first?.rootViewController as? FlutterViewController else {
      return
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
  }
}
