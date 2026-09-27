import 'dart:async';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/model/Livegiftmodel/livegiftmodel.dart';
import 'package:astrokavach/screen/giftslive/giftlive.dart';
import 'package:astrokavach/screen/walletupdate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

class AgoraCredentials {
  final String appId;
  final String token;
  final String channelName;
  final String userId;
  final String userName;
  final String astrologerLiveUserId;
  final String uuid;
  final String rtmtoken;

  AgoraCredentials({
    required this.appId,
    required this.token,
    required this.channelName,
    required this.userId,
    required this.userName,
    required this.astrologerLiveUserId,
    required this.uuid,
    required this.rtmtoken,
  });
}

class ChatMessage {
  final String id;
  final String userId;
  final String userName;
  final String message;
  final DateTime timestamp;
  final bool isSystem;
  final String? customType;
  final String? uid;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.timestamp,
    this.uid,
    this.isSystem = false,
    this.customType,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'message': message,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'isSystem': isSystem,
        'customType': customType,
        'metadata': metadata,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: json['userId'] ?? '',
        userName: json['userName'] ?? 'Unknown',
        message: json['message'] ?? '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(
            json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
        isSystem: json['isSystem'] ?? false,
        customType: json['customType'],
        metadata: json['metadata'],
      );
}

class LivePage extends StatefulWidget {
  final int astrologerId;
  final AgoraCredentials credentials;
  final int liveId;
  final bool isHost;

  const LivePage(
      {Key? key,
      required this.credentials,
      required this.astrologerId,
      required this.liveId,
      this.isHost = false})
      : super(key: key);

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> with TickerProviderStateMixin {
  Timer? _heartbeatTimer;
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  RtmClient? _rtmClient;
  bool _rtmLoggedIn = false;
  bool _rtmChannelJoined = false;

  late RtcEngine _engine;
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _isAudioMuted = false;
  bool _isVideoMuted = false;
  List<int> _remoteUsers = [];

  final TextEditingController _chatController = TextEditingController();
  final FocusNode _chatFocusNode = FocusNode();
  final List<ChatMessage> _onScreenMessages = [];

  @override
  void initState() {
    super.initState();
    _initSequence();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  Future<void> _initSequence() async {
    await initAgora();
    await _initializeRTM();
    startHeartbeat();
  }

  Future<void> _initializeRTM() async {
    try {
      final (status, client) =
          await RTM(widget.credentials.appId, widget.credentials.userId);
      if (status.error == true) return;

      _rtmClient = client;
      _rtmClient!.addListener(
        message: (event) {
          try {
            final messageData = jsonDecode(utf8.decode(event.message!));
            final chatMessage = ChatMessage.fromJson(messageData);
            if (chatMessage.userId != widget.credentials.userId) {
              _addChatMessage(chatMessage);
            }
          } catch (e) {
            // Fallback for plain text messages
          }
        },
        linkState: (event) {
          if (mounted) {
            setState(() =>
                _rtmLoggedIn = event.currentState == RtmLinkState.connected);
          }
        },
      );
      await _loginRTM();
    } catch (e) {}
  }

  Future<void> _loginRTM() async {
    if (_rtmClient == null) return;
    try {
      final (status, _) = await _rtmClient!.login(widget.credentials.rtmtoken);
      if (status.error == true) return;
      if (mounted) setState(() => _rtmLoggedIn = true);
      await _subscribeToChannel();
    } catch (e) {}
  }

  Future<void> _subscribeToChannel() async {
    if (_rtmClient == null || !_rtmLoggedIn) return;
    try {
      await _rtmClient!.subscribe(widget.credentials.channelName);
      if (mounted) setState(() => _rtmChannelJoined = true);

      if (!widget.isHost) {
        Future.delayed(const Duration(milliseconds: 800), () async {
          await _sendMessage(
            defaultmessage: '👋 ${widget.credentials.userName} joined',
            sendToApi: true,
          );
        });
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _pulseController.dispose();
    _rotationController.dispose();
    _chatController.dispose();
    _chatFocusNode.dispose();
    _disposeAll();
    super.dispose();
  }

  Future<void> _disposeAll() async {
    try {
      if (_rtmClient != null) {
        if (_rtmChannelJoined)
          await _rtmClient!.unsubscribe(widget.credentials.channelName);
        if (_rtmLoggedIn) await _rtmClient!.logout();
        await _rtmClient!.release();
        _rtmClient = null;
      }
      await _engine.leaveChannel();
      await _engine.release();
    } catch (e) {}
  }

  Future<void> initAgora() async {
    try {
      await [Permission.microphone, Permission.camera].request();

      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(
        appId: widget.credentials.appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            if (mounted) {
              setState(() => _localUserJoined = true);
            }
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            if (mounted) {
              setState(() {
                if (!_remoteUsers.contains(remoteUid))
                  _remoteUsers.add(remoteUid);
                _remoteUid = remoteUid;
              });
            }
          },
          onUserOffline: (connection, remoteUid, reason) {
            if (mounted) {
              setState(() {
                _remoteUsers.remove(remoteUid);
                if (_remoteUid == remoteUid) {
                  _remoteUid = null;
                }
              });
            }
          },
          onError: (err, msg) {
            debugPrint("Agora Error: $err, $msg");
          },
        ),
      );

      await _engine.enableVideo();

      if (widget.isHost) {
        await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
        await _engine.startPreview();
      } else {
        await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
      }

      int myUid = int.tryParse(widget.credentials.userId) ?? 0;

      await _engine.joinChannel(
        token: widget.credentials.token,
        channelId: widget.credentials.channelName,
        uid: myUid,
        options: ChannelMediaOptions(
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
          publishCameraTrack: widget.isHost,
          publishMicrophoneTrack: widget.isHost,
          clientRoleType: widget.isHost
              ? ClientRoleType.clientRoleBroadcaster
              : ClientRoleType.clientRoleAudience,
        ),
      );
    } catch (e) {
      debugPrint("Init Agora Error: $e");
    }
  }

  void startHeartbeat() {
    debugPrint(
        '[LIVE UI] LivePage heartbeat started (every 5s → updateLiveStatus)');
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      AstroApiService.updateLiveStatus(
          int.tryParse(widget.credentials.astrologerLiveUserId) ?? 0);
    });
  }

