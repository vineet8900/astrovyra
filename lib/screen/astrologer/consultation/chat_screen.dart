
import 'dart:async';
import 'package:astrokavach/api/astro_list_detail_api.dart';
import 'package:astrokavach/api/consultation/chat_api/can_chat_api.dart';
import 'package:astrokavach/api/consultation/chat_api/chat_log_api.dart';
import 'package:astrokavach/api/consultation/chat_api/chat_send_api.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/custom_elevated_btn.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/astrologer/astro_detail_model.dart';
import 'package:astrokavach/model/astrologer/chat_model/can_chat_model.dart';
import 'package:astrokavach/model/astrologer/chat_model/chat_log_model.dart';
import 'package:astrokavach/screen/astrologer/home_screen.dart';
import 'package:astrokavach/screen/thankyou_screen.dart';
import 'package:astrokavach/screen/wallet/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  bool? leadingbtn;
  String? slug;
  int? consultationid;
  String? apitoken;
  int? timeslot;
  bool? isCompleted;

  ChatScreen({
    super.key,
    this.slug,
    this.consultationid,
    this.apitoken,
    this.timeslot,
    this.leadingbtn = false,
    this.isCompleted = false,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FocusNode _focusNode = FocusNode();
  String formattedTime = DateFormat.jm().format(DateTime.now());
  TextEditingController messageController = TextEditingController();
  CanChatApiService canChatApiService = CanChatApiService();
  CanChatModel? canChatModel;
  ChatLogApiSevice chatLogApiSevice = ChatLogApiSevice();
  ChatSendApiService chatSendApiService = ChatSendApiService();
  AstrologerDetailApiService astrologerDetailApiService =
      AstrologerDetailApiService();
  AstroDetailModel? astroDetailModel;
  AstroDetailDatum? astroDetailDatum;
  var result;
  bool isloading = false;
  bool showTextBox = true;
  String? apiToken;
  int? chatid;
  String? status;
  String astroname = 'Astrologer';
  String expertise = '';
  String lawyerimg = '';
  ChatLogModel? chatLogModel;
  List<ChatListDatum> chatlist = [];
  String? startTime;
  int? consultationTimeInMinutes;
  Timer? _canChatTimer;
  Timer? rechargePopupTimer;
  bool _isPopupShown = false;
  Timer? _countdownTimer;
  String countdown = "";
  String? canchatmsg;
  String? chatlogmsg;
  int? rechagecountdown;
  String? whenn;
  bool isSendEnabled = false;
  bool showTimer = false;

  Future<void> getcanchat() async {
    setState(() {
      isloading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');

    canChatModel = await canChatApiService.canchatapidata(
      apiToken.toString(),
      widget.consultationid!,
    );

    if (canChatModel != null) {
      astroname = canChatModel!.astrologerDetails?.name ?? "";
      if (canChatModel!.success == true) {
        status = canChatModel!.status;
        chatid = canChatModel!.chatId;
        startTime = canChatModel!.consultationDetail?.startTime ?? "";
        whenn = canChatModel!.whenn ?? "now";
        canchatmsg = canChatModel!.message ?? "";
        if (canChatModel?.astrologerDetails?.slug != null) {
          astroDetailModel = await astrologerDetailApiService.fetchAstroDetails(
            canChatModel!.astrologerDetails!.slug,
          );
          astroDetailDatum = astroDetailModel?.data?.detail;
        }

        String countdownVal = canChatModel!.countdown ?? "";
        rechagecountdown = canChatModel!.consultationDetail!.rechargepupupcount;

        if (status == "wait") {
          if (!_isPopupShown) {
            _isPopupShown = true;
            setState(() {
              isloading = false;
            });
            showCountdownPopup(context, canchatmsg.toString(), countdownVal);
          }

          if (_canChatTimer == null || !_canChatTimer!.isActive) {
            _canChatTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
              await getcanchat();
            });
          }
        } else if (status == "start" || status == "done") {
          setState(() {
            showTimer = true;
          });
          if (status == "done" || widget.isCompleted == true) {
            setState(() {
              showTimer = false;
              showTextBox = false;
            });
          }
          _canChatTimer?.cancel();
          _countdownTimer?.cancel();
          if (rechagecountdown! > 0) {
            rechargePopupTimer = Timer.periodic(Duration(seconds: 1), (timer) {
              if (rechagecountdown == 0) {
                timer.cancel();
                showRechargeDialog(context);
                rechargePopupTimer?.cancel();
              } else {
                if (mounted) {
                  setState(() {
                    rechagecountdown = rechagecountdown! - 1;
                  });
                }
              }
            });
          }

          if (_isPopupShown) {
            Navigator.of(context, rootNavigator: true).pop();
            _isPopupShown = false;
          }

          _chatTimer = Timer.periodic(Duration(seconds: 2), (timer) {
            getchat("continue");
          });

          startCountdown(startTime.toString());
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
        }
      }
    }

    setState(() {
      isloading = false;
    });
  }

  Timer? _chatTimer;
  String? chatstatus;
  bool? leadpopupshown;

  getchat(String chatstatus) async {
    try {
      chatLogModel = await chatLogApiSevice.fetchatloapidata(
          apiToken.toString(), widget.consultationid!, chatid!, chatstatus);

      if (chatLogModel != null) {
        chatlist = chatLogModel?.data ?? [];
        chatstatus = chatLogModel?.status ?? "";
        chatlogmsg = chatLogModel?.message ?? "";
        leadpopupshown = chatLogModel!.consultationDetail!.showLeadPopup;

        if (mounted) {
          setState(() {});
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }

        if (chatstatus == "done" && _chatTimer != null) {
          setState(() {
            showTimer = false;
            showTextBox = false;
          });
          _chatTimer?.cancel();
          _chatTimer = null;
          return false;
        }
      }
    } catch (e) {
      print("Error in getchat(): $e");
    }
  }

  void startCountdown(String startTime) {
    List<String> parts = startTime.split(':');
    if (parts.length != 2) return;

    int minutes = int.tryParse(parts[0]) ?? 0;
    int seconds = int.tryParse(parts[1]) ?? 0;

    remainingSeconds = (minutes * 60) + seconds;
    _timer?.cancel();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        whenn == "later" ? remainingSeconds-- : remainingSeconds++;
      });
    });
  }

  String getFormattedTime() {
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  final ScrollController _scrollController = ScrollController();
  bool isAtBottom = true;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  Timer? _timer;
  int remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isCompleted == true) {
      showTextBox = false;
    }
    getcanchat();

    messageController.addListener(() {
      setState(() {
        isSendEnabled = messageController.text.trim().isNotEmpty;
      });
    });

    _scrollController.addListener(() {
      isAtBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _canChatTimer?.cancel();
    _countdownTimer?.cancel();
    _chatTimer?.cancel();
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: CustomStyles.whiteColor,
                   leading: showTextBox == false
              ? IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              : (astroDetailDatum?.image == null ||
                      astroDetailDatum!.image!.isEmpty)
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Icon(Icons.person, size: 24, color: Colors.black),
                    )
                  : Container(
                      margin: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          astroDetailDatum!.image!,
                          fit: BoxFit.cover,
                          width: 40,
                          height: 40,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person, size: 20);
                          },
                        ),
                      ),
                    ),

          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    astroname.toString(),
                    style: CustomStyles.black14600,
                  ),
                ],
              ),
              Text(
                (astroDetailDatum?.languages?.isNotEmpty ?? false)
                    ? astroDetailDatum!.languages!.join(', ')
                    : '',
                style: CustomStyles.black12400,
              ),
            ],
          ),
          actions: [
            status == "start" && showTimer
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Time", style: CustomStyles.black12400),
                      Text(
                        getFormattedTime(),
                        style: CustomStyles.black14600,
                      ),
                    ],
                  )
                : SizedBox.shrink(),
            SizedBox(width: 10),
            showTimer
                ? GestureDetector(
                    onTap: () async {
                      showdialog(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text("End", style: CustomStyles.white12500),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
            SizedBox(width: 10),
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: chatlist.length,
                itemBuilder: (context, index) {
                  final chat = chatlist[index];
                  final isUser = chat.messageBy == "user";
                  final isSecondUserMessage = index == 1 && isUser;
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 300,
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(
                          color:
                              isUser ? Colors.grey.shade300 : Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chat.message ?? '',
                              style: TextStyle(
                                color: isSecondUserMessage
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              chat.createdAt ?? '',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            showTextBox == false
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Chat has ended.",
                        style: CustomStyles.black14500,
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            focusNode: _focusNode,
                            style: CustomStyles.black14500,
                            onTap: () {
                              Future.delayed(Duration(milliseconds: 300), () {
                                _scrollToBottom();
                              });
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Type a message',
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: CustomStyles.bgcolor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        GestureDetector(
                          onTap: isSendEnabled
                              ? () async {
                                  await chatSendApiService.fetchsendapidata(
                                      apiToken.toString(),
                                      messageController.text,
                                      widget.consultationid!);
                                  // _focusNode.unfocus();
                                  setState(() {
                                    isSendEnabled = false;
                                  });
                                  messageController.clear();
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    _scrollToBottom();
                                  });
                                }
                              : null,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: isSendEnabled
                                  ? const Color(0xFF25D366)
                                  : Colors.grey,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.send,
                                color: isSendEnabled
                                    ? Colors.white
                                    : Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
           SizedBox(height: MediaQuery.of(context).padding.bottom + 15),
          ],
        ),
      ),
    );
  }

  void showdialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(
              "Do you want to end this chat.",
              style: CustomStyles.black14400,
              textAlign: TextAlign.center,
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: CustomOutlinedButton(
                        width: 80,
                        height: 35,
                        text: "Yes",
                        textstyle: CustomStyles.white13600,
                        onPressed: () {
                          getchat("leave");
                          Future.delayed(Duration(seconds: 1), () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ThankyouScreen(
                                          msg:
                                              "Your Intrest Has Been saved Successfully.",
                                        )));
                          });
                        }),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                      child: CustomOutlinedButton(
                          width: 80,
                          height: 35,
                          text: "No",
                          textstyle: CustomStyles.white13600,
                          onPressed: () {
                            Navigator.of(context).pop();
                          }))
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void showCountdownPopup(
      BuildContext parentContext, String msg, String initialTime) {
    List<String> parts = initialTime.split(":");
    int minutes = int.tryParse(parts[0]) ?? 0;
    int seconds = int.tryParse(parts[1]) ?? 0;
    int totalSeconds = (minutes * 60) + seconds;

    BuildContext? dialogContext;

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (context) {
        dialogContext = context;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            _countdownTimer?.cancel();
            _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
              if (totalSeconds > 0) {
                totalSeconds--;
                int displayMinutes = totalSeconds ~/ 60;
                int displaySeconds = totalSeconds % 60;
                setStateDialog(() {
                  countdown =
                      "${displayMinutes.toString().padLeft(2, '0')}:${displaySeconds.toString().padLeft(2, '0')}";
                });
              } else {
                timer.cancel();

                if (dialogContext != null) {
                  Navigator.of(dialogContext!, rootNavigator: true).pop();
                  _isPopupShown = false;
                  getchat("cancel");
                }

                _isPopupShown = false;
                _canChatTimer?.cancel();
                _countdownTimer?.cancel();
                _chatTimer?.cancel();
                _chatTimer = null;

                Future.delayed(Duration(milliseconds: 300), () {
                  showDialog(
                    context: parentContext,
                    barrierDismissible: false,
                    builder: (context) => WillPopScope(
                      onWillPop: () async => false,
                      child: AlertDialog(
                          title: Text(
                            "The Astrologer cannot join the call.",
                            style: CustomStyles.black14600,
                          ),
                          content: Text(
                            "Try again sometime or connect with another Astrologer.",
                            style: CustomStyles.black12500,
                          ),
                          actions: [
                            Center(
                                child: CustomElevatedButton(
                                    text: "Check other Astrologer",
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BottomAppBarScreen(),
                                        ),
                                      );
                                    }))
                          ]),
                    ),
                  );
                });
              }
            });

            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text(
                  msg,
                  style: CustomStyles.black14400,
                  textAlign: TextAlign.center,
                ),
                content: Text(
                  countdown,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        );
      },
    );
  }

  showRechargeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Your wallet balance is low. Please recharge your wallet to avoid any interruption during the consultation.",
                  style: CustomStyles.black12500,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 48),
              ],
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: CustomElevatedButton(
                        text: "Yes",
                        onPressed: () {
                          getchat("leave");
                          _chatTimer?.cancel();
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WalletScreen(),
                            ),
                          );
                        }),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CustomElevatedButton(
                        text: "No",
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
