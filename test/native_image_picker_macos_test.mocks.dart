// Mocks generated by Mockito 5.4.5 from annotations
// in native_image_picker_macos/test/native_image_picker_macos_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i5;
import 'package:native_image_picker_macos/src/messages.g.dart' as _i4;

import 'test_api.g.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [TestHostImagePickerApi].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestHostImagePickerApi extends _i1.Mock
    implements _i2.TestHostImagePickerApi {
  @override
  bool supportsPHPicker() => (super.noSuchMethod(
        Invocation.method(
          #supportsPHPicker,
          [],
        ),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  _i3.Future<_i4.ImagePickerResult> pickImages(
    _i4.ImageSelectionOptions? options,
    _i4.GeneralOptions? generalOptions,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #pickImages,
          [
            options,
            generalOptions,
          ],
        ),
        returnValue: _i3.Future<_i4.ImagePickerResult>.value(
            _i5.dummyValue<_i4.ImagePickerResult>(
          this,
          Invocation.method(
            #pickImages,
            [
              options,
              generalOptions,
            ],
          ),
        )),
        returnValueForMissingStub: _i3.Future<_i4.ImagePickerResult>.value(
            _i5.dummyValue<_i4.ImagePickerResult>(
          this,
          Invocation.method(
            #pickImages,
            [
              options,
              generalOptions,
            ],
          ),
        )),
      ) as _i3.Future<_i4.ImagePickerResult>);

  @override
  _i3.Future<_i4.ImagePickerResult> pickVideos(
          _i4.GeneralOptions? generalOptions) =>
      (super.noSuchMethod(
        Invocation.method(
          #pickVideos,
          [generalOptions],
        ),
        returnValue: _i3.Future<_i4.ImagePickerResult>.value(
            _i5.dummyValue<_i4.ImagePickerResult>(
          this,
          Invocation.method(
            #pickVideos,
            [generalOptions],
          ),
        )),
        returnValueForMissingStub: _i3.Future<_i4.ImagePickerResult>.value(
            _i5.dummyValue<_i4.ImagePickerResult>(
          this,
          Invocation.method(
            #pickVideos,
            [generalOptions],
          ),
        )),
      ) as _i3.Future<_i4.ImagePickerResult>);

  @override
  _i3.Future<_i4.ImagePickerResult> pickMedia(
    _i4.MediaSelectionOptions? options,
    _i4.GeneralOptions? generalOptions,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #pickMedia,
          [
            options,
            generalOptions,
          ],
        ),
        returnValue: _i3.Future<_i4.ImagePickerResult>.value(
            _i5.dummyValue<_i4.ImagePickerResult>(
          this,
          Invocation.method(
            #pickMedia,
            [
              options,
              generalOptions,
            ],
          ),
        )),
        returnValueForMissingStub: _i3.Future<_i4.ImagePickerResult>.value(
            _i5.dummyValue<_i4.ImagePickerResult>(
          this,
          Invocation.method(
            #pickMedia,
            [
              options,
              generalOptions,
            ],
          ),
        )),
      ) as _i3.Future<_i4.ImagePickerResult>);

  @override
  bool openPhotosApp() => (super.noSuchMethod(
        Invocation.method(
          #openPhotosApp,
          [],
        ),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
}
