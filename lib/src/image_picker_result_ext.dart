@internal
library;

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'messages.g.dart';

@internal
extension ImagePickerResultExt on ImagePickerResult {
  /// Returns the result as an [ImagePickerSuccessResult], or throws a [PlatformException]
  /// if the result is an [ImagePickerErrorResult].
  ImagePickerSuccessResult getSuccessOrThrow() {
    final ImagePickerResult result = this;
    return switch (result) {
      ImagePickerSuccessResult() => result,
      ImagePickerErrorResult() => () {
          final String errorMessage = switch (result.error) {
            ImagePickerError.phpickerUnsupported =>
              'PHPicker is only supported on macOS 13.0 or newer.',
            ImagePickerError.windowNotFound =>
              'No active window to present the picker.',
            ImagePickerError.invalidImageSelection =>
              'One of the selected items is not an image.',
            ImagePickerError.invalidVideoSelection =>
              'One of the selected items is not a video.',
            ImagePickerError.imageLoadFailed =>
              'An error occurred while loading the image.',
            ImagePickerError.videoLoadFailed =>
              'An error occurred while loading the video.',
            ImagePickerError.imageConversionFailed =>
              'Failed to convert the NSImage to TIFF data.',
            ImagePickerError.imageSaveFailed =>
              'Error saving the NSImage data to a file.',
            ImagePickerError.imageCompressionFailed =>
              'Error while compressing the Data of the NSImage.',
            ImagePickerError.multiVideoSelectionUnsupported =>
              'The multi-video selection is not supported.',
          };
          // TODO(EchoEllet): Replace PlatformException with a plugin-specific exception.
          //  This is currently implemented to maintain compatibility with the existing behavior
          //  of other implementations of `image_picker`. For more details, refer to:
          //  https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#platform-exception-handling
          //  and https://github.com/flutter/packages/pull/8079/
          throw PlatformException(
            code: result.error.code,
            message: errorMessage,
            details: result.platformErrorMessage,
          );
        }(),
    };
  }
}

@internal
extension ImagePickerErrorExt on ImagePickerError {
  String get code {
    final String errorCode = switch (this) {
      ImagePickerError.phpickerUnsupported => 'phpicker-unsupported',
      ImagePickerError.windowNotFound => 'window-not-found',
      ImagePickerError.invalidImageSelection => 'invalid-image-selection',
      ImagePickerError.invalidVideoSelection => 'invalid-video-selection',
      ImagePickerError.imageLoadFailed => 'image-load-failed',
      ImagePickerError.videoLoadFailed => 'video-load-failed',
      ImagePickerError.imageConversionFailed => 'image-conversion-failed',
      ImagePickerError.imageSaveFailed => 'image-save-failed',
      ImagePickerError.imageCompressionFailed => 'image-compression-failed',
      ImagePickerError.multiVideoSelectionUnsupported =>
        'multi-video-selection-unsupported',
    };
    return errorCode;
  }
}
