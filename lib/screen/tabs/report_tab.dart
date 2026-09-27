// lib/screen/tabs/report_tab.dart

import 'package:flutter/material.dart';
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/model/kundalidash/kundalidosja.dart';
import 'package:astrokavach/model/kundalidash/kundalireport.dart';

// --- Helper Widgets (No Changes) ---
Widget _buildLoadingIndicator() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Colors.blue[600]),
        SizedBox(height: 16),
        Text('Loading Report...', style: TextStyle(fontSize: 16)),
      ],
    ),
  );
}

Widget _buildErrorView(String message) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50, color: Colors.red[400]),
          SizedBox(height: 16),
          Text(message,
              style: TextStyle(fontSize: 16, color: Colors.red[600]),
              textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
// --- End Helper Widgets ---

// --- Main Report Screen (No Changes) ---
class ReportScreen extends StatefulWidget {
  final int planetId;

  const ReportScreen(
      {Key? key,
      required this.planetId,
      GeneralReportResponse? generalReportData,
      DoshaReportResponse? doshaReportData})
      : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.blue[800],
          unselectedLabelColor: Colors.grey[700],
          indicatorColor: Colors.blue[600],
          tabs: [
            Tab(text: 'General'),
            Tab(text: 'Dosha'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              GeneralReportTab(planetId: widget.planetId),
              DoshaReportTab(planetId: widget.planetId),
            ],
          ),
        ),
      ],
    );
  }
}
// --- End Main Report Screen ---

// --- General Report Tab Widget (UPDATED) ---
class GeneralReportTab extends StatefulWidget {
  final int planetId;
  const GeneralReportTab({Key? key, required this.planetId}) : super(key: key);

  @override
  _GeneralReportTabState createState() => _GeneralReportTabState();
}

class _GeneralReportTabState extends State<GeneralReportTab>
    with SingleTickerProviderStateMixin {
  Future<GeneralReportResponse?>? _generalReportFuture;
  late TabController _subTabController;

  @override
  void initState() {
    super.initState();
    _generalReportFuture = AstroApiService.getGeneralReport(widget.planetId);
    _subTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GeneralReportResponse?>(
      future: _generalReportFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return _buildErrorView('Failed to load general report.');
        }

        final reportData = snapshot.data!.data;

        // Return a new structure with a TabBar for sub-tabs
        return Column(
          children: [
            TabBar(
              controller: _subTabController,
              labelColor: Colors.green[800],
              unselectedLabelColor: Colors.grey[700],
              indicatorColor: Colors.green[600],
              tabs: [
                Tab(text: 'General'),
                Tab(text: 'Planetary'),
                Tab(text: 'Yogas'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _subTabController,
                children: [
                  // Content for "General" sub-tab
                  _buildPredictionsList(reportData.reportGeneral),
                  // Content for "Planetary" sub-tab
                  _buildPredictionsList(reportData.reportPlanetary),
                  // Content for "Yogas" sub-tab
                  _buildYogaList(reportData.reportYoga),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Reusable widget to build a list of general or planetary predictions
  Widget _buildPredictionsList(List<Report> reports) {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildPredictionCard(report.name, report.prediction);
      },
    );
  }

  /// Reusable widget to build a list of yoga predictions
  Widget _buildYogaList(List<ReportYoga> yogas) {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: yogas.length,
      itemBuilder: (context, index) {
        final yoga = yogas[index];
        return _buildPredictionCard(yoga.name, yoga.meaning);
      },
    );
  }

  /// Reusable card for displaying any prediction item
  Widget _buildPredictionCard(String title, String content) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800),
            ),
            SizedBox(height: 8),
            Text(
              content,
              style:
                  TextStyle(fontSize: 14, height: 1.5, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// Dosha Report Tab Widget
class DoshaReportTab extends StatefulWidget {
  final int planetId;
  const DoshaReportTab({Key? key, required this.planetId}) : super(key: key);

  @override
  _DoshaReportTabState createState() => _DoshaReportTabState();
}

class _DoshaReportTabState extends State<DoshaReportTab>
    with SingleTickerProviderStateMixin {
  Future<DoshaReportResponse?>? _doshaReportFuture;
  late TabController _doshaTabController;

  @override
  void initState() {
    super.initState();
    _doshaReportFuture = AstroApiService.getDoshaReport(widget.planetId);
    _doshaTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _doshaTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DoshaReportResponse?>(
      future: _doshaReportFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return _buildErrorView('Failed to load dosha report.');
        }

        final doshaData = snapshot.data!.data;
        return Column(
          children: [
            TabBar(
              controller: _doshaTabController,
              labelColor: Colors.deepOrange[800],
              unselectedLabelColor: Colors.grey[700],
              indicatorColor: Colors.deepOrange[600],
              tabs: [
                Tab(text: 'Manglik'),
                Tab(text: 'Kalsarpa'),
                Tab(text: 'Sadesati'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _doshaTabController,
                children: [
                  _buildManglikTab(doshaData.reportManglik),
                  _buildKalsarpaTab(doshaData.reportKalsarpa),
                  _buildSadesatiTab(doshaData.reportSadesati),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildManglikTab(ReportManglik manglik) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDoshaStatus(manglik.fullName, manglik.isDoshaPresent),
          SizedBox(height: 16),
          Text('Factors:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ...manglik.factors.map((factor) => Text('• $factor')),
          SizedBox(height: 16),
          Text('Note:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(manglik.note, style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildKalsarpaTab(ReportKalsarpa kalsarpa) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDoshaStatus(kalsarpa.fullName, kalsarpa.isDoshaPresent),
          if (kalsarpa.isDoshaPresent) ...[
            SizedBox(height: 16),
            Text('Remedies:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ...kalsarpa.remedies.map((remedy) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('• $remedy'),
                )),
          ]
        ],
      ),
    );
  }

  Widget _buildSadesatiTab(ReportSadesati sadesati) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDoshaStatus(sadesati.fullName, sadesati.isDoshaPresent),
          SizedBox(height: 16),
          Text('Description:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(sadesati.description),
          if (sadesati.details.isNotEmpty) ...[
            SizedBox(height: 16),
            Text('Upcoming Periods:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ...sadesati.details.map((d) =>
                Text('• ${d.type} (${d.zodiac}): ${d.start} to ${d.end}')),
          ],
          if (sadesati.remedies.isNotEmpty) ...[
            SizedBox(height: 16),
            Text('Remedies:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ...sadesati.remedies.map((remedy) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('• $remedy'),
                )),
          ]
        ],
      ),
    );
  }

  Widget _buildDoshaStatus(String name, bool isPresent) {
    return Row(
      children: [
        Text('$name: ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(
          isPresent ? 'Present' : 'Not Present',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isPresent ? Colors.red : Colors.green,
          ),
        ),
      ],
    );
  }
}
