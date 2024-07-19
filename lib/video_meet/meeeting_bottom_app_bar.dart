import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:videosdk/videosdk.dart';

class MeetingBottomAppBar extends StatelessWidget {
  final bool micEnabled;
  final bool camEnabled;
  final Room room;
  final VoidCallback onChatIconPressed;
  final VoidCallback onVideoIconPressed;
  final VoidCallback onMicIconPressed;

  const MeetingBottomAppBar({
    required this.camEnabled,
    required this.micEnabled,
    required this.room,
    required this.onVideoIconPressed,
    required this.onMicIconPressed,
    required this.onChatIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: onMicIconPressed,
            icon: Icon(
              micEnabled ? Icons.mic : Icons.mic_off,
              color: micEnabled ? Colors.blue : Colors.grey,
            ),
          ),
          IconButton(
            onPressed: onVideoIconPressed,
            icon: Icon(
              camEnabled ? Icons.videocam : Icons.videocam_off,
              color: camEnabled ? Colors.blue : Colors.grey,
            ),
          ),
          IconButton(
            onPressed: () {
              room.leave();
            },
            icon: const Icon(
              Icons.call_end,
              color: Colors.red,
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Meeting ID: ${room.id}'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: room.id));
                          Navigator.of(context).pop();
                        },
                        child: const Text('Copy'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.info_outline_rounded,
              color: Colors.blue,
            ),
          ),
          IconButton(
            onPressed: onChatIconPressed,
            icon: const Icon(
              Icons.message,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
