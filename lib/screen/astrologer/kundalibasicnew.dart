import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/kundalichange/kundalibasic.dart';
import 'package:flutter/material.dart';

class KundliBasicTab extends StatelessWidget {
  final KundaliBasicResponse basic;

  const KundliBasicTab({Key? key, required this.basic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final response = basic.response;
    final panchang =
        (response['panchang'] is Map) ? (response['panchang'] as Map) : null;
    final extended =
        (response['extended'] is Map) ? (response['extended'] as Map) : null;

    String v(dynamic x) => (x == null) ? '' : x.toString();
    String safe(dynamic x) {
      final s = v(x).trim();
      return s.isEmpty ? '-' : s;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Astro Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: CustomStyles.callActionBlue,
                ),
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 2,
                    width: double.infinity,
                    color: CustomStyles.callActionBlue.withOpacity(0.2),
                  ),
                  Container(
                    height: 3,
                    width: 60,
                    decoration: BoxDecoration(
                      color: CustomStyles.callActionBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _sectionCard('Basic Details', [
                _infoRow('Name', safe(basic.name)),
                _infoRow('Date', safe(basic.date)),
                _infoRow('Time', safe(basic.time)),
                _infoRow('Place', safe(basic.place)),
                _infoRow('Latitude', safe(basic.latitude)),
                _infoRow('Longitude', safe(basic.longitude)),
                _infoRow('Timezone', safe(basic.timezone)),
                _infoRow('Sun Rise', safe(panchang?['sunrise_at_birth'])),
                _infoRow('Sun Set', safe(panchang?['sunset_at_birth'])),
                _infoRow('Ayanamsha', safe(panchang?['ayanamsa_name'])),
              ]),
              _sectionCard('Astrological Details', [
                _infoRow('Varna', safe(extended?['varna'])),
                _infoRow('Vashya', safe(extended?['vasya'])),
                _infoRow('Yoni', safe(extended?['yoni'])),
                _infoRow('Gan', safe(extended?['gana'])),
                _infoRow('Nadi', safe(extended?['nadi'])),
                _infoRow('Zodiac', safe(extended?['rasi'])),
                _infoRow('Zodiac Lord', safe(extended?['rasi_lord'])),
                _infoRow('Nakshatra', safe(extended?['nakshatra'])),
                _infoRow('Yog', safe(extended?['yoga'])),
                _infoRow('Karan', safe(extended?['karana'])),
                _infoRow('Tithi', safe(extended?['tithi'])),
                _infoRow('Tatva', safe(extended?['tatva'])),
                _infoRow('Name alphabet', safe(extended?['name_start'])),
                _infoRow('Paya', safe(extended?['paya'])),
              ]),
              _sectionCard('Panchang Details', [
                _infoRow('Tithi', safe(panchang?['tithi'])),
                _infoRow('Karana', safe(panchang?['karana'])),
                _infoRow('Yog', safe(panchang?['yoga'])),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[100]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(children: children),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value.trim().isEmpty ? '-' : value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey[100]),
      ],
    );
  }
}
