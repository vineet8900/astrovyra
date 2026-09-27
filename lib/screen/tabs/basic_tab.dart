import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:astrokavach/model/kundalimodel/kundalicreate.dart';
import 'package:astrokavach/screen/widgets/info_row.dart';

class BasicTab extends StatelessWidget {
  final BasicDetail basicDetail;
  final AvakhadaDetail avakhadaDetail;
  final PanchangDetail panchangDetail;

  const BasicTab(
      {Key? key,
      required this.basicDetail,
      required this.avakhadaDetail,
      required this.panchangDetail})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCard(
            title: 'Birth Details',
            icon: Icons.cake_outlined,
            children: [
              InfoRow('Name:', basicDetail.name),
              InfoRow('Date:', basicDetail.date),
              InfoRow('Time:', basicDetail.time),
              InfoRow('Place:', basicDetail.place),
              InfoRow('Latitude:', basicDetail.latitude.toString()),
              InfoRow('Longitude:', basicDetail.longitude.toString()),
              InfoRow('Timezone:', basicDetail.timezone),
              InfoRow('Sunrise:', basicDetail.sunRise),
              InfoRow('Sunset:', basicDetail.sunSet),
              InfoRow('Ayanamsha:', basicDetail.ayanamsha),
            ],
          ),
          SizedBox(height: 16),
          _buildCard(
            title: 'Avakhada Details',
            icon: Icons.star_border_outlined,
            children: [
              InfoRow('Varna:', avakhadaDetail.varna),
              InfoRow('Vashya:', avakhadaDetail.vasya),
              InfoRow('Yoni:', avakhadaDetail.yoni),
              InfoRow('Gan:', avakhadaDetail.gana),
              InfoRow('Nadi:', avakhadaDetail.nadi),
              InfoRow('Sign:', avakhadaDetail.zodiac),
              InfoRow('Sign Lord:', avakhadaDetail.zodiacLord),
              InfoRow('Nakshatra:', avakhadaDetail.nakshatra),
              InfoRow('Yoga:', avakhadaDetail.yoga),
              InfoRow('Karan:', avakhadaDetail.karana),
              InfoRow('Tithi:', avakhadaDetail.tithi),
              InfoRow('Name Alphabet:', avakhadaDetail.nameAlphabet),
              InfoRow('Paya:', avakhadaDetail.paya),
            ],
          ),
          SizedBox(height: 16),
          _buildCard(
            title: 'Panchang Details',
            icon: Icons.calendar_today_outlined,
            children: [
              InfoRow('Tithi:', panchangDetail.tithi),
              InfoRow('Karan:', panchangDetail.karana),
              InfoRow('Yoga:', panchangDetail.yoga),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[700], size: 22),
                SizedBox(width: 10),
                Text(title,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Divider(height: 24, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }
}
