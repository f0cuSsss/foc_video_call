import 'dart:async';
import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foc_live_call/utils/colors.dart';
import 'package:flutter_pip/platform_channel/channel.dart';
import 'package:permission_handler/permission_handler.dart';

const appId = "4072b1813d034add9655b86ffb8c6634";

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  int? _remoteUid;
  bool muted = false;
  bool isCameraActive = false;
  bool isCollapsed = false;
  bool _localUserJoined = false;

  String token = "";
  TextEditingController tokenFieldController = TextEditingController();

  late final Timer? _timer;

  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
    runTimer();
  }

  void runTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) async {
      final isPiped = await FlutterPip.isInPictureInPictureMode();
      if (isPiped != null && !isPiped) {
        setState(() {
          isCollapsed = false;
        });

        // if (_timer != null) {
        //   _timer!.cancel();
        //   setState(() {
        //     _timer = null;
        //   });
        // }
        // timer.cancel();
      } else {
        setState(() {
          isCollapsed = true;
        });
      }
    });
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = await RtcEngine.create(appId);
    await _engine.enableVideo();
    _engine.setCameraAutoFocusFaceModeEnabled(true);
    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          //print("local user $uid joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        userJoined: (int uid, int elapsed) {
          //print("remote user $uid joined");
          setState(() {
            _remoteUid = uid;
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          //print("remote user $uid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );
    await _engine.joinChannel(token, "vladlena", null, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: token.isEmpty
          ? _buildTokenField()
          : Stack(
              children: [
                Center(child: _remoteVideo()),
                isCollapsed
                    ? const SizedBox()
                    : Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          width: 100,
                          height: 150,
                          child: Center(
                            child: _localUserJoined
                                ? RtcLocalView.SurfaceView()
                                : const CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 1),
                          ),
                        ),
                      ),
                _toolbar()
              ],
            ),
    );
  }

  Widget _buildTokenField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: tokenFieldController,
                  style: const TextStyle(color: Colors.white),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 5),
              tokenFieldController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          tokenFieldController.text = "";
                        });
                      },
                      icon: const Icon(
                        Icons.cancel_rounded,
                        color: Colors.white,
                      ),
                    )
                  : const SizedBox(),
              IconButton(
                onPressed: () {
                  Clipboard.getData(Clipboard.kTextPlain).then((value) {
                    if (value == null || value.text == null) {
                      return;
                    } else {
                      setState(() {
                        tokenFieldController.text = value.text!;
                      });
                    }
                  });
                },
                icon: const Icon(
                  Icons.paste,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          TextButton(
            onPressed: () {
              if (tokenFieldController.text.isEmpty) {
                return;
              }

              setState(() {
                token = tokenFieldController.text;
              });
            },
            child: const Text('Подключиться'),
          )
        ],
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return RtcRemoteView.SurfaceView(uid: _remoteUid!);
    } else {
      return isCollapsed
          ? const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 1.5,
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Твой человечек подключается...\nПодожди его 💗:)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 25),
                TextButton(
                  onPressed: () {
                    setState(() {
                      token = "";
                      tokenFieldController.text = "";
                    });
                  },
                  child: const Text('Обнулить токен'),
                ),
              ],
            );
    }
  }

  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: isCollapsed
          ? const SizedBox()
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RawMaterialButton(
                  onPressed: _onToggleVideo,
                  child: Icon(
                    isCameraActive
                        ? Icons.videocam_off_outlined
                        : Icons.videocam,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: isCameraActive
                      ? const Color(0xFF8A0707)
                      : kBackgroundColor,
                  padding: const EdgeInsets.all(12.0),
                ),
                RawMaterialButton(
                  onPressed: _onToggleMute,
                  child: Icon(
                    muted ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: muted ? const Color(0xFF8A0707) : kBackgroundColor,
                  padding: const EdgeInsets.all(12.0),
                ),
                RawMaterialButton(
                  onPressed: _onSwitchCamera,
                  child: const Icon(
                    Icons.cameraswitch_outlined,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: kBackgroundColor,
                  padding: const EdgeInsets.all(12.0),
                ),
                RawMaterialButton(
                  onPressed: _collapseApp,
                  child: const Icon(
                    Icons.copy_all_sharp,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: kBackgroundColor,
                  padding: const EdgeInsets.all(12.0),
                ),
              ],
            ),
    );
  }

  void _collapseApp() async {
    final res = await FlutterPip.enterPictureInPictureMode();

    if (res == 0) {
      setState(() {
        isCollapsed = true;
      });
    }
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onToggleVideo() {
    setState(() {
      isCameraActive = !isCameraActive;
    });
    isCameraActive ? _engine.disableVideo() : _engine.enableAudio();
  }

  void _onSwitchCamera() {
    // if (streamId != null)
    _engine.switchCamera();
    // _engine.sendStreamMessage(streamId, 'mute user blet');
    //_engine.switchCamera();
  }
}
