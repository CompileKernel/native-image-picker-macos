# 🖼️ Native Image Picker for macOS

<p align="center">
<a href="https://pub.dev/packages/native_image_picker_macos"><img src="https://img.shields.io/pub/v/native_image_picker_macos" alt="Pub Version"></a>
<a href="https://github.com/CompileKernel/native-image-picker-macos"><img src="https://img.shields.io/github/stars/CompileKernel/native-image-picker-macos" alt="Star on Github"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://github.com/CompileKernel/native-image-picker-macos"><img src="https://img.shields.io/badge/Dart%20Code%20Coverage-100%25-brightgreen" alt="Dart Code Coverage"></a>
</p>

A macOS platform implementation of [`image_picker`](https://pub.dev/packages/image_picker)
using the native system picker instead of the system open file dialog.

This package is an alternative to [`image_picker_macos`](https://pub.dev/packages/image_picker_macos)
which uses [`file_selector`](https://pub.dev/packages/file_selector).

> [!NOTE]
> This native picker depends on the photos in the [Photos for MacOS App](https://www.apple.com/in/macos/photos/), which uses the [Apple PhotosUI](https://developer.apple.com/documentation/photosui) Picker, also known as PHPicker.

| Default picker | Native picker |
|-------------------|-------------------|
| <img src="https://github.com/CompileKernel/native-image-picker-macos/blob/main/readme_assets/image-picker-macos-file-selector.png?raw=true" alt="Default picker" height="400"/> | <img src="https://github.com/CompileKernel/native-image-picker-macos/blob/main/readme_assets/native-image-picker-macos-phpicker.png?raw=true" alt="macOS PHPicker" height="400"/> |

## ✨ Features

- 🚀 **Seamless Integration**  
  Effortlessly integrates with the [`image_picker`](https://pub.dev/packages/image_picker) package. Switch seamlessly between [`image_picker_macos`](https://pub.dev/packages/image_picker_macos) and this native platform implementation without modifying existing code.  
- 🔒 **No Permissions or Setup Required**  
  Requires no runtime permission prompts or entitlement configuration. Everything works out of the box.  
- 📱 **macOS Photos App**  
  Enables picking images from the macOS Photos app, integrating with the Apple ecosystem and supporting photo imports from connected iOS devices.
- 🛠️ **Supports Image Options**  
  Adds support for image arguments like `maxWidth`, `maxHeight`, and `imageQuality`—features [not currently supported in `image_picker_macos`](https://pub.dev/packages/image_picker_macos#limitations).

<img src="https://github.com/CompileKernel/native-image-picker-macos/blob/main/readme_assets/import-photos-from-connected-ios-devices.png?raw=true" alt="Import photos from the connected iOS devices to macOS" width="600">

## 🛠️ Getting started

Run the following command to add the dependencies:

```shell
$ flutter pub add image_picker image_picker_macos native_image_picker_macos
```

1. [`image_picker`](https://pub.dev/packages/image_picker): The app-facing package for the Image Picker plugin which specifies the API used by Flutter apps.
2. [`image_picker_macos`](https://pub.dev/packages/image_picker_macos): The default macOS implementation of `image_picker`, built on [`file_selector`](https://pub.dev/packages/file_selector) and using [`NSOpenPanel`](https://developer.apple.com/documentation/appkit/nsopenpanel) with appropriate file type filters set. Lacks image resizing/compression options but supports older macOS versions.
3. [`native_image_picker_macos`](https://pub.dev/packages/native_image_picker_macos): A macOS implementation of `image_picker`, built on [`PHPickerViewController`](https://developer.apple.com/documentation/photosui/phpickerviewcontroller) which depends on the [Photos for macOS App](https://www.apple.com/in/macos/photos/). Supports image resizing/compression options. Requires macOS 13.0+.

Using both `image_picker_macos` and `native_image_picker_macos` can enable user-level opt-in to switch between implementations if the user prefers to pick images from the photos app or the file system.

<img src="https://github.com/CompileKernel/native-image-picker-macos/blob/main/readme_assets/use-native-macos-picker-switch-button.png?raw=true" alt="Use native macOS picker switch button" width="250">

The platform implementation `image_picker_macos` is required to ensure compatibility with macOS versions before 13.0, which is used as a fallback, in that case, it's necessary to [setup `image_picker_macos`](https://pub.dev/packages/image_picker_macos#entitlements).

> [!TIP]
> After registering this implementation as outlined in the [Usage](#-usage) section, you can [use the `image_picker`](https://pub.dev/packages/image_picker#example) plugin as usual.

## 📜 Usage

By default, this package doesn't replace the default implementation of [`image_picker`](https://pub.dev/packages/image_picker) for macOS to avoid conflict with [`image_picker_macos`](https://pub.dev/packages/image_picker_macos).

This implementation supports macOS 13 Ventura and later.

**To apply this package only in case it's supported on the current macOS version**:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NativeImagePickerMacOS.registerWithIfSupported(); // ADD THIS LINE

  runApp(const MainApp());
}
```

**To checks if the current implementation of `image_picker` is `native_image_picker_macos`**:

```dart
final bool isRegistered = NativeImagePickerMacOS.isRegistered();

// OR

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

final bool isRegistered = ImagePickerPlatform.instance is NativeImagePickerMacOS;
```

**To checks if the current macOS version supports this implementation**:

```dart
final bool isSupported = await NativeImagePickerMacOS().isSupported(); // Returns false on non-macOS platforms or if PHPicker is not supported on the current macOS version.
```

**To switch between `image_picker_macos` and `native_image_picker_macos` implementations**:

```dart
// NOTE: This code assumes the current target platform is macOS and native_image_picker_macos implementation is supported.

import 'package:image_picker_macos/image_picker_macos.dart';
import 'package:native_image_picker_macos/native_image_picker_macos.dart';

// To switch to image_picker_macos (supported on all macOS versions):

ImagePickerMacOS.registerWith();

// To switch to native_image_picker_macos (supported on macOS 13 and above):

NativeImagePickerMacOS.registerWith();

```

**To open the macOS photos app**:

```dart
<!-- TODO: This approach needs more consideration, also update the example (which has related TODO) -->
await NativeImagePickerMacOS().openPhotosApp();

// OR

final ImagePickerPlatform imagePickerImplementation = ImagePickerPlatform.instance;
if (imagePickerImplementation is NativeImagePickerMacOS) {
  await imagePickerImplementation.openPhotosApp();
}
```

> [!TIP]
> You can use `NativeImagePickerMacOS.registerWith()` to register this implementation. However, this bypasses platform checks, which **may result in runtime errors** if the current platform is not macOS or if the macOS version is unsupported. Instead, use `registerWithIfSupported()` if uncertain.

## 🌱 Contributing

This package uses [pigeon](https://pub.dev/packages/pigeon) for platform communication with the platform host and [mockito](https://pub.dev/packages/mockito) for mocking in unit tests and [swift-format](https://github.com/swiftlang/swift-format) for formatting the Swift code.

```shell
$ dart run pigeon --input pigeons/messages.dart # To generate the required Dart and host-language code.
$ dart run build_runner build --delete-conflicting-outputs # To generate the mock classes.
$ swift-format format --in-place --recursive macos/native_image_picker_macos/Sources/native_image_picker_macos # To format the Swift code.
```

### Resources

* [Flutter repo style guide](https://github.com/flutter/flutter/blob/master/docs/contributing/Style-guide-for-Flutter-repo.md).
* [Flutter repo plugin tests](https://github.com/flutter/flutter/blob/master/docs/ecosystem/testing/Plugin-Tests.md).
* [Flutter repo writing effective tests](https://github.com/flutter/flutter/blob/master/docs/contributing/testing/Writing-Effective-Tests.md).
* [Flutter developing plugin packages](https://docs.flutter.dev/packages-and-plugins/developing-packages#plugin).
* [Flutter testing plugins](https://docs.flutter.dev/testing/testing-plugins), [Flutter plugins in Flutter tests](https://docs.flutter.dev/testing/plugins-in-tests) and [Flutter mock dependencies using Mockito](https://docs.flutter.dev/cookbook/testing/unit/mocking).
* [Pigeon example README](https://github.com/flutter/packages/blob/main/packages/pigeon/example/README.md).
* [Effective Dart](https://dart.dev/effective-dart).
* [PHPickerViewController](https://developer.apple.com/documentation/photosui/phpickerviewcontroller).

Contributions are welcome. File issues to the [GitHub repo](https://github.com/CompileKernel/native-image-picker-macos).

## 📚 Additional information

This functionality was originally proposed as a [pull request to `image_picker_macos`](https://github.com/flutter/packages/pull/8079/), but it was later decided to split it into a community package which is unendorsed.

<img src="https://github.com/CompileKernel/native-image-picker-macos/blob/main/readme_assets/phpicker-window.png?raw=true" alt="PHPicker window" width="600">

[Ask a question about using the package](https://github.com/CompileKernel/native-image-picker-macos/discussions/new?category=q-a).
