import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class KundliDivisionalChartsTab extends StatefulWidget {
  final int kundaliId;
  const KundliDivisionalChartsTab({Key? key, required this.kundaliId})
      : super(key: key);

  @override
  State<KundliDivisionalChartsTab> createState() =>
      _KundliDivisionalChartsTabState();
}

class _KundliDivisionalChartsTabState extends State<KundliDivisionalChartsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String selectedDiv = 'D1';
  String selectedChartType = 'north';

  Future<String?>? _chartFuture;

  @override
  void initState() {
    super.initState();
    _loadChart();
  }

  void _loadChart() {
    setState(() {
      _chartFuture = AstroApiService.getChartSvg(
        kundaliId: widget.kundaliId,
        div: selectedDiv,
        chartType: selectedChartType,
      );
    });
  }

  bool _isValidSvg(String svgString) {
    if (svgString.isEmpty) return false;
    if (!svgString.contains('<svg') || !svgString.contains('</svg>')) {
      return false;
    }
    return true;
  }

  String _cleanSvg(String rawData) {
    if (rawData.isEmpty) return '';
    String svg = rawData.trim();
    svg = svg.replaceAll(RegExp(r'display:\s?flex;?'), '');
    svg = svg.replaceAll(RegExp(r'justify-content:\s?center;?'), '');
    svg = svg.replaceAll(RegExp(r'align-items:\s?center;?'), '');
    svg = svg.replaceAll("font-family: '',", 'font-family: sans-serif,');
    if (!svg.contains('xmlns="http://www.w3.org/2000/svg"')) {
      svg = svg.replaceFirst('<svg', '<svg xmlns="http://www.w3.org/2000/svg"');
    }
    return svg;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Divisional Charts',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: CustomStyles.callActionBlue,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 3,
                width: 60,
                color: CustomStyles.callActionBlue,
              ),
            ),
            const Divider(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedDiv,
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    items: divisionalCharts.map((chart) {
                      return DropdownMenuItem(
                        value: chart.div,
                        child: Text(chart.name,
                            style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        selectedDiv = val;
                        _loadChart();
                      }
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTypeButton(
                    'North India Chart',
                    'north',
                    const Color(0xFFFFB300),
                  ),
                  const SizedBox(width: 10),
                  _buildTypeButton(
                    'South India Chart',
                    'south',
                    const Color(0xFFC62828),
                  ),
                ],
              ),
            ),
            FutureBuilder<String?>(
              future: _chartFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data == null) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text('Chart load failed'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadChart,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final rawSvg = snapshot.data!;
                if (!_isValidSvg(rawSvg)) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image,
                              size: 48, color: Colors.orange),
                          const SizedBox(height: 16),
                          const Text('Invalid SVG'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadChart,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final cleanedSvg = _cleanSvg(rawSvg);

                return Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10)
                      ],
                    ),
                    child: SvgPicture.string(
                      cleanedSvg,
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 350,
                      fit: BoxFit.contain,
                      placeholderBuilder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String title, String type, Color activeColor) {
    final isSelected = selectedChartType == type;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          selectedChartType = type;
          _loadChart();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class ChartSelection {
  final String div;
  final String name;
  ChartSelection({required this.div, required this.name});
}

final List<ChartSelection> divisionalCharts = [
  ChartSelection(div: 'D1', name: 'Lagna/Ascendant/Basic Birth Chart'),
  ChartSelection(div: 'D3', name: 'D3 Dreshkana'),
  ChartSelection(div: 'D3-s', name: 'D3-Somanatha'),
  ChartSelection(div: 'D7', name: 'D7 Saptamsa'),
  ChartSelection(div: 'D9', name: 'D9 Navamsa'),
  ChartSelection(div: 'D10', name: 'D10 Dasamsa'),
  ChartSelection(div: 'D10-R', name: 'D10-R Dasamsa-EvenReverse'),
  ChartSelection(div: 'D12', name: 'D12 Dwadasamsa'),
  ChartSelection(div: 'D16', name: 'D16 Shodashamsa'),
  ChartSelection(div: 'D20', name: 'D20 Vimsamsa'),
  ChartSelection(div: 'D24', name: 'D24 ChaturVimshamsha'),
  ChartSelection(div: 'D24-R', name: 'D24-R ChaturVimshamsha-EvenReverse'),
  ChartSelection(div: 'D30', name: 'D30 Trimshamsha'),
  ChartSelection(div: 'D40', name: 'D40 KhaVedamsa'),
  ChartSelection(div: 'D45', name: 'D45 AkshaVedamsa'),
  ChartSelection(div: 'D60', name: 'D60 Shastiamsha'),
  ChartSelection(div: 'chalit', name: 'Bhav-chalit'),
  ChartSelection(div: 'moon', name: 'Moon chart'),
  ChartSelection(div: 'sun', name: 'Sun chart'),
];
