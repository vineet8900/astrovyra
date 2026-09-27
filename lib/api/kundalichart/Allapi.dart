import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:astrokavach/model/AIastrologermodel/aiastrologer.dart';
import 'package:astrokavach/model/AIastrologermodel/aiconsulationlist.dart';
import 'package:astrokavach/model/AIastrologermodel/airesponse.dart';
import 'package:astrokavach/model/AIastrologermodel/airesponsechatlog.dart';
import 'package:astrokavach/model/AddressModel/ordermodel.dart';
import 'package:astrokavach/model/AddressModel/ordermodelscreen.dart';
import 'package:astrokavach/model/Gemstonemodel.dart';
import 'package:astrokavach/model/Livegiftmodel/lifesentmodel.dart';
import 'package:astrokavach/model/Livegiftmodel/livegiftmodel.dart';
import 'package:astrokavach/model/Livemodelstream/liveastrologermodel.dart';
import 'package:astrokavach/model/Livemodelstream/livemodelstream.dart';
import 'package:astrokavach/model/Livemodelstream/livestreamupdate.dart';
import 'package:astrokavach/model/Supportmodel.dart/supportmodel.dart';
import 'package:astrokavach/model/Supportticketresponse/supportticketresponse.dart';
import 'package:astrokavach/model/aichatmodel/aichatmodel.dart';
import 'package:astrokavach/model/cardupdatemodel/cartupdate.dart';
import 'package:astrokavach/model/kundalichange/ashtavar.dart';
import 'package:astrokavach/model/kundalichange/doshanew.dart';
import 'package:astrokavach/model/kundalichange/gemstone.dart';
import 'package:astrokavach/model/kundalichange/jaiminkarasmodel.dart';
import 'package:astrokavach/model/kundalichange/kundalibasic.dart';
import 'package:astrokavach/model/kundalichange/kundalimahadash.dart';
import 'package:astrokavach/model/kundalichange/kundalimahadasha.dart';
import 'package:astrokavach/model/kundalichange/kundalinewmahadasha.dart';
import 'package:astrokavach/model/kundalichange/kundlinew1.dart';
import 'package:astrokavach/model/kundalichange/rudramide.dart';
import 'package:astrokavach/model/kundalichange/vims.dart';
import 'package:astrokavach/model/kundalidash/allcharts.dart';
import 'package:astrokavach/model/kundalidash/dashkundalimodel.dart';
import 'package:astrokavach/model/kundalidash/kundaliashtakvarga.dart';
import 'package:astrokavach/model/kundalidash/kundalidash.dart';
import 'package:astrokavach/model/kundalidash/kundalidosja.dart';
import 'package:astrokavach/model/kundalidash/kundalikp.dart';
import 'package:astrokavach/model/kundalidash/kundalireport.dart';
import 'package:astrokavach/model/kundalimodel/kundalicreate.dart';
import 'package:astrokavach/model/kundalimodel/kundali_generated_list.dart';
import 'package:astrokavach/model/kundalimodel/locationkundali.dart';
import 'package:astrokavach/model/livechatscreen/livechatscreen.dart';
import 'package:astrokavach/model/notifymodel.dart';
import 'package:astrokavach/model/orderreturnmodel/requestmodel.dart';
import 'package:astrokavach/model/pages/page_detail_model.dart';
import 'package:astrokavach/model/pages/pages_list_model.dart';
import 'package:astrokavach/model/refer_earn_model/refer_earn_model.dart';
import 'package:astrokavach/model/reviemproduct.dart';
import 'package:astrokavach/model/reviewmodel/can_reviewmodel.dart';
import 'package:astrokavach/model/reviewmodel/productmodelreview.dart';
import 'package:astrokavach/model/reviewmodel/submitmodelreview.dart';
import 'package:astrokavach/model/rudramodel.dart';
import 'package:astrokavach/model/Product_Api_Model/recent_views_model.dart';
import 'package:astrokavach/model/services/services.dart';
import 'package:astrokavach/model/sortbymodel/sortbymodel.dart';
import 'package:astrokavach/model/supportlistmodel/supportlistmodel.dart';
import 'package:astrokavach/model/supportmessagemodel/supportmessagemodel.dart';
import 'package:astrokavach/model/supportsendmessagemodel.dart/supportsendmessagemodel.dart';
import 'package:astrokavach/model/transactionhistory/transactionhistory.dart';
import 'package:astrokavach/model/earnings/user_earnings_model.dart';
import 'package:astrokavach/model/earnings/referral_rules_model.dart';
import 'package:astrokavach/model/earnings/user_commissions_model.dart';
import 'package:astrokavach/model/earnings/app_referrals_model.dart';
import 'package:astrokavach/model/wishaddremovemodel/wishaddremovemodel.dart';
import 'package:astrokavach/model/wishlist1/wishlist1.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrokavach/custom_widgets/styles.dart';

// For location search

class KundliDataBundle {
  final KundaliChartResponse? kundaliChart;
  final KundaliKpResponse? kpChart;
  final AshtakvargaResponse? ashtakvargaChart;
  final AllChartsResponse? allCharts;
  final DashaResponse? dashaDetails;
  final GeneralReportResponse? generalReport;
  final DoshaReportResponse? doshaReport;

  KundliDataBundle({
    this.kundaliChart,
    this.kpChart,
    this.ashtakvargaChart,
    this.allCharts,
    this.dashaDetails,
    this.generalReport,
    this.doshaReport,
  });
}

class AstroApiService {
  // --- API Endpoints ---
  static const String kundaliDetailEndpoint =
      '${CustomStyles.apiBaseUrl}/kundali/detail';
  static const String kundaliCreateEndpoint =
      '${CustomStyles.apiBaseUrl}/kundali';
  static const String kundaliBasicEndpoint =
      '${CustomStyles.apiBaseUrl}/kundali/basic';
  static const String kundaliChartSvgEndpoint =
      '${CustomStyles.apiBaseUrl}/kundali/chart';
  static const String mahadashaEndpoint =
      '${CustomStyles.apiBaseUrl}/kundali/dasha/mahadasha';
  static const String yoginiDashaEndpoint =
      '${CustomStyles.apiBaseUrl}/kundali/dasha/yogini';
  static const String antarDashaTableEndpoint =
      '${CustomStyles.apiBaseUrl}/kundali/dasha/antardasha';
  static const String jaiminiKarakasEndpoint =
      '${CustomStyles.apiBaseUrl}/kundali/jaimini-karakas';
  static const String mangalAnalysisEndpoint =
      '${CustomStyles.apiBaseUrl}/kundali/dosha/mangal';
  static const String kundaliChartEndpoint =
      '${CustomStyles.apiBaseUrl}/kundali/kundali';
  static const String kpChartEndpoint = '${CustomStyles.apiBaseUrl}/kundali/kp';
  static const String locationEndpoint = '${CustomStyles.apiBaseUrl}/location';
  static const String gemSuggestionEndpoint =
      '${CustomStyles.apiBaseUrl}/kundali/gem-suggestion';
  static const String rudrakshSuggestionEndpoint =
      '${CustomStyles.apiBaseUrl}/kundali/rudraksh-suggestion';
  static const String ashtakvargaEndpoint =
      '${CustomStyles.apiBaseUrl}/kundali/ashtakvarga';

  static const String allChartsEndpoint =
      '${CustomStyles.apiBaseUrl}/kundali/charts';
  static const String dashaEndpoint =
      '${CustomStyles.apiBaseUrl}/kundali/dasha';
  static const String generalReportEndpoint =
      '${CustomStyles.apiBaseUrl}/kundali/report/general';
  static const String doshaReportEndpoint =
      '${CustomStyles.apiBaseUrl}/kundali/report/dosha';
  static const String _supportTypesEndpoint =
      '${CustomStyles.apiBaseUrl}/user/support/types';
  static const String _submitTicketEndpoint =
      '${CustomStyles.apiBaseUrl}/user/support/submit-ticket';

