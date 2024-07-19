import 'package:evisit_mobile/video_meet/meeeting_bottom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import './participant_tile.dart';
import 'chat_view.dart';

class MeetingScreen extends StatefulWidget {
  final String meetingId;
  final String meetingName;
  final String token;

  const MeetingScreen({super.key, required this.meetingId, required this.token, required this.meetingName});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  late Room _room;
  var micEnabled = true;
  var camEnabled = true;
  bool showChatSnackbar = true;
  Participant? remoteParticipant;
  Map<String, Participant> participants = {};

  @override
  void initState() {
    _room = VideoSDK.createRoom(
      roomId: widget.meetingId,
      token: widget.token,
      displayName: widget.meetingName,
      micEnabled: micEnabled,
      camEnabled: camEnabled,
      defaultCameraIndex:
      1, // Index of MediaDevices will be used to set default camera
    );

    setMeetingEventListener();

    try {
      remoteParticipant = _room.participants.isNotEmpty
        ? _room.participants.entries.first.value
        : null;
    } catch (error) {}

    _room.join();

    super.initState();
  }

  // listening to meeting events
  void setMeetingEventListener() {
    _room.on(Events.roomJoined, () {
      setState(() {
        participants.putIfAbsent(_room.localParticipant.id, () => _room.localParticipant);
        subscribeToChatMessages(_room);
      });
    });

    _room.on(Events.participantJoined, (Participant participant) {
        setState(() => participants.putIfAbsent(participant.id, () => participant));
      },
    );

    _room.on(Events.participantLeft, (String participantId) {
      if (participants.containsKey(participantId)) {
        setState(() => participants.remove(participantId));
      }
    });

    _room.on(Events.roomLeft, () {
      participants.clear();
      Navigator.popUntil(context, ModalRoute.withName('/'));
    });
  }

  void subscribeToChatMessages(Room meeting) {
    meeting.pubSub.subscribe("CHAT", (message) {
      if (message.senderId != meeting.localParticipant.id) {
        if (mounted) {
          if (showChatSnackbar) {
            showSnackBarMessage(
                message: message.senderName + ": " + message.message,
                context: context);
          }
        }
      }
    });
  }

  Future<bool> _onWillPop() async {
    _room.leave();
    return true;
  }

  void toggleChatInput() {
    setState(() {
      showChatSnackbar = false;
    });
    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 100),
        isScrollControlled: true,
        builder: (context) => ChatView(
          key: const Key("ChatScreen"),
          meeting: _room),
    ).whenComplete(() => setState(() {
      showChatSnackbar = true;
    }));
  }

  void toggleVideoButton() {
    setState(() {
      if (camEnabled) {
        _room.disableCam();
        camEnabled = false;
      } else {
        _room.enableCam();
        camEnabled = true;
      }
    });
  }

  void toggleMicButton() {
    setState(() {
      if (micEnabled) {
        _room.muteMic();
        micEnabled = false;
      } else {
        _room.unmuteMic();
        micEnabled = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        bottomNavigationBar: MeetingBottomAppBar(
          camEnabled: camEnabled,
          onVideoIconPressed: toggleVideoButton,
          onMicIconPressed: toggleMicButton,
          micEnabled: micEnabled,
          room: _room,
          onChatIconPressed: toggleChatInput,
        ),
        body: Stack(
          children: [
            ParticipantTile(
              key: Key(remoteParticipant != null ? remoteParticipant!.id : _room.localParticipant.id),
              participant: remoteParticipant != null ? remoteParticipant! : _room.localParticipant),
            if (remoteParticipant != null)
            Positioned(
              right: 10.0,
              bottom: 10.0,
              width: 100,
              height: 150,
              child: ParticipantTile(key: Key(_room.localParticipant.id), participant: _room.localParticipant),
            ),
          ],
        ),
      ),
    );
  }
}

void showSnackBarMessage(
    {required String message,
      Widget? icon,
      Color messageColor = Colors.black87,
      required BuildContext context}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      content: Row(
        children: [
          if (icon != null) icon,
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: messageColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.fade,
            ),
          )
        ],
      )));
}