  void _addChatMessage(ChatMessage message) {
    if (mounted) {
      setState(() {
        _onScreenMessages.insert(
            0, message); // Latest message at top for reverse list
        if (_onScreenMessages.length > 30) _onScreenMessages.removeLast();
      });
    }
  }

  Future<void> _sendMessage(
      {String defaultmessage = "", bool sendToApi = false}) async {
    String text = defaultmessage.isNotEmpty
        ? defaultmessage
        : _chatController.text.trim();
    if (text.isEmpty || _rtmClient == null || !_rtmChannelJoined) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: widget.credentials.userId,
      userName: widget.credentials.userName,
      message: text,
      timestamp: DateTime.now(),
      customType: 'UserMessage',
      uid: widget.credentials.uuid,
    );

    try {
      if (defaultmessage.isEmpty || sendToApi) {
        debugPrint('[LIVE UI] sendLiveChatMessage (also RTM publish)');
        await AstroApiService.sendLiveChatMessage(
          astrologerLiveUserId:
              int.tryParse(widget.credentials.astrologerLiveUserId) ?? 0,
          message: text,
        );
      }
      await _rtmClient!.publish(
          widget.credentials.channelName, jsonEncode(message.toJson()),
          channelType: RtmChannelType.message, customType: 'ChatMessage');
      _addChatMessage(message);
      if (defaultmessage.isEmpty) _chatController.clear();
    } catch (e) {}
  }

  void _showGiftsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => GiftsScreen(
        astrologerId: widget.astrologerId,
        liveId: widget.liveId,
        onGiftSent: (Gift sentGift) async {
          try {
            final freshUserData = await ReusableFunction().getUserData();
            if (freshUserData != null && mounted)
              WalletEventBus().updateWallet(freshUserData);
          } catch (e) {}
        },
      ),
    );
  }

  void _leaveChannel() async {
    await _disposeAll();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildVideoView()),
            _buildTopBar(),
            _buildOnScreenChat(),
            if (widget.isHost) _buildHostControls(),
            if (!widget.isHost) _buildAudienceControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoView() {
    if (!_localUserJoined) {
      return const Center(child: CircularProgressIndicator(color: Colors.pink));
    }

    if (widget.isHost) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      // For Audience: If remote host is present
      if (_remoteUid != null) {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine,
            canvas: VideoCanvas(uid: _remoteUid),
            connection:
                RtcConnection(channelId: widget.credentials.channelName),
          ),
        );
      } else {
        return Container(
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const CircularProgressIndicator(color: Colors.orange),
              const SizedBox(height: 20),
              Text("Waiting for Host to join...",
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
        );
      }
    }
  }

  Widget _buildOnScreenChat() {
    return Positioned(
      bottom: 120,
      left: 15,
      right: 70, // Keep space for gift button
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.35,
        child: ListView.builder(
          reverse: true, // Newer messages at bottom
          itemCount: _onScreenMessages.length,
          itemBuilder: (context, index) {
            return _buildChatMessage(_onScreenMessages[index]);
          },
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent])),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(5)),
              child: const Text('LIVE',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.visibility, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text('${_remoteUsers.length + (widget.isHost ? 1 : 0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12))
              ]),
            ),
            const Spacer(),
            GestureDetector(
                onTap: _leaveChannel,
                child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 20))),
          ],
        ),
      ),
    );
  }

  Widget _buildHostControls() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
              icon: _isAudioMuted ? Icons.mic_off : Icons.mic,
              color: _isAudioMuted ? Colors.red : Colors.white,
              onTap: () {
                setState(() => _isAudioMuted = !_isAudioMuted);
                _engine.muteLocalAudioStream(_isAudioMuted);
              }),
          _buildControlButton(
              icon: _isVideoMuted ? Icons.videocam_off : Icons.videocam,
              color: _isVideoMuted ? Colors.red : Colors.white,
              onTap: () {
                setState(() => _isVideoMuted = !_isVideoMuted);
                _engine.muteLocalVideoStream(_isVideoMuted);
              }),
          _buildControlButton(
              icon: Icons.switch_camera,
              color: Colors.white,
              onTap: () => _engine.switchCamera()),
        ],
      ),
    );
  }

  Widget _buildAudienceControls() {
    return Positioned(
      bottom: 20,
      left: 15,
      right: 15,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white24)),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: _chatController,
                          focusNode: _chatFocusNode,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none),
                          onSubmitted: (_) => _sendMessage())),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.pinkAccent),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildGiftButton(),
        ],
      ),
    );
  }

  Widget _buildGiftButton() {
    return GestureDetector(
      onTap: _showGiftsBottomSheet,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) => Transform.scale(
          scale: 1.0 + (0.1 * _pulseController.value),
          child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [Colors.pink, Colors.red]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.pink.withOpacity(0.5), blurRadius: 10)
                  ]),
              child: const Icon(Icons.card_giftcard,
                  color: Colors.white, size: 24)),
        ),
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    bool isGift = message.customType == 'GiftMessage';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isGift
            ? Colors.pink.withOpacity(0.3)
            : Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${message.userName}: ",
              style: TextStyle(
                  color: isGift ? Colors.pink : Colors.pinkAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          Expanded(
            child: Text(message.message,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24)),
            child: Icon(icon, color: color, size: 24)));
  }
}
