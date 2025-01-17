@internal
library;

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:meta/meta.dart';

import 'messages.g.dart';

/// Maps APIs from the [image_picker_platform_interface](https://pub.dev/packages/image_picker_platform_interface)
/// to APIs specific to this package.
abstract final class ImagePickerApiMapper {
  /// Maps the [ImageOptions] from the `image_picker_platform_interface` package to
  /// the Pigeon-generated [ImageSelectionOptions] for platform communication.
  static ImageSelectionOptions imageOptionsToImageSelectionOptions(
    ImageOptions imageOptions,
  ) {
    final int? imageQuality = imageOptions.imageQuality;
    if (imageQuality != null && imageQuality < 0) {
      throw ArgumentError.value(
        imageQuality,
        'imageQuality',
        'quality cannot be negative',
      );
    }

    return ImageSelectionOptions(
      quality: imageQuality ?? 100,
      maxSize: MaxSize(
        width: imageOptions.maxWidth,
        height: imageOptions.maxHeight,
      ),
    );
  }
}
