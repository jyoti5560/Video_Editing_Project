import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
//import 'package:create_video/main.dart';
import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_editing/main.dart';
//import 'package:screen_recorder/screen_recorder.dart';

class VideoFileScreen extends StatefulWidget {
  List<ImageFileItem> imageFileList = <ImageFileItem>[];
  VideoFileScreen({required this.imageFileList});

  //VideoFileScreen({Key? key}) : super(key: key);

  @override
  _VideoFileScreenState createState() => _VideoFileScreenState();
}

class _VideoFileScreenState extends State<VideoFileScreen> {
  var activeIndex = 0;
  final double height = 60;
  //ScreenRecorderController controller = ScreenRecorderController();
  int ? i;
  File ? list;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 3), () {
      //list = Image.file(File(widget.imageFileList[i!].file.path));
      //print("Yeah, this line is printed after 3 seconds");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      /*body: Center(
        child: Image.file(File('${widget.imageFileList[0].file.path}')),
      ),*/
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
               height: MediaQuery.of(context).size.height/2,
              //width: MediaQuery.of(context).size.width,
              //controller: controller,
              child: CarouselSlider.builder(
                itemCount: widget.imageFileList.length,
                itemBuilder: (context, index, realIndex) {
                  i = index;
                  return Container(
                    // decoration: BoxDecoration(
                    //   //borderRadius: BorderRadius.circular(10),
                    //   color: Colors.grey,
                    //   // image: DecorationImage(
                    //   //   image: FileImage(File(widget.imageFileList[index].file.path)),
                    //   // ),
                    // ),
                    child: Image.file(File(widget.imageFileList[index].file.path),
                      fit: BoxFit.fill,
                      width: MediaQuery.of(context).size.width,),
                  );
                },
                options: CarouselOptions(
                  //height: 150,
                    autoPlay: true,
                    pageSnapping: true,
                    //reverse: false,
                    autoPlayAnimationDuration: Duration(seconds: 5),
                    viewportFraction: 1,
                    onPageChanged: (index, reason) {
                      setState(() {
                        activeIndex = index;
                      });

                    }),
              ),
            ),


            //Image.file(list!),

            SizedBox(height: 10,),
            Container(
              height: 50,
              child: ListView.builder(
                  itemCount: widget.imageFileList.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    return Container(
                      child: Image.file(File(widget.imageFileList[index].file.path)),
                    );
                  }
              ),
            ),

            /*ElevatedButton(
              onPressed: () {
                controller.start();
              },
              child: Text('Start'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.stop();
              },
              child: Text('Stop'),
            ),
            ElevatedButton(
              onPressed: () async {
                var gif = await controller.export();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Image.memory(Uint8List.fromList(gif!)),
                    );
                  },
                );
              },
              child: Text('show recoded video'),
            ),*/
          ],
        ),
      ),
    );
  }
}
