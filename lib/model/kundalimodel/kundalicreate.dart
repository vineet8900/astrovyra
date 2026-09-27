
class KundaliRequest {
  final String name;
  final String gender;
  final String date;
  final String time;
  final String lang;
  final String city;
  final String phone;

  KundaliRequest({
    required this.name,
    required this.gender,
    required this.date,
    required this.time,
    required this.lang,
    required this.city,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'gender': gender,
      'date': date,
      'time': time,
      'lang': lang,
      'city': city,
      'return_type': 'json',
    };
    final p = phone.trim();
    if (p.isNotEmpty && p != '9999999999') {
      map['phone'] = p;
    }
    return map;
  }
}

class KundaliResponse {
  final bool success;
  final KundaliData data;

  KundaliResponse({
    required this.success,
    required this.data,
  });

  factory KundaliResponse.fromJson(Map<String, dynamic> json) {
    return KundaliResponse(
      success: json['suceess'] ?? false, // Note: API has typo "suceess"
      data: KundaliData.fromJson(json['data'] ?? {}),
    );
  }
}

class KundaliData {
  final int planetId;
  final BasicDetail basicDetail;
  final AvakhadaDetail avakhadaDetail;
  final PanchangDetail panchangDetail;

  KundaliData({
    required this.planetId,
    required this.basicDetail,
    required this.avakhadaDetail,
    required this.panchangDetail,
  });

  factory KundaliData.fromJson(Map<String, dynamic> json) {
    return KundaliData(
      planetId: json['planet_id'] ?? 0,
      basicDetail: BasicDetail.fromJson(json['basic_detail'] ?? {}),
      avakhadaDetail: AvakhadaDetail.fromJson(json['avakhada_detail'] ?? {}),
      panchangDetail: PanchangDetail.fromJson(json['panchang_detail'] ?? {}),
    );
  }
}

class BasicDetail {
  final String name;
  final String date;
  final String time;
  final String place;
  final String latitude;
  final String longitude;
  final String timezone;
  final String sunRise;
  final String sunSet;
  final String ayanamsha;

  BasicDetail({
    required this.name,
    required this.date,
    required this.time,
    required this.place,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.sunRise,
    required this.sunSet,
    required this.ayanamsha,
  });

  factory BasicDetail.fromJson(Map<String, dynamic> json) {
    return BasicDetail(
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      place: json['place'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      timezone: json['timezone'] ?? '',
      sunRise: json['sun_rise'] ?? '',
      sunSet: json['sun_set'] ?? '',
      ayanamsha: json['ayanamsha'] ?? '',
    );
  }
}

class AvakhadaDetail {
  final String varna;
  final String vasya;
  final String yoni;
  final String gana;
  final String nadi;
  final String zodiac;
  final String zodiacLord;
  final String nakshatra;
  final String yoga;
  final String karana;
  final String tithi;
  final String tatva;
  final String nameAlphabet;
  final String paya;

  AvakhadaDetail({
    required this.varna,
    required this.vasya,
    required this.yoni,
    required this.gana,
    required this.nadi,
    required this.zodiac,
    required this.zodiacLord,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    required this.tithi,
    required this.tatva,
    required this.nameAlphabet,
    required this.paya,
  });

  factory AvakhadaDetail.fromJson(Map<String, dynamic> json) {
    return AvakhadaDetail(
      varna: json['varna'] ?? '',
      vasya: json['vasya'] ?? '',
      yoni: json['yoni'] ?? '',
      gana: json['gana'] ?? '',
      nadi: json['nadi'] ?? '',
      zodiac: json['zodiac'] ?? '',
      zodiacLord: json['zodiac_lord'] ?? '',
      nakshatra: json['nakshatra'] ?? '',
      yoga: json['yoga'] ?? '',
      karana: json['karana'] ?? '',
      tithi: json['tithi'] ?? '',
      tatva: json['tatva'] ?? '',
      nameAlphabet: json['name_alphabet'] ?? '',
      paya: json['paya'] ?? '',
    );
  }
}

class PanchangDetail {
  final String tithi;
  final String karana;
  final String yoga;

  PanchangDetail({
    required this.tithi,
    required this.karana,
    required this.yoga,
  });

  factory PanchangDetail.fromJson(Map<String, dynamic> json) {
    return PanchangDetail(
      tithi: json['tithi'] ?? '',
      karana: json['karana'] ?? '',
      yoga: json['yoga'] ?? '',
    );
  }
}
