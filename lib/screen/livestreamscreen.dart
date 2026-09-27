

import 'dart:async';

import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/cart_icon.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/offline_banner.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Livemodelstream/livemodelstream.dart';
import 'package:astrokavach/screen/live_page.dart';
import 'package:astrokavach/screen/youtubevideo/blinkingliveindicator.dart';
import 'package:astrokavach/utils/network_connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LiveAstrologerListScreen extends StatefulWidget {
  const LiveAstrologerListScreen({Key? key}) : super(key: key);

  @override
  State<LiveAstrologerListScreen> createState() =>
      _LiveAstrologerListScreenState();
}

class _LiveAstrologerListScreenState extends State<LiveAstrologerListScreen> {
  List<LiveAstrologer> liveAstrologerList = [];

  bool isNetworkError = false;
  Timer? _connectivityTimer;
  bool isLoading = true;
  bool isJoiningLive = false;
  dynamic error;

  // Responsive helper methods
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  double responsiveHeight(double percentage) =>
      screenHeight * (percentage / 100);
  double responsiveWidth(double percentage) => screenWidth * (percentage / 100);
  double responsiveFontSize(double baseSize) => baseSize * (screenWidth / 375);

  @override
  void initState() {
    super.initState();
    // _checkNetworkConnectivity();
    setupNetworkListener();
    _fetchData();
  }

