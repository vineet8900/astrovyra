import 'dart:async';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/screen/user_dashboard_screen/user_wallet_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class KundliAIChatScreen extends StatefulWidget {
  final int consultationId;
  final String astrologerName;

  const KundliAIChatScreen({
    Key? key,
    required this.consultationId,
    required this.astrologerName,
  }) : super(key: key);

  @override
  _KundliAIChatScreenState createState() => _KundliAIChatScreenState();
}

class _KundliAIChatScreenState extends State<KundliAIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String _chatStatus = 'continue';
  String? _apiToken;
  int _endAt = 0; // Add this to track end_at value
  bool _showRechargeButton =
      false; // Add this to control recharge button visibility
  Timer? _chatUpdateTimer;
  int _secondsLeft = 0;
  Timer? _chatTimer;
  bool _isAITyping = false;
  static const Color _supportSendGreen = Color(0xFF25D366);
  String _resolvedAstrologerName = '';

  @override
  void initState() {
    super.initState();
    _resolvedAstrologerName = widget.astrologerName.trim();
    _getTokenAndLoad();

    // Start calling the update API every 5 seconds
    _startUpdatingChatTime();
  }

  Future<void> _getTokenAndLoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _apiToken = prefs.getString('api_token');
    await _loadChatHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatTimer?.cancel();
    _chatUpdateTimer?.cancel();
    super.dispose();
  }

  void _stopAllTimers() {
    _chatTimer?.cancel();
    _chatUpdateTimer?.cancel();
  }

  void _startUpdatingChatTime() {
    _chatUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateChatTime();
    });
  }

  Future<void> _updateChatTime() async {
    // Check if widget is still mounted
    if (!mounted) return;

    try {
      final response = await http.post(
        Uri.parse(
            '${CustomStyles.apiBaseUrl}/user/update-chat-time-ai'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiToken',
        },
        body: jsonEncode({
          'consultation_id': widget.consultationId,
        }),
      );

      if (!mounted) return; // Check again after async operation

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          setState(() {
            _chatStatus = data['status'] ?? 'continue';
          });

          // If chat ended, stop the timer
          if (_chatStatus != 'continue') {
            // _chatUpdateTimer?.cancel();
            _stopAllTimers();
          }
        }
      }
    } catch (e) {
       
    }
  }

  Future<void> _loadChatHistory() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${CustomStyles.apiBaseUrl}/user/chat-logs-ai'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiToken',
        },
        body: jsonEncode({
          'consultation_id': widget.consultationId,
          'message': _messageController.text.isEmpty
              ? 'Tell me about my life'
              : _messageController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final List<dynamic> chatData = data['data'] ?? [];
          final dynamic apiName = data['astrologer_name'] ??
              data['consultant_name'] ??
              (data['astrologer'] is Map
                  ? (data['astrologer'] as Map)['name']
                  : null);

          setState(() {
            if (apiName is String && apiName.trim().isNotEmpty) {
              if (_resolvedAstrologerName.isEmpty) {
                _resolvedAstrologerName = apiName.trim();
              }
            }
            _messages =
                chatData.map((msg) => ChatMessage.fromJson(msg)).toList();
            _chatStatus = data['status'] ?? 'continue';
            _endAt = data['end_at'] ?? 0;
            int startAt = data['start_at'] ?? 0;

            // ✅ Recharge button show only if endAt == 0 and status is 'continue'
            _showRechargeButton = (_endAt == 0 && _chatStatus == 'continue');

            // if (_endAt > 0) {
            //   _startCountdown(_endAt);
            // }
            if (startAt >= 0 &&
                _chatStatus == 'continue' &&
                _chatTimer == null) {
              _startCountdownForward(startAt);
            }
          });

          _scrollToBottom();
        }  
      }  
    } catch (e) {
      
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startCountdownForward(int startSeconds) {
    _chatTimer?.cancel();
    _secondsLeft = startSeconds;
    _chatTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsLeft++; // Seconds ko aage badha rahe hain
      });
       
    });
  }

  void _startCountdown(int seconds) {
    _chatTimer?.cancel();
    _secondsLeft = seconds;

    _chatTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
         
      } else {
        timer.cancel();
        setState(() {
          _showRechargeButton = true;
        });

        // ✅ stop all timers when time is finished
        _stopAllTimers();

         
      }
    });
  }

  Future<void> _endChatSession() async {
    bool? confirmEnd = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: const Text("End Chat"),
            content:
                const Text("Are you sure to want to end this chat session"),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Cancel")),
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text("End")),
            ],
          );
        });
    if (confirmEnd != true) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
          Uri.parse(
              '${CustomStyles.apiBaseUrl}/user/update-chat-time-ai'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiToken',
          },
          body: jsonEncode({
            'consultation_id': widget.consultationId,
            'status': 'end', // Pass 'end' status to the API
          }));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _chatStatus = 'end';
          });
          _stopAllTimers();
          // Fluttertoast.showToast(msg: "Chat session ended successfully.");
        } else {
          Fluttertoast.showToast(
              msg: 'Could not end chat.',
              backgroundColor: Colors.red,
              textColor: Colors.white);
        }
      }
    } catch (e) {
      
      Fluttertoast.showToast(
          msg: 'An error occurred. Please try again.',
          backgroundColor: Colors.red,
          textColor: Colors.white);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// ✅ Send message to AI API
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    // Check if recharge is needed
    if (_showRechargeButton) {
      _navigateToRechargeScreen();
      return;
    }

    if (_chatStatus != 'continue') {
      // Fluttertoast.showToast(
      //   msg: 'Chat session has ended',
      //   backgroundColor: Colors.orange,
      //   textColor: Colors.white,
      // );
      return;
    }

    final userMessage = _messageController.text.trim();

    // Show message in UI instantly
    setState(() {
      _messages.add(ChatMessage(
        messageBy: 'user',
        message: userMessage,
        createdAt: DateTime.now().toString(),
      ));
      _isSending = true;
      _isAITyping = true; // ✅ AI typing start
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('${CustomStyles.apiBaseUrl}/user/send-message-ai'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiToken',
        },
        body: jsonEncode({
          'consultation_id': widget.consultationId,
          'message': userMessage,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          if (data['response'] != null) {
            setState(() {
              _isAITyping = false; // ✅ AI typing stop
              _messages.add(ChatMessage(
                messageBy: data['response']['message_by'] ?? 'astrologer',
                message: data['response']['message'] ?? 'No response received',
                createdAt:
                    data['response']['created_at'] ?? DateTime.now().toString(),
              ));
            });
          } else {
            await Future.delayed(const Duration(seconds: 1));
            setState(() {
              _isAITyping = false; // ✅ AI typing stop
            });
            await _loadChatHistory();
          }
          _scrollToBottom();
        } else {
          setState(() {
            _messages.removeLast();
            _isAITyping = false; // ✅ AI typing stop on error
          });
          // Fluttertoast.showToast(
          //   msg: data['message'] ?? 'Failed to send message',
          //   backgroundColor: Colors.red,
          //   textColor: Colors.white,
          // );
        }
      } else {
        setState(() {
          _messages.removeLast();
          _isAITyping = false; // ✅ AI typing stop on error
        });
         
      }
    } catch (e) {
       
      setState(() {
        _messages.removeLast();
        _isAITyping = false; // ✅ AI typing stop on error
      });
     
    } finally {
      setState(() => _isSending = false);
    }
  }

  /// ✅ Navigate to recharge screen
  void _navigateToRechargeScreen() {
    // Replace 'RechargeScreen' with your actual recharge screen widget
    // You can navigate using your preferred method
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => WalletHistoryScreen()));
    // Or if you have the screen widget:
    // Navigator.push(context, MaterialPageRoute(builder: (context) => RechargeScreen()));
  }

  /// ✅ Auto-scroll chat to bottom
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _popWithConsultationId() {
    Navigator.of(context).pop(widget.consultationId);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _popWithConsultationId();
        return false;
      },
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: _popWithConsultationId,
        ),
        centerTitle: false,
        titleSpacing: 8,
        title: Text(
          _resolvedAstrologerName.isNotEmpty
              ? _resolvedAstrologerName
              : 'Astrologer',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.red,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: CustomStyles.whiteColor,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
        foregroundColor: Colors.black,
        actions: [
          if (_secondsLeft >= 0 &&
              _chatStatus == 'continue' &&
              !_showRechargeButton)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: CustomStyles.darkgreen, width: 1.5)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer, size: 15, color: CustomStyles.green),
                    const SizedBox(width: 4),
                    Text(
                      _formatSeconds(_secondsLeft),
                      style: TextStyle(
                        color: CustomStyles.green,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          IconButton(
            tooltip: 'End Chat',
            icon: const Icon(Icons.call_end, color: Colors.red),
            onPressed: _chatStatus == 'continue' ? _endChatSession : null,
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Show recharge notification when time is up
            if (_showRechargeButton)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.red.shade100,
                child: Row(
                  children: [
                    Icon(Icons.access_time,
                        color: Colors.red.shade800, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Chat time expired. Please recharge to continue.',
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _navigateToRechargeScreen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        minimumSize: Size(0, 32),
                      ),
                      child: const Text('Recharge',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),

            if (_chatStatus != 'continue' && !_showRechargeButton)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade100,
                child: Text(
                  'Chat session has ended',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: CustomStyles.bgcolor),
                    )
                  : _messages.isEmpty
                      ? Center(
                          child: Text(
                            'No messages yet. Start your conversation!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length +
                              (_isAITyping
                                  ? 1
                                  : 0), // ✅ Typing indicator ke liye +1
                          itemBuilder: (context, index) {
                            // ✅ Show typing indicator at the end
                            if (index == _messages.length && _isAITyping) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 12, right: 50),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'AI is typing',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final message = _messages[index];
                            final isUser =
                                message.messageBy.toLowerCase() != 'astrologer';

                            return Align(
                              alignment: isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 300,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? Colors.grey.shade300
                                        : Colors.grey[400],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message.message,
                                        style: TextStyle(
                                          color: isUser
                                              ? Colors.black
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        _formatTime(message.createdAt),
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),

            Container(
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, -2),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: _showRechargeButton
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton.icon(
                          onPressed: _navigateToRechargeScreen,
                          icon: const Icon(Icons.account_balance_wallet),
                          label: const Text('Recharge to Continue Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: CustomStyles.black14500,
                              enabled:
                                  _chatStatus == 'continue' && !_isSending,
                              onTap: () {
                                Future.delayed(const Duration(milliseconds: 300),
                                    _scrollToBottom);
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: _chatStatus == 'continue'
                                    ? 'Type a message'
                                    : 'Chat session ended',
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: CustomStyles.bgcolor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              maxLines: null,
                              textCapitalization:
                                  TextCapitalization.sentences,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 15),
                          GestureDetector(
                            onTap: _chatStatus == 'continue' && !_isSending
                                ? _sendMessage
                                : null,
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: _chatStatus == 'continue' && !_isSending
                                    ? _supportSendGreen
                                    : Colors.grey,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _isSending
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        Icons.send,
                                        color: _chatStatus == 'continue' &&
                                                !_isSending
                                            ? Colors.white
                                            : Colors.grey[400],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  String _formatSeconds(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatTime(String dateTimeString) {
    try {
      if (dateTimeString.toLowerCase().contains('am') ||
          dateTimeString.toLowerCase().contains('pm')) {
        return dateTimeString;
      }
      final dateTime = DateTime.parse(dateTimeString);
      int hour = dateTime.hour;
      String period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) {
        hour -= 12;
      } else if (hour == 0) {
        hour = 12;
      }
      return '${hour.toString()}:${dateTime.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return dateTimeString;
    }
  }
}

String _formatTime(String dateTimeString) {
  try {
    // Check if it's already in time format (like "03:45 pm")
    if (dateTimeString.toLowerCase().contains('am') ||
        dateTimeString.toLowerCase().contains('pm')) {
      return dateTimeString; // Return as is
    }

    // If it's a full datetime string, parse and format
    final dateTime = DateTime.parse(dateTimeString);
    int hour = dateTime.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) {
      hour -= 12;
    } else if (hour == 0) {
      hour = 12;
    }
    return '${hour.toString()}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  } catch (e) {
    // Fallback: return the original string
    return dateTimeString;
  }
}

class ChatMessage {
  final String messageBy;
  final String message;
  final String createdAt;

  ChatMessage({
    required this.messageBy,
    required this.message,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageBy: json['message_by'] ?? 'user',
      message: json['message'] ?? '',
      createdAt: json['created_at'] ?? DateTime.now().toString(),
    );
  }
}
