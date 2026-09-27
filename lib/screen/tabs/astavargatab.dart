import 'package:flutter/material.dart';

import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/kundalidash/kundaliashtakvarga.dart'; // AshtakvargaResponse ke liye
import 'package:astrokavach/screen/widgets/common_error_view.dart';
import 'package:astrokavach/screen/widgets/commoncommon_loading_indicator.dart';
import 'package:astrokavach/screen/widgets/generic_chart_view.dart';

class AshtakvargaTab extends StatefulWidget {
  final int planetId;
  const AshtakvargaTab(
      {Key? key, required this.planetId, AshtakvargaResponse? ashtakvargaData})
      : super(key: key);

  @override
  _AshtakvargaTabState createState() => _AshtakvargaTabState();
}

class _AshtakvargaTabState extends State<AshtakvargaTab>
    with AutomaticKeepAliveClientMixin {
  late Future<AshtakvargaResponse?> _ashtakvargaFuture;

  @override
  void initState() {
    super.initState();
    _fetchAshtakvargaChart();
  }

  void _fetchAshtakvargaChart() {
    setState(() {
      _ashtakvargaFuture = AstroApiService.getAshtakvargaChart(widget.planetId);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<AshtakvargaResponse?>(
      future: _ashtakvargaFuture,
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
            message: 'Failed to load Ashtakvarga chart data. Please try again.',
            onRetry: _fetchAshtakvargaChart,
          );
        }

        // --- Success State ---
        final chartData = snapshot.data!.data.charts;
        // API se aane wale charts ke naam (keys) se ek list bana lein (e.g., 'Sun', 'Moon', etc.)
        final planetTabs = chartData.keys.toList();

        // Agar koi chart data nahi hai toh message dikhayein
        if (planetTabs.isEmpty) {
          return const Center(child: Text("No Ashtakvarga charts available."));
        }

        // dynamically create tabs based on the number of charts
        return DefaultTabController(
          length: planetTabs.length,
          child: Column(
            children: [
              // Tab Bar
              Container(
                color: Colors.white,
                child: TabBar(
                  isScrollable: true,
                  labelColor: CustomStyles.callActionBlue,
                  indicatorColor: CustomStyles.callActionBlue,
                  // Har planet ke naam ka ek Tab banayein
                  tabs: planetTabs
                      .map((planetName) => Tab(text: planetName))
                      .toList(),
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  // Har planet ke chart ke liye GenericChartView ka istemal karein
                  children: planetTabs.map((planetName) {
                    final svgData = chartData[planetName]!;
                    return GenericChartView(
                      svgData: svgData,
                      title: '$planetName - Ashtakvarga',
                      color: CustomStyles.callActionBlue,
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
