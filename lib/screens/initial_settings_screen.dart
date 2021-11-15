import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foc_live_call/screens/video_call_screen.dart';

class InitialSettingsScreen extends StatefulWidget {
  const InitialSettingsScreen({Key? key}) : super(key: key);

  @override
  State<InitialSettingsScreen> createState() => _InitialSettingsScreenState();
}

class _InitialSettingsScreenState extends State<InitialSettingsScreen> {
  TextEditingController tokenFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
              onPressed: () async {
                if (tokenFieldController.text.isEmpty) {
                  return;
                }

                final token = tokenFieldController.text;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VideoCallScreen(token: token, channel: "vladlena"),
                  ),
                );
              },
              child: const Text('Подключиться'),
            )
          ],
        ),
      ),
    );
  }
}
