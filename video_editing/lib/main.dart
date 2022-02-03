/*

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:helpers/helpers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        textTheme: TextTheme(
          bodyText1: TextStyle(),
          bodyText2: TextStyle(),
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: VideoPickerPage(),
    );
  }
}

//PICKUP VIDEO SCREEN//

class VideoPickerPage extends StatefulWidget {
  @override
  _VideoPickerPageState createState() => _VideoPickerPageState();
}

class _VideoPickerPageState extends State<VideoPickerPage> {
  final ImagePicker _picker = ImagePicker();

  void _pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) context.to(VideoEditor(file: File(file.path)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.blue, title: Text("Image / Video Picker")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextDesigned(
              "Click on Pick Video to select video",
              color: Colors.black,
              size: 18.0,
            ),
            ElevatedButton(
              onPressed: _pickVideo,
              child: Text("Pick Video From Gallery"),
            ),
          ],
        ),
      ),
    );
  }
}

//VIDEO EDITOR SCREEN//

class VideoEditor extends StatefulWidget {
  VideoEditor({Key? key, required this.file}) : super(key: key);

  final File file;

  @override
  _VideoEditorState createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  bool _exported = false;
  String _exportText = "";
  late VideoEditorController _controller;

  @override
  void initState() {
    _controller = VideoEditorController.file(widget.file,
        maxDuration: Duration(seconds: 30))
      ..initialize().then((_) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _openCropScreen() => context.to(CropScreen(controller: _controller));

  void _exportVideo() async {
    _isExporting.value = true;
    bool _firstStat = true;
    //NOTE: To use [-crf 17] and [VideoExportPreset] you need ["min-gpl-lts"] package
    final File? file= await _controller.exportVideo(
      // preset: VideoExportPreset.medium,
      // customInstruction: "-crf 17",
      onProgress: (statics) {
        // First statistics is always wrong so if first one skip it
        if (_firstStat) {
          _firstStat = false;
        } else {
          _exportingProgress.value = statics.time/
              _controller.video.value.duration.inMilliseconds;
        }
      },
      //onCompleted: (file) {

     // },
    );
    _isExporting.value = false;
    if (!mounted) return;
    if (file != null) {
      final VideoPlayerController _videoController =
      VideoPlayerController.file(file);
      _videoController.initialize().then((value) async {
        setState(() {});
        _videoController.play();
        _videoController.setLooping(true);
        await showModalBottomSheet(
          context: context,
          backgroundColor: Colors.black54,
          builder: (_) => AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: VideoPlayer(_videoController),
          ),
        );
        await _videoController.pause();
        _videoController.dispose();
      });
      print("file: ${file.path}");
      GallerySaver.saveVideo(file.path,
          albumName: "OTWPhotoEditingDemo");
      _exportText = "Video success export!";
    } else {
      _exportText = "Error on export video :(";
    }

    setState(() => _exported = true);
    Misc.delayed(2000, () => setState(() => _exported = false));
  }

  void _exportCover() async {
    setState(() => _exported = false);
    final File? cover = await _controller.extractCover();
      //onCompleted: (cover) {
        if (!mounted) return;

        if (cover != null) {
          _exportText = "Cover exported! ${cover.path}";
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.black54,
            builder: (BuildContext context) =>
                Image.memory(cover.readAsBytesSync()),
          );
          GallerySaver.saveImage(cover.path,
              albumName: "OTWPhotoEditingDemo");
        } else
          _exportText = "Error on cover exportation :(";

        setState(() => _exported = true);
        Misc.delayed(2000, () => setState(() => _exported = false));
     // },

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller.initialized
          ? SafeArea(
          child: Stack(children: [
            Column(children: [
              _topNavBar(),
              Expanded(
                  child: DefaultTabController(
                      length: 2,
                      child: Column(children: [
                        Expanded(
                            child: TabBarView(
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                Stack(alignment: Alignment.center, children: [
                                  CropGridViewer(
                                    controller: _controller,
                                    showGrid: false,
                                  ),
                                  AnimatedBuilder(
                                    animation: _controller.video,
                                    builder: (_, __) => OpacityTransition(
                                      visible: !_controller.isPlaying,
                                      child: GestureDetector(
                                        onTap: _controller.video.play,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.play_arrow,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                                CoverViewer(controller: _controller)
                              ],
                            )),
                        Container(
                            height: 200,
                            margin: Margin.top(10),
                            child: Column(children: [
                              TabBar(
                                indicatorColor: Colors.white,
                                tabs: [
                                  Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                            padding: Margin.all(5),
                                            child: Icon(Icons.content_cut)),
                                        Text('Trim')
                                      ]),
                                  Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                            padding: Margin.all(5),
                                            child: Icon(Icons.video_label)),
                                        Text('Cover')
                                      ]),
                                ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    Container(
                                        child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: _trimSlider())),
                                    Container(
                                      child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [_coverSelection()]),
                                    ),
                                  ],
                                ),
                              )
                            ])),
                        _customSnackBar(),
                        ValueListenableBuilder(
                          valueListenable: _isExporting,
                          builder: (_, bool export, __) => OpacityTransition(
                            visible: export,
                            child: AlertDialog(
                              backgroundColor: Colors.white,
                              title: ValueListenableBuilder(
                                valueListenable: _exportingProgress,
                                builder: (_, double value, __) =>
                                    TextDesigned(
                                      "Exporting video ${(value * 100).ceil()}%",
                                      color: Colors.black,
                                      bold: true,
                                    ),
                              ),
                            ),
                          ),
                        )
                      ])))
            ])
          ]))
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _topNavBar() {
    return SafeArea(
      child: Container(
        height: height,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _controller.rotate90Degrees(RotateDirection.left),
                child: Icon(Icons.rotate_left),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _controller.rotate90Degrees(RotateDirection.right),
                child: Icon(Icons.rotate_right),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _openCropScreen,
                child: Icon(Icons.crop),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _exportCover,
                child: Icon(Icons.save_alt, color: Colors.white),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _exportVideo,
                child: Icon(Icons.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
    duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
    duration.inSeconds.remainder(60).toString().padLeft(2, '0')
  ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: _controller.video,
        builder: (_, __) {
          final duration = _controller.video.value.duration.inSeconds;
          final pos = _controller.trimPosition * duration;
          final start = _controller.minTrim * duration;
          final end = _controller.maxTrim * duration;

          return Padding(
            padding: Margin.horizontal(height / 4),
            child: Row(children: [
              TextDesigned(formatter(Duration(seconds: pos.toInt()))),
              Expanded(child: SizedBox()),
              OpacityTransition(
                visible: _controller.isTrimming,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  TextDesigned(formatter(Duration(seconds: start.toInt()))),
                  SizedBox(width: 10),
                  TextDesigned(formatter(Duration(seconds: end.toInt()))),
                ]),
              )
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: Margin.vertical(height / 4),
        child: TrimSlider(
            child: TrimTimeline(
                controller: _controller, margin: EdgeInsets.only(top: 10)),
            controller: _controller,
            height: height,
            horizontalMargin: height / 4),
      )
    ];
  }

  Widget _coverSelection() {
    return Container(
        margin: Margin.horizontal(height / 4),
        child: CoverSelection(
          controller: _controller,
          height: height,
          nbSelection: 8,
        ));
  }

  Widget _customSnackBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SwipeTransition(
        visible: _exported,
        //direction: SwipeDirection.fromBottom,
        child: Container(
          height: height,
          width: double.infinity,
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: TextDesigned(
              _exportText,
              bold: true,
            ),
          ),
        ),
      ),
    );
  }
}


//CROP VIDEO SCREEN//

class CropScreen extends StatelessWidget {
  CropScreen({Key? key, required this.controller}) : super(key: key);

  final VideoEditorController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: Margin.all(30),
          child: Column(children: [
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.rotate90Degrees(RotateDirection.left),
                  child: Icon(Icons.rotate_left),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      controller.rotate90Degrees(RotateDirection.right),
                  child: Icon(Icons.rotate_right),
                ),
              )
            ]),
            SizedBox(height: 15),
            Expanded(
              child: AnimatedInteractiveViewer(
                maxScale: 2.4,
                child: CropGridViewer(
                    controller: controller),
              ),
            ),
            SizedBox(height: 15),
            Row(children: [
              Expanded(
                child: SplashTap(
                  onTap: context.goBack,
                  child: Center(
                    child: TextDesigned(
                      "CANCEL",
                      bold: true,
                    ),
                  ),
                ),
              ),
              buildSplashTap("16:9", 16 / 9, padding: Margin.horizontal(10)),
              buildSplashTap("1:1", 1 / 1),
              buildSplashTap("4:5", 4 / 5, padding: Margin.horizontal(10)),
              buildSplashTap("NO", null, padding: Margin.right(10)),
              Expanded(
                child: SplashTap(
                  onTap: () {
                    //2 WAYS TO UPDATE CROP
                    //WAY 1:
                    controller.updateCrop();
                    context.goBack();
                  },
                  child: Center(
                    child: TextDesigned("OK", bold: true),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget buildSplashTap(
      String title,
      double? aspectRatio, {
        EdgeInsetsGeometry? padding,
      }) {
    return SplashTap(
      onTap: () => controller.preferredCropAspectRatio = aspectRatio,
      child: Padding(
        padding: padding ?? Margin.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.aspect_ratio, color: Colors.white),
            TextDesigned(title, bold: true),
          ],
        ),
      ),
    );
  }
}*/


