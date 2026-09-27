import 'dart:async';
import 'package:astrokavach/api/consultation/video_call_api/can_video_api.dart';
import 'package:astrokavach/api/consultation/video_call_api/update_videocall_api.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/custom_elevated_btn.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/astrologer/video_api_model/can_videocall_model.dart';
import 'package:astrokavach/model/astrologer/video_api_model/update_videcallmodel.dart';
import 'package:astrokavach/screen/agora/video_calling.dart';
import 'package:astrokavach/screen/astrologer/home_screen.dart';
import 'package:astrokavach/screen/thankyou_screen.dart';
import 'package:astrokavach/screen/wallet/wallet_screen.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
// Remove ZegoCloud imports and add Agora screen import
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
//import 'package:jyotish_setu/screen/agora_call_screen.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart';

class VideoWebviewScreen extends StatefulWidget {
  int? consultationid;

  VideoWebviewScreen({
    super.key,
    this.consultationid,
  });
  @override
  State<VideoWebviewScreen> createState() => _VideoWebviewScreenState();
}

class _VideoWebviewScreenState extends State<VideoWebviewScreen> {
  String lawyername = 'Astrologer';
  bool isloading = false;
  bool leadPopupShowed = false;
  String? apiToken;
  VideoLogModel? videoLogModel;
  CanVideoApiService canVideoApiService = CanVideoApiService();
  CanVideoCallModel? canVideoCallModel;
  UpdateVideoApiService updatevideoapiservice = UpdateVideoApiService();

  // Remove ZegoCloud controller and add Agora related variables
  // final ZegoUIKitPrebuiltCallController videocallController = ZegoUIKitPrebuiltCallController();

  bool joinCall = false;
  bool autoJoinTriggered = false;
  dynamic appID;
  dynamic appSign; // This might be token for Agora
  dynamic userID;
  dynamic userName;
  dynamic callID; // This will be channel name for Agora
  dynamic status;
  Timer? _canVideoTimer;
  Timer? rechargePopupTimer;
  bool _isPopupShown = false;

  Timer? _countdownTimer;
  String countdown = "";
  String? canvideomsg;

  String? videologmsg;
  int? rechagecountdown;
  String? startTime;
  String? whenn;
  Timer? _videoTimer;
  bool? leadpopupshown;
  int? consultatioid = 0;
  bool setvideotimer = false;

