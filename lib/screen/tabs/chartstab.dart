import 'package:flutter/material.dart';

// Apni API Service aur Models ka sahi path yahan daalein
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/model/kundalidash/allcharts.dart'; // AllChartsResponse ke liye
import 'package:astrokavach/screen/widgets/common_error_view.dart';
import 'package:astrokavach/screen/widgets/commoncommon_loading_indicator.dart';
import 'package:astrokavach/screen/widgets/generic_chart_view.dart';

class ChartsTab extends StatefulWidget {
  final int planetId;
  const ChartsTab(
      {Key? key, required this.planetId, AllChartsResponse? allChartsData})
      : super(key: key);

  @override
  _ChartsTabState createState() => _ChartsTabState();
}

class _ChartsTabState extends State<ChartsTab>
    with AutomaticKeepAliveClientMixin {
  late final Future<AllChartsResponse?> _chartsFuture;

  @override
  void initState() {
    super.initState();
    _fetchCharts();
  }

  void _fetchCharts() {
    // setState ki zaroorat nahi hai kyunki FutureBuilder handle karega
    _chartsFuture = AstroApiService.getAllCharts(widget.planetId);
  }

  void _retryFetch() {
    // setState ke andar future ko re-assign karein taaki FutureBuilder rebuild ho
    setState(() {
      _chartsFuture = AstroApiService.getAllCharts(widget.planetId);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<AllChartsResponse?>(
      future: _chartsFuture,
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
            message: 'Failed to load divisional charts. Please try again.',
            onRetry: _retryFetch,
          );
        }

        // --- Success State ---
        final allChartsData = snapshot.data!.data;
        final charts = allChartsData.charts;
        final chartKeys = charts.keys.toList(); // e.g., ['D2', 'D3', 'D4', ...]

        if (chartKeys.isEmpty) {
          return const Center(child: Text("No divisional charts available."));
        }

        return DefaultTabController(
          length: chartKeys.length,
          child: Column(
            children: [
              // Tab Bar
              Container(
                color: Colors.white,
                child: TabBar(
                  isScrollable: true,
                  labelColor: Colors.teal[800],
                  indicatorColor: Colors.teal[600],
                  tabs: chartKeys.map((key) => Tab(text: key)).toList(),
                ),
              ),
              // Tab Content
              Expanded(
                child: TabBarView(
                  children: chartKeys.map((key) {
                    return GenericChartView(
                      svgData: charts[key]!,
                      title: key, // Chart ka naam hi title hoga
                      color: Colors.teal[800]!,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