import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:helpers/helpers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_editing/add_music.dart';
import 'package:video_editing/compress_video.dart';
import 'package:video_editing/video_file_screen.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';
import 'package:video_compress/video_compress.dart';
import 'package:file_selector/file_selector.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        textTheme: TextTheme(
          bodyText1: TextStyle(),
          bodyText2: TextStyle(),
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: VideoPickerPage(),
    );
  }
}

//-------------------//
//PICKUP VIDEO SCREEN//
//-------------------//
class VideoPickerPage extends StatefulWidget {
  @override
  _VideoPickerPageState createState() => _VideoPickerPageState();
}

class _VideoPickerPageState extends State<VideoPickerPage> {
  final ImagePicker _picker = ImagePicker();
  var file;
  String _counter = "video";
  File? compressFile;

  List<ImageFileItem> imageFileList = <ImageFileItem>[];

  final ImagePicker imagePicker = ImagePicker();

  void _pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    //var images = await ExportVideoFrame.exportImage(file!.path, 10, 0);
    if (file != null) context.to(VideoEditor(file: File(file.path)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.blue, title: Text("Image / Video Picker")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickVideo,
              child: Text("Pick Video From Gallery"),
            ),

            ElevatedButton(
              onPressed: () {
                _compressVideo().then((value) {

                  //context.to(CompressVideo(compressFile: compressFile!, file: file,));
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  CompressVideo(compressFile: compressFile!, file: file,)),
                  );
                });
              },
              child: Text('Compress Video From Gallery'),
            ),

            ElevatedButton(
              onPressed: () {
                _compressVideo1().then((value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  CompressVideo(compressFile: compressFile!, file: file,)),
                  );
                });
              },
              child: Text('Compress Video From Camera'),
            ),

            ElevatedButton(
              onPressed: () {
                selectImages();
              },
              child: Text('Create Video Using Multiple Images'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMusic()),
                );
              },
              child: Text('Add music'),
            ),
          ],
        ),
      ),
    );
  }

  Future _compressVideo() async {

    if (Platform.isMacOS) {
      final typeGroup = XTypeGroup(label: 'videos', extensions: ['mov', 'mp4']);
      file = await openFile(acceptedTypeGroups: [typeGroup]);
    } else {
      final picker = ImagePicker();
      PickedFile? pickedFile = await picker.getVideo(source: ImageSource.gallery);
      file = File(pickedFile!.path);
    }
    if (file == null) {
      return;
    }
    await VideoCompress.setLogLevel(0);
    Fluttertoast.showToast(
        msg: "Compressing Video Please wait",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 10,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
    final MediaInfo? info = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
      includeAudio: true,
    );
    print(info!.path);
    if (info != null) {
      setState(() {
        _counter = info.path!;
        compressFile = File(_counter);
      });

    }
    GallerySaver.saveVideo(compressFile!.path,
        albumName: "OTWPhotoEditingDemo");

  }

  Future _compressVideo1() async {

    if (Platform.isMacOS) {
      final typeGroup = XTypeGroup(label: 'videos', extensions: ['mov', 'mp4']);
      file = await openFile(acceptedTypeGroups: [typeGroup]);
    } else {
      final picker = ImagePicker();
      PickedFile? pickedFile = await picker.getVideo(source: ImageSource.camera);
      file = File(pickedFile!.path);
    }
    if (file == null) {
      return;
    }
    await VideoCompress.setLogLevel(0);
    Fluttertoast.showToast(
        msg: "Compressing Video Please wait",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 10,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
    final MediaInfo? info = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
      includeAudio: true,
    );
    print(info!.path);
    if (info != null) {
      setState(() {
        _counter = info.path!;
        compressFile = File(_counter);
      });

    }
    GallerySaver.saveVideo(compressFile!.path,
        albumName: "OTWPhotoEditingDemo");
  }

  void selectImages() async {
    final List<XFile>? selectedImages = await imagePicker.pickMultiImage();
    // print('${selectedImages!.length}');
    try{
      if(selectedImages!.isEmpty){
      } else if(selectedImages.length == 1 ){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Please Select Minimum 2 images"),
        ));
      } else if(selectedImages.length >= 2 && selectedImages.length <= 10){
        setState(() {
          imageFileList.clear();
          for(int i =0; i< selectedImages.length; i++){
            imageFileList.add(ImageFileItem(file: selectedImages[i]));
          }
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VideoFileScreen(imageFileList: imageFileList,)),
        );
        //Get.to(()=> CollageScreen());
      } else if(selectedImages.length >= 11 ){

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Please Select Maximum 10 images"),
        ));
        // Get.snackbar("Please select minimum 2 image", "", snackPosition: SnackPosition.BOTTOM, );
      }
    } catch(e) {
      print('Error : $e');
    }

    print('Images List Length : ${imageFileList.length}');
  }
}

