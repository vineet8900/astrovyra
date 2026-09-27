// lib/model/join_live_model.dart

import 'dart:convert';

// import 'dart.convert';

JoinLiveResponse joinLiveResponseFromJson(String str) => JoinLiveResponse.fromJson(json.decode(str));

class JoinLiveResponse {
    final bool success;
    final ResponseData data;

    JoinLiveResponse({
        required this.success,
        required this.data,
    });

    factory JoinLiveResponse.fromJson(Map<String, dynamic> json) => JoinLiveResponse(
        success: json["success"] ?? false,
        data: ResponseData.fromJson(json["data"] ?? {}),
    );
}

class ResponseData {
    final ZegoCredentials credentials;

    ResponseData({
        required this.credentials,
    });

    factory ResponseData.fromJson(Map<String, dynamic> json) => ResponseData(
        credentials: ZegoCredentials.fromJson(json["credientials"] ?? {}),
    );
}

class   ZegoCredentials {
    final String userId;
    final String userName;
    final String mode;
    final String role;
    final String logo;
    final String appId;
    final String appSecret;
    final String appSign;
    final String rtmtoken;
    final String Uid;
    final String roomId;
    final int astrologerLiveUserId;

    ZegoCredentials({
        required this.userId,
        required this.userName,
        required this.mode,
        required this.role,
        required this.logo,
        required this.appId,
        required this.appSecret,
        required this.appSign,
        required this.roomId,
        required this.Uid,
        required this.astrologerLiveUserId,
        required this.rtmtoken,
    });

    factory ZegoCredentials.fromJson(Map<String, dynamic> json) => ZegoCredentials(
        userId: json["user_id"]?.toString() ?? "",
        userName: json["user_name"] ?? "",
        mode: json["mode"] ?? "",
        role: json["role"] ?? "",
        logo: json["logo"] ?? "",
        appId: json["app_id"] ?? 0,
        appSecret: json["app_secret"] ?? "",
        appSign: json["app_sign"] ?? "",
        rtmtoken: json["rtm_token"],
        roomId: json["room_id"] ?? "",
        Uid: json["uid"],
        astrologerLiveUserId: json["astrologer_live_user_id"] ?? 0,
    );
}