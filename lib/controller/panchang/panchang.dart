class PanchangResponse {
  final bool success;
  final PanchangData data;

  PanchangResponse({
    required this.success,
    required this.data,
  });

  factory PanchangResponse.fromJson(Map<dynamic, dynamic> json) {
    return PanchangResponse(
      success: json['success'] ?? false,
      data: PanchangData.fromJson(json['data']),
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class PanchangData {
  final dynamic date;
  final PanchangDetails response;

  PanchangData({
    required this.date,
    required this.response,
  });

  factory PanchangData.fromJson(Map<dynamic, dynamic> json) {
    return PanchangData(
      date: json['date'] ?? '',
      response: PanchangDetails.fromJson(json['response']),
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'date': date,
      'response': response.toJson(),
    };
  }
}

class ChoghadiyaItem {
  final String name;
  final String time;
  final String type;

  ChoghadiyaItem({
    required this.name,
    required this.time,
    required this.type,
  });

  factory ChoghadiyaItem.fromJson(Map<String, dynamic> json) {
    return ChoghadiyaItem(
      name: json['name']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }

  static List<ChoghadiyaItem> listFromJson(dynamic raw) {
    if (raw == null || raw is! List) return [];
    final out = <ChoghadiyaItem>[];
    for (final e in raw) {
      if (e is Map) {
        out.add(ChoghadiyaItem.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return out;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'time': time,
        'type': type,
      };
}

class PanchangDetails {
  final Panchang panchang;
  final SunAndMoon sunAndMoon;
  final MonthAndYear monthAndYear;
  final InauspiciousTiming inauspiciousTiming;
  final AuspiciousTiming auspiciousTiming;
  final DishaShoola dishaShoola;
  final List<ChoghadiyaItem> dayChoghadiya;
  final List<ChoghadiyaItem> nightChoghadiya;

  PanchangDetails({
    required this.panchang,
    required this.sunAndMoon,
    required this.monthAndYear,
    required this.inauspiciousTiming,
    required this.auspiciousTiming,
    required this.dishaShoola,
    required this.dayChoghadiya,
    required this.nightChoghadiya,
  });

  factory PanchangDetails.fromJson(Map<dynamic, dynamic> json) {
    return PanchangDetails(
      panchang: Panchang.fromJson(
          Map<dynamic, dynamic>.from(json['panchang'] ?? {})),
      sunAndMoon: SunAndMoon.fromJson(
          Map<dynamic, dynamic>.from(json['sun_and_moon'] ?? {})),
      monthAndYear: MonthAndYear.fromJson(
          Map<dynamic, dynamic>.from(json['month_and_year'] ?? {})),
      inauspiciousTiming: InauspiciousTiming.fromJson(
          Map<dynamic, dynamic>.from(json['inauspicious_timming'] ?? {})),
      auspiciousTiming: AuspiciousTiming.fromJson(
          Map<dynamic, dynamic>.from(json['auspicious_timming'] ?? {})),
      dishaShoola: DishaShoola.fromJson(
          Map<dynamic, dynamic>.from(json['disha_shoola'] ?? {})),
      dayChoghadiya: ChoghadiyaItem.listFromJson(json['day_choghadiya']),
      nightChoghadiya: ChoghadiyaItem.listFromJson(json['night_choghadiya']),
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'panchang': panchang.toJson(),
      'sun_and_moon': sunAndMoon.toJson(),
      'month_and_year': monthAndYear.toJson(),
      'inauspicious_timming': inauspiciousTiming.toJson(),
      'auspicious_timming': auspiciousTiming.toJson(),
      'disha_shoola': dishaShoola.toJson(),
      'day_choghadiya': dayChoghadiya.map((e) => e.toJson()).toList(),
      'night_choghadiya': nightChoghadiya.map((e) => e.toJson()).toList(),
    };
  }
}

class Panchang {
  final dynamic tithi;
  final dynamic nakshatra;
  final dynamic karana;
  final dynamic yoga;
  final dynamic day;

  Panchang({
    required this.tithi,
    required this.nakshatra,
    required this.karana,
    required this.yoga,
    required this.day,
  });

  factory Panchang.fromJson(Map<dynamic, dynamic> json) {
    return Panchang(
      tithi: json['tithi'] ?? '',
      nakshatra: json['nakshatra'] ?? '',
      karana: json['karana'] ?? '',
      yoga: json['yoga'] ?? '',
      day: json['day'] ?? '',
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'tithi': tithi,
      'nakshatra': nakshatra,
      'karana': karana,
      'yoga': yoga,
      'day': day,
    };
  }
}

class SunAndMoon {
  final dynamic sunRise;
  final dynamic sunSet;
  final dynamic moonSign;
  final dynamic moonRise;
  final dynamic moonSet;
  final dynamic ritu;

  SunAndMoon({
    required this.sunRise,
    required this.sunSet,
    required this.moonSign,
    required this.moonRise,
    required this.moonSet,
    required this.ritu,
  });

  factory SunAndMoon.fromJson(Map<dynamic, dynamic> json) {
    return SunAndMoon(
      sunRise: json['sun_rise'] ?? '',
      sunSet: json['sun_set'] ?? '',
      moonSign: json['moon_sign'] ?? '',
      moonRise: json['moon_rise'] ?? '',
      moonSet: json['moon_set'] ?? '',
      ritu: json['ritu'] ?? '',
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'sun_rise': sunRise,
      'sun_set': sunSet,
      'moon_sign': moonSign,
      'moon_rise': moonRise,
      'moon_set': moonSet,
      'ritu': ritu,
    };
  }
}

class MonthAndYear {
  final dynamic purnimanta;
  final dynamic amanta;
  final dynamic shakaSamvat;
  final dynamic vikramSamvat;
  final dynamic kaliSamvat;

  MonthAndYear({
    required this.purnimanta,
    required this.amanta,
    required this.shakaSamvat,
    required this.vikramSamvat,
    required this.kaliSamvat,
  });

  factory MonthAndYear.fromJson(Map<dynamic, dynamic> json) {
    return MonthAndYear(
      purnimanta: json['purnimanta'] ?? '',
      amanta: json['amanta'] ?? '',
      shakaSamvat: json['shaka_samvat'] ?? '',
      vikramSamvat: json['vikram_samvat'] ?? 0,
      kaliSamvat: json['kali_samvat'] ?? 0,
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'purnimanta': purnimanta,
      'amanta': amanta,
      'shaka_samvat': shakaSamvat,
      'vikram_samvat': vikramSamvat,
      'kali_samvat': kaliSamvat,
    };
  }
}

class InauspiciousTiming {
  final dynamic gulika;
  final dynamic yamakanta;

  InauspiciousTiming({
    required this.gulika,
    required this.yamakanta,
  });

  factory InauspiciousTiming.fromJson(Map<dynamic, dynamic> json) {
    return InauspiciousTiming(
      gulika: json['gulika'] ?? '',
      yamakanta: json['yamakanta'] ?? '',
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'gulika': gulika,
      'yamakanta': yamakanta,
    };
  }
}

class AuspiciousTiming {
  final dynamic abhijit;

  AuspiciousTiming({
    required this.abhijit,
  });

  factory AuspiciousTiming.fromJson(Map<dynamic, dynamic> json) {
    return AuspiciousTiming(
      abhijit: json['abhijit'] ?? '',
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'abhijit': abhijit,
    };
  }
}

class DishaShoola {
  final dynamic dishaShoola;

  DishaShoola({
    required this.dishaShoola,
  });

  factory DishaShoola.fromJson(Map<dynamic, dynamic> json) {
    return DishaShoola(
      dishaShoola: json['disha_shoola'] ?? '',
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'disha_shoola': dishaShoola,
    };
  }
}