  static const String _supportListEndpoint =
      '${CustomStyles.apiBaseUrl}/user/support/list';

  static const String _supportMessagesEndpoint =
      '${CustomStyles.apiBaseUrl}/user/support/messages';
  static const String _submitMessageEndpoint =
      '${CustomStyles.apiBaseUrl}/user/support/submit-message';

  static const String liveAstrologersEndpoint =
      '${CustomStyles.apiBaseUrl}/user/live/astrologers';
  static const String joinLiveEndpoint =
      '${CustomStyles.apiBaseUrl}/user/join/live/astrologer';

  static const String updateJoinedUserEndpoint =
      '${CustomStyles.apiBaseUrl}/user/update/joined/user';

  static const String aiAstrologerListEndpoint =
      '${CustomStyles.apiBaseUrl}/astrologer/list/AI';

  static const String sortByEndpoint =
      '${CustomStyles.apiBaseUrl}/astrologer/sort-by';
  static const String giftsEndpoint = '${CustomStyles.apiBaseUrl}/gifts';

  static const String sendGiftEndpoint =
      '${CustomStyles.apiBaseUrl}/user/gifts/send';
  static const String updateCartEndpoint =
      '${CustomStyles.apiBaseUrl}/cart/update';

  static const String sendLiveMessageEndpoint =
      '${CustomStyles.apiBaseUrl}/user/live-chat/send';
  static const String bookAiConsultationEndpoint =
      '${CustomStyles.apiBaseUrl}/user/book-ai-consultaion';
  static const String aiChatLogsEndpoint =
      '${CustomStyles.apiBaseUrl}/user/chat-logs-ai';
  static const String sendMessageAiEndpoint =
      '${CustomStyles.apiBaseUrl}/user/send-message-ai';
  static const String astrologerServicesEndpoint =
      '${CustomStyles.apiBaseUrl}/astrologer/services';

  static const String aiConsultationsEndpoint =
      '${CustomStyles.apiBaseUrl}/user/ai-consultations';
  static const String userOrdersEndpoint =
      '${CustomStyles.apiBaseUrl}/user/orders';
  static const String userOrderDetailEndpoint =
      '${CustomStyles.apiBaseUrl}/user/order-detail';

  static const String canReviewEndpoint =
      '${CustomStyles.apiBaseUrl}/can-review';

  static const String submitReviewEndpoint =
      '${CustomStyles.apiBaseUrl}/user/submit-review';

  static const String productReviewEndpoint =
      '${CustomStyles.apiBaseUrl}/product/review';
  static const String walletTransitionHistoryEndpoint =
      '${CustomStyles.apiBaseUrl}/user/wallet-transition-history';
  static const String wishlistEndpoint =
      '${CustomStyles.apiBaseUrl}/user/wishlist/list';
  static const String wishlistAddRemoveEndpoint =
      '${CustomStyles.apiBaseUrl}/user/wishlist/add';
  static const String orderRequestEndpoint =
      '${CustomStyles.apiBaseUrl}/user/order-request';
  static const String notifyUserEndpoint =
      '${CustomStyles.apiBaseUrl}/user/notify-user/save'; // New endpoint
  static const String certifiedGemstoneEndpoint =
      '${CustomStyles.apiBaseUrl}/certified-gemstone';
  static const String certifiedRudrakshaEndpoint =
      '${CustomStyles.apiBaseUrl}/certified-rudraksh';
  static const String recentViewsEndpoint =
      '${CustomStyles.apiBaseUrl}/product/recent-views';
  static const String pujaParticipateSchemaEndpoint =
      '${CustomStyles.apiBaseUrl}/puja/participate/schema';
  static const String accountDeleteRequestEndpoint =
      '${CustomStyles.apiBaseUrl}/user/account-delete-request';
  static const String deleteRequestAcceptEndpoint =
      '${CustomStyles.apiBaseUrl}/user/delete-request-accept';
  static const String referEarnEndpoint =
      '${CustomStyles.apiBaseUrl}/user/refer-earn';
  static const String pagesListEndpoint =
      '${CustomStyles.apiBaseUrl}/pages/list';
  static const String pageDetailEndpoint =
      '${CustomStyles.apiBaseUrl}/pages/detail';
  static const String userEarningsEndpoint =
      '${CustomStyles.apiBaseUrl}/user/earnings';
  static const String referralRulesEndpoint =
      '${CustomStyles.apiBaseUrl}/user/referral-rules';
  static const String userCommissionsEndpoint =
      '${CustomStyles.apiBaseUrl}/user/commissions';
  static const String userAppReferralsEndpoint =
      '${CustomStyles.apiBaseUrl}/user/app-referrals';
  static const String kundaliGeneratedListEndpoint =
      '${CustomStyles.apiBaseUrl}/user/kundali-generated-list';

