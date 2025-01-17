import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_macos/image_picker_macos.dart';
import 'package:native_image_picker_macos/native_image_picker_macos.dart';
import 'package:video_player/video_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NativeImagePickerMacOS.registerWithIfSupported();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(64.0),
            child: SingleChildScrollView(child: Buttons()),
          ),
        ),
      ),
    );
  }
}

class Buttons extends StatefulWidget {
  const Buttons({super.key});

  @override
  State<Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> {
  late bool _useMacOSNativePicker;
  late Future<bool> _macOSNativePickerSupportedFuture;

  final imagePicker = ImagePicker();

  final TextEditingController _imageMaxWidthController =
      TextEditingController();
  final TextEditingController _imageMaxHeightController =
      TextEditingController();

  final TextEditingController _imageQualityController = TextEditingController();

  final _mediaFiles = <XFile>[];

  @override
  void initState() {
    super.initState();

    _useMacOSNativePicker = NativeImagePickerMacOS.isRegistered();
    _macOSNativePickerSupportedFuture = NativeImagePickerMacOS.isSupported();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 12,
      children: [
        Form(
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            spacing: 8,
            children: [
              ElevatedButton.icon(
                label: Text('Open Photos App'),
                icon: Icon(Icons.photo_album),
                // TODO: Not exactly a good practice.
                onPressed: () => NativeImagePickerMacOS().openPhotosApp(),
              ),
              TextFormField(
                controller: _imageMaxWidthController,
                decoration: InputDecoration(labelText: 'Image Max Width'),
                textInputAction: TextInputAction.next,
                validator: validateNumber,
              ),
              TextFormField(
                controller: _imageMaxHeightController,
                decoration: InputDecoration(labelText: 'Image Max Height'),
                textInputAction: TextInputAction.next,
                validator: validateNumber,
              ),
              TextFormField(
                controller: _imageQualityController,
                decoration: InputDecoration(labelText: 'Image Quality'),
                textInputAction: TextInputAction.next,
                validator: validateNumber,
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.photo),
          label: Text('Pick Image'),
          onPressed: () async {
            final imageFile = await imagePicker.pickImage(
              source: ImageSource.gallery,
              imageQuality: int.tryParse(_imageQualityController.text) ?? 100,
              maxWidth: double.tryParse(_imageMaxWidthController.text),
              maxHeight: double.tryParse(_imageMaxHeightController.text),
            );
            _setMediaFileListFromFile(imageFile);
          },
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.photo_library),
          label: Text('Pick Images'),
          onPressed: () async {
            final imageFiles = await imagePicker.pickMultiImage(
              imageQuality: int.tryParse(_imageQualityController.text) ?? 100,
              maxWidth: double.tryParse(_imageMaxWidthController.text),
              maxHeight: double.tryParse(_imageMaxHeightController.text),
            );
            _setMediaFileListFromFiles(imageFiles);
          },
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.movie),
          label: Text('Pick Video'),
          onPressed: () async {
            final videoFile = await imagePicker.pickVideo(
              source: ImageSource.gallery,
            );
            _setMediaFileListFromFile(videoFile);
          },
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.perm_media),
          label: Text('Pick Media'),
          onPressed: () async {
            final mediaFiles = await imagePicker.pickMultipleMedia(
              imageQuality: int.tryParse(_imageQualityController.text) ?? 100,
              maxWidth: double.tryParse(_imageMaxWidthController.text),
              maxHeight: double.tryParse(_imageMaxHeightController.text),
            );
            _setMediaFileListFromFiles(mediaFiles);
          },
        ),
        FutureBuilder(
          future: _macOSNativePickerSupportedFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator.adaptive();
            }
            if (snapshot.hasError) {
              return Text(
                'Error while checking whether the native macOS picker is supported: ${snapshot.error.toString()}',
              );
            }
            final bool nativeMacOSPickerSupported = snapshot.requireData;
            if (nativeMacOSPickerSupported) {
              return SwitchListTile.adaptive(
                title: Text('Use native macOS picker'),
                value: _useMacOSNativePicker,
                onChanged: (bool value) {
                  if (value) {
                    NativeImagePickerMacOS.registerWith();
                  } else {
                    ImagePickerMacOS.registerWith();
                  }
                  setState(() => _useMacOSNativePicker = value);
                },
              );
            } else {
              return Text(
                  'The current macOS version does not supports PHPicker.');
            }
          },
        ),
        ..._mediaFiles.nonNulls.map(
          (e) => isImage(e.path)
              ? Image.file(File(e.path))
              : _buildInlineVideoPlayer(e.path),
        )
      ],
    );
  }

  void _setMediaFileListFromFile(XFile? file) {
    setState(() {
      _mediaFiles.clear();
      if (file != null) {
        _mediaFiles.add(file);
      }
    });
  }

  void _setMediaFileListFromFiles(List<XFile> files) {
    setState(() {
      _mediaFiles.clear();
      _mediaFiles.addAll(files);
    });
  }

  Widget _buildInlineVideoPlayer(String videoFilePath) {
    final VideoPlayerController controller =
        VideoPlayerController.file(File(videoFilePath));
    const double volume = 1.0;
    controller.setVolume(volume);
    controller.initialize();
    controller.setLooping(true);
    controller.play();
    return Center(child: AspectRatioVideo(controller));
  }

  String? validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return int.tryParse(value) == null ? 'Invalid number.' : null;
  }

  bool isImage(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    return {'jpg', 'jpeg', 'png', 'gif', 'bmp'}.contains(ext);
  }

  @override
  void dispose() {
    _imageMaxWidthController.dispose();
    _imageMaxHeightController.dispose();
    _imageQualityController.dispose();
    super.dispose();
  }
}

class AspectRatioVideo extends StatefulWidget {
  const AspectRatioVideo(this.controller, {super.key});

  final VideoPlayerController? controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController? get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller!.value.isInitialized) {
      initialized = controller!.value.isInitialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller!.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller!.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller!),
        ),
      );
    } else {
      return CircularProgressIndicator.adaptive();
    }
  }
}
