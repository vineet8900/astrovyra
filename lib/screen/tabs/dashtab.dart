import 'package:flutter/material.dart';

// Apni API Service aur Models ka sahi path yahan daalein
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/model/kundalidash/dashkundalimodel.dart'; // DashaResponse, VimshottariDasha, etc.
import 'package:astrokavach/screen/widgets/common_error_view.dart';
import 'package:astrokavach/screen/widgets/commoncommon_loading_indicator.dart';

// Common Widgets ko import karein

class DashaTab extends StatefulWidget {
  final int planetId;
  const DashaTab({Key? key, required this.planetId, DashaResponse? dashaData})
      : super(key: key);

  @override
  _DashaTabState createState() => _DashaTabState();
}

class _DashaTabState extends State<DashaTab>
    with AutomaticKeepAliveClientMixin {
  late final Future<DashaResponse?> _dashaFuture;

  @override
  void initState() {
    super.initState();
    _fetchDashaDetails();
  }

  void _fetchDashaDetails() {
    _dashaFuture = AstroApiService.getDashaDetails(widget.planetId);
  }

  void _retryFetch() {
    setState(() {
      _dashaFuture = AstroApiService.getDashaDetails(widget.planetId);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<DashaResponse?>(
      future: _dashaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CommonLoadingIndicator();
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null ||
            !snapshot.data!.success) {
          return CommonErrorView(
            message: 'Failed to load Dasha details.',
            onRetry: _retryFetch,
          );
        }

        final dashaData = snapshot.data!.data;

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: TabBar(
                  labelColor: Colors.orange[800],
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: Colors.orange[700],
                  tabs: const [
                    Tab(text: 'Vimshottari'),
                    Tab(text: 'Yogini'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildVimshottariList(dashaData.vimshottari),
                    _buildYoginiView(dashaData.yogini),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Vimshottari Dasha ki list banane wala widget
  Widget _buildVimshottariList(List<VimshottariDasha> dashas) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: dashas.length,
      itemBuilder: (context, index) {
        final dasha = dashas[index];
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ExpansionTile(
            title: Text(dasha.fullName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87)),
            subtitle:
                Text(dasha.startEnd, style: TextStyle(color: Colors.grey[600])),
            childrenPadding: const EdgeInsets.all(16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Prediction:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(dasha.prediction, style: const TextStyle(height: 1.4)),
              const SizedBox(height: 16),
              const Text("Planet in Zodiac:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(dasha.planetInZodiac, style: const TextStyle(height: 1.4)),
            ],
          ),
        );
      },
    );
  }

  /// Yogini Dasha ka view banane wala widget
  Widget _buildYoginiView(YoginiDasha yogini) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Yogini Dasha",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800])),
              const SizedBox(height: 8),
              Text(yogini.description,
                  style: TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.grey[700])),
              const SizedBox(height: 16),
              DataTable(
                columnSpacing: 20,
                columns: const [
                  DataColumn(
                      label: Text('Planet',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Start Date',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('End Date',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: yogini.planets.map((planet) {
                  return DataRow(cells: [
                    DataCell(Text(planet.planet)),
                    DataCell(Text(planet.start)),
                    DataCell(Text(planet.end)),
                  ]);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