  Future<void> getcanvideo() async {
    setState(() {
      isloading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');

    canVideoCallModel = await canVideoApiService.canvideoapidata(
        apiToken.toString(), consultatioid ?? 0);
    if (canVideoCallModel != null) {
      lawyername = canVideoCallModel!.astrologerDetails?.name ?? "";

      if (canVideoCallModel!.success == true) {
        status = canVideoCallModel!.status;
        appID = canVideoCallModel!.consultationDetail!.appId;
        appSign = canVideoCallModel!
            .consultationDetail!.appSign; // This should be token for Agora
        userID = canVideoCallModel!.consultationDetail!.userId;
        userName = canVideoCallModel!.consultationDetail!.userName.toString();
        callID = canVideoCallModel!
            .consultationDetail!.callId; // Channel name for Agora
        startTime = canVideoCallModel!.consultationDetail?.startTime ?? "";
        whenn = canVideoCallModel!.whenn ?? "now";
        canvideomsg = canVideoCallModel!.message ?? "";
        consultatioid = canVideoCallModel!.consultationDetail!.id;
       
        String countdownVal = canVideoCallModel!.countdown ?? "";
        rechagecountdown =
            canVideoCallModel!.consultationDetail!.rechargepupupcount;

        

        if (status == "wait") {
          if (!_isPopupShown) {
            _isPopupShown = true;
            setState(() {
              isloading = false;
            });
            showCountdownPopup(context, canvideomsg.toString(), countdownVal);
          }

          if (_canVideoTimer == null || !_canVideoTimer!.isActive) {
            _canVideoTimer =
                Timer.periodic(Duration(seconds: 3), (timer) async {
              await getcanvideo();
            });
          }
        } else if (status == "start" || status == "done") {
          _canVideoTimer?.cancel();
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

          // ================== AUTO-JOIN LOGIC START ==================
          if (!autoJoinTriggered) {
            autoJoinTriggered = true; // Flag set to prevent re-joining

            // Agar countdown popup dikh raha hai to use band kar do
            if (_isPopupShown) {
              Navigator.of(context, rootNavigator: true).pop();
              _isPopupShown = false;
            }

            _joinAgoraCall(); // Seedhe call join karo
            return; // Yahan se function ko rok do taki aage ka code na chale
          }
          // =================== AUTO-JOIN LOGIC END ===================

          if (_isPopupShown) {
            Navigator.of(context, rootNavigator: true).pop();
            _isPopupShown = false;
          }

          startCountdown(startTime.toString());
        } else {
          setvideotimer = false;
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

  getupdatevideo(String videostatus) async {
    
    try {
      if (consultatioid != 0) {
        videoLogModel = await await updatevideoapiservice.updatevideoapidata(
            apiToken.toString(), consultatioid ?? 0, videostatus);
       
        if (videoLogModel != null) {
          videostatus = videoLogModel?.status ?? "";
          videologmsg = videoLogModel?.message ?? "";
          leadpopupshown = videoLogModel!.consultationDetail!.showLeadPopup;

          if (videostatus == "done" && _videoTimer != null) {
            _videoTimer?.cancel();
            _videoTimer = null;
            
            setvideotimer = false;
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
        if (videostatus == "leave" ||
            videostatus == "cancel" ||
            videostatus == "done") {
          getupdatevideo(videostatus);
        }
      }

      setState(() {});
    } catch (e) {
      
    }
  }

  Future<void> _requestPermissions() async {
    var cameraStatus = await Permission.camera.request();
    var micStatus = await Permission.microphone.request();

    if (cameraStatus.isDenied || micStatus.isDenied) {
      
    }

    if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _init() async {
    await _requestPermissions();
    await getcanvideo();
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
    _canVideoTimer?.cancel();
    _countdownTimer?.cancel();
    _videoTimer?.cancel();
    consultatioid = null;
    super.dispose();
  }

  // Navigate to Agora call screen instead of showing ZegoCloud UI
  void _joinAgoraCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgoraVideoCallScreen(
          appId: appID.toString(),
          token: appSign.toString(), // Using appSign as token
          channelName: callID.toString(), // Using callID as channel name
          userId: int.tryParse(userID.toString()) ?? 0,
          userName: userName.toString(),
          consultationId: consultatioid ?? 0,
          isVideoCall: true, // Set to true for video call, false for audio call
          astrologerName: lawyername,
        ),
      ),
    ).then((_) {
      // When user returns from Agora call screen
      getupdatevideo("leave");
      setvideotimer = false;
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
          title: "Video Call",
          automaticallyImplyLeading: false,
          actions: [],
        ),
        body: Center(
          child: CustomElevatedButton(
            text: "Join video Call",
            onPressed: () {
              // Check if all required data is available
              if (appID != null &&
                  appSign != null &&
                  userID != null &&
                  userName != null &&
                  callID != null) {
                _joinAgoraCall();

                // Start the video timer for status updates
                if (!setvideotimer && consultatioid != 0) {
                  
                  setState(() {
                    setvideotimer = true;
                  });
                  _videoTimer = Timer.periodic(Duration(seconds: 3), (timer) {
                    getupdatevideo("continue");
                  });
                }
              } else {
                // Show error message if data is not available
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
                  getupdatevideo("cancel");
                }

                _isPopupShown = false;
                _canVideoTimer?.cancel();
                _countdownTimer?.cancel();
                _videoTimer?.cancel();
                _canVideoTimer = null;
                _videoTimer = null;

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
                                    setvideotimer = false;
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
                          _videoTimer?.cancel();
                          _videoTimer = null;
                          setvideotimer = false;
                          consultatioid = 0;
                          widget.consultationid = 0;
                          getupdatevideo("leave");

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
