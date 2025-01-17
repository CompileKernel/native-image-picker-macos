import Cocoa
import FlutterMacOS

public class NativeImagePickerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger
    let api = ImagePickerImpl()
    ImagePickerApiSetup.setUp(binaryMessenger: messenger, api: api)
  }
}
