import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Enum for default available phone cameras.
enum Cameras { back, front }

class StoryCamera extends StatefulWidget {
  final Function(XFile)? onImageCaptured;
  final Function(XFile)? onVideoRecorded;
  final Function()? onClosePressed;

  /// Optional parameters
  final Color iconsColor;
  final Color recordingIconColor;

  const StoryCamera(
      {super.key,
      this.onImageCaptured,
      this.onVideoRecorded,
      this.onClosePressed,
      this.iconsColor = Colors.white,
      this.recordingIconColor = Colors.red});

  @override
  State<StoryCamera> createState() => _StoryCameraState();
}

class _StoryCameraState extends State<StoryCamera> {
  List<CameraDescription>? _cameras;

  CameraController? _controller;

  bool flashState = false;
  bool isStartVideo = false;
  bool isFrontCamera = false;

  @override
  void initState() {
    super.initState();

    initCamera().then((_) {
      /// Initialize camera and choose the back camera as the initial camera in use.
      _controller = CameraController(_cameras![0], ResolutionPreset.max);
      _controller!.initialize().then((_) {
        setState(() {});
      });
    });
  }

  @override
  dispose() {
    super.dispose();

    _controller?.dispose();
  }

  Future initCamera() async {
    _cameras = await availableCameras();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
            child: Container(
                decoration: (isStartVideo)
                    ? BoxDecoration(
                        border: Border.all(color: widget.recordingIconColor))
                    : null,
                child: CameraPreview(_controller!,
                    child: Container(
                        margin: const EdgeInsets.all(15),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                        onPressed: widget.onClosePressed,
                                        icon: Icon(Icons.close,
                                            color: widget.iconsColor,
                                            size: 25)),
                                    IconButton(
                                        onPressed: () {
                                          if (!flashState) {
                                            flashState = true;
                                            _setFlashMode(FlashMode.torch);
                                          } else {
                                            flashState = false;
                                            _setFlashMode(FlashMode.off);
                                          }

                                          setState(() {});
                                        },
                                        icon: Icon(
                                            (!flashState)
                                                ? Icons.flash_off
                                                : Icons.flash_on,
                                            color: widget.iconsColor,
                                            size: 25))
                                  ]),
                              Expanded(child: Container()),
                              _bottomCameraOptions()
                            ]))))));
  }

  /// Method that button actions (take photo, record video and flip camera) are content.
  Widget _bottomCameraOptions() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(
          onPressed: _controller!.value.isInitialized
              ? (!isStartVideo)
                  ? _onVideoRecordButtonPressed
                  : _onStopButtonPressed
              : null,
          icon: Icon(
              (isStartVideo) ? Icons.fiber_manual_record : Icons.videocam,
              color: (isStartVideo)
                  ? widget.recordingIconColor
                  : widget.iconsColor,
              size: 25)),
      IconButton(
          onPressed: _controller!.value.isInitialized
              ? _onTakePictureButtonPressed
              : null,
          icon:
              Icon(Icons.camera_alt_sharp, color: widget.iconsColor, size: 25)),
      IconButton(
          onPressed: () {
            _onNewCameraSelected(
                (!isFrontCamera) ? Cameras.front : Cameras.back);
          },
          icon: Icon(Icons.flip_camera_android,
              color: widget.iconsColor, size: 25))
    ]);
  }

  /// Method that enable or disable camera flash lighting.
  Future<void> _setFlashMode(FlashMode mode) async {
    try {
      await _controller!.setFlashMode(mode);
    } on CameraException catch (_) {
      return;
    }
  }

  /// Action after pressing the video button to start recording.
  void _onVideoRecordButtonPressed() {
    _startVideoRecording().then((_) {
      setState(() {});
    });
  }

  /// Method that allow start to recording when press video button.
  Future<void> _startVideoRecording() async {
    final CameraController cameraController = _controller!;

    if (cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.startVideoRecording();

      setState(() {
        isStartVideo = true;
      });
    } on CameraException catch (_) {
      return;
    }
  }

  /// Action after pressing the video button to stop recording.
  void _onStopButtonPressed() {
    _stopVideoRecording().then((file) {
      // Navigator.pop(context);
      widget.onVideoRecorded!(file!);
    });
  }

  /// Method that allow stop to recording when press video button.
  Future<XFile?> _stopVideoRecording() async {
    final CameraController cameraController = _controller!;

    try {
      setState(() {
        isStartVideo = false;
      });

      return cameraController.stopVideoRecording();
    } on CameraException catch (_) {
      return null;
    }
  }

  /// Action after pressing the photo button to take picture.
  void _onTakePictureButtonPressed() {
    _takePicture().then((file) {
      // Navigator.pop(context);
      widget.onImageCaptured!(file!);
    });
  }

  /// Method that allow capture picture when press camera button.
  Future<XFile?> _takePicture() async {
    final CameraController cameraController = _controller!;

    if (cameraController.value.isTakingPicture) {
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (_) {
      return null;
    }
  }

  /// Method that allow choose which camera you prefer, front or back camera.
  Future<void> _onNewCameraSelected(Cameras type) async {
    switch (type) {
      case Cameras.back:
        setState(() => isFrontCamera = false);
        return _controller!.setDescription(_cameras![0]);
      case Cameras.front:
        setState(() => isFrontCamera = true);
        return _controller!.setDescription(_cameras![1]);
    }
  }
}
