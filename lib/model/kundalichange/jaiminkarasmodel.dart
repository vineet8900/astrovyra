class JaiminiKarakasModel {
  final JaiminiKaraka? atma;
  final JaiminiKaraka? amatya;
  final JaiminiKaraka? bhratru;
  final JaiminiKaraka? matri;
  final JaiminiKaraka? putra;
  final JaiminiKaraka? gnati;
  final JaiminiKaraka? dara;

  JaiminiKarakasModel({
    required this.atma,
    required this.amatya,
    required this.bhratru,
    required this.matri,
    required this.putra,
    required this.gnati,
    required this.dara,
  });

  factory JaiminiKarakasModel.fromJson(Map<dynamic, dynamic> json) {
    return JaiminiKarakasModel(
      atma: json['Atma'] != null ? JaiminiKaraka.fromJson(json['Atma']) : null,
      amatya: json['Amatya'] != null
          ? JaiminiKaraka.fromJson(json['Amatya'])
          : null,
      bhratru: json['Bhratru'] != null
          ? JaiminiKaraka.fromJson(json['Bhratru'])
          : null,
      matri:
          json['Matri'] != null ? JaiminiKaraka.fromJson(json['Matri']) : null,
      putra:
          json['Putra'] != null ? JaiminiKaraka.fromJson(json['Putra']) : null,
      gnati:
          json['Gnati'] != null ? JaiminiKaraka.fromJson(json['Gnati']) : null,
      dara: json['Dara'] != null ? JaiminiKaraka.fromJson(json['Dara']) : null,
    );
  }
}

class JaiminiKaraka {
  final dynamic name;
  final dynamic planet;
  final dynamic signifier;
  final dynamic house;
  final dynamic zodiac;
  final dynamic rasiNo;
  final double? localDegree;
  final double? globalDegree;

  JaiminiKaraka({
    required this.name,
    required this.planet,
    required this.signifier,
    required this.house,
    required this.zodiac,
    required this.rasiNo,
    required this.localDegree,
    required this.globalDegree,
  });

  factory JaiminiKaraka.fromJson(Map<dynamic, dynamic> json) {
    return JaiminiKaraka(
      name: json['name'],
      planet: json['planet'],
      signifier: json['siginfier'],
      house: json['house'],
      zodiac: json['zodiac'],
      rasiNo: json['rasi_no'],
      localDegree: (json['local_degree'] as num?)?.toDouble(),
      globalDegree: (json['global_degree'] as num?)?.toDouble(),
    );
  }
}
