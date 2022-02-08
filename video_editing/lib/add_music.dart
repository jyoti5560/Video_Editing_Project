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

  VideoPlayerController ? controller;

  // To Do
  late AnimationController animationIconController1;
  AudioCache ? audioCache;
  late AudioPlayer audioPlayer;
  Duration _duration = new Duration();
  Duration _position = new Duration();

  bool issongplaying = false;

  bool isplaying = false;
  int ? time;
  Duration ? dur;

  void seekToSeconds(int second) {
    Duration newDuration = Duration(seconds: second);
    audioPlayer.seek(newDuration);
  }

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.file(File(widget.file.path))
      ..initialize().then((_) async {
        //_controller!.setLooping(true);
        controller!.setVolume(0);

        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(()  {
          print('Video Duration: ${controller!.value.duration.inSeconds}');

          // if(_controller!.value.position == _controller!.value.duration){
          //     setState(() {
          //       Duration player = Duration(milliseconds: _controller!.value.position.inMilliseconds.round());
          //       nowTime = [player.inHours, player.inMinutes, player.inSeconds]
          //           .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
          //           .join(':');
          //
          //     });
          //     print('now time: $nowTime');
          //     if(nowTime!.isEmpty){
          //        audioPlayer.pause();
          //        audioPlayer.stop();
          //     }
          //   }else{
          //     print('empty');
          //     audioPlayer.pause();
          //     audioPlayer.stop();
          //   }


          //if(_controller!.value.duration)
           //_duration = _controller!.value.duration;
        });
      });
    controller!.addListener(checkVideo);

    initPlayer();
    //load_path_video();
  }

  void checkVideo(){
    // Implement your calls inside these conditions' bodies :
    if(controller!.value.position == Duration(seconds: 0, minutes: 0, hours: 0)) {
      print('video Started');
    }
    print('Video position: ${controller!.value.position}');
    print('Video duration: ${controller!.value.duration}');
    if(controller!.value.position == controller!.value.duration) {
      print('video Ended');
      audioPlayer.stop();
    }

  }

  void initPlayer() {
    animationIconController1 = AnimationController(
      vsync: this,
      duration:  Duration(milliseconds: 750),
      reverseDuration: Duration(milliseconds: 750),
    );

    audioPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: audioPlayer);

    //_controller!.value.isPlaying ? audioCache!.play("Song1.mp3") : audioPlayer.pause();

    // audioPlayer.onDurationChanged.listen((Duration d) {
    //   setState(() {
    //     _duration = d;
    //   });
    //   print('Max duration: $_duration');
    // });

    // audioPlayer.getDuration().then((d) {
    //
    //   setState(() {
    //     _duration = Duration(milliseconds: d);
    //     print('Total duration: ${_duration.inSeconds}');
    //   });
    // });
    // audioPlayer.getCurrentPosition().then((p) {
    //   setState(() {
    //     _position = Duration(minutes: p);
    //     print('position: $_position');
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
    controller!.dispose();
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
  String ? nowTime;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: AppBar(
       // actionsIconTheme: IconThemeData(color: Colors.black),
        //backgroundColor: Colors.white,
        title: Text("Add Music"),
        centerTitle: true,
        actions: [
          // GestureDetector(
          //   onTap: () async {
          //     // final video = File(_controller!.value.toString());
          //     // await GallerySaver.saveVideo('${video.path}');
          //     // print('path: ${video.path}');
          //     load_path_video();
          //   },
          //     child: Icon(Icons.save_alt))
        ],
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            controller!.value.isInitialized
                ? Container(
              height: MediaQuery.of(context).size.height,
              //aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(controller!),
            )
                : Container(),

            GestureDetector(
              onTap: ()async{
                //print('Video Duration: ${_controller!.value.duration.inSeconds}');
                print('Duration1: $_duration');

                setState(() {
                  controller!.value.isPlaying
                      ? controller!.pause()
                      : controller!.play();
                  print('data source : ${controller!.dataSource}');
                });

                //to do
                setState(() {
                  isplaying
                      ? animationIconController1.reverse()
                      : animationIconController1.forward();
                  isplaying = !isplaying;
                });
                if (controller!.value.isPlaying) {
                  print('isPlaying: ${controller!.value.isPlaying}');
                   audioCache!.play("Song1.mp3");

                   // audioPlayer.play('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
                 //  setState(() {
                 //    issongplaying = true;
                 //  });
                } else {
                  print('isPlaying: ${controller!.value.isPlaying}');
                  audioPlayer.pause();

                  // setState(() {
                  //   issongplaying = false;
                  // });
                }
              },
              child: Icon(
                controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
