// lib/model/kundalireport/general_report_model.dart

import 'dart:convert';

class GeneralReportResponse {
    final bool success;
    final Data data;

    GeneralReportResponse({
        required this.success,
        required this.data,
    });

    factory GeneralReportResponse.fromRawJson(String str) => GeneralReportResponse.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory GeneralReportResponse.fromJson(Map<String, dynamic> json) => GeneralReportResponse(
        success: json["suceess"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "suceess": success,
        "data": data.toJson(),
    };
}

class Data {
    final List<Report> reportGeneral;
    final List<Report> reportPlanetary;
    final List<ReportYoga> reportYoga;

    Data({
        required this.reportGeneral,
        required this.reportPlanetary,
        required this.reportYoga,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        reportGeneral: List<Report>.from(json["reportGeneral"].map((x) => Report.fromJson(x))),
        reportPlanetary: List<Report>.from(json["reportPlanetary"].map((x) => Report.fromJson(x))),
        reportYoga: List<ReportYoga>.from(json["reportYoga"].map((x) => ReportYoga.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "reportGeneral": List<dynamic>.from(reportGeneral.map((x) => x.toJson())),
        "reportPlanetary": List<dynamic>.from(reportPlanetary.map((x) => x.toJson())),
        "reportYoga": List<dynamic>.from(reportYoga.map((x) => x.toJson())),
    };
}

class Report {
    final String name;
    final String prediction;
    final String? planet;

    Report({
        required this.name,
        required this.prediction,
        this.planet,
    });

    factory Report.fromJson(Map<String, dynamic> json) => Report(
        name: json["name"] ?? json["planet"] ?? "Unknown",
        prediction: json["prediction"],
        planet: json["planet"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "prediction": prediction,
        "planet": planet,
    };
}

class ReportYoga {
    final String name;
    final String meaning;

    ReportYoga({
        required this.name,
        required this.meaning,
    });

    factory ReportYoga.fromJson(Map<String, dynamic> json) => ReportYoga(
        name: json["name"],
        meaning: json["meaning"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "meaning": meaning,
    };
}