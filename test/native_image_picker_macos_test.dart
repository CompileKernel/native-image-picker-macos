import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:native_image_picker_macos/native_image_picker_macos.dart';
import 'package:native_image_picker_macos/src/image_picker_result_ext.dart';
import 'package:native_image_picker_macos/src/messages.g.dart';

import './test_api.g.dart';
@GenerateNiceMocks(
  <MockSpec<Object>>[
    MockSpec<TestHostImagePickerApi>(),
  ],
)
import 'native_image_picker_macos_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NativeImagePickerMacOS plugin;
  late MockTestHostImagePickerApi mockImagePickerApi;

  setUp(() {
    plugin = NativeImagePickerMacOS();
    mockImagePickerApi = MockTestHostImagePickerApi();

    TestHostImagePickerApi.setUp(mockImagePickerApi);
  });

  setUpAll(() {
    // Mockito cannot generate a dummy value of type ImagePickerResult
    provideDummy<ImagePickerResult>(
      ImagePickerSuccessResult(filePaths: <String>[]),
    );
  });

  test('registered instance', () {
    NativeImagePickerMacOS.registerWith();
    expect(ImagePickerPlatform.instance, isA<NativeImagePickerMacOS>());
  });

  test(
    'supportsPHPicker delegates to supportsPHPicker from platform API correctly',
    () async {
      for (final bool supportsPHPickerValue in <bool>{true, false}) {
        when(mockImagePickerApi.supportsPHPicker())
            .thenAnswer((_) => supportsPHPickerValue);
        expect(await plugin.supportsPHPicker(), supportsPHPickerValue);
        verify(mockImagePickerApi.supportsPHPicker()).called(1);
      }
      verifyNoMoreInteractions(mockImagePickerApi);
    },
  );

  group('image', () {
    test(
        'getImageFromSource calls delegate when source is ${ImageSource.camera.name}',
        () async {
      const String fakePath = '/tmp/foo';
      plugin.cameraDelegate = _FakeCameraDelegate(result: XFile(fakePath));
      expect(
        (await plugin.getImageFromSource(source: ImageSource.camera))!.path,
        fakePath,
      );
    });
    test(
        'getImageFromSource throws $StateError when source is ${ImageSource.camera.name} with no delegate',
        () async {
      plugin.cameraDelegate = null;
      await expectLater(
        plugin.getImageFromSource(source: ImageSource.camera),
        throwsA(
          isA<StateError>().having(
            (StateError e) => e.message,
            'message',
            equals('This implementation of ImagePickerPlatform requires a '
                '"cameraDelegate" in order to use ImageSource.camera'),
          ),
        ),
      );
    });

    test('getImageFromSource calls pickImages from the platform API', () async {
      await plugin.getImageFromSource(source: ImageSource.gallery);
      verify(mockImagePickerApi.pickImages(any, any)).called(1);
    });

    test(
      'getImageFromSource passes 1 for the limit to the platform API',
      () async {
        await plugin.getImageFromSource(source: ImageSource.gallery);
        final VerificationResult result = verify(
          mockImagePickerApi.pickImages(
            any,
            captureAny,
          ),
        );
        expect((result.captured.first as GeneralOptions).limit, equals(1));
      },
    );

    test(
      'getImageFromSource passes the arguments correctly to the platform API',
      () async {
        const ImagePickerOptions options = ImagePickerOptions(
          imageQuality: 50,
          maxHeight: 500,
          maxWidth: 250,
        );
        await plugin.getImageFromSource(
          source: ImageSource.gallery,
          options: options,
        );
        final VerificationResult result = verify(
          mockImagePickerApi.pickImages(
            captureAny,
            any,
          ),
        );
        final ImageSelectionOptions imageSelectionOptions =
            result.captured.single as ImageSelectionOptions;

        expect(imageSelectionOptions.maxSize?.width, options.maxWidth);
        expect(imageSelectionOptions.maxSize?.height, options.maxHeight);
        expect(imageSelectionOptions.quality, options.imageQuality);
      },
    );

    test(
      'getImageFromSource uses 100 for the image quality when unspecified',
      () async {
        await plugin.getImageFromSource(
          source: ImageSource.gallery,
        );

        final VerificationResult result = verify(
          mockImagePickerApi.pickImages(
            captureAny,
            any,
          ),
        );
        expect(
          (result.captured.single as ImageSelectionOptions).quality,
          equals(100),
        );
      },
    );

    test(
      'getImageFromSource throws $PlatformException on platform API error',
      () async {
        const ImagePickerError error = ImagePickerError.imageCompressionFailed;
        when(mockImagePickerApi.pickImages(any, any)).thenAnswer(
          (_) async => ImagePickerErrorResult(
            error: error,
          ),
        );
        await expectLater(
          () => plugin.getImageFromSource(source: ImageSource.gallery),
          throwsA(
            isA<PlatformException>().having(
              (PlatformException e) => e.code,
              'code',
              equals(error.code),
            ),
          ),
        );
      },
    );

    test(
      'getImageFromSource returns null when the platform API returns an empty result',
      () async {
        when(mockImagePickerApi.pickImages(any, any)).thenAnswer(
          (_) async => ImagePickerSuccessResult(filePaths: <String>[]),
        );
        expect(
          await plugin.getImageFromSource(source: ImageSource.gallery),
          isNull,
        );
      },
    );

    test(
      'getImageFromSource returns the file from the platform API',
      () async {
        const String filePath = '/foo/bar';
        when(mockImagePickerApi.pickImages(any, any)).thenAnswer(
          (_) async => ImagePickerSuccessResult(filePaths: <String>[filePath]),
        );
        expect(
          (await plugin.getImageFromSource(source: ImageSource.gallery))?.path,
          equals(XFile(filePath).path),
        );
      },
    );
  });
  group('images', () {
    test('getMultiImageWithOptions calls pickImages from the platform API',
        () async {
      await plugin.getMultiImageWithOptions();
      verify(mockImagePickerApi.pickImages(any, any)).called(1);
    });

    test(
      'getMultiImageWithOptions passes the arguments correctly to the platform API',
      () async {
        const MultiImagePickerOptions options = MultiImagePickerOptions(
          imageOptions: ImageOptions(
            imageQuality: 50,
            maxHeight: 500,
            maxWidth: 250,
          ),
          limit: 50,
        );
        await plugin.getMultiImageWithOptions(
          options: options,
        );
        final VerificationResult result = verify(
          mockImagePickerApi.pickImages(
            captureAny,
            captureAny,
          ),
        );
        final ImageSelectionOptions imageSelectionOptions =
            result.captured.first as ImageSelectionOptions;

        expect(
          imageSelectionOptions.maxSize?.width,
          equals(options.imageOptions.maxWidth),
        );
        expect(
          imageSelectionOptions.maxSize?.height,
          equals(options.imageOptions.maxHeight),
        );
        expect(
          imageSelectionOptions.quality,
          equals(options.imageOptions.imageQuality),
        );
        final GeneralOptions generalOptions =
            result.captured[1] as GeneralOptions;
        expect(
          generalOptions.limit,
          equals(options.limit),
        );
      },
    );

    test(
      'getMultiImageWithOptions passes 0 for the limit to the platform API when unspecified',
      () async {
        await plugin.getMultiImageWithOptions();
        final VerificationResult result = verify(
          mockImagePickerApi.pickImages(
            any,
            captureAny,
          ),
        );
        expect((result.captured.single as GeneralOptions).limit, equals(0));
      },
    );
  });

  test(
    'getMultiImageWithOptions throws $PlatformException on platform API error',
    () async {
      const ImagePickerError error = ImagePickerError.imageSaveFailed;
      when(mockImagePickerApi.pickImages(any, any)).thenAnswer(
        (_) async => ImagePickerErrorResult(
          error: error,
        ),
      );
      await expectLater(
        () => plugin.getMultiImageWithOptions(),
        throwsA(
          isA<PlatformException>().having(
            (PlatformException e) => e.code,
            'code',
            equals(error.code),
          ),
        ),
      );
    },
  );

  test(
    'getMultiImageWithOptions returns the file paths from the platform API',
    () async {
      for (final List<String> filePaths in <List<String>>{
        <String>[
          '/foo/bar/image.png',
          'path/to/file.jpeg',
        ],
        <String>[],
      }) {
        when(mockImagePickerApi.pickImages(any, any)).thenAnswer(
          (_) async => ImagePickerSuccessResult(
            filePaths: filePaths,
          ),
        );
        expect(
          (await plugin.getMultiImageWithOptions())
              .map((XFile file) => file.path),
          filePaths,
        );
      }
    },
  );

  group('video', () {
    test('getVideo calls delegate when source is ${ImageSource.camera.name}',
        () async {
      const String fakePath = '/tmp/foo';
      plugin.cameraDelegate = _FakeCameraDelegate(result: XFile(fakePath));
      expect(
        (await plugin.getVideo(source: ImageSource.camera))!.path,
        fakePath,
      );
    });
    test(
        'getVideo throws $StateError when source is ${ImageSource.camera.name} with no delegate',
        () async {
      plugin.cameraDelegate = null;
      await expectLater(
        plugin.getVideo(source: ImageSource.camera),
        throwsA(
          isA<StateError>().having(
            (StateError e) => e.message,
            'message',
            equals('This implementation of ImagePickerPlatform requires a '
                '"cameraDelegate" in order to use ImageSource.camera'),
          ),
        ),
      );
    });

    test('getVideo calls pickVideos from the platform API', () async {
      await plugin.getVideo(source: ImageSource.gallery);
      verify(mockImagePickerApi.pickVideos(any)).called(1);
    });

    test(
      'getVideo passes 1 for the limit to the platform API',
      () async {
        await plugin.getVideo(source: ImageSource.gallery);
        final VerificationResult result = verify(
          mockImagePickerApi.pickVideos(
            captureAny,
          ),
        );
        expect((result.captured.first as GeneralOptions).limit, equals(1));
      },
    );

    // No need to verify the arguments passed to the platform
    // API like pickImages and pickMedia since
    // pickVideos (the platform API) accepts only the limit.

    test(
      'getVideo throws $PlatformException on platform API error',
      () async {
        const ImagePickerError error = ImagePickerError.videoLoadFailed;
        when(mockImagePickerApi.pickVideos(any)).thenAnswer(
          (_) async => ImagePickerErrorResult(
            error: error,
          ),
        );
        await expectLater(
          () => plugin.getVideo(source: ImageSource.gallery),
          throwsA(
            isA<PlatformException>().having(
              (PlatformException e) => e.code,
              'code',
              equals(error.code),
            ),
          ),
        );
      },
    );

    test(
      'getVideo returns null when the platform API returns an empty result',
      () async {
        when(mockImagePickerApi.pickVideos(any)).thenAnswer(
          (_) async => ImagePickerSuccessResult(filePaths: <String>[]),
        );
        expect(
          await plugin.getVideo(source: ImageSource.gallery),
          isNull,
        );
      },
    );

    test(
      'getVideo returns the file from the platform API',
      () async {
        const String filePath = '/foo/bar';
        when(mockImagePickerApi.pickVideos(any)).thenAnswer(
          (_) async => ImagePickerSuccessResult(filePaths: <String>[filePath]),
        );
        expect(
          (await plugin.getVideo(source: ImageSource.gallery))?.path,
          equals(XFile(filePath).path),
        );
      },
    );
  });
  group('media', () {
    test('multiple media handles an empty path response gracefully', () async {
      expect(
        await plugin.getMedia(
          options: const MediaOptions(
            allowMultiple: true,
          ),
        ),
        <String>[],
      );
    });

    test('single media handles an empty path response gracefully', () async {
      expect(
        await plugin.getMedia(
          options: const MediaOptions(
            allowMultiple: false,
          ),
        ),
        <String>[],
      );
    });

    test('getMedia calls pickMedia from the platform API', () async {
      await plugin.getMedia(
        options: const MediaOptions(
          allowMultiple: true,
        ),
      );
      verify(mockImagePickerApi.pickMedia(any, any)).called(1);
    });

    test(
      'getMedia passes the arguments correctly to the platform API',
      () async {
        const MediaOptions options = MediaOptions(
          allowMultiple: true,
          imageOptions: ImageOptions(
            imageQuality: 50,
            maxHeight: 500,
            maxWidth: 250,
          ),
          limit: 4,
        );
        await plugin.getMedia(
          options: options,
        );
        final VerificationResult result = verify(
          mockImagePickerApi.pickMedia(
            captureAny,
            captureAny,
          ),
        );
        final MediaSelectionOptions mediaSelectionOptions =
            result.captured.first as MediaSelectionOptions;

        expect(
          mediaSelectionOptions.imageSelectionOptions.maxSize?.width,
          options.imageOptions.maxWidth,
        );
        expect(
          mediaSelectionOptions.imageSelectionOptions.maxSize?.height,
          options.imageOptions.maxHeight,
        );
        expect(
          mediaSelectionOptions.imageSelectionOptions.quality,
          options.imageOptions.imageQuality,
        );

        final GeneralOptions generalOptions =
            result.captured[1] as GeneralOptions;
        expect(generalOptions.limit, options.limit);
      },
    );

    test(
      'getMedia passes 0 for the limit when allowMultiple is true and limit unspecified',
      () async {
        await plugin.getMedia(
          options: const MediaOptions(allowMultiple: true),
        );
        final VerificationResult result = verify(
          mockImagePickerApi.pickMedia(
            any,
            captureAny,
          ),
        );

        expect((result.captured.single as GeneralOptions).limit, 0);
      },
    );

    test(
      'getMedia passes 1 for the limit when allowMultiple is false and limit unspecified',
      () async {
        await plugin.getMedia(
          options: const MediaOptions(allowMultiple: false),
        );
        final VerificationResult result = verify(
          mockImagePickerApi.pickMedia(
            any,
            captureAny,
          ),
        );

        expect((result.captured.single as GeneralOptions).limit, 1);
      },
    );

    test(
      'getMedia throws $PlatformException on platform API error',
      () async {
        const ImagePickerError error = ImagePickerError.imageConversionFailed;
        when(mockImagePickerApi.pickMedia(any, any)).thenAnswer(
          (_) async => ImagePickerErrorResult(
            error: error,
          ),
        );
        await expectLater(
          () => plugin.getMedia(
            options: const MediaOptions(allowMultiple: false),
          ),
          throwsA(
            isA<PlatformException>().having(
              (PlatformException e) => e.code,
              'code',
              equals(error.code),
            ),
          ),
        );
      },
    );

    test(
      'getMedia returns the file paths from the platform API',
      () async {
        for (final List<String> filePaths in <List<String>>{
          <String>[
            '/foo/bar/image.png',
            '/dev/flutter/plugins/video.mp4',
            'path/to/file.jpeg',
          ],
          <String>[],
        }) {
          when(mockImagePickerApi.pickMedia(any, any)).thenAnswer(
            (_) async => ImagePickerSuccessResult(
              filePaths: filePaths,
            ),
          );
          expect(
            (await plugin.getMedia(
              options: const MediaOptions(allowMultiple: true),
            ))
                .map((XFile file) => file.path),
            filePaths,
          );
        }
      },
    );
  });

  group('openPhotosApp', () {
    test('calls openPhotosApp from the platform API', () async {
      await plugin.openPhotosApp();
      verify(mockImagePickerApi.openPhotosApp()).called(1);
    });

    test('returns true on success', () async {
      when(mockImagePickerApi.openPhotosApp()).thenAnswer((_) => true);
      expect(await plugin.openPhotosApp(), isTrue);
    });

    test('returns false on failure', () async {
      when(mockImagePickerApi.openPhotosApp()).thenAnswer((_) => false);
      expect(await plugin.openPhotosApp(), isFalse);
    });
  });

  // Methods that are in the image_picker_platform_interface and implemented
  // for backward compatibility.
  group('backward compatibility', () {
    // getImage is soft-deprecated in the platform interface, and is only implemented
    // for compatibility. Callers should be using getImageFromSource.
    test('getImage delegates to getImageFromSource correctly', () async {
      const int imageQuality = 40;
      const double maxWidth = 400;
      const double maxHeight = 400;

      await plugin.getImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      final VerificationResult result = verify(
        mockImagePickerApi.pickImages(
          captureAny,
          any,
        ),
      );
      final ImageSelectionOptions imageSelectionOptions =
          result.captured.single as ImageSelectionOptions;

      expect(imageSelectionOptions.quality, equals(imageQuality));
      expect(imageSelectionOptions.maxSize?.width, equals(maxWidth));
      expect(imageSelectionOptions.maxSize?.height, equals(maxHeight));
    });

    // pickImage is soft-deprecated in the platform interface, and is only implemented
    // for compatibility. Callers should be using getImageFromSource.
    test('pickImage delegates to getImageFromSource correctly', () async {
      const int imageQuality = 40;
      const double maxWidth = 400;
      const double maxHeight = 400;

      await plugin.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      final VerificationResult result = verify(
        mockImagePickerApi.pickImages(
          captureAny,
          any,
        ),
      );
      final ImageSelectionOptions imageSelectionOptions =
          result.captured.single as ImageSelectionOptions;

      expect(imageSelectionOptions.quality, equals(imageQuality));
      expect(imageSelectionOptions.maxSize?.width, equals(maxWidth));
      expect(imageSelectionOptions.maxSize?.height, equals(maxHeight));
    });

    test(
      'pickImage returns null when the platform API returns an empty result',
      () async {
        when(mockImagePickerApi.pickImages(any, any)).thenAnswer(
          (_) async => ImagePickerSuccessResult(filePaths: <String>[]),
        );
        expect(
          await plugin.pickImage(
            source: ImageSource.gallery,
          ),
          isNull,
        );
      },
    );

    test(
      'pickImage returns the file from the platform API',
      () async {
        const String filePath = '/foo/bar';
        when(mockImagePickerApi.pickImages(any, any)).thenAnswer(
          (_) async => ImagePickerSuccessResult(filePaths: <String>[filePath]),
        );
        expect(
          (await plugin.pickImage(
            source: ImageSource.gallery,
          ))
              ?.path,
          filePath,
        );
      },
    );

    // getMultiImage is soft-deprecated in the platform interface, and is only implemented
    // for compatibility. Callers should be using getMultiImageWithOptions.
    test('getMultiImage delegates to getMultiImageWithOptions correctly',
        () async {
      const int imageQuality = 40;
      const double maxWidth = 400;
      const double maxHeight = 400;

      await plugin.getMultiImage(
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      final VerificationResult result = verify(
        mockImagePickerApi.pickImages(
          captureAny,
          any,
        ),
      );
      final ImageSelectionOptions imageSelectionOptions =
          result.captured.single as ImageSelectionOptions;

      expect(imageSelectionOptions.quality, equals(imageQuality));
      expect(imageSelectionOptions.maxSize?.width, equals(maxWidth));
      expect(imageSelectionOptions.maxSize?.height, equals(maxHeight));
    });

    // pickVideo is soft-deprecated in the platform interface, and is only implemented
    // for compatibility. Callers should be using getVideo.
    test('pickVideo delegates to getVideo correctly', () async {
      await plugin.pickVideo(
        source: ImageSource.gallery,
      );

      verify(
        mockImagePickerApi.pickVideos(
          captureAny,
        ),
      ).called(1);
    });

    test(
      'pickVideo returns null when the platform API returns an empty result',
      () async {
        when(mockImagePickerApi.pickVideos(any)).thenAnswer(
          (_) async => ImagePickerSuccessResult(filePaths: <String>[]),
        );
        expect(
          await plugin.pickVideo(
            source: ImageSource.gallery,
          ),
          isNull,
        );
      },
    );

    test(
      'pickVideo returns the file from the platform API',
      () async {
        const String filePath = '/foo/bar';
        when(mockImagePickerApi.pickVideos(any)).thenAnswer(
          (_) async => ImagePickerSuccessResult(filePaths: <String>[filePath]),
        );
        expect(
          (await plugin.pickVideo(
            source: ImageSource.gallery,
          ))
              ?.path,
          filePath,
        );
      },
    );
  });

  group('helpers', () {
    group('isRegistered', () {
      test(
        'returns true if the instance is $NativeImagePickerMacOS',
        () {
          NativeImagePickerMacOS.registerWith();
          expect(NativeImagePickerMacOS.isRegistered(), isTrue);
        },
      );

      test(
        'returns false if the instance is not $NativeImagePickerMacOS',
        () {
          _FakeImagePicker.registerWith();
          expect(NativeImagePickerMacOS.isRegistered(), isFalse);

          expect(ImagePickerPlatform.instance, isA<_FakeImagePicker>());
        },
      );
    });

    group('registerWithIfSupported', () {
      test(
        'returns false if the target platform is not ${TargetPlatform.macOS.name}',
        () async {
          debugDefaultTargetPlatformOverride = TargetPlatform.linux;

          try {
            expect(
              await NativeImagePickerMacOS.registerWithIfSupported(),
              isFalse,
            );
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        },
      );

      test(
        'returns false when not supported on the current macOS version',
        () async {
          debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

          try {
            when(mockImagePickerApi.supportsPHPicker())
                .thenAnswer((_) => false);
            expect(
              await NativeImagePickerMacOS.registerWithIfSupported(),
              isFalse,
            );
            verify(mockImagePickerApi.supportsPHPicker()).called(1);
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        },
      );

      test(
        'returns true when supported on the current macOS version',
        () async {
          debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

          try {
            when(mockImagePickerApi.supportsPHPicker()).thenAnswer((_) => true);
            expect(
              await NativeImagePickerMacOS.registerWithIfSupported(),
              isTrue,
            );
            verify(mockImagePickerApi.supportsPHPicker()).called(1);
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        },
      );
    });

    group('isSupported', () {
      test(
        'returns false if the target platform is not ${TargetPlatform.macOS.name}',
        () async {
          debugDefaultTargetPlatformOverride = TargetPlatform.linux;

          try {
            expect(
              await NativeImagePickerMacOS.isSupported(),
              isFalse,
            );
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        },
      );

      test(
        'returns false when not supported on the current macOS version',
        () async {
          debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

          try {
            when(mockImagePickerApi.supportsPHPicker())
                .thenAnswer((_) => false);
            expect(
              await NativeImagePickerMacOS.isSupported(),
              isFalse,
            );
            verify(mockImagePickerApi.supportsPHPicker()).called(1);
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        },
      );

      test(
        'returns true when supported on the current macOS version',
        () async {
          debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

          try {
            when(mockImagePickerApi.supportsPHPicker()).thenAnswer((_) => true);
            expect(
              await NativeImagePickerMacOS.isSupported(),
              isTrue,
            );
            verify(mockImagePickerApi.supportsPHPicker()).called(1);
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        },
      );
    });

    group('instanceOrNull', () {
      test(
        'returns null if the current instance is not $NativeImagePickerMacOS',
        () {
          ImagePickerPlatform.instance = _FakeImagePicker();
          expect(NativeImagePickerMacOS.instanceOrNull, isNull);
        },
      );

      test(
        'returns $NativeImagePickerMacOS if the current instance is $NativeImagePickerMacOS',
        () {
          ImagePickerPlatform.instance = NativeImagePickerMacOS();
          expect(NativeImagePickerMacOS.instanceOrNull, isNotNull);
        },
      );
    });

    group('instanceOrThrow', () {
      test(
        'throws $StateError if the current instance is not $NativeImagePickerMacOS',
        () {
          ImagePickerPlatform.instance = _FakeImagePicker();
          expect(
            () => NativeImagePickerMacOS.instanceOrThrow,
            throwsStateError,
          );
        },
      );

      test(
        'returns $NativeImagePickerMacOS if the current instance is $NativeImagePickerMacOS',
        () {
          ImagePickerPlatform.instance = NativeImagePickerMacOS();
          expect(NativeImagePickerMacOS.instanceOrThrow, isNotNull);
        },
      );
    });
  });
}

class _FakeCameraDelegate extends ImagePickerCameraDelegate {
  _FakeCameraDelegate({this.result});

  XFile? result;

  @override
  Future<XFile?> takePhoto({
    ImagePickerCameraDelegateOptions options =
        const ImagePickerCameraDelegateOptions(),
  }) async =>
      result;

  @override
  Future<XFile?> takeVideo({
    ImagePickerCameraDelegateOptions options =
        const ImagePickerCameraDelegateOptions(),
  }) async =>
      result;
}

class _FakeImagePicker extends ImagePickerPlatform {
  static void registerWith() {
    ImagePickerPlatform.instance = _FakeImagePicker();
  }
}
