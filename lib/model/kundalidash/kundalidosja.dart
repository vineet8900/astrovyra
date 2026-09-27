// lib/model/kundalireport/dosha_report_model.dart

import 'dart:convert';

class DoshaReportResponse {
    final bool success;
    final Data data;

    DoshaReportResponse({
        required this.success,
        required this.data,
    });

    factory DoshaReportResponse.fromRawJson(String str) => DoshaReportResponse.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory DoshaReportResponse.fromJson(Map<String, dynamic> json) => DoshaReportResponse(
        success: json["suceess"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "suceess": success,
        "data": data.toJson(),
    };
}

class Data {
    final ReportManglik reportManglik;
    final ReportKalsarpa reportKalsarpa;
    final ReportSadesati reportSadesati;

    Data({
        required this.reportManglik,
        required this.reportKalsarpa,
        required this.reportSadesati,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        reportManglik: ReportManglik.fromJson(json["reportManglik"]),
        reportKalsarpa: ReportKalsarpa.fromJson(json["reportKalsarpa"]),
        reportSadesati: ReportSadesati.fromJson(json["reportSadesati"]),
    );

    Map<String, dynamic> toJson() => {
        "reportManglik": reportManglik.toJson(),
        "reportKalsarpa": reportKalsarpa.toJson(),
        "reportSadesati": reportSadesati.toJson(),
    };
}

class ReportKalsarpa {
    final String fullName;
    final bool isDoshaPresent;
    final List<String> remedies;

    ReportKalsarpa({
        required this.fullName,
        required this.isDoshaPresent,
        required this.remedies,
    });

    factory ReportKalsarpa.fromJson(Map<String, dynamic> json) => ReportKalsarpa(
        fullName: json["full_name"],
        isDoshaPresent: json["is_dosha_present"],
        remedies: List<String>.from(json["remedies"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "full_name": fullName,
        "is_dosha_present": isDoshaPresent,
        "remedies": List<dynamic>.from(remedies.map((x) => x)),
    };
}

class ReportManglik {
    final String fullName;
    final bool isDoshaPresent;
    final List<String> factors;
    final String note;

    ReportManglik({
        required this.fullName,
        required this.isDoshaPresent,
        required this.factors,
        required this.note,
    });

    factory ReportManglik.fromJson(Map<String, dynamic> json) => ReportManglik(
        fullName: json["full_name"],
        isDoshaPresent: json["is_dosha_present"],
        factors: List<String>.from(json["factors"].map((x) => x)),
        note: json["note"],
    );

    Map<String, dynamic> toJson() => {
        "full_name": fullName,
        "is_dosha_present": isDoshaPresent,
        "factors": List<dynamic>.from(factors.map((x) => x)),
        "note": note,
    };
}

class ReportSadesati {
    final String fullName;
    final bool isDoshaPresent;
    final String description;
    final List<SadesatiDetail> details;
    final List<String> remedies;

    ReportSadesati({
        required this.fullName,
        required this.isDoshaPresent,
        required this.description,
        required this.details,
        required this.remedies,
    });

    factory ReportSadesati.fromJson(Map<String, dynamic> json) => ReportSadesati(
        fullName: json["full_name"],
        isDoshaPresent: json["is_dosha_present"],
        description: json["description"],
        details: List<SadesatiDetail>.from(json["details"].map((x) => SadesatiDetail.fromJson(x))),
        remedies: List<String>.from(json["remedies"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "full_name": fullName,
        "is_dosha_present": isDoshaPresent,
        "description": description,
        "details": List<dynamic>.from(details.map((x) => x.toJson())),
        "remedies": List<dynamic>.from(remedies.map((x) => x)),
    };
}

class SadesatiDetail {
    final String start;
    final String end;
    final String zodiac;
    final String type;

    SadesatiDetail({
        required this.start,
        required this.end,
        required this.zodiac,
        required this.type,
    });

    factory SadesatiDetail.fromJson(Map<String, dynamic> json) => SadesatiDetail(
        start: json["start"],
        end: json["end"],
        zodiac: json["zodiac"],
        type: json["type"],
    );

    Map<String, dynamic> toJson() => {
        "start": start,
        "end": end,
        "zodiac": zodiac,
        "type": type,
    };
}