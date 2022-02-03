import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AddMusic extends StatefulWidget {
  const AddMusic({Key? key}) : super(key: key);

  @override
  _AddMusicState createState() => _AddMusicState();
}

class _AddMusicState extends State<AddMusic> with TickerProviderStateMixin {

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

    initPlayer();
  }

  void initPlayer() {
    _animationIconController1 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 750),
      reverseDuration: Duration(milliseconds: 750),
    );
    audioPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: audioPlayer);
    audioPlayer.getDuration().then((d) {
      setState(() {
        _duration = Duration(milliseconds: d);
      });
    });
    audioPlayer.getCurrentPosition().then((p) {
          setState(() {
            _position = Duration(minutes: p);
          });
        });
    // audioPlayer.durationHandler = (d) => setState(() {
    //       _duration = d;
    //     });
    // audioPlayer.positionHandler = (p) => setState(() {
    //       _position = p;
    //     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AudioPlayer"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Slider(
              activeColor: Colors.blue,
              inactiveColor: Colors.grey,
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds.toDouble(),
              onChanged: (double value) {
                setState(() {
                  seekToSeconds(value.toInt());
                  value = value;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${_position.inSeconds.toDouble()}"),
                  Text("${_duration.inSeconds.toDouble()}"),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isplaying
                      ? _animationIconController1.reverse()
                      : _animationIconController1.forward();
                  isplaying = !isplaying;
                });
                if (issongplaying == false) {
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
              child: ClipOval(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2.5,
                      color: Colors.green,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(50.0),
                    ),
                  ),
                  width: 75,
                  height: 75,
                  child: Center(
                    child: AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      progress: _animationIconController1,
                      color: Colors.grey,
                      size: 60,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
