import 'dart:async';
import 'package:astrokavach/api/phoncallapi/can_call_api.dart';
import 'package:astrokavach/api/phoncallapi/update_phonecall_api.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/custom_elevated_btn.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/phonecallmodel/phonecall.dart';
import 'package:astrokavach/model/phonecallmodel/updatecall.dart';
import 'package:astrokavach/screen/astrologer/consultation/agoravoicecalling.dart';
import 'package:astrokavach/screen/astrologer/home_screen.dart';
import 'package:astrokavach/screen/thankyou_screen.dart';
import 'package:astrokavach/screen/wallet/wallet_screen.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Renamed the class for clarity
class PhoneCallScreen extends StatefulWidget {
  int? consultationid;

  PhoneCallScreen({
    super.key,
    this.consultationid,
  });
  @override
  State<PhoneCallScreen> createState() => _PhoneCallScreenState();
}

class _PhoneCallScreenState extends State<PhoneCallScreen> {
  String lawyername = 'Astrologer';
  bool isloading = false;
  bool leadPopupShowed = false;
  String? apiToken;

  // --- Replaced Models and Services ---
  // callLogModel? callLogModel;
  callLogModel? CallLogModel;
  CanCallApiService canCallApiService = CanCallApiService();
  CancallModel? canCallModel;
  UpdateCallApiService updateCallApiService = UpdateCallApiService();
  // --- End of Replacements ---

  bool joinCall = false;
  bool autoJoinTriggered = false; // New flag to prevent multiple auto joins

  dynamic appID;
  dynamic appSign; // This might be token for Agora
  dynamic userID;
  dynamic userName;
  dynamic callID; // This will be channel name for Agora
  dynamic status;
  Timer? _canCallTimer;
  Timer? rechargePopupTimer;
  bool _isPopupShown = false;

  Timer? _countdownTimer;
  String countdown = "";
  String? canCallMsg;

  String? callLogMsg;
  int? rechagecountdown;
  String? startTime;
  String? whenn;
  Timer? _callStatusTimer;
  bool? leadpopupshown;
  int? consultatioid = 0;
  bool setCallStatusTimer = false;