  static Future<KundaliGeneratedListResult?> fetchKundaliGeneratedList({
    int page = 1,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');
    if (token == null || token.isEmpty) {
      return null;
    }
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({'page': page});
    try {
      final response = await http.post(
        Uri.parse(kundaliGeneratedListEndpoint),
        headers: headers,
        body: body,
      );
      if (response.statusCode != 200 || response.body.isEmpty) {
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      if (decoded['success'] != true) return null;
      return KundaliGeneratedListResult.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  static Future<KundliDataBundle> getKundliDataBundle(int planetId) async {
    try {
      final results = await Future.wait([
        getKundaliChart(planetId),
        getKpChart(planetId),
        getAshtakvargaChart(planetId),
        getAllCharts(planetId),
        getDashaDetails(planetId),
        getGeneralReport(planetId),
        getDoshaReport(planetId),
      ]);

      return KundliDataBundle(
        kundaliChart: results[0] as KundaliChartResponse?,
        kpChart: results[1] as KundaliKpResponse?,
        ashtakvargaChart: results[2] as AshtakvargaResponse?,
        allCharts: results[3] as AllChartsResponse?,
        dashaDetails: results[4] as DashaResponse?,
        generalReport: results[5] as GeneralReportResponse?,
        doshaReport: results[6] as DoshaReportResponse?,
      );
    } catch (e) {
      throw Exception('Please check your connection and try again.');
    }
  }

  static Future<JaiminiKarakasModel?> getJaiminiKarakas(int kundaliId) async {
    try {
      final response = await http.post(
        Uri.parse(jaiminiKarakasEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({'kundali_id': kundaliId, 'return_type': 'json'}),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        Map<dynamic, dynamic> jsonMap = decoded is Map<String, dynamic>
            ? Map<dynamic, dynamic>.from(decoded)
            : Map<dynamic, dynamic>.from(decoded as Map);
        final inner = jsonMap['data'];
        if (inner is Map) {
          jsonMap = Map<dynamic, dynamic>.from(inner);
        }
        return JaiminiKarakasModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<CertifiedGemstone>?> fetchCertifiedGemstones() async {
    try {
      final response = await http.post(
        Uri.parse(certifiedGemstoneEndpoint),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Parse the JSON list directly using the model helper
        return certifiedGemstoneFromJson(response.body);
      } else {
        // Fluttertoast.showToast(msg: "Failed to load gemstones.");
        return null;
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: 'An unexpected error occurred.');
      return null;
    }
  }

  static KundaliKpResponse _parseKpResponse(String body) =>
      KundaliKpResponse.fromRawJson(body);
  static AshtakvargaResponse _parseAshtakvargaResponse(String body) =>
      AshtakvargaResponse.fromRawJson(body);

  static Future<KundaliResponse?> getKundaliDetails(
      KundaliRequest request) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('api_token');
      final Map<String, String> headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = token;
      }
      final bodyMap = Map<String, dynamic>.from(request.toJson());
      if (token != null && token.isNotEmpty) {
        bodyMap['api_token'] = token;
      }
      final response = await http.post(
        Uri.parse(kundaliDetailEndpoint),
        headers: headers,
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return KundaliResponse.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<KundaliBasicResponse?> getKundaliBasic(int kundaliId) async {
    try {
      final response = await http.post(
        Uri.parse(kundaliBasicEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'kundali_id': kundaliId, 'return_type': 'json'}),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        return KundaliBasicResponse.fromJson(decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getChartSvg({
    required int kundaliId,
    required String div,
    required String chartType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(kundaliChartSvgEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          'kundali_id': kundaliId,
          'div': div,
          'chart_type': chartType,
          'return_type': 'json',
        }),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        final jsonMap = decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded as Map);
        if (jsonMap.containsKey(div)) {
          return jsonMap[div]?.toString();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<MahadashaModel?> getMahadasha(int kundaliId) async {
    try {
      final response = await http.post(
        Uri.parse(mahadashaEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          'kundali_id': kundaliId,
          'dasha': 'maha-dasha',
          'return_type': 'json',
        }),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        Map<dynamic, dynamic> jsonMap = decoded is Map<String, dynamic>
            ? Map<dynamic, dynamic>.from(decoded)
            : Map<dynamic, dynamic>.from(decoded as Map);
        final inner = jsonMap['data'];
        if (inner is Map) {
          jsonMap = Map<dynamic, dynamic>.from(inner);
        }
        return MahadashaModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<YoginiModel?> getYoginiDasha(int kundaliId) async {
    try {
      final response = await http.post(
        Uri.parse(yoginiDashaEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode(
          {'kundali_id': kundaliId, 'dasha': 'yogini', 'return_type': 'json'},
        ),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        final jsonMap = decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded as Map);
        return YoginiModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<AntarDashaTableModel?> getAntarDashaTable(int kundaliId) async {
    try {
      final response = await http.post(
        Uri.parse(antarDashaTableEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode(
          {
            'kundali_id': kundaliId,
            'dasha': 'antar-dasha',
            'return_type': 'json'
          },
        ),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        final jsonMap = decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded as Map);
        return AntarDashaTableModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<DoshaResponse?> getDoshaDetails({
    required int kundaliId,
    required String doshaType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$CustomStyles.apiBaseUrl/kundali/dosha/$doshaType'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode(
          {'kundali_id': kundaliId, 'id': doshaType, 'return_type': 'json'},
        ),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        final jsonMap = decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded as Map);
        return DoshaResponse.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Yeh function AstroApiService class ke andar add karein

  /// Submits a new message to a support ticket.
  static Future<SubmitMessageResponse?> submitSupportMessage({
    required int ticketId,
    required String message,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      //Fluttertoast.showToast(msg: "Authentication token not found.");
      return null;
    }

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'ticket_id': ticketId,
      'message': message,
    });

    try {
      final response = await http.post(
        Uri.parse(_submitMessageEndpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return submitMessageResponseFromJson(response.body);
      } else {
        // Error response ko parse karke message dikhayein
        try {
          final errorData = jsonDecode(response.body);
          //Fluttertoast.showToast(msg: errorData['message'] ?? 'Failed to send message.');
        } catch (_) {
          //Fluttertoast.showToast(msg: 'Error: ${response.statusCode}. Failed to send message.');
        }
        return null;
      }
    } catch (e) {
      //Fluttertoast.showToast(msg: 'An unexpected error occurred.');
      return null;
    }
  }

  // Yeh function AstroApiService class ke andar add karein

  /// Fetches the details and messages for a specific support ticket.
  static Future<SupportMessageResponse?> fetchTicketMessages(
      int ticketId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      Fluttertoast.showToast(msg: "Authentication token not found.");
      return null;
    }

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({'ticket_id': ticketId});

    try {
      final response = await http.post(
        Uri.parse(_supportMessagesEndpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return supportMessageResponseFromJson(response.body);
      } else {
        //Fluttertoast.showToast(msg: 'Error: ${response.statusCode}.');
        return null;
      }
    } catch (e) {
      //Fluttertoast.showToast(msg: 'An unexpected error occurred.');
      return null;
    }
  }

  // Yeh function AstroApiService class ke andar add karein

  /// Fetches the list of support tickets for the logged-in user.
  static Future<List<SupportTicket>?> fetchSupportTickets() async {
    // 1. Authentication token retrieve karein
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      //Fluttertoast.showToast(msg: "Authentication token not found. Please log in again.");
      return null;
    }

    // 2. Headers add karein
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      // 3. Authenticated POST request karein
      final response = await http.post(
        Uri.parse(_supportListEndpoint),
        headers: headers,
      );

      // 4. Response ko process karein
      if (response.statusCode == 200) {
        final responseData = supportTicketListResponseFromJson(response.body);

        if (responseData.success && responseData.data != null) {
          return responseData.data!.list;
        } else {
          // API ne success: false return kiya
          final errorJson = jsonDecode(response.body);
          //Fluttertoast.showToast(msg: errorJson['message'] ?? 'Failed to get data.');
          return null;
        }
      } else {
        //Fluttertoast.showToast(msg: 'Error: ${response.statusCode}. Please try again.');
        return null;
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: 'An unexpected error occurred. Check your connection.');
      return null;
    }
  }

  static Future<SupportTicketResponse?> submitSupportTicket({
    required String subject,
    required String type,
    required String message,
    File? documentFile, // File object lena behtar hai
  }) async {
    // 1. Authentication token retrieve karein
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      // Fluttertoast.showToast(msg: "Authentication token not found. Please log in again.");
      return null;
    }

    // 2. Multipart request banayein
    var request =
        http.MultipartRequest('POST', Uri.parse(_submitTicketEndpoint));

    // 3. Headers add karein (BEARER TOKEN YAHAN ADD HOTA HAI)
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    // 4. Text fields add karein
    request.fields['subject'] = subject;
    request.fields['type'] = type;
    request.fields['message'] = message;

    // 5. Agar file di gayi hai, to use attach karein
    if (documentFile != null) {
      try {
        request.files.add(await http.MultipartFile.fromPath(
          'document',
          documentFile.path,
        ));
      } catch (e) {
        //Fluttertoast.showToast(msg: 'Could not attach the file.');
        return null;
      }
    }

    try {
      // 6. Request send karein
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // 7. Response ko process karein
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final ticketResponse = SupportTicketResponse.fromJson(responseData);
        // Fluttertoast.showToast(
        //   msg: ticketResponse.message,
        //   toastLength: Toast.LENGTH_LONG,
        // );
        return ticketResponse;
      } else {
        // final String errorMessage = responseData['message'] ?? 'An unknown error occurred.';
        // Fluttertoast.showToast(msg: 'Erro: ${response.statusCode}. $errorMessage');
        // return null;
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: 'An unexpected error occurred. Check your connection.');
      return null;
    }
  }

  static Future<List<SupportType>?> fetchSupportTypes() async {
    // 1. Retrieve the saved authentication token
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      //Fluttertoast.showToast(msg: "Authentication token not found. Please log in again.");
      return null;
    }

    // 2. Prepare the request headers
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      // 3. Make the authenticated POST request
      final response = await http.post(
        Uri.parse(_supportTypesEndpoint),
        headers: headers,
      );

      // 4. Process the response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> dataList = responseData['data'];

          final List<SupportType> supportTypes = dataList
              .map((jsonItem) => SupportType.fromJson(jsonItem))
              .toList();

          return supportTypes;
        } else {
          // Fluttertoast.showToast(msg: responseData['message'] ?? 'Failed to get data.');
          return null;
        }
      } else {
        //Fluttertoast.showToast(msg: 'Error: ${response.statusCode}. Please try again.');
        return null;
      }
    } catch (e) {
      //Fluttertoast.showToast(msg: 'An unexpected error occurred. Check your connection.');
      return null;
    }
  }

  /// Fetches the Kundli chart data (D1, D9 charts) for the 'Kundali' tab.
  static Future<KundaliChartResponse?> getKundaliChart(int planetId) async {
    try {
      final requestBody = {'planet_id': planetId};

      final response = await http.post(
        Uri.parse(kundaliChartEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return KundaliChartResponse.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e, stackTrace) {
      return null;
    }
  }

  /// Fetches the Kundli KP (Krishnamurti Paddhati) chart data for the 'KP' tab.
  ///
  ///
  static Future<KundaliKpResponse?> getKpChart(int planetId) async {
    try {
      final requestBody = {'planet_id': planetId};
      final response = await http.post(
        Uri.parse(kpChartEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return await compute(_parseKpResponse, response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<AshtakvargaApiResponse?> getAshtakvarga({
    required int kundaliId,
    required String planet,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ashtakvargaEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'kundali_id': kundaliId,
          'planet': planet,
          'return_type': 'json',
        }),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        return AshtakvargaApiResponse.fromJson(decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<AshtakvargaResponse?> getAshtakvargaChart(int planetId) async {
    try {
      final requestBody = {'planet_id': planetId};
      final response = await http.post(
        Uri.parse(ashtakvargaEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return await compute(_parseAshtakvargaResponse, response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<AllChartsResponse?> getAllCharts(int planetId) async {
    try {
      final requestBody = {'planet_id': planetId};

      final response = await http.post(
        Uri.parse(allChartsEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return AllChartsResponse.fromRawJson(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<VimshottariModel?> getVimshottariDasha(
      int kundaliId, String type) async {
    try {
      final response = await http.post(
        Uri.parse('$dashaEndpoint/$type'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode(
          {'kundali_id': kundaliId, 'dasha': type, 'return_type': 'json'},
        ),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        final jsonMap = decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded as Map);
        return VimshottariModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<RudrakshModel?> getRudrakshSuggestion(int kundaliId) async {
    try {
      final response = await http.post(
        Uri.parse(rudrakshSuggestionEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'kundali_id': kundaliId,
          'return_type': 'json',
        }),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        final jsonMap = decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded as Map);
        final data = (jsonMap['data'] is Map<String, dynamic>)
            ? (jsonMap['data'] as Map<String, dynamic>)
            : jsonMap;
        return RudrakshModel.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<GemModel?> getGemSuggestion(int kundaliId) async {
    try {
      final response = await http.post(
        Uri.parse(gemSuggestionEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'kundali_id': kundaliId,
          'return_type': 'json',
        }),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        final jsonMap = decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded as Map);
        final data = (jsonMap['data'] is Map<String, dynamic>)
            ? (jsonMap['data'] as Map<String, dynamic>)
            : jsonMap;
        return GemModel.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<DashaResponse?> getDashaDetails(int planetId) async {
    try {
      final requestBody = {'planet_id': planetId};

      final response = await http.post(
        Uri.parse(dashaEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return DashaResponse.fromRawJson(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Searches for locations to get latitude and longitude.
  static Future<LocationSearchResponse?> searchLocations(
      String searchPlace) async {
    try {
      final request = LocationSearchRequest(searchPlace: searchPlace);
      final response = await http.post(
        Uri.parse(locationEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return LocationSearchResponse.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<GeneralReportResponse?> getGeneralReport(int planetId) async {
    try {
      final requestBody = {'planet_id': planetId};
      final response = await http.post(
        Uri.parse(generalReportEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return GeneralReportResponse.fromRawJson(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Fetches the Dosha Report for a Kundli.
  static Future<DoshaReportResponse?> getDoshaReport(int planetId) async {
    try {
      final requestBody = {'planet_id': planetId};
      final response = await http.post(
        Uri.parse(doshaReportEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return DoshaReportResponse.fromRawJson(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //livestreaming
  static Future<List<LiveAstrologer>?> fetchLiveAstrologers() async {
    debugPrint(
        '[LIVE API] fetchLiveAstrologers → POST $liveAstrologersEndpoint');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      Fluttertoast.showToast(msg: "Please log in again");
      return null;
    }

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.post(
        Uri.parse(liveAstrologersEndpoint),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = liveAstrologerResponseFromJson(response.body);

        if (responseData.success) {
          debugPrint(
              '[LIVE API] fetchLiveAstrologers ← OK count=${responseData.data.length}');
          return responseData.data;
        } else {
          debugPrint('[LIVE API] fetchLiveAstrologers ← success=false');
          return [];
        }
      } else {
        debugPrint(
            '[LIVE API] fetchLiveAstrologers ← HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('[LIVE API] fetchLiveAstrologers ← error: $e');
      return null;
    }
  }

  static Future<ZegoCredentials?> joinLiveStream(int liveId) async {
    debugPrint(
        '[LIVE API] joinLiveStream → POST $joinLiveEndpoint body: {"live_id": $liveId}');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      Fluttertoast.showToast(msg: "Authentication token not found.");
      return null;
    }

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({'live_id': liveId});

    try {
      final response = await http.post(
        Uri.parse(joinLiveEndpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = joinLiveResponseFromJson(response.body);
        if (responseData.success) {
          debugPrint('[LIVE API] joinLiveStream ← OK (credentials received)');
          return responseData.data.credentials;
        } else {
          debugPrint('[LIVE API] joinLiveStream ← API success=false');
          return null;
        }
      } else {
        debugPrint('[LIVE API] joinLiveStream ← HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('[LIVE API] joinLiveStream ← error: $e');
      return null;
    }
  }

  static Future<void> updateLiveStatus(int astrologerLiveUserId) async {
    debugPrint(
        '[LIVE API] updateLiveStatus (heartbeat ~5s) → POST $updateJoinedUserEndpoint body: {"astrologer_live_user_id": $astrologerLiveUserId}');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      return;
    }

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'astrologer_live_user_id': astrologerLiveUserId,
    });

    try {
      final response = await http.post(
        Uri.parse(updateJoinedUserEndpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = updateLiveStatusResponseFromJson(response.body);
      } else {}
    } catch (e) {}
  }

  //Ai astrolger api
  static Future<List<AiAstrologer>?> fetchAiAstrologers() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('api_token');
      if (token == null) {
        return null;
      }
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final Map<String, String> body = {
        'api_token': token,
      };

      final response = await http.post(
        Uri.parse(aiAstrologerListEndpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = aiAstrologerResponseFromJson(response.body);
        if (responseData.success) {
          return responseData.data.list;
        } else {
          // Fluttertoast.showToast(msg: "Failed to load AI astrologers.");
          return [];
        }
      } else {
        //Fluttertoast.showToast(msg: 'Error fetching AI astrologers: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: 'An unexpected error occurred.');
      return null;
    }
  }

  static Future<List<SortByOption>?> fetchSortByOptions() async {
    try {
      final response = await http.post(
        Uri.parse(sortByEndpoint),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final sortByResponse = sortByResponseFromJson(response.body);
        if (sortByResponse.success) {
          return sortByResponse.data;
        } else {
          // Fluttertoast.showToast(msg: "Could not fetch sort options.");
          return [];
        }
      } else {
        //Fluttertoast.showToast(msg: "Error fetching sort options: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: 'An unexpected error occurred.');
      return null;
    }
  }

  //gift

  static Future<List<Gift>?> fetchGifts() async {
    debugPrint('[LIVE API] fetchGifts (gift sheet) → POST $giftsEndpoint');
    try {
      final response = await http.post(
        Uri.parse(giftsEndpoint),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final giftResponse = giftResponseFromJson(response.body);

        if (giftResponse.success) {
          return giftResponse.data;
        } else {
          // Fluttertoast.showToast(msg: "Failed to load gifts.");
          return null;
        }
      } else {
        // Fluttertoast.showToast(msg: 'Error fetching gifts: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      //Fluttertoast.showToast(msg: 'An unexpected error occurred. Check your connection.');
      return null;
    }
  }

  static Future<SendGiftResponse?> sendGift({
    required int giftId,
    required int astrologerId,
    required int liveId,
  }) async {
    debugPrint(
        '[LIVE API] sendGift → POST $sendGiftEndpoint body: gift_id=$giftId astrologer_id=$astrologerId live_id=$liveId');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      // Fluttertoast.showToast(msg: "Authentication token not found. Please log in again.");
      return null;
    }

    // 2. Prepare headers with the Bearer Token
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json', // We are sending a JSON body
      'Authorization': 'Bearer $token',
    };

    // 3. Prepare the request body
    final body = jsonEncode({
      'gift_id': giftId,
      'astrologer_id': astrologerId,
      'live_id': liveId,
    });

    try {
      // 4. Make the authenticated POST request
      final response = await http.post(
        Uri.parse(sendGiftEndpoint),
        headers: headers,
        body: body,
      );

      // 5. Process the response
      if (response.statusCode == 200) {
        final responseData = sendGiftResponseFromJson(response.body);

        // Show the message from the API (e.g., "Gift send successfully.")
        Fluttertoast.showToast(
            msg: "Gift Send Successfully", backgroundColor: Colors.green);

        // Return the full response object so you can update the wallet balance in your UI
        return responseData;
      } else {
        // Handle server-side errors
        print(response.statusCode);
        try {
          final errorData = jsonDecode(response.body);
          Fluttertoast.showToast(msg: errorData, backgroundColor: Colors.red);
        } catch (_) {
          //Fluttertoast.showToast(msg: 'Error: ${response.statusCode}. Please try again.');
        }
        return null;
      }
    } catch (e) {
      // Handle network or other exceptions

      //Fluttertoast.showToast(msg: 'An unexpected error occurred. Check your connection.');
      return null;
    }
  }

  //--- update cart
  static Future<CartUpdateResponse?> updateCartItem({
    required int itemId,
    required List<FormDataItem> formData,
    String? apiToken,
  }) async {
    try {
      final requestBody = {
        'item_id': itemId, // yahan itemId use ho raha hai
        'form_data': formData.map((item) => item.toJson()).toList(),
      };

      // Request body ko bhi print karke check kar sakte hain

      final response = await http.post(
        Uri.parse(
            '${CustomStyles.apiBaseUrl}/cart/update'), // base from CustomStyles
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final updateResponse = CartUpdateResponse.fromJson(data);
        return updateResponse;
      } else {
        // return CartUpdateResponse(success: false, message: data['message'] ?? 'Update failed');
      }
    } catch (e) {
      // return CartUpdateResponse(success: false, message: 'Error: $e');
    }
  }

  //live chart
  static Future<SendLiveChatResponse?> sendLiveChatMessage({
    required int astrologerLiveUserId,
    required String message,
  }) async {
    debugPrint(
        '[LIVE API] sendLiveChatMessage → POST $sendLiveMessageEndpoint astrologer_live_user_id=$astrologerLiveUserId');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      Fluttertoast.showToast(msg: "Authentication token not found.");
      return null;
    }

    // 2. Prepare headers
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // 3. Prepare the body
    final body = jsonEncode({
      'astrologer_live_user_id': astrologerLiveUserId,
      'message': message,
    });

    try {
      // 4. Make the POST request
      final response = await http.post(
        Uri.parse('${CustomStyles.apiBaseUrl}/user/live-chat/send'),
        headers: headers,
        body: body,
      );

      // 5. Process the response using the model
      if (response.statusCode == 200) {
        // Use the model's helper function to parse the response
        final sendLiveChatResponse =
            sendLiveChatResponseFromJson(response.body);

        if (sendLiveChatResponse.success) {
          // You can show the success message from the API directly
        } else {
          Fluttertoast.showToast(msg: sendLiveChatResponse.message);
        }
        return sendLiveChatResponse;
      } else {
        // Handle server errors
        //Fluttertoast.showToast(msg: 'Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Handle network exceptions

      //Fluttertoast.showToast(msg: 'An unexpected error occurred.');
      return null;
    }
  }

//bookaiconsulation

  static Future<MangalAnalysisResponse?> getMangalAnalysis(
      int kundaliId) async {
    try {
      final response = await http.post(
        Uri.parse(mangalAnalysisEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode(
          {'kundali_id': kundaliId, 'id': 'mangal', 'return_type': 'json'},
        ),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        final jsonMap = decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded as Map);
        return MangalAnalysisResponse.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<BookAiConsultationResponse?> bookAiConsultation({
    required int astrologerId,
    required String name,
    required String email,
    required String birthPlace,
    required String mobile,
    required String birthDate, // format: "YYYY-MM-DD"
    required String birthTime,
    int? gender,
    String? occupation,
    String? maritalstatus,
  }) async {
    // 1. Retrieve the authentication token from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      Fluttertoast.showToast(
          msg: "Authentication token not found. Please log in.");
      return null;
    }

    // 2. Prepare the request headers
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // 3. Prepare the request body with all the required fields
    final body = jsonEncode({
      'astrologer_id': astrologerId,
      'name': name,
      'email': email,
      'birth_place': birthPlace,
      'mobile': mobile,
      'birth_date': birthDate,
      'birth_time': birthTime,
      "gender": gender,
      "occupation": occupation,
      "maritial_status": maritalstatus,
    });

    try {
      // 4. Make the authenticated POST request
      final response = await http.post(
        Uri.parse(bookAiConsultationEndpoint),
        headers: headers,
        body: body,
      );

      // 5. Process the response
      if (response.statusCode == 200) {
        final responseData = bookAiConsultationResponseFromJson(response.body);
        Fluttertoast.showToast(
            msg: responseData.message, backgroundColor: Colors.green);
        return responseData;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage =
              errorData['message'] ?? 'An unknown error occurred.';
          Fluttertoast.showToast(
              msg: '$errorMessage', backgroundColor: Colors.red);
        } catch (_) {
          // Fallback error message
          // Fluttertoast.showToast(msg: 'Error: ${response.statusCode}. Please try again.', backgroundColor: Colors.red);
        }
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'An unexpected error occurred. Check your connection.');
      return null;
    }
  }

  static Future<AiChatResponse?> getAiChatLogs({
    required int consultationId,
    String message = "", // Message is optional, for fetching initial logs
  }) async {
    // 1. Get the authentication token
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      Fluttertoast.showToast(msg: "Authentication token not found.");
      return null;
    }

    // 2. Prepare headers
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // 3. Prepare the body
    final body = jsonEncode({
      'consultation_id': consultationId,
      'message': message,
    });

    try {
      // 4. Make the POST request
      final response = await http.post(
        Uri.parse(aiChatLogsEndpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return aiChatResponseFromJson(response.body);
      } else {
        Fluttertoast.showToast(msg: 'Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'An unexpected error occurred.');
      return null;
    }
  }

  static Future<SendMessageAiResponse?> sendMessageToAi({
    required int consultationId,
    required String message,
  }) async {
    // 1. Get the authentication token
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      Fluttertoast.showToast(msg: "Authentication token not found.");
      return null;
    }

    // 2. Prepare headers
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // 3. Prepare the body
    final body = jsonEncode({
      'consultation_id': consultationId,
      'message': message,
    });

    try {
      // 4. Make the POST request
      final response = await http.post(
        Uri.parse(sendMessageAiEndpoint), // Use the new endpoint
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        return sendMessageAiResponseFromJson(response.body);
      } else {
        // Handle server errors
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage =
              errorData['message'] ?? 'Failed to send message.';
          Fluttertoast.showToast(msg: '$errorMessage');
        } catch (_) {
          Fluttertoast.showToast(msg: ' ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      // Handle network exceptions

      Fluttertoast.showToast(msg: 'An unexpected error occurred.');
      return null;
    }
  }

  static Future<List<AstrologerService>?> fetchAstrologerServices() async {
    try {
      // Using POST to be consistent with the rest of your API
      final response = await http.post(
        Uri.parse(astrologerServicesEndpoint),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Decode the response using the model we created
        final servicesResponse =
            astrologerServicesResponseFromJson(response.body);

        if (servicesResponse.success) {
          return servicesResponse.data; // Return the list of services
        } else {
          //Fluttertoast.showToast(msg: "Failed to load astrologer services.");
          return null;
        }
      } else {
        //Fluttertoast.showToast(msg: 'Error fetching services: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      //Fluttertoast.showToast(msg: 'An unexpected error occurred.');
      return null;
    }
  }

  static Future<List<AiConsultation>?> fetchAiConsultations() async {
    // 1. Get the authentication token
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      Fluttertoast.showToast(msg: "Authentication token not found.");
      return null;
    }

    // 2. Prepare headers with the Bearer Token
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      // 3. Make the authenticated POST request
      final response = await http.post(
        Uri.parse(aiConsultationsEndpoint),
        headers: headers,
      );

      // 4. Process the response
      if (response.statusCode == 200) {
        final responseData = aiConsultationListResponseFromJson(response.body);

        if (responseData.success && responseData.data != null) {
          return responseData.data!.list; // Return the list of consultations
        } else {
          //Fluttertoast.showToast(msg: "Failed to load consultation history.");
          return []; // Return an empty list if API reports failure
        }
      } else {
        //Fluttertoast.showToast(msg: 'Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      //Fluttertoast.showToast(msg: 'An unexpected error occurred.');
      return null;
    }
  }

  // +++ ADD THIS ENTIRE METHOD +++
  /// Fetches the order history for the logged-in user.
  static Future<List<UserOrder>?> fetchUserOrders() async {
    // 1. Get the authentication token from shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      Fluttertoast.showToast(
          msg: "Authentication token not found. Please log in again.");
      return null;
    }

    // 2. Prepare headers with the Bearer Token
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      // 3. Make the authenticated POST request (as per your other APIs)
      final response = await http.post(
        Uri.parse(userOrdersEndpoint),
        headers: headers,
      );

      // 4. Process the response
      if (response.statusCode == 200) {
        final userOrdersResponse = userOrdersResponseFromJson(response.body);

        if (userOrdersResponse.success) {
          // If the API call was successful, return the list of orders
          return userOrdersResponse.data;
        } else {
          //Fluttertoast.showToast(msg: "Failed to load order history.");
          return []; // Return an empty list if API reports success: false
        }
      } else {
        //Fluttertoast.showToast(msg: 'Error fetching orders: ${response.statusCode}');
        return null; // Return null if there was an HTTP error
      }
    } catch (e) {
      // Handle network or other exceptions

      //Fluttertoast.showToast(msg: 'An unexpected error occurred. Check your connection.');
      return null;
    }
  }

  static Future<ReferEarnData?> fetchReferEarn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      Fluttertoast.showToast(
          msg: "Authentication token not found. Please log in again.");
      return null;
    }

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.post(
        Uri.parse(referEarnEndpoint),
        headers: headers,
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        final Map<String, dynamic> m = decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded as Map);
        final parsed = ReferEarnResponse.fromJson(m);
        if (parsed.success && parsed.data != null) {
          return parsed.data;
        }
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<UserEarningsData?> fetchUserEarnings({
    String? walletType,
    String? transactionType,
    String? dateFrom,
    String? dateTo,
    int? page,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');
    if (token == null || token.isEmpty) return null;

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = <String, dynamic>{};
    if (walletType != null && walletType.trim().isNotEmpty) {
      body['wallet_type'] = walletType.trim();
    }
    if (transactionType != null && transactionType.trim().isNotEmpty) {
      body['transaction_type'] = transactionType.trim();
    }
    if (dateFrom != null && dateFrom.trim().isNotEmpty) {
      body['date_from'] = dateFrom.trim();
    }
    if (dateTo != null && dateTo.trim().isNotEmpty) {
      body['date_to'] = dateTo.trim();
    }
    if (page != null && page > 0) body['page'] = page;

    try {
      final response = await http.post(
        Uri.parse(userEarningsEndpoint),
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode != 200 || response.body.isEmpty) return null;
      final parsed = userEarningsResponseFromJson(response.body);
      if (parsed.success && parsed.data != null) return parsed.data;
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<ReferralRulesData?> fetchReferralRules() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');
    if (token == null || token.isEmpty) return null;

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.post(
        Uri.parse(referralRulesEndpoint),
        headers: headers,
      );
      if (response.statusCode != 200 || response.body.isEmpty) return null;
      final parsed = referralRulesResponseFromJson(response.body);
      if (parsed.status && parsed.data != null) return parsed.data;
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<UserCommissionsData?> fetchUserCommissions({
    int? categoryId,
    String? status,
    String? dateFrom,
    String? dateTo,
    int? page,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');
    if (token == null || token.isEmpty) return null;

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = <String, dynamic>{};
    if (categoryId != null && categoryId > 0) body['category_id'] = categoryId;
    if (status != null && status.trim().isNotEmpty)
      body['status'] = status.trim();
    if (dateFrom != null && dateFrom.trim().isNotEmpty)
      body['date_from'] = dateFrom.trim();
    if (dateTo != null && dateTo.trim().isNotEmpty)
      body['date_to'] = dateTo.trim();
    if (page != null && page > 0) body['page'] = page;

    try {
      final response = await http.post(
        Uri.parse(userCommissionsEndpoint),
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode != 200 || response.body.isEmpty) return null;
      final parsed = userCommissionsResponseFromJson(response.body);
      if (parsed.success && parsed.data != null) return parsed.data;
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<AppReferralsData?> fetchUserAppReferrals({
    String? status,
    String? rewardTrigger,
    int? page,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');
    if (token == null || token.isEmpty) return null;

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = <String, dynamic>{};
    if (status != null && status.trim().isNotEmpty) {
      body['status'] = status.trim();
    }
    if (rewardTrigger != null && rewardTrigger.trim().isNotEmpty) {
      body['reward_trigger'] = rewardTrigger.trim();
    }
    if (page != null && page > 0) body['page'] = page;

    try {
      final response = await http.post(
        Uri.parse(userAppReferralsEndpoint),
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode != 200 || response.body.isEmpty) return null;
      final parsed = appReferralsResponseFromJson(response.body);
      if (parsed.success && parsed.data != null) return parsed.data;
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<OrderDetailResponse?> fetchOrderDetail(int orderId) async {
    // 1. Get authentication token
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      Fluttertoast.showToast(
          msg: "Authentication token not found. Please log in again.");
      return null;
    }

    // 2. Prepare headers
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // 3. Prepare the request body
    final body = jsonEncode({
      'order_id': orderId,
    });

    try {
      // 4. Make the authenticated POST request
      final response = await http.post(
        Uri.parse(userOrderDetailEndpoint),
        headers: headers,
        body: body,
      );

      // 5. Process the response
      if (response.statusCode == 200) {
        print("nA$body");
        final orderDetailResponse = orderDetailResponseFromJson(response.body);

        if (orderDetailResponse.success) {
          return orderDetailResponse;
        } else {
          // Fluttertoast.showToast(msg: "Failed to load order details.");
          return null;
        }
      } else {
        // Fluttertoast.showToast(
        //     msg: 'Error fetching order details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print("het$e");
      // Fluttertoast.showToast(msg: 'An unexpected error occurred. Check your connection.');
      return null;
    }
  }

  //canmodel
  static Future<CanReviewResponse?> canReview({
    required String page, // e.g., "shop"
    required int id, // e.g., 15
  }) async {
    // 1. Get the authentication token from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      Fluttertoast.showToast(
          msg: "Authentication token not found. Please log in.");
      return null;
    }

    // 2. Prepare the request body
    final body = jsonEncode({
      'api_token': token,
      'page': page,
      'id': id,
    });

    try {
      // 3. Make the POST request
      final response = await http.post(
        Uri.parse(canReviewEndpoint),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // 4. Process the response
      if (response.statusCode == 200) {
        return canReviewResponseFromJson(response.body);
      } else {
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage =
              errorData['message'] ?? 'Failed to check review status.';
          // Fluttertoast.showToast(msg: '$errorMessage');
        } catch (_) {
          //  Fluttertoast.showToast(msg: 'Error: ${response.statusCode}. Please try again.');
        }
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'An unexpected error occurred. Check your connection.');
      return null;
    }
  }

  static Future<SubmitReviewResponse?> submitReview({
    int? orderId,
    required String page, // e.g., "shop"
    required int id, // e.g., 1
    required int rating, // e.g., 2
    required String review,
    int? appointment,
    // e.g., "good"
  }) async {
    // 1. Get the authentication token from SharedPreferences for the header
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      //  Fluttertoast.showToast(msg: "Authentication token not found. Please log in.");
      return null;
    }

    // 2. Prepare headers with the Bearer Token for authorization
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // 3. Prepare the request body
    final body = jsonEncode({
      'page': page,
      'id': id,
      'rating': rating,
      'review': review,
      'order_id': orderId,
      'appointment_id': appointment,
    });

    try {
      // 4. Make the authenticated POST request
      final response = await http.post(
        Uri.parse(submitReviewEndpoint),
        headers: headers,
        body: body,
      );

      // 5. Process the response
      if (response.statusCode == 200) {
        final responseData = submitReviewResponseFromJson(response.body);
        Fluttertoast.showToast(
            msg: responseData.message,
            backgroundColor: responseData.success ? Colors.green : Colors.red);
        return responseData;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage =
              errorData['message'] ?? 'Failed to submit review.';
          // Fluttertoast.showToast(msg: '$errorMessage', backgroundColor: Colors.red);
        } catch (_) {
          // Fluttertoast.showToast(msg: 'Error: ${response.statusCode}. Please try again.');
        }
        return null;
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: 'An unexpected error occurred. Check your connection.');
      return null;
    }
  }

  static Future<List<ReviewData>?> fetchProductReviews({
    required int productId,
  }) async {
    final body = jsonEncode({'id': productId});

    try {
      final response = await http.post(
        Uri.parse(productReviewEndpoint),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Use the new model's helper function
        final reviewResponse = productReviewsResponseFromJson(response.body);
        if (reviewResponse.success) {
          // On success, return the list of review data
          return reviewResponse.data;
        } else {
          return []; // Return empty list if API says success: false
        }
      } else {
        //Fluttertoast.showToast(msg: 'Error fetching reviews: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      //Fluttertoast.showToast(msg: 'An unexpected error occurred.');
      return null;
    }
  }

  static Future<List<ProductReview>?> fetchAstrologerReviews({
    required int astrologerId,
  }) async {
    // 1. Define the endpoint
    const String astrologerReviewEndpoint =
        '${CustomStyles.apiBaseUrl}/astrologer/review';

    // 2. Prepare the request body
    final body = jsonEncode({
      'id': astrologerId,
    });

    debugPrint(
        '[fetchAstrologerReviews] POST $astrologerReviewEndpoint body=$body');

    try {
      // 3. Make the POST request
      final response = await http.post(
        Uri.parse(astrologerReviewEndpoint),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      debugPrint(
          '[fetchAstrologerReviews] id=$astrologerId status=${response.statusCode}');

      // 4. Process the response
      if (response.statusCode == 200) {
        // Reusing the same response model as product/astrologer reviews
        final reviewResponse = productReviewResponseFromJson(response.body);

        if (reviewResponse.success) {
          return reviewResponse.data; // Return the list of reviews on success
        } else {
          // Fluttertoast.showToast(msg: "Could not load reviews.");
          return []; // Return an empty list if API reports success: false
        }
      } else {
        // Handle HTTP errors
        // Fluttertoast.showToast(msg: 'Error fetching reviews: ${response.statusCode}');
        return null; // Return null to indicate a server error
      }
    } catch (e) {
      // Handle network or other exceptions

      //Fluttertoast.showToast(msg: 'An unexpected error occurred.');
      return null;
    }
  }

  static Future<KundaliCreateResponse> createKundali(
      KundaliRequest request) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('api_token');
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = token;
      }
      final bodyMap = Map<String, dynamic>.from(request.toJson());
      if (token != null && token.isNotEmpty) {
        bodyMap['api_token'] = token;
      }
      final response = await http.post(
        Uri.parse(kundaliCreateEndpoint),
        headers: headers,
        body: jsonEncode(bodyMap),
      );

      if (kDebugMode) {
        debugPrint('kundali create POST status=${response.statusCode}');
        debugPrint('kundali create body=${response.body}');
      }

      if (response.body.isEmpty) {
        return KundaliCreateResponse.failure(
          'Empty response from server',
          httpStatus: response.statusCode,
        );
      }

      Map<String, dynamic> jsonMap;
      try {
        final decoded = jsonDecode(response.body);
        jsonMap = decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded as Map);
      } catch (_) {
        final preview = response.body.length > 300
            ? '${response.body.substring(0, 300)}...'
            : response.body;
        return KundaliCreateResponse.failure(
          'Invalid JSON: $preview',
          httpStatus: response.statusCode,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return KundaliCreateResponse.fromJson(jsonMap);
      }

      final errMsg = KundaliCreateResponse.extractErrorMessage(jsonMap) ??
          'Request failed';
      return KundaliCreateResponse.failure(errMsg,
          httpStatus: response.statusCode);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('kundali create exception $e');
        debugPrint('$st');
      }
      return KundaliCreateResponse.failure(e.toString());
    }
  }

  static Future<WalletHistoryResponse?> fetchWalletHistory(
      {required int page}) async {
    // 1. Authentication token retrieve karein
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      //Fluttertoast.showToast(msg: "Authentication token not found. Please log in again.");
      return null;
    }

    // 2. Headers add karein
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // 3. Request body banayein
    final body = jsonEncode({
      'page': page,
    });

    try {
      // 4. Authenticated POST request karein
      final response = await http.post(
        Uri.parse(walletTransitionHistoryEndpoint),
        headers: headers,
        body: body,
      );

      // 5. Response ko process karein
      if (response.statusCode == 200) {
        // Model ka istemal karke response ko parse karein
        return walletHistoryResponseFromJson(response.body);
      } else {
        // Server se error aane par
        //Fluttertoast.showToast(msg: 'Error: ${response.statusCode}. Please try again.');
        return null;
      }
    } catch (e) {
      // Network ya dusre exceptions ke liye

      //Fluttertoast.showToast(msg: 'An unexpected error occurred. Check your connection.');
      return null;
    }
  }

  /// Fetches the user's wishlist (products and services).
  static Future<WishlistData?> fetchWishlist() async {
    // 1. Get the authentication token from shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      Fluttertoast.showToast(
          msg: "Authentication token not found. Please log in again.");
      return null;
    }

    // 2. Prepare headers with the Bearer Token for authorization
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      // 3. Make the authenticated POST request
      final response = await http.post(
        Uri.parse(wishlistEndpoint),
        headers: headers,
      );

      // 4. Process the response
      if (response.statusCode == 200) {
        final wishlistResponse = wishlistResponseFromJson(response.body);

        if (wishlistResponse.success) {
          // If the API call was successful, return the data object
          return wishlistResponse.data;
        } else {
          // API reported success: false
          Fluttertoast.showToast(msg: wishlistResponse.message);
          return null;
        }
      } else {
        // Handle HTTP errors
        Fluttertoast.showToast(
            msg: 'Error fetching wishlist: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Handle network or other exceptions

      Fluttertoast.showToast(
          msg: 'An unexpected error occurred. Check your connection.');
      return null;
    }
  }

  static Future<WishlistAddRemoveResponse?> updateWishlist({
    required int itemId,
    required String action,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');
    if (token == null) {
      Fluttertoast.showToast(
          msg: "Authentication token not found. Please log in again.");
      return null;
    }
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({'item_id': itemId, 'action': action});

    try {
      final response = await http.post(
        Uri.parse(wishlistAddRemoveEndpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final addRemoveResponse =
            wishlistAddRemoveResponseFromJson(response.body);
        Fluttertoast.showToast(
          msg: addRemoveResponse.message,
          backgroundColor:
              addRemoveResponse.success ? Colors.green : Colors.red,
        );
        return addRemoveResponse;
      } else {
        Fluttertoast.showToast(msg: "Unable to add wishlist");
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'An unexpected error occurred. Check your connection.');
      return null;
    }
  }

  static Future<OrderRequestResponse?> orderRequest({
    required String requestType,
    required int orderId,
    required String reason,
    String? message,
    List<int>? itemIds,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      Fluttertoast.showToast(msg: "Authentication token not found.");
      return null;
    }

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final Map<String, dynamic> body = {
      'request_type': requestType,
      'order_id': orderId,
      'reason': reason,
    };

    if (message != null && message.isNotEmpty) {
      body['message'] = message;
    }
    if (requestType == 'return' && itemIds != null) {
      body['item_ids'] = itemIds;
    }

    try {
      final response = await http.post(
        Uri.parse(orderRequestEndpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      // Response ko model se parse karein
      final responseData = orderRequestResponseFromJson(response.body);

      // API se mila message toast mein dikhayein
      Fluttertoast.showToast(
        msg: responseData.message,
        backgroundColor: responseData.success ? Colors.green : Colors.red,
      );

      // Poora response object return karein
      return responseData;
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'An unexpected error occurred. Check connection.');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> requestAccountDelete() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');
    if (token == null || token.isEmpty) {
      Fluttertoast.showToast(msg: "Authentication token not found.");
      return null;
    }

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.post(
        Uri.parse(accountDeleteRequestEndpoint),
        headers: headers,
      );

      if (response.body.isEmpty) {
        Fluttertoast.showToast(msg: 'Something went wrong.');
        return null;
      }

      final decoded = jsonDecode(response.body);
      final Map<String, dynamic> jsonMap = decoded is Map<String, dynamic>
          ? decoded
          : Map<String, dynamic>.from(decoded as Map);

      final msg = (jsonMap['message'] ?? '').toString();
      if (msg.isNotEmpty) {
        Fluttertoast.showToast(
          msg: msg,
          backgroundColor:
              (jsonMap['success'] == true) ? Colors.green : Colors.red,
          toastLength: Toast.LENGTH_LONG,
        );
      }

      return jsonMap;
    } catch (e) {
      Fluttertoast.showToast(msg: 'An unexpected error occurred.');
      return null;
    }
  }

  static int? _parseDeleteRequestAccepted(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v ? 1 : 0;
    if (v is int) return v;
    if (v is double) return v.round();
    final s = v.toString().trim().toLowerCase();
    if (s == 'true' || s == 'yes') return 1;
    if (s == 'false' || s == 'no') return 0;
    return int.tryParse(v.toString());
  }

  static Future<int?> fetchDeleteRequestAccepted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');
    if (token == null || token.isEmpty) return null;

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.post(
        Uri.parse(deleteRequestAcceptEndpoint),
        headers: headers,
        body: '{}',
      );

      debugPrint(
          '[delete-request-accept] HTTP ${response.statusCode} body=${response.body}');

      if (response.body.isEmpty) return null;
      final decoded = jsonDecode(response.body);
      final Map<String, dynamic> jsonMap = decoded is Map<String, dynamic>
          ? decoded
          : Map<String, dynamic>.from(decoded as Map);

      int? parsed;
      final dynamic dataRaw = jsonMap['data'];
      if (dataRaw is Map) {
        final Map<String, dynamic> dataMap =
            Map<String, dynamic>.from(dataRaw as Map);
        final dynamic inner = dataMap['delete_request_accepted'] ??
            dataMap['deleteRequestAccepted'];
        parsed = _parseDeleteRequestAccepted(inner);
      }
      parsed ??= _parseDeleteRequestAccepted(
          jsonMap['delete_request_accepted'] ??
              jsonMap['deleteRequestAccepted']);
      debugPrint('[delete-request-accept] delete_request_accepted=$parsed');
      return parsed;
    } catch (e) {
      debugPrint('[delete-request-accept] error=$e');
      return null;
    }
  }

  static Future<NotifyUserResponse?> notifyUser({
    required int astrologerId,
    required String type,
  }) async {
    debugPrint(
        '[LIVE API] notifyUser (Notify Me) → POST $notifyUserEndpoint astrologer_id=$astrologerId type=$type');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      Fluttertoast.showToast(
          msg: "Authentication token not found. Please log in.");
      return null;
    }

    // 2. Prepare headers with the Bearer Token
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // 3. Prepare the request body
    final body = jsonEncode({
      'astrologer_id': astrologerId,
      'type': type,
    });

    try {
      // 4. Make the authenticated POST request
      final response = await http.post(
        Uri.parse(notifyUserEndpoint),
        headers: headers,
        body: body,
      );

      // 5. Process the response
      final responseData = notifyUserResponseFromJson(response.body);

      // Show a toast message from the API response
      Fluttertoast.showToast(
        msg: responseData.message,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: responseData.success ? Colors.green : Colors.red,
      );

      if (response.statusCode == 200) {
        return responseData;
      } else {
        // The toast above will already show the error message from the API
        return null;
      }
    } catch (e) {
      // Handle network or other exceptions

      Fluttertoast.showToast(
          msg: 'An unexpected error occurred. Check your connection.');
      return null;
    }
  }

  static Future<List<CertifiedRudraksha>?> fetchCertifiedRudraksha() async {
    try {
      final response = await http.post(
        Uri.parse(certifiedRudrakshaEndpoint),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return certifiedRudrakshaFromJson(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<RecentViewsModel?> fetchRecentViews(int productId) async {
    try {
      final response = await http.post(
        Uri.parse(recentViewsEndpoint),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product_id': productId.toString(),
        }),
      );
      print('recent-views request product_id: $productId');
      print('recent-views status code: ${response.statusCode}');
      print('recent-views raw response: ${response.body}');

      if (response.statusCode == 200) {
        final parsed = recentViewsModelFromJson(response.body);
        print('recent-views parsed count: ${parsed.data?.length ?? 0}');
        return parsed;
      } else {
        print('recent-views failed for product_id: $productId');
        return null;
      }
    } catch (e) {
      print('recent-views exception: $e');
      return null;
    }
  }

  static Future<PagesListResponse?> fetchPagesList({
    String appType = 'customer',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(pagesListEndpoint),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'app_type': appType}),
      );
      if (response.body.isEmpty) return null;
      return pagesListResponseFromJson(response.body);
    } catch (_) {
      return null;
    }
  }

  static Future<PageDetailResponse?> fetchPageDetail({
    required String slug,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(pageDetailEndpoint),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'slug': slug}),
      );
      if (response.body.isEmpty) return null;
      return pageDetailResponseFromJson(response.body);
    } catch (_) {
      return null;
    }
  }
}
