import 'package:flutter/material.dart';

// Apni API Service aur Models ka sahi path yahan daalein
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/model/kundalidash/allcharts.dart';
import 'package:astrokavach/model/kundalidash/kundalidash.dart';
import 'package:astrokavach/screen/widgets/common_error_view.dart';
import 'package:astrokavach/screen/widgets/commoncommon_loading_indicator.dart';
import 'package:astrokavach/screen/widgets/generic_chart_view.dart'; // KundaliChartResponse aur PlanetInfo ke liye

// Common Widgets jo humne banaye the, unhe import karein

class KundaliTab extends StatefulWidget {
  final int planetId;
  const KundaliTab(
      {Key? key,
      required this.planetId,
      KundaliChartResponse? kundaliChartData})
      : super(key: key);

  @override
  _KundaliTabState createState() => _KundaliTabState();
}

class _KundaliTabState extends State<KundaliTab>
    with AutomaticKeepAliveClientMixin {
  // Future ko state mein rakhein taaki baar baar API call na ho
  late Future<KundaliChartResponse?> _kundaliChartFuture;

  @override
  void initState() {
    super.initState();
    // Widget ke initialize hote hi data fetch karein
    _fetchKundaliChart();
  }

  // API se data laane ke liye function
  void _fetchKundaliChart() {
    setState(() {
      _kundaliChartFuture = AstroApiService.getKundaliChart(widget.planetId);
    });
  }

  // Tab switch karne par state ko zinda rakhne ke liye
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // Mixin ke liye zaroori
    super.build(context);

    return FutureBuilder<KundaliChartResponse?>(
      future: _kundaliChartFuture,
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
            message: 'Failed to load Kundali chart data. Please try again.',
            onRetry:
                _fetchKundaliChart, // Retry button pe yeh function call hoga
          );
        }

        // --- Success State ---
        final kundaliChartData = snapshot.data!.data;

        return DefaultTabController(
          length: 2, // D1 aur D9 ke liye 2 tabs
          child: Column(
            children: [
              // Tab Bar (D1 and D9)
              Container(
                color: Colors.white,
                child: TabBar(
                  labelColor: Colors.blue[800],
                  indicatorColor: Colors.blue[600],
                  tabs: const [Tab(text: 'D1 Chart'), Tab(text: 'D9 Chart')],
                ),
              ),

              // Tab Content (Charts)
              Expanded(
                child: TabBarView(
                  children: [
                    // D1 Chart View
                    GenericChartView(
                      svgData: kundaliChartData.d1,
                      title: 'D1 - Birth Chart',
                      color: Colors.blue[800]!,
                    ),
                    // D9 Chart View
                    GenericChartView(
                      svgData: kundaliChartData.d9,
                      title: 'D9 - Navamsa Chart',
                      color: Colors.blue[800]!,
                    ),
                  ],
                ),
              ),

              // Planetary positions ka section neeche
              _buildPlanetsInfo(kundaliChartData.planets),
            ],
          ),
        );
      },
    );
  }

  /// Grahon ki sthiti (Planetary Positions) dikhane ke liye ek helper widget
  Widget _buildPlanetsInfo(List<PlanetInfo> planets) {
    return Container(
      // Height fix kar dein taaki list scrollable ho
      height: 220,
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.all(16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Planetary Positions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ),
            const Divider(indent: 16, endIndent: 16),
            Expanded(
              // ListView.builder ka istemal karein lambi lists ke liye
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: planets.length,
                itemBuilder: (context, index) {
                  final planet = planets[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: Text(
                            planet.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(' in ', style: TextStyle(color: Colors.grey[600])),
                        Expanded(
                          child: Text(
                            planet.zodiac,
                            style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          '(House ${planet.house})',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
