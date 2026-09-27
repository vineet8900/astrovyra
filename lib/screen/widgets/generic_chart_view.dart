import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GenericChartView extends StatelessWidget {
  final String svgData;
  final String title;
  final Color color;

  const GenericChartView({
    Key? key,
    required this.svgData,
    required this.title,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              padding: EdgeInsets.all(12),
              child: SvgPicture.string(
                svgData,
                placeholderBuilder: (context) => Center(child: CircularProgressIndicator()),
                width: double.infinity,
                height: 350,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}