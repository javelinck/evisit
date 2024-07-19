import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_call.dart';
import 'meeting_screen.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({Key? key}) : super(key: key);

  @override
  _JoinScreenState createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final TextEditingController _meetingIdController = TextEditingController();
  final TextEditingController _meetingNameController = TextEditingController();

  void onCreateButtonPressed() async {
    String meetingName = _meetingNameController.text;
    await createMeeting().then((meetingId) {
      if (!mounted || meetingId == null) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Meeting ID: $meetingId'),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: meetingId));
                  Navigator.of(context).pop();
                },
                child: const Text('Copy'),
              ),
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: meetingId));
                  // You can add your logic here to start the meeting
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MeetingScreen(
                        meetingId: meetingId,
                        token: getToken(),
                        meetingName: meetingName,
                      ),
                    ),
                  );
                },
                child: const Text('Copy and Start'),
              ),
            ],
          );
        },
      );
    });
  }

  void onJoinButtonPressed() {
    String meetingId = _meetingIdController.text;
    String meetingName = _meetingNameController.text;

    var re = RegExp("\\w{4}\\-\\w{4}\\-\\w{4}");
    if (meetingId.isNotEmpty && re.hasMatch(meetingId)) {
      _meetingIdController.clear();
      _meetingNameController.clear();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MeetingScreen(
            meetingId: meetingId,
            token: getToken(),
            meetingName: meetingName,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter a valid meeting id or name"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Meeting Id',
                  border: OutlineInputBorder(),
                ),
                controller: _meetingIdController,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Meeting Name',
                  border: OutlineInputBorder(),
                ),
                controller: _meetingNameController,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: onCreateButtonPressed,
                  child: const Text('Create Meeting'),
                ),
                ElevatedButton(
                  onPressed: onJoinButtonPressed,
                  child: const Text('Join Meeting'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