class ImageFileItem {
  XFile file;

  ImageFileItem({required this.file});
}

//-------------------//
//VIDEO EDITOR SCREEN//
//-------------------//
class VideoEditor extends StatefulWidget {
  VideoEditor({Key? key, required this.file}) : super(key: key);

  final File file;

  @override
  _VideoEditorState createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> with TickerProviderStateMixin {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  bool _exported = false;
  String _exportText = "";
  late VideoEditorController _controller;
  final ImagePicker imagePicker = ImagePicker();
  File? file;
  File? compressFile;
  bool isplaying = false;

  late AnimationController _animationIconController1;

  AudioCache ? audioCache;

  late AudioPlayer audioPlayer;

  Duration _duration = new Duration();
  Duration _position = new Duration();

  bool issongplaying = false;

  void seekToSeconds(int second) {
    Duration newDuration = Duration(seconds: second);
    audioPlayer.seek(newDuration);
  }

  void initPlayer() {
    _animationIconController1 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 750),
      reverseDuration: Duration(milliseconds: 750),
    );
    audioPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: audioPlayer);
    // audioPlayer.getDuration().then((d) {
    //   setState(() {
    //     _duration = Duration(milliseconds: d);
    //   });
    // });
    // audioPlayer.getCurrentPosition().then((p) {
    //   setState(() {
    //     _position = Duration(minutes: p);
    //   });
    // });
    // audioPlayer.durationHandler = (d) => setState(() {
    //       _duration = d;
    //     });
    // audioPlayer.positionHandler = (p) => setState(() {
    //       _position = p;
    //     });
  }

  @override
  void initState() {
    _controller = VideoEditorController.file(widget.file,
        maxDuration: Duration(seconds: 30))
      ..initialize().then((_) => setState(() {}));
    iconController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));

    audioPlayer1.open(Audio('assets/Song1.mp3'),autoStart: false,showNotification: true);
    //initPlayer();
    super.initState();
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();

    iconController.dispose();
    audioPlayer1.dispose();
    super.dispose();
  }

  late AnimationController
  iconController;
  AssetsAudioPlayer audioPlayer1 = AssetsAudioPlayer();
  bool isAnimated = false;

  void _openCropScreen() => context.to(CropScreen(controller: _controller));

  void _exportVideo() async {
    _isExporting.value = true;
    bool _firstStat = true;
    //NOTE: To use [-crf 17] and [VideoExportPreset] you need ["min-gpl-lts"] package
    await _controller.exportVideo(
      // preset: VideoExportPreset.medium,
      // customInstruction: "-crf 17",
      onProgress: (statics) {
        // First statistics is always wrong so if first one skip it
        if (_firstStat) {
          _firstStat = false;
        } else {
          _exportingProgress.value = statics.getTime() /
              _controller.video.value.duration.inMilliseconds;
        }
      },
      onCompleted: (file) {
        _isExporting.value = false;
        if (!mounted) return;
        if (file != null) {
          final VideoPlayerController _videoController =
          VideoPlayerController.file(file);
          _videoController.initialize().then((value) async {
            setState(() {});
             //_videoController.setVolume(0);
            _videoController.play();
            _videoController.setLooping(true);
            await showModalBottomSheet(
              context: context,
              backgroundColor: Colors.black54,
              builder: (_) => AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: VideoPlayer(_videoController),
              ),
            );
            await _videoController.pause();
            _videoController.dispose();
          });
          GallerySaver.saveVideo(file.path,
              albumName: "OTWPhotoEditingDemo");
          _exportText = "Video success export!";
        } else {
          _exportText = "Error on export video :(";
        }

        setState(() => _exported = true);
        Misc.delayed(2000, () => setState(() => _exported = false));
      },
    );
  }

  void _exportCover() async {
    setState(() => _exported = false);
    await _controller.extractCover(
      onCompleted: (cover) {
        if (!mounted) return;

        if (cover != null) {
          _exportText = "Cover exported! ${cover.path}";
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.black54,
            builder: (BuildContext context) =>
                Image.memory(cover.readAsBytesSync()),
          );
          GallerySaver.saveImage(cover.path,
              albumName: "OTWPhotoEditingDemo");
        } else
          _exportText = "Error on cover exportation :(";

        setState(() => _exported = true);
        Misc.delayed(2000, () => setState(() => _exported = false));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller.initialized
          ? SafeArea(
          child: Stack(children: [
            Column(children: [
              _topNavBar(),
              Expanded(
                  child: DefaultTabController(
                      length: 2,
                      child: Column(children: [
                        Expanded(
                            child: TabBarView(
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                Stack(alignment: Alignment.center,
                                    children: [
                                  Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CropGridViewer(
                                        controller: _controller,
                                        showGrid: false,
                                      ),

                                      Positioned(
                                        bottom: 5,
                                          child: file != null ? Image.file(file!,
                                            height: 50,
                                            width: MediaQuery.of(context).size.width,) : Container())
                                      // Positioned(
                                      //     bottom: 5,
                                      //       child: Text("WaterMark"))
                                    ],
                                  ),

                                  AnimatedBuilder(
                                    animation: _controller.video,
                                    builder: (_, __) => OpacityTransition(
                                      visible: !_controller.isPlaying,
                                      child: GestureDetector(
                                        //onTap: _controller.video.play,
                                        //onTap: ()=> _controller.video.play,
                                        onTap: () async {

                                          _controller.video.play();

                                          // setState(() {
                                          //   isplaying ? _animationIconController1.reverse() : _animationIconController1.forward();
                                          //   isplaying = !isplaying;
                                          //   print('isplaying : $isplaying');
                                          // });
                                          // if (issongplaying == false) {
                                          //   // audioCache!.play("Song1.mp3");
                                          //   audioPlayer.play('song1.mp3');
                                          //   setState(() {
                                          //     issongplaying = true;
                                          //     print('issongplaying1 : $issongplaying');
                                          //   });
                                          // } else {
                                          //   await Future.delayed(Duration(seconds: 1));
                                          //   await audioPlayer.pause();
                                          //   setState(() {
                                          //     issongplaying = false;
                                          //     print('issongplaying2 : $issongplaying');
                                          //   });
                                          // }

                                          /*setState(() {
                                            isAnimated = !isAnimated;

                                            if(isAnimated)
                                            {
                                              print('print: $isAnimated');
                                              _controller.video.play();
                                              iconController.forward();
                                              audioPlayer1.play();
                                            }else{
                                              print('print1: $isAnimated');
                                             // _controller.video.pause();
                                              iconController.reverse();
                                              audioPlayer1.pause();
                                            }


                                          });*/
                                        },
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.play_arrow,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                                ),
                                //Container()
                                CoverViewer(controller: _controller)
                              ],
                            )),
                        Container(
                            height: 200,
                            margin: Margin.top(10),
                            child: Column(children: [
                              TabBar(
                                indicatorColor: Colors.white,
                                tabs: [
                                  Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                            padding: Margin.all(5),
                                            child: Icon(Icons.content_cut)),
                                        Text('Trim')
                                      ]),
                                  Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                            padding: Margin.all(5),
                                            child: Icon(Icons.video_label)),
                                        Text('Cover')
                                      ]),
                                ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    Container(
                                        child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: _trimSlider())),
                                    Container(
                                      child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [_coverSelection()]),
                                    ),
                                  ],
                                ),
                              )
                            ])),
                        _customSnackBar(),
                        ValueListenableBuilder(
                          valueListenable: _isExporting,
                          builder: (_, bool export, __) => OpacityTransition(
                            visible: export,
                            child: AlertDialog(
                              backgroundColor: Colors.white,
                              title: ValueListenableBuilder(
                                valueListenable: _exportingProgress,
                                builder: (_, double value, __) =>
                                    TextDesigned(
                                      "Downloading video ${(value * 100).ceil()}%",
                                      color: Colors.black,
                                      bold: true,
                                    ),
                              ),
                            ),
                          ),
                        )
                      ])))
            ])
          ]))
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _topNavBar() {
    return SafeArea(
      child: Container(
        height: height,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: gallery,
                child: Icon(Icons.collections),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _controller.rotate90Degrees(RotateDirection.left),
                child: Icon(Icons.rotate_left),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _controller.rotate90Degrees(RotateDirection.right),
                child: Icon(Icons.rotate_right),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _openCropScreen,
                child: Icon(Icons.crop),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _exportCover,
                child: Icon(Icons.save_alt, color: Colors.white),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _exportVideo,
                child: Icon(Icons.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void gallery() async {
    final image = await imagePicker.pickImage(source: ImageSource.gallery);
    if(image != null){
      setState(() {
        file = File(image.path);
      });
    }
    // file = image != null ? File(image.path) : null;
    // setState(() {
    //   compressFile = image != null ? File(image.path) : null;
    // });
    // if(file != null){
    //   Get.to(()=> GalleryScreen(file: file!,compressFile: compressFile,));
    // }

  }

  String formatter(Duration duration) => [
    duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
    duration.inSeconds.remainder(60).toString().padLeft(2, '0')
  ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: _controller.video,
        builder: (_, __) {
          final duration = _controller.video.value.duration.inSeconds;
          final pos = _controller.trimPosition * duration;
          final start = _controller.minTrim * duration;
          final end = _controller.maxTrim * duration;

          return Padding(
            padding: Margin.horizontal(height / 4),
            child: Row(children: [
              TextDesigned(formatter(Duration(seconds: pos.toInt()))),
              Expanded(child: SizedBox()),
              OpacityTransition(
                visible: _controller.isTrimming,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  TextDesigned(formatter(Duration(seconds: start.toInt()))),
                  SizedBox(width: 10),
                  TextDesigned(formatter(Duration(seconds: end.toInt()))),
                ]),
              )
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: Margin.vertical(height / 4),
        child: TrimSlider(
            child: TrimTimeline(
                controller: _controller, margin: EdgeInsets.only(top: 10)),
            controller: _controller,
            height: height,
            horizontalMargin: height / 4),
      ),
      // Slider(
      //   activeColor: Colors.blue,
      //   inactiveColor: Colors.grey,
      //   value: _position.inSeconds.toDouble(),
      //   max: _duration.inSeconds.toDouble(),
      //   onChanged: (double value) {
      //     setState(() {
      //       seekToSeconds(value.toInt());
      //       value = value;
      //     });
      //   },
      // ),
    ];
  }

  Widget _coverSelection() {
    return Container(
        margin: Margin.horizontal(height / 4),
        child: CoverSelection(
          controller: _controller,
          height: height,
          nbSelection: 8,
        ));
  }

  Widget _customSnackBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SwipeTransition(
        visible: _exported,
        //direction: SwipeDirection.fromBottom,
        child: Container(
          height: height,
          width: double.infinity,
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: TextDesigned(
              _exportText,
              bold: true,
            ),
          ),
        ),
      ),
    );
  }
}

