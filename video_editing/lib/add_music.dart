import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class AddMusic extends StatefulWidget {
  XFile file;
  AddMusic({required this.file});

  @override
  _AddMusicState createState() => _AddMusicState();
}

class _AddMusicState extends State<AddMusic> with TickerProviderStateMixin {

  VideoPlayerController ? _controller;

  // To Do
  late AnimationController _animationIconController1;
  AudioCache ? audioCache;
  late AudioPlayer audioPlayer;
  Duration _duration = new Duration();
  Duration _position = new Duration();

  bool issongplaying = false;

  bool isplaying = false;

  void seekToSeconds(int second) {
    Duration newDuration = Duration(seconds: second);
    audioPlayer.seek(newDuration);
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.file.path))
      ..initialize().then((_) {
        //_controller!.setLooping(true);
        _controller!.setVolume(0);
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });

    initPlayer();
    //load_path_video();
  }

  void initPlayer() {
    _animationIconController1 = AnimationController(
      vsync: this,
      duration:  Duration(milliseconds: 750),
      reverseDuration: Duration(milliseconds: 750),
    );

    audioPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: audioPlayer);

    _controller!.value.isPlaying ? audioCache!.play("Song1.mp3") : audioPlayer.pause();
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
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }
  String ? dirPath;
  bool loading = false;

  Future load_path_video() async {

    // loading = true;
    //
    // final Directory extDir = await getApplicationDocumentsDirectory();
    //
    // setState(() {
    //   dirPath = '${extDir.path}/Movies/2019-11-08.mp4';
    //   print("Directory path: $dirPath");
    //   loading = false;
    //   // if I print ($dirPath) I have /data/user/0/com.XXXXX.flutter_video_test/app_flutter/Movies/2019-11-08.mp4
    // });
    // return "";
    DateTime time= DateTime.now();
    final String video = "video_maker_${time.hour}_${time.minute}_${time.second}." + "mp4";
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    print('Document directory: ${documentsDirectory.path}');
    File videoFile = File("${documentsDirectory.path}/$video");
    GallerySaver.saveVideo(widget.file.path, albumName: "Video Maker");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Music"),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () async {
              // final video = File(_controller!.value.toString());
              // await GallerySaver.saveVideo('${video.path}');
              // print('path: ${video.path}');
              load_path_video();
            },
              child: Icon(Icons.save_alt))
        ],
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _controller!.value.isInitialized
                ? Container(
              height: MediaQuery.of(context).size.height,
              //aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            )
                : Container(),

            GestureDetector(
              onTap: (){
                print('Duration: ${_controller!.value.duration.inSeconds}');
                print('isplaying : ${_controller!.value.isPlaying}');
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                  print('data source : ${_controller!.dataSource}');
                });

                //to do
                // setState(() {
                //   isplaying
                //       ? _animationIconController1.reverse()
                //       : _animationIconController1.forward();
                //   isplaying = !isplaying;
                // });
                if (_controller!.value.isPlaying) {
                  audioCache!.play("Song1.mp3");
                  setState(() {
                    issongplaying = true;
                  });
                } else {
                  audioPlayer.pause();
                  setState(() {
                    issongplaying = false;
                  });
                }
              },
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
