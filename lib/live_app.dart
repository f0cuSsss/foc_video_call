import 'package:flutter/material.dart';
import 'package:flutter_foc_live_call/screens/video_call_screen.dart';
import 'package:flutter_foc_live_call/utils/colors.dart';

class LiveApp extends StatelessWidget {
  const LiveApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: kBackgroundColor,
      ),
      debugShowCheckedModeBanner: false,
      title: 'Live Video Call',
      home: const VideoCallScreen(),
    );
  }
}
