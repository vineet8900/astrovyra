

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraVoiceCallScreen extends StatefulWidget {
  final String appId;
  final String token;
  final String channelName;
  final int userId;
  final String astrologerName;
  final String userName;
  final int consultationId;
  final bool isvoiceCall;

  const AgoraVoiceCallScreen({
    Key? key,
    required this.appId,
    required this.token,
    required this.channelName,
    required this.userId,
    required this.astrologerName,
    required this.userName,
    required this.consultationId,
    required this.isvoiceCall,
  }) : super(key: key);

  @override
  State<AgoraVoiceCallScreen> createState() => _AgoraVoiceCallScreenState();
}

class _AgoraVoiceCallScreenState extends State<AgoraVoiceCallScreen> {
  RtcEngine? _engine;
  int? _remoteUid;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isSpeakerEnabled = true;
  bool _isDisposing = false;
  Timer? _connectionTimer;
  int _callDurationSeconds = 0;
  Timer? _callDurationTimer;

  String _formatCallDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _startCallDurationTimer() {
    _callDurationTimer?.cancel();
    _callDurationSeconds = 0;
    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isDisposing) {
        setState(() => _callDurationSeconds++);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeVoiceCall();

    _connectionTimer = Timer(const Duration(seconds: 30), () {
      if (!_isJoined || _remoteUid == null) {
        _showErrorDialog('Could not connect to the call. Please check your internet connection and try again.');
      }
    });
  }

  Future<void> _initializeVoiceCall() async {
    try {
      await Permission.microphone.request();

      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(appId: widget.appId));
      
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            if (mounted) {
              setState(() => _isJoined = true);
              _startCallDurationTimer();
            }
            _connectionTimer?.cancel();
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            if (mounted) {
              setState(() => _remoteUid = remoteUid);
            }
          },
          onUserOffline: (connection, remoteUid, reason) {
            if (mounted) {
              setState(() => _remoteUid = null);
              _showCallEndedDialog();
            }
          },
          onError: (err, msg) {
            debugPrint('Agora Error: $err - $msg');
            if (mounted && err != ErrorCodeType.errOk) {
              _showErrorDialog('An error occurred: $msg');
            }
          },
        ),
      );

      // Set audio-only mode
      await _engine!.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioChatroom,
      );
      await _engine!.setChannelProfile(ChannelProfileType.channelProfileCommunication);
      
      await _engine!.joinChannel(
        token: widget.token,
        channelId: widget.channelName,
        uid: widget.userId,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
        ),
      );
    } catch (e) {
      debugPrint('Failed to initialize voice call: $e');
      if (mounted) {
        _showErrorDialog('Failed to initialize call: $e');
      }
    }
  }

  @override
  void dispose() {
    _isDisposing = true;
    _connectionTimer?.cancel();
    _callDurationTimer?.cancel();
    _cleanupEngine();
    super.dispose();
  }

  Future<void> _cleanupEngine() async {
    if (_engine != null) {
      try {
        // First check if we're in a channel
        if (_isJoined) {
          await _engine!.leaveChannel();
        }
      } catch (e) {
        debugPrint('Error leaving channel: $e');
      }
      
      try {
        // Add a small delay before releasing
        await Future.delayed(const Duration(milliseconds: 100));
        await _engine!.release();
        _engine = null;
      } catch (e) {
        debugPrint('Error releasing engine: $e');
      }
    }
  }

  void _onEndCall() async {
    if (_isDisposing) return;
    
    try {
      await _cleanupEngine();
    } catch (e) {
      debugPrint('Error during end call: $e');
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _onToggleMute() {
    if (_engine == null || _isDisposing) return;
    
    setState(() => _isMuted = !_isMuted);
    _engine!.muteLocalAudioStream(_isMuted).catchError((e) {
      debugPrint('Error toggling mute: $e');
    });
  }

  void _onToggleSpeaker() {
    if (_engine == null || _isDisposing) return;
    
    setState(() => _isSpeakerEnabled = !_isSpeakerEnabled);
    _engine!.setEnableSpeakerphone(_isSpeakerEnabled).catchError((e) {
      debugPrint('Error toggling speaker: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onEndCall();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeader(),
              _buildCallStatusView(),
              _buildToolbar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _remoteUid != null ? 'Connected' : 'Connecting...',
            style: TextStyle(
              color: _remoteUid != null ? Colors.greenAccent : Colors.orangeAccent,
              fontSize: 18,
            ),
          ),
          if (_isJoined && _callDurationSeconds >= 0) ...[
            const SizedBox(height: 8),
            Text(
              _formatCallDuration(_callDurationSeconds),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCallStatusView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.blueAccent,
          child: Text(
            widget.astrologerName.isNotEmpty ? widget.astrologerName[0].toUpperCase() : 'A',
            style: const TextStyle(fontSize: 50, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.astrologerName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        if (_remoteUid == null)
          const Text(
            'Ringing...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          )
        else
          const Text(
            'Audio Call',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
      ],
    );
  }
  
  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            onPressed: _onToggleMute,
          ),
          _buildControlButton(
            icon: Icons.call_end,
            onPressed: _onEndCall,
            backgroundColor: Colors.red,
          ),
          _buildControlButton(
            icon: _isSpeakerEnabled ? Icons.volume_up : Icons.volume_off,
            onPressed: _onToggleSpeaker,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return CircleAvatar(
      radius: 32,
      backgroundColor: backgroundColor ?? Colors.white.withOpacity(0.2),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 28),
        onPressed: onPressed,
      ),
    );
  }
  
  void _showCallEndedDialog() {
    if (mounted && !_isDisposing) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Call Ended'),
          content: Text('The call with ${widget.astrologerName} has ended.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _onEndCall();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    if (mounted && !_isDisposing) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _onEndCall();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}