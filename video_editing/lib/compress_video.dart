import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_editor/domain/bloc/controller.dart';
import 'package:video_editor/ui/crop/crop_grid.dart';
//import 'package:video_editor/video_editor.dart';

class CompressVideo extends StatefulWidget {
  //const CompressVideo({Key? key}) : super(key: key);
  File compressFile;
  File file;
  CompressVideo({Key? key, required this.compressFile, required this.file}) : super(key: key);

  @override
  _CompressVideoState createState() => _CompressVideoState();
}

class _CompressVideoState extends State<CompressVideo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.file.toString().isNotEmpty ? Text('Original video size: ${widget.file.lengthSync()} KB') : const Text('0'),
            widget.compressFile.toString().isNotEmpty ? Text('Compress video size: ${widget.compressFile.lengthSync()} KB') : const Text('0'),
            SizedBox(height: 10,),
            Text('Original path: ${widget.file.path}'),
            SizedBox(height: 10,),
            Text('Compress path: ${widget.compressFile.path}'),
          ],
        ),
      ),
    );
  }
}
