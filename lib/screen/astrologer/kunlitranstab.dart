import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class KundliTransitTab extends StatefulWidget {
  final int kundaliId;
  const KundliTransitTab({Key? key, required this.kundaliId}) : super(key: key);

  @override
  State<KundliTransitTab> createState() => _KundliTransitTabState();
}

class _KundliTransitTabState extends State<KundliTransitTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String selectedDiv = 'D1';
  String selectedChartType = 'north';

  final Map<String, String> _svgCache = {};
  bool _isLoading = false;

  String _cacheKey() => '${widget.kundaliId}-$selectedDiv-$selectedChartType';

  Future<String?> _loadChartData() async {
    final key = _cacheKey();

    if (_svgCache.containsKey(key)) {
      return _svgCache[key];
    }

    if (_isLoading) return null;
    setState(() => _isLoading = true);

    try {
      final svgData = await AstroApiService.getChartSvg(
        kundaliId: widget.kundaliId,
        div: selectedDiv,
        chartType: selectedChartType,
      );

      final v = svgData?.toString() ?? '';
      if (v.isNotEmpty) {
        _svgCache[key] = v;
      }
      return svgData;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

  bool _isValidSvg(String svgString) {
    if (svgString.isEmpty) return false;
    if (!svgString.contains('<svg')) return false;
    if (!svgString.contains('</svg>')) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Transit (Gochar) Today',
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
                  isExpanded: true,
                  items: _transitCharts.map((chart) {
                    return DropdownMenuItem(
                      value: chart.div,
                      child: Text(chart.name,
                          style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null && val != selectedDiv) {
                      setState(() => selectedDiv = val);
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
          _buildChartWidget(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Ashtakvarga Point for Transit',
              style: TextStyle(
                fontSize: 18,
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
          const SizedBox(height: 10),
          Container(
            height: 500,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              color: Colors.white,
            ),
            child: const Center(
              child: Text('Transit table not wired yet'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildChartWidget() {
    final key = _cacheKey();
    if (_svgCache.containsKey(key)) {
      final cleanedSvg = _cleanSvg(_svgCache[key]!);
      return _renderSvg(cleanedSvg);
    }

    return FutureBuilder<String?>(
      future: _loadChartData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return _buildErrorWidget();
        }

        final rawSvg = snapshot.data!;
        if (!_isValidSvg(rawSvg)) {
          return _buildErrorWidget();
        }

        final cleanedSvg = _cleanSvg(rawSvg);
        return _renderSvg(cleanedSvg);
      },
    );
  }

  Widget _renderSvg(String cleanedSvg) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SvgPicture.string(
            cleanedSvg,
            width: MediaQuery.of(context).size.width * 0.85,
            height: 400,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const SizedBox(
      height: 450,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: CustomStyles.callActionBlue),
            SizedBox(height: 16),
            Text('Loading chart...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return SizedBox(
      height: 450,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('No chart data available'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _svgCache.remove(_cacheKey());
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String title, String type, Color activeColor) {
    final isSelected = selectedChartType == type;
    return GestureDetector(
      onTap: () {
        if (type != selectedChartType) {
          setState(() => selectedChartType = type);
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

class _TransitChartSelection {
  final String div;
  final String name;
  const _TransitChartSelection({required this.div, required this.name});
}

const List<_TransitChartSelection> _transitCharts = [
  _TransitChartSelection(div: 'D1', name: 'Lagna/Ascendant/Basic Birth Chart'),
  _TransitChartSelection(div: 'D9', name: 'D9 Navamsa'),
];
