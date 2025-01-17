import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:native_image_picker_macos/src/image_picker_api_mapper.dart';
import 'package:native_image_picker_macos/src/messages.g.dart';

void main() {
  test(
    'imageOptionsToImageSelectionOptions throws $ArgumentError when quality is negative',
    () {
      for (final int imageQuality in <int>{-1, -10, -100}) {
        expect(
          () => ImagePickerApiMapper.imageOptionsToImageSelectionOptions(
            ImageOptions(imageQuality: imageQuality),
          ),
          throwsA(
            isA<ArgumentError>()
                .having(
                  (ArgumentError e) => e.invalidValue,
                  'invalidValue',
                  equals(imageQuality),
                )
                .having(
                  (ArgumentError e) => e.name,
                  'name',
                  equals('imageQuality'),
                )
                .having(
                  (ArgumentError e) => e.message,
                  'message',
                  equals('quality cannot be negative'),
                ),
          ),
        );
      }
    },
  );
  test(
    'imageOptionsToImageSelectionOptions returns $ImageSelectionOptions correctly',
    () {
      const int imageQuality = 80;
      const double maxWidth = 250;
      const double maxHeight = 100;
      final ImageSelectionOptions imageSelectionOptions =
          ImagePickerApiMapper.imageOptionsToImageSelectionOptions(
        const ImageOptions(
          imageQuality: imageQuality,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
        ),
      );
      expect(imageSelectionOptions.quality, equals(imageQuality));
      expect(
        imageSelectionOptions.maxSize?.width,
        equals(maxWidth),
      );
      expect(
        imageSelectionOptions.maxSize?.height,
        equals(maxHeight),
      );
    },
  );

  test(
    'imageOptionsToImageSelectionOptions passes 100 for image quality to $ImageSelectionOptions when unspecified',
    () {
      final ImageSelectionOptions imageSelectionOptions =
          ImagePickerApiMapper.imageOptionsToImageSelectionOptions(
        const ImageOptions(
          maxHeight: 100,
          maxWidth: 80,
        ),
      );

      expect(
        imageSelectionOptions.quality,
        equals(100),
      );
    },
  );
}
