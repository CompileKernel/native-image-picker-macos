import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    dartTestOut: 'test/test_api.g.dart',
    swiftOut:
        'macos/native_image_picker_macos/Sources/native_image_picker_macos/Messages.g.swift',
    dartOptions: DartOptions(
      copyrightHeader: <String>[
        'coverage:ignore-file',
      ],
    ),
  ),
)

/// The common options between [ImageSelectionOptions], [VideoSelectionOptions]
/// and [MediaSelectionOptions].
class GeneralOptions {
  GeneralOptions({required this.limit});

  /// The value `0` means no limit.
  int limit;
}

/// Represents the maximum size with [width] and [height] dimensions.
class MaxSize {
  MaxSize(this.width, this.height);
  double? width;
  double? height;
}

/// Options for image selection and output.
class ImageSelectionOptions {
  ImageSelectionOptions({this.maxSize, required this.quality});

  /// If set, the max size that the image should be resized to fit in.
  MaxSize? maxSize;

  /// The quality of the output image, from 0-100.
  ///
  /// 100 indicates original quality.
  int quality;
}

// TODO(EchoEllet): Confirm if it's not possible to support maxDurationSeconds with macOS PHPicker.
//  remove references to this commented class in this file.
// /// Options for video selection and output.
// class VideoSelectionOptions {
//   VideoSelectionOptions();

// }

class MediaSelectionOptions {
  MediaSelectionOptions({
    required this.imageSelectionOptions,
  });

  ImageSelectionOptions imageSelectionOptions;
}

/// Possible error conditions for [ImagePickerApi] calls.
enum ImagePickerError {
  /// The current macOS version doesn't support [PHPickerViewController](https://developer.apple.com/documentation/photosui/phpickerviewcontroller)
  /// which is supported on macOS 13+.
  phpickerUnsupported,

  /// Could not show the picker due to the missing window.
  /// This May occur if the `NSView` is `nil`, for instance in a headless environment.
  windowNotFound,

  /// When a `PHPickerResult` can't load `NSImage`. This error should not be reached
  /// as the filter in the `PHPickerConfiguration` is set to accept only images.
  invalidImageSelection,

  /// When a `PHPickerResult` is not a video. This error should not be reached
  /// as the filter in the `PHPickerConfiguration` is set to accept only videos.
  invalidVideoSelection,

  /// Could not load the image object as `NSImage`.
  imageLoadFailed,

  /// Could not load the video data representation.
  videoLoadFailed,

  /// The image tiff representation could not be loaded from the `NSImage`.
  imageConversionFailed,

  /// The loaded `Data` from the `NSImage` could not be written as a file.
  imageSaveFailed,

  /// The image could not be compressed or the `NSImage` could not be created
  /// from the compressed `Data`.
  imageCompressionFailed,

  // TODO(EchoEllet): Add support multi-video selection via pickVideos instead of only pickMedia
  /// The multi-video selection is not supported as it's not supported in
  /// the app-facing package (`pickVideos` is missing).
  /// The multi-video selection is supported when using `pickMedia` instead.
  multiVideoSelectionUnsupported;
}

sealed class ImagePickerResult {}

class ImagePickerSuccessResult extends ImagePickerResult {
  ImagePickerSuccessResult({required this.filePaths});

  /// The temporary file paths as a result of picking the images and/or videos.
  final List<String> filePaths;
}

class ImagePickerErrorResult extends ImagePickerResult {
  ImagePickerErrorResult(this.error, {this.platformErrorMessage});

  /// Potential error conditions for [ImagePickerApi] calls.
  final ImagePickerError error;

  /// Additional error message from the platform side.
  final String? platformErrorMessage;
}

@HostApi(dartHostTestHandler: 'TestHostImagePickerApi')
abstract class ImagePickerApi {
  /// Returns whether [PHPickerViewController](https://developer.apple.com/documentation/photosui/phpickerviewcontroller)
  /// is supported on the current macOS version.
  bool supportsPHPicker();

  @async
  ImagePickerResult pickImages(
    ImageSelectionOptions options,
    GeneralOptions generalOptions,
  );

  @async
  ImagePickerResult pickVideos(
    GeneralOptions generalOptions,
  );
  @async
  ImagePickerResult pickMedia(
    MediaSelectionOptions options,
    GeneralOptions generalOptions,
  );

  /// Opens the [Photos for macOS](https://www.apple.com/in/macos/photos/) app.
  ///
  /// Returns whether the Photos app was successfully opened.
  bool openPhotosApp();
}