  Future<void> getCanCall() async {
    setState(() {
      isloading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');

    // Using the new service and model
    canCallModel = await canCallApiService.canvideoapidata(
        apiToken.toString(), consultatioid ?? 0);

    if (canCallModel != null) {
      lawyername = canCallModel!.astrologerDetails?.name ?? "";

      if (canCallModel!.success == true) {
        status = canCallModel!.status;
        appID = canCallModel!.consultationDetail!.appId;
        appSign = canCallModel!
            .consultationDetail!.appSign; // This should be token for Agora
        userID = canCallModel!.consultationDetail!.userId;
        userName = canCallModel!.consultationDetail!.userName.toString();
        callID =
            canCallModel!.consultationDetail!.callId; // Channel name for Agora
        startTime = canCallModel!.consultationDetail?.startTime ?? "";
        whenn = canCallModel!.whenn ?? "now";
        canCallMsg = canCallModel!.message ?? "";
        consultatioid = canCallModel!.consultationDetail!.id;

        String countdownVal = canCallModel!.countdown ?? "";
        rechagecountdown = canCallModel!.consultationDetail!.rechargepupupcount;

        if (status == "wait") {
          if (!_isPopupShown) {
            _isPopupShown = true;
            setState(() {
              isloading = false;
            });
            showCountdownPopup(context, canCallMsg.toString(), countdownVal);
          }

          if (_canCallTimer == null || !_canCallTimer!.isActive) {
            _canCallTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
              await getCanCall();
            });
          }
        } else if (status == "start" || status == "done") {
          _canCallTimer?.cancel();
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

          if (!autoJoinTriggered) {
            autoJoinTriggered = true;

            if (_isPopupShown) {
              Navigator.of(context, rootNavigator: true).pop();
              _isPopupShown = false;
            }

            _joinAgoraCall();
            return; // Return early
          }

          //startCountdown(startTime.toString());
        } else {
          setCallStatusTimer = false;
          consultatioid = 0;
          widget.consultationid = 0;
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

  int remainingSeconds = 0;
  Timer? _timer;
  void startCountdown(String startTime) {
    List<String> parts = startTime.split(':');
    if (parts.length != 2) {
      return;
    }

    int minutes = int.tryParse(parts[0]) ?? 0;
    int seconds = int.tryParse(parts[1]) ?? 0;

    remainingSeconds = (minutes * 60) + seconds;

    _timer?.cancel();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          whenn == "later" ? remainingSeconds-- : remainingSeconds++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  bool _dialogShown = false;

  getUpdateCallStatus(String callStatus) async {
    try {
      if (consultatioid != 0) {
        // Using the new service and model
        CallLogModel = await await updateCallApiService.updatevideoapidata(
            apiToken.toString(), consultatioid ?? 0, callStatus);

        if (callLogModel != null) {
          callStatus = CallLogModel?.status ?? "";
          callLogMsg = CallLogModel?.message ?? "";
          leadpopupshown = CallLogModel!.consultationDetail!.showLeadPopup;

          if (callStatus == "done" && _callStatusTimer != null) {
            _callStatusTimer?.cancel();
            _callStatusTimer = null;

            setCallStatusTimer = false;
            consultatioid = 0;
            widget.consultationid = 0;

            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ThankyouScreen(
                          msg: "Your Intrest Has Been saved Successfully.",
                        )));
          }
        }
      } else {
        if (callStatus == "leave" ||
            callStatus == "cancel" ||
            callStatus == "done") {
          getUpdateCallStatus(callStatus);
        }
      }

      setState(() {});
    } catch (e) {}
  }

  Future<void> _requestPermissions() async {
    // Only microphone permission is essential for a phone call
    var micStatus = await Permission.microphone.request();

    if (micStatus.isDenied) {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text("Microphone permission is required for phone calls."),
      // ));
    }

    if (micStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _init() async {
    await _requestPermissions();
    await getCanCall();
  }

  @override
  void initState() {
    super.initState();
    consultatioid = widget.consultationid;

    _init();
    _dialogShown = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _canCallTimer?.cancel();
    _countdownTimer?.cancel();
    _callStatusTimer?.cancel();
    consultatioid = null;
    super.dispose();
  }

  void _joinAgoraCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgoraVoiceCallScreen(
          appId: appID.toString(),
          token: appSign.toString(),
          channelName: callID.toString(),
          userId: int.tryParse(userID.toString()) ?? 0,
          userName: userName.toString(),
          consultationId: consultatioid ?? 0,

          isvoiceCall: true,
          // --- End of Key Change ---
          astrologerName: lawyername,
        ),
      ),
    ).then((_) {
      // When user returns from Agora call screen
      getUpdateCallStatus("leave");
      setCallStatusTimer = false;
      consultatioid = 0;
      widget.consultationid = 0;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ThankyouScreen(
            msg: "Your consultation has been completed successfully.",
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          // Changed Title
          title: "Phone Call",
          automaticallyImplyLeading: false,
          actions: [],
        ),
        body: Center(
          child: CustomElevatedButton(
            text: "Join Call",
            onPressed: () {
              if (appID != null &&
                  appSign != null &&
                  userID != null &&
                  userName != null &&
                  callID != null) {
                _joinAgoraCall();

                if (!setCallStatusTimer && consultatioid != 0) {
                  setState(() {
                    setCallStatusTimer = true;
                  });
                  _callStatusTimer =
                      Timer.periodic(Duration(seconds: 3), (timer) {
                    // Using the new update function
                    getUpdateCallStatus("continue");
                  });
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Call data not available. Please try again."),
                  ),
                );
              }
            },
          ),
        ),
      ),
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
      useRootNavigator: true,
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
                  // Using the new update function
                  getUpdateCallStatus("cancel");
                }

                _isPopupShown = false;
                _canCallTimer?.cancel();
                _countdownTimer?.cancel();
                _callStatusTimer?.cancel();
                _canCallTimer = null;
                _callStatusTimer = null;

                Future.delayed(Duration(milliseconds: 300), () {
                  showDialog(
                    context: parentContext,
                    barrierDismissible: false,
                    useRootNavigator: true,
                    builder: (context) => AlertDialog(
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
                                    setCallStatusTimer = false;
                                    consultatioid = 0;
                                    widget.consultationid = 0;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BottomAppBarScreen(),
                                      ),
                                    );
                                  }))
                        ]),
                  );
                });
              }
            });

            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text(
                  msg,
                  style: CustomStyles.black14500,
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
      useRootNavigator: true,
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
                          _callStatusTimer?.cancel();
                          _callStatusTimer = null;
                          setCallStatusTimer = false;
                          consultatioid = 0;
                          widget.consultationid = 0;
                          getUpdateCallStatus("leave");

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WalletScreen(),
                            ),
                          );
                        }),
                  ),
                  SizedBox(
                    width: 10,
                  ),
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
