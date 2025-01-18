import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:native_image_picker_macos/native_image_picker_macos.dart';
import 'package:native_image_picker_macos_example/main.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

@GenerateNiceMocks([
  MockSpec<NativeImagePickerMacOS>(as: Symbol('BaseMockNativeImagePickerMacOS'))
])
import 'main_test.mocks.dart';

// Add the mixin to make the platform interface accept the mock.
// For more details, refer to https://pub.dev/packages/plugin_platform_interface#mocking-or-faking-platform-interfaces
class MockNativeImagePickerMacOS extends BaseMockNativeImagePickerMacOS
    with MockPlatformInterfaceMixin {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockNativeImagePickerMacOS mockNativeImagePickerMacOS;

  setUp(() {
    mockNativeImagePickerMacOS = MockNativeImagePickerMacOS();

    ImagePickerPlatform.instance = mockNativeImagePickerMacOS;
  });

  testWidgets(
    'pressing the open photos button calls openPhotosApp from $NativeImagePickerMacOS',
    (WidgetTester tester) async {
      when(mockNativeImagePickerMacOS.openPhotosApp())
          .thenAnswer((_) async => true);

      await tester.pumpWidget(const MainApp());

      final openPhotosFinder = find.text('Open Photos App');

      expect(openPhotosFinder, findsOneWidget);

      await tester.tap(openPhotosFinder);
      await tester.pump();

      verify(mockNativeImagePickerMacOS.openPhotosApp()).called(1);
      verifyNoMoreInteractions(mockNativeImagePickerMacOS);
    },
  );
}
