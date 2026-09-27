import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

class AgoraVideoCallScreen extends StatefulWidget {
  final String appId;
  final String token;
  final String channelName;
  final int userId;
  final String userName;
  final int consultationId;
  final bool isVideoCall;
  final String astrologerName;

  const AgoraVideoCallScreen({
    Key? key,
    required this.appId,
    required this.token,
    required this.channelName,
    required this.userId,
    required this.userName,
    required this.consultationId,
    required this.isVideoCall,
    required this.astrologerName,
  }) : super(key: key);

  @override
  State<AgoraVideoCallScreen> createState() => _AgoraVideoCallScreenState();
}

class _AgoraVideoCallScreenState extends State<AgoraVideoCallScreen> {
  late RtcEngine _engine;
  int? _remoteUid;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isLocalVideoEnabled = true;
  bool _isSpeakerEnabled = true;
  bool _isRemoteVideoEnabled = false; // Track remote video state
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
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _callDurationSeconds++);
    });
  }

  @override
  void initState() {
    super.initState();
    _isVideoEnabled = widget.isVideoCall;
    _isLocalVideoEnabled = widget.isVideoCall;
    _initAgora();
    
    // Connection timeout timer
    _connectionTimer = Timer(Duration(seconds: 30), () {
      if (!_isJoined || _remoteUid == null) {
        _showErrorDialog('Connection timeout. Please try again.');
      }
    });
  }


  Future<void> _initAgora() async {
    try {
      // Permissions request karo
      Map<Permission, PermissionStatus> permissions = await [
        Permission.microphone,
        if (widget.isVideoCall) Permission.camera,
      ].request();

      // Check permissions
      if (permissions[Permission.microphone] != PermissionStatus.granted) {
        _showErrorDialog('Microphone permission is required for calls.');
        return;
      }
      
      if (widget.isVideoCall && permissions[Permission.camera] != PermissionStatus.granted) {
        _showErrorDialog('Camera permission is required for video calls.');
        return;
      }

      // Create engine
      _engine = createAgoraRtcEngine();
      
      // Initialize engine with proper context
      await _engine.initialize(RtcEngineContext(
        appId: widget.appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Register event handlers
      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
             
            setState(() => _isJoined = true);
            _connectionTimer?.cancel();
            _startCallDurationTimer();
          },
          
          onUserJoined: (connection, remoteUid, elapsed) {
            
            setState(() => _remoteUid = remoteUid);
          },
          
          onUserOffline: (connection, remoteUid, reason) {
            
            setState(() {
              _remoteUid = null;
              _isRemoteVideoEnabled = false;
            });
            _showCallEndedDialog();
          },
          
          onRemoteVideoStateChanged: (connection, remoteUid, state, reason, elapsed) {
            
            if (remoteUid == _remoteUid) {
              setState(() {
                _isRemoteVideoEnabled = state == RemoteVideoState.remoteVideoStateStarting || 
                                       state == RemoteVideoState.remoteVideoStateDecoding;
              });
            }
          },
          
          onRemoteAudioStateChanged: (connection, remoteUid, state, reason, elapsed) {
           
          },
          
          onLeaveChannel: (connection, stats) {
             
            setState(() {
              _isJoined = false;
              _remoteUid = null;
              _isRemoteVideoEnabled = false;
            });
            _callDurationTimer?.cancel();
          },
          
          onError: (err, msg) {
             
            _showErrorDialog('Connection Error: $msg');
          },
          
          onConnectionStateChanged: (connection, state, reason) {
             
            if (state == ConnectionStateType.connectionStateFailed) {
              _showErrorDialog('Connection failed. Please check your internet connection.');
            }
          },
          
          onNetworkQuality: (connection, remoteUid, txQuality, rxQuality) {
            // Network quality monitoring
            if (txQuality.index > 4 || rxQuality.index > 4) {
               
            }
          },
        ),
      );

      // Audio settings
      await _engine.enableAudio();
      await _engine.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioGameStreaming, // Better for real-time communication
      );

      // Video settings agar video call hai
      if (widget.isVideoCall) {
        await _engine.enableVideo();
         await _engine.enableLocalVideo(true);  
        
        // Better video configuration
        await _engine.setVideoEncoderConfiguration(
          const VideoEncoderConfiguration(
            dimensions: VideoDimensions(width: 640, height: 480),
            frameRate: 15,
            bitrate: 800, // Increased bitrate for better quality
            orientationMode: OrientationMode.orientationModeAdaptive,
          ),
        );
        
        // Enable dual stream mode for better performance
        await _engine.enableDualStreamMode(enabled: true);
        
        // Start preview
        await _engine.startPreview();
      } else {
        await _engine.disableVideo();
      }

      // Channel media options with proper settings
      ChannelMediaOptions options = ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        autoSubscribeAudio: true,
        autoSubscribeVideo: widget.isVideoCall,
        publishCameraTrack: widget.isVideoCall,
        publishMicrophoneTrack: true,
       
      );

       

      // Join channel
      await _engine.joinChannel(
        token: widget.token,
        channelId: widget.channelName,
        uid: widget.userId,
        options: options,
      );

       

    } catch (e) {
      
      _showErrorDialog('Failed to initialize call: $e');
    }
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    _callDurationTimer?.cancel();
    _dispose();
    super.dispose();
  }

  Future<void> _dispose() async {
    try {
      if (widget.isVideoCall) {
        await _engine.stopPreview();
      }
      await _engine.leaveChannel();
      await _engine.release();
    } catch (e) {
       
    }
  }

  void _onCallEnd(BuildContext context) async {
    try {
      // Backend ko call end signal bhejo
      // await ApiService.endCall(widget.consultationId);
      
      if (widget.isVideoCall) {
        await _engine.stopPreview();
      }
      await _engine.leaveChannel();
      Navigator.of(context).pop();
    } catch (e) {
      
      Navigator.of(context).pop();
    }
  }

  void _onToggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _engine.muteLocalAudioStream(_isMuted);
  }

  void _onToggleVideo() {
    if (widget.isVideoCall) {
      setState(() {
        _isLocalVideoEnabled = !_isLocalVideoEnabled;
      });
      _engine.enableLocalVideo(_isLocalVideoEnabled);
      
      // Update channel media options
      _engine.updateChannelMediaOptions(ChannelMediaOptions(
        publishCameraTrack: _isLocalVideoEnabled,
      ));
    }
  }

  void _onSwitchCamera() {
    if (widget.isVideoCall && _isLocalVideoEnabled) {
      _engine.switchCamera();
    }
  }

  void _onToggleSpeaker() {
    setState(() {
      _isSpeakerEnabled = !_isSpeakerEnabled;
    });
    _engine.setEnableSpeakerphone(_isSpeakerEnabled);
  }

  void _showCallEndedDialog() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Call Ended'),
          content: Text('Call with ${widget.astrologerName} has ended.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close call screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showErrorDialog(String error) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close call screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onCallEnd(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // Remote user video/audio view
              _remoteVideoView(),
              
              // Call info header
              _callInfoHeader(),
              
              // Local user video view (small window)
              if (widget.isVideoCall && _isLocalVideoEnabled)
                Positioned(
                  top: 100,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      // Optionally allow user to expand local video
                    },
                    child: Container(
                      width: 120,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _localVideoView(),
                      ),
                    ),
                  ),
                ),
              
              // Call controls
              _toolbar(),
              
              // Debug info (remove in production)
              if (false) // Set to true for debugging
                Positioned(
                  top: 300,
                  left: 20,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    color: Colors.black54,
                    child: Text(
                      'Debug:\nJoined: $_isJoined\nRemote UID: $_remoteUid\nRemote Video: $_isRemoteVideoEnabled\nLocal Video: $_isLocalVideoEnabled',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _callInfoHeader() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              widget.astrologerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isJoined && _remoteUid != null ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isJoined && _remoteUid != null ? 'Connected' : 'Connecting...',
                  style: TextStyle(
                    color: _isJoined && _remoteUid != null ? Colors.green : Colors.orange,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _formatCallDuration(_callDurationSeconds),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolbar() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Mute button
            _buildControlButton(
              icon: _isMuted ? Icons.mic_off : Icons.mic,
              isActive: !_isMuted,
              onPressed: _onToggleMute,
            ),
            
            // Speaker button (for audio calls)
            if (!widget.isVideoCall)
              _buildControlButton(
                icon: _isSpeakerEnabled ? Icons.volume_up : Icons.volume_down,
                isActive: _isSpeakerEnabled,
                onPressed: _onToggleSpeaker,
              ),
            
            // Video toggle button (for video calls)
            if (widget.isVideoCall)
              _buildControlButton(
                icon: _isLocalVideoEnabled ? Icons.videocam : Icons.videocam_off,
                isActive: _isLocalVideoEnabled,
                onPressed: _onToggleVideo,
              ),
            
            // End call button
            _buildControlButton(
              icon: Icons.call_end,
              isActive: false,
              onPressed: () => _onCallEnd(context),
              backgroundColor: Colors.red,
              size: 60,
            ),
            
            // Switch camera button (for video calls)
            if (widget.isVideoCall && _isLocalVideoEnabled)
              _buildControlButton(
                icon: Icons.flip_camera_ios,
                isActive: true,
                onPressed: _onSwitchCamera,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    Color? backgroundColor,
    double size = 50,
  }) {
    return Container(
      width: size,
      height: size,
      child: RawMaterialButton(
        onPressed: onPressed,
        shape: const CircleBorder(),
        elevation: 2.0,
        fillColor: backgroundColor ?? (isActive ? Colors.white : Colors.grey[800]),
        child: Icon(
          icon,
          color: backgroundColor != null 
            ? Colors.white 
            : (isActive ? Colors.blue : Colors.white),
          size: size == 60 ? 30 : 24,
        ),
      ),
    );
  }

  Widget _remoteVideoView() {
    if (_remoteUid != null) {
      if (widget.isVideoCall) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: _isRemoteVideoEnabled 
            ? AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine,
                  canvas: VideoCanvas(
                    uid: _remoteUid,
                    renderMode: RenderModeType.renderModeHidden,
                  ),
                  connection: RtcConnection(channelId: widget.channelName),
                ),
              )
            : _buildVideoOffView(),
        );
      } else {
        // Audio call - show avatar/placeholder
        return _buildAudioCallView();
      }
    } else {
      // No remote user - show connecting view
      return _buildConnectingView();
    }
  }

  Widget _buildVideoOffView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.videocam_off,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.astrologerName}\'s camera is off',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioCallView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.astrologerName.isNotEmpty 
                    ? widget.astrologerName[0].toUpperCase()
                    : 'A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.astrologerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Audio Call',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectingView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              'Connecting to ${widget.astrologerName}...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.isVideoCall ? 'Video Call' : 'Audio Call',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _localVideoView() {
    if (_isJoined && widget.isVideoCall && _isLocalVideoEnabled) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: const VideoCanvas(
            uid: 0,
            renderMode: RenderModeType.renderModeHidden,
          ),
        ),
      );
    }
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.videocam_off,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}