//-----------------//
//CROP VIDEO SCREEN//
//-----------------//
class CropScreen extends StatelessWidget {
  CropScreen({Key? key, required this.controller}) : super(key: key);

  final VideoEditorController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: Margin.all(30),
          child: Column(children: [
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.rotate90Degrees(RotateDirection.left),
                  child: Icon(Icons.rotate_left),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      controller.rotate90Degrees(RotateDirection.right),
                  child: Icon(Icons.rotate_right),
                ),
              )
            ]),
            SizedBox(height: 15),
            Expanded(
              child: AnimatedInteractiveViewer(
                maxScale: 2.4,
                child: CropGridViewer(
                    controller: controller, horizontalMargin: 60),
              ),
            ),
            SizedBox(height: 15),
            Row(children: [
              Expanded(
                child: SplashTap(
                  onTap: context.goBack,
                  child: Center(
                    child: TextDesigned(
                      "CANCEL",
                      bold: true,
                    ),
                  ),
                ),
              ),
              buildSplashTap("16:9", 16 / 9, padding: Margin.horizontal(10)),
              buildSplashTap("1:1", 1 / 1),
              buildSplashTap("4:5", 4 / 5, padding: Margin.horizontal(10)),
              buildSplashTap("NO", null, padding: Margin.right(10)),
              Expanded(
                child: SplashTap(
                  onTap: () {
                    //2 WAYS TO UPDATE CROP
                    //WAY 1:
                    controller.updateCrop();
                    /*WAY 2:
                    controller.minCrop = controller.cacheMinCrop;
                    controller.maxCrop = controller.cacheMaxCrop;
                    */
                    context.goBack();
                  },
                  child: Center(
                    child: TextDesigned("OK", bold: true),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget buildSplashTap(
      String title,
      double? aspectRatio, {
        EdgeInsetsGeometry? padding,
      }) {
    return SplashTap(
      onTap: () => controller.preferredCropAspectRatio = aspectRatio,
      child: Padding(
        padding: padding ?? Margin.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.aspect_ratio, color: Colors.white),
            TextDesigned(title, bold: true),
          ],
        ),
      ),
    );
  }
}