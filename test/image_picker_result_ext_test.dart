import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_image_picker_macos/src/image_picker_result_ext.dart';
import 'package:native_image_picker_macos/src/messages.g.dart';

void main() {
  test(
    'getSuccessOrThrow throws $PlatformException on $ImagePickerErrorResult correctly',
    () {
      for (final ImagePickerError error in ImagePickerError.values) {
        final String platformErrorMessage =
            'Example message ${Random().nextInt(100)}';
        final ImagePickerResult result = ImagePickerErrorResult(
          error: error,
          platformErrorMessage: platformErrorMessage,
        );
        final String errorMessage = switch (error) {
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
        expect(
          () => result.getSuccessOrThrow(),
          throwsA(
            isA<PlatformException>()
                .having(
                  (PlatformException e) => e.code,
                  'code',
                  equals(error.code),
                )
                .having(
                  (PlatformException e) => e.details,
                  'details',
                  equals(platformErrorMessage),
                )
                .having(
                  (PlatformException e) => e.message,
                  'message',
                  equals(errorMessage),
                ),
          ),
        );
      }
    },
  );

  test(
    'getSuccessOrThrow returns the result on $ImagePickerSuccessResult',
    () {
      final ImagePickerResult result = ImagePickerSuccessResult(
        filePaths: <String>[],
      );
      expect(() => result.getSuccessOrThrow(), returnsNormally);
      expect(result.getSuccessOrThrow(), equals(result));
      expect(result.getSuccessOrThrow(), isA<ImagePickerSuccessResult>());
    },
  );

  test('$ImagePickerError returns the error code correctly', () {
    for (final ImagePickerError error in ImagePickerError.values) {
      final String errorCode = switch (error) {
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
      expect(error.code, errorCode);
    }
  });
}
