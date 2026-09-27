import 'package:flutter/material.dart';

// Apni API Service aur Models ka sahi path yahan daalein
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/model/kundalidash/kundalikp.dart'; // KundaliKpResponse, RulingPlanet, Planet ke liye
import 'package:astrokavach/screen/widgets/common_error_view.dart';
import 'package:astrokavach/screen/widgets/commoncommon_loading_indicator.dart';
import 'package:astrokavach/screen/widgets/generic_chart_view.dart';

class KPTab extends StatefulWidget {
  final int planetId;
  const KPTab({Key? key, required this.planetId, KundaliKpResponse? kpData})
      : super(key: key);

  @override
  _KPTabState createState() => _KPTabState();
}

class _KPTabState extends State<KPTab> with AutomaticKeepAliveClientMixin {
  late Future<KundaliKpResponse?> _kpChartFuture;

  @override
  void initState() {
    super.initState();
    _fetchKpChart();
  }

  void _fetchKpChart() {
    setState(() {
      _kpChartFuture = AstroApiService.getKpChart(widget.planetId);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<KundaliKpResponse?>(
      future: _kpChartFuture,
      builder: (context, snapshot) {
        // --- Loading State ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CommonLoadingIndicator();
        }

        // --- Error State ---
        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null ||
            !snapshot.data!.success) {
          return CommonErrorView(
            message: 'Failed to load KP chart data. Please try again.',
            onRetry: _fetchKpChart,
          );
        }

        // --- Success State ---
        final kpData = snapshot.data!.data;

        return DefaultTabController(
          length: 4, // 4 tabs hain
          child: Column(
            children: [
              // Tab Bar
              Container(
                color: Colors.white,
                child: TabBar(
                  isScrollable: true, // Taaki saare tabs fit ho jayein
                  labelColor: Colors.blue[800],
                  indicatorColor: Colors.blue[600],
                  tabs: const [
                    Tab(text: 'Lagna Chart'),
                    Tab(text: 'Chalit Chart'),
                    Tab(text: 'Ruling Planets'),
                    Tab(text: 'KP Planets')
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  children: [
                    // Lagna Chart
                    GenericChartView(
                      svgData: kpData.d1,
                      title: 'KP - Lagna Chart',
                      color: Colors.blue[800]!,
                    ),
                    // Chalit Chart
                    GenericChartView(
                      svgData: kpData.chalit,
                      title: 'KP - Chalit Chart',
                      color: Colors.blue[800]!,
                    ),
                    // Ruling Planets Info
                    _buildRulingPlanetsInfo(kpData.rulingPlanets),
                    // KP Planets Info
                    _buildKpPlanetsInfo(kpData.planets),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Ruling Planets ki list dikhane wala widget
  Widget _buildRulingPlanetsInfo(List<RulingPlanet> planets) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias, // To clip the content to rounded corners
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Ruling Planets",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: planets.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final planet = planets[index];
                return ListTile(
                  title: Text(planet.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "Nakshatra Lord: ${planet.nakshatraLord} | Zodiac Lord: ${planet.zodiacLord}",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// KP Planetary Positions ki table dikhane wala widget
  Widget _buildKpPlanetsInfo(List<Planet> planets) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Planetary Positions (KP)",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ),
          // Header Row
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: const [
                Expanded(
                    flex: 3,
                    child: Text("Planet",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text("N.Lord",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text("Sub.Lord",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text("Cup",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          // List of Planets
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero, // Remove default padding
              itemCount: planets.length,
              itemBuilder: (context, index) {
                final planet = planets[index];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text(planet.planet,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500))),
                      Expanded(flex: 2, child: Text(planet.nakshatraLord)),
                      Expanded(flex: 2, child: Text(planet.subLord)),
                      Expanded(flex: 2, child: Text('${planet.cups}')),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