  void setupNetworkListener() {
    _checkNetworkConnectivity();
    _connectivityTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _checkNetworkConnectivity();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkNetworkConnectivity() async {
    final ok = await checkDeviceHasInternet();
    if (!mounted) return;
    setState(() => isNetworkError = !ok);
  }

  Future<void> _fetchData() async {
    debugPrint('[LIVE UI] LiveAstrologerListScreen._fetchData()');
    if (mounted) setState(() => isLoading = true);
    liveAstrologerList = await AstroApiService.fetchLiveAstrologers() ?? [];
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _connectivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
     appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
        title: 'live_astrologer'.tr,
        actions: [
          CartIcon.appBarAction(),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(),
          if (isNetworkError && !isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: OfflineBanner(onRetry: _fetchData),
              ),
            ),
          if (isJoiningLive)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: CustomStyles.bgcolor,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: responsiveHeight(2)),
                    Text(
                      'joining_live_session'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsiveFontSize(16),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: CustomStyles.bgcolor),
            SizedBox(height: responsiveHeight(2)),
            Text('loading_live_astrologers'.tr,
                style: TextStyle(
                    fontSize: responsiveFontSize(16), color: Colors.grey)),
          ],
        ),
      );
    }

    if (liveAstrologerList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off_outlined,
                size: responsiveWidth(20), color: Colors.grey.shade400),
            SizedBox(height: responsiveHeight(2.5)),
            Text("No Astrologers Live",
                style: TextStyle(
                    fontSize: responsiveFontSize(20),
                    fontWeight: FontWeight.bold)),
            SizedBox(height: responsiveHeight(1.2)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsiveWidth(10)),
              child: Text("Please check back later to join a live session.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: responsiveFontSize(14),
                      color: Colors.grey.shade600)),
            ),
            SizedBox(height: responsiveHeight(2.5)),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: Icon(Icons.refresh_rounded,
                  color: Colors.white, size: responsiveFontSize(18)),
              label: Text(
                'refresh'.tr,
                style: TextStyle(
                    color: Colors.white, fontSize: responsiveFontSize(14)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveWidth(6),
                  vertical: responsiveHeight(1.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: CustomStyles.bgcolor,
      child: ListView.builder(
        padding: EdgeInsets.all(responsiveWidth(3)),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: liveAstrologerList.length,
        itemBuilder: (context, index) {
          final astrologer = liveAstrologerList[index];
          return _buildAstrologerCard(astrologer);
        },
      ),
    );
  }

  Widget _buildAstrologerCard(LiveAstrologer astrologer) {
    bool isScheduled = astrologer.status.toLowerCase() == 'scheduled';

    String formattedTime = "";

    if (isScheduled && astrologer.startAt.isNotEmpty) {
      try {
        DateTime startTime =
            DateFormat("yyyy-MM-dd HH:mm:ss").parse(astrologer.startAt);
        String startTimeFormatted =
            "Today, ${DateFormat.jm().format(startTime)}";

        String endTimeFormatted = "";
        if (astrologer.endAt != null && astrologer.endAt.isNotEmpty) {
          try {
            DateTime endTime =
                DateFormat("yyyy-MM-dd HH:mm:ss").parse(astrologer.endAt);
            //  endTimeFormatted = " - ${DateFormat.jm().format(endTime)}";
          } catch (e) {
            endTimeFormatted = "";
          }
        }

        formattedTime = "$startTimeFormatted$endTimeFormatted";
      } catch (e) {
        formattedTime = astrologer.startAt;
      }
    } else if (!isScheduled && astrologer.startAt.isNotEmpty) {
      try {
        DateTime startTime =
            DateFormat("yyyy-MM-dd HH:mm:ss").parse(astrologer.startAt);
        formattedTime = "Today, ${DateFormat.jm().format(startTime)}";
      } catch (e) {
        formattedTime = "Live Now";
      }
    } else {
      formattedTime = "Live Now";
    }

    return Container(
      margin: EdgeInsets.only(bottom: responsiveHeight(1.5)),
      height: responsiveHeight(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsiveWidth(4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(responsiveWidth(4)),
        child: Stack(
          children: [
            // Background Banner
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(responsiveWidth(4)),
                image: DecorationImage(
                  image: AssetImage('assets/kismis.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Content
            Row(
              children: [
                // Profile Image - Responsive
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: responsiveWidth(20),
                    height: responsiveHeight(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(responsiveWidth(3)),
                      border: Border.all(
                          color: Colors.white, width: responsiveWidth(0.2)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(responsiveWidth(2.5)),
                      child: astrologer.astrologerImage.isNotEmpty
                          ? Image.network(
                              astrologer.astrologerImage,
                              fit: BoxFit.cover,
                              width: responsiveWidth(20),
                              height: responsiveHeight(15),
                              errorBuilder: (_, __, ___) => Icon(Icons.person,
                                  size: responsiveFontSize(40)),
                            )
                          : Icon(Icons.person, size: responsiveFontSize(40)),
                    ),
                  ),
                ),

                SizedBox(width: responsiveWidth(3)),

                // Astrologer Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        astrologer.name,
                        style: TextStyle(
                            fontSize: responsiveFontSize(16),
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: responsiveHeight(0.5)),
                      Text(
                        astrologer.mode,
                        style: TextStyle(
                            fontSize: responsiveFontSize(13),
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.95)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: responsiveHeight(0.4)),
                        child: Text(
                          formattedTime,
                          style: TextStyle(
                              fontSize: responsiveFontSize(11),
                              color: isScheduled
                                  ? Colors.yellowAccent
                                  : Colors.yellowAccent,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Top Right Badge
            Positioned(
              top: responsiveHeight(1.2),
              right: responsiveWidth(2.5),
              child: isScheduled ? _buildScheduledBadge() : _buildLiveBadge(),
            ),

            // Bottom Right Button
            Positioned(
              bottom: responsiveHeight(1.2),
              right: responsiveWidth(2.5),
              child: isScheduled
                  ? _buildNotifyMeButton(astrologer.astrologerId)
                  : _buildJoinNowButton(astrologer),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveWidth(2),
        vertical: responsiveHeight(0.5),
      ),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(responsiveWidth(2.5)),
        // border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlinkingLiveIndicator(
            size: responsiveWidth(1.3),
            color: Colors.white,
          ),
          // Container(
          //     width: responsiveWidth(1.3),
          //     height: responsiveWidth(1.3),
          //     decoration:
          //         BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          SizedBox(width: responsiveWidth(0.8)),
          Text('LIVE',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: responsiveFontSize(9))),
        ],
      ),
    );
  }

  Widget _buildScheduledBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveWidth(2),
        vertical: responsiveHeight(0.5),
      ),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(responsiveWidth(2.5)),
        // border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications,
              size: responsiveFontSize(12), color: Colors.black),
          SizedBox(width: responsiveWidth(0.8)),
          Text('Scheduled',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: responsiveFontSize(9))),
        ],
      ),
    );
  }

  Widget _buildJoinNowButton(LiveAstrologer astrologer) {
    return GestureDetector(
      onTap: () async {
        setState(() => isJoiningLive = true);
        debugPrint(
            '[LIVE UI] Join Now tapped → joinLiveStream liveId=${astrologer.liveId}');
        final credentials =
            await AstroApiService.joinLiveStream(astrologer.liveId);
        if (!mounted) return;
        setState(() => isJoiningLive = false);

        if (credentials != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LivePage(
                astrologerId: astrologer.astrologerId,
                liveId: astrologer.liveId,
                credentials: AgoraCredentials(
                  appId: credentials.appId,
                  token: credentials.appSecret,
                  channelName: credentials.roomId,
                  userId: credentials.userId,
                  userName: credentials.userName,
                  astrologerLiveUserId:
                      credentials.astrologerLiveUserId.toString(),
                  uuid: credentials.Uid.toString(),
                  rtmtoken: credentials.rtmtoken,
                ),
                isHost: false,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsiveWidth(3.5),
          vertical: responsiveHeight(0.5),
        ),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(responsiveWidth(5)),
        ),
        child: Text('Join Now',
            style: TextStyle(
                fontSize: responsiveFontSize(12),
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
    );
  }

  Widget _buildNotifyMeButton(int astrologerId) {
    return GestureDetector(
      onTap: () async {
        debugPrint('[LIVE UI] Notify Me tapped astrologerId=$astrologerId');
        await AstroApiService.notifyUser(
          astrologerId: astrologerId,
          type: "astrologer-live",
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsiveWidth(3.5),
          vertical: responsiveHeight(0.3),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(responsiveWidth(5)),
          border: Border.all(color: Colors.pink, width: 1.5),
        ),
        child: Text('Notify Me',
            style: TextStyle(
                fontSize: responsiveFontSize(10),
                fontWeight: FontWeight.bold,
                color: Colors.pink)),
      ),
    );
  }
}

