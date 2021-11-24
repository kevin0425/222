import 'dart:isolate';
import 'dart:async';
import 'dart:io';
import 'dart:ffi';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:flutter_opencv_example/myhomepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_opencv_example/native_opencv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:camera/camera.dart';
import 'package:flutter_opencv_example/screens/calendar_page.dart';
import 'package:flutter_opencv_example/theme/colors/light_colors.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_opencv_example/widgets/task_column.dart';
import 'package:flutter_opencv_example/widgets/active_project_card.dart';
import 'package:flutter_opencv_example/widgets/top_container.dart';

Directory tempDir;
String get tempPath => '${tempDir.path}/temp.jpg';

class HomePage extends StatelessWidget {

  bool _isProcessed = false;
  bool _isWorking = false;
  bool isWorking = false;
  String result = "";
  CameraController cameraController;
  CameraImage imgCamera;
  File image;

  Text subheading(String title) {
    return Text(
      title,
      style: TextStyle(
          color: LightColors.kDarkBlue,
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2),
    );
  }

  Future<void> takeImageAndProcess() async {
    final image = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (image == null) {
      return;
    }

    //setState(() {
      _isWorking = true;
    //});

    // Creating a port for communication with isolate and arguments for entry point
    final port = ReceivePort();
    final args = ProcessImageArguments(image.path, tempPath);

    // Spawning an isolate
    Isolate.spawn<ProcessImageArguments>(
        processImage,
        args,
        onError: port.sendPort,
        onExit: port.sendPort
    );

    // Making a variable to store a subscription in
    StreamSubscription sub;

    // Listeting for messages on port
    sub = port.listen((_) async {
      // Cancel a subscription after message received called
      await sub?.cancel();

      //setState(() {
        _isProcessed = true;
        _isWorking = false;
      //});
    });
  }

  static CircleAvatar calendarIcon() {
    return CircleAvatar(
      radius: 25.0,
      backgroundColor: LightColors.kGreen,
      child: Icon(
        Icons.calendar_today,
        size: 20.0,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    if (_isProcessed && !_isWorking) {
      return Scaffold(
        appBar: AppBar(
            title: Text('123')
        ),
        body: Stack(
          children: <Widget>[
            Center(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  if (_isProcessed && !_isWorking)
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 3000, maxHeight: 300),
                      child: Image.file(
                        File(tempPath),
                        alignment: Alignment.center,
                      ),
                    ),
                  Builder(
                      builder: (context) {
                        return RaisedButton(
                            child: Text('Show version'),
                        );
                      }
                  ),
                  RaisedButton(
                      child: Text('Process photo'),
                      onPressed: (
                  ){}
                  )
                ],
              ),
            ),
            if (_isWorking)
              Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(.7),
                    child: Center(
                        child: CircularProgressIndicator()
                    ),
                  )
              ),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: LightColors.kLightYellow,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TopContainer(
              height: 200,
              width: width,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Icon(Icons.menu,
                            color: LightColors.kDarkBlue, size: 30.0),
                        Icon(Icons.search,
                            color: LightColors.kDarkBlue, size: 25.0),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          CircularPercentIndicator(
                            radius: 90.0,
                            lineWidth: 5.0,
                            animation: true,
                            percent: 0.75,
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: LightColors.kRed,
                            backgroundColor: LightColors.kDarkYellow,
                            center: CircleAvatar(
                              backgroundColor: LightColors.kBlue,
                              radius: 35.0,
                              backgroundImage: AssetImage(
                                'assets/images/pill.png',
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  'David Chan',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    color: LightColors.kDarkBlue,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Container(
                                child: Text(
                                  'Patients',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black45,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              subheading('My Tasks'),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CalendarPage()),
                                  );
                                },
                                child: calendarIcon(),
                              ),
                            ],
                          ),
                          SizedBox(height: 15.0),
                          TaskColumn(
                            icon: Icons.alarm,
                            iconBackgroundColor: LightColors.kRed,
                            title: 'To Do',
                            subtitle: '2 tasks now.',
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          TaskColumn(
                            icon: Icons.blur_circular,
                            iconBackgroundColor: LightColors.kDarkYellow,
                            title: 'In Progress',
                            subtitle: '0 tasks now.',
                          ),
                          SizedBox(height: 15.0),
                          TaskColumn(
                            icon: Icons.check_circle_outline,
                            iconBackgroundColor: LightColors.kBlue,
                            title: 'Done',
                            subtitle: '1 tasks now',
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          subheading('What to do'),
                          SizedBox(height: 5.0),
                          Row(
                            children: <Widget>[
                              ActiveProjectsCard(
                                cardColor: LightColors.kGreen,
                                loadingPercent: 0.25,
                                title: 'Today Pills',
                                subtitle: 'Pills intake',
                              ),
                              SizedBox(width: 20.0),
                              ActiveProjectsCard(
                                cardColor: LightColors.kRed,
                                loadingPercent: 0.6,
                                title: 'History',
                                subtitle: 'Pills intake',
                              ),

                            ],
                          ),
                          Row(
                            children: <Widget>[
                              RaisedButton(
                                child: Text('Pills checking'),
                                onPressed: () {
                                  takeImageAndProcess();
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 3000, maxHeight: 300),
                                    child: Image.file(
                                      File(tempPath),
                                      alignment: Alignment.center,
                                    ),
                                  );
                                },
                              ),
                              SizedBox(width: 20.0),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
