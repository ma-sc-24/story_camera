import 'dart:io';

import 'package:flutter/material.dart';
import 'package:story_camera/story_camera.dart';

void main() => runApp(MyApp());

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  File? file;

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StoryCamera(
      onImageCaptured: (value) {
        file = File(value.path);
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => FileContent(file: file!)));
      },
      onVideoRecorded: (value) {
        file = File(value.path);

        // Use your favorite video player to display it.
      },
      // onClosePressed: () => Navigator.pop(context),
    );
  }
}

class FileContent extends StatelessWidget {
  final File file;

  const FileContent({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Image.file(file));
  }
